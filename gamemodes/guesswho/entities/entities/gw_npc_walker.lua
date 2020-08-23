AddCSLuaFile()

local Behaviour = include("gw_behaviour_tree_lib.lua")

ENT.Base = "base_nextbot"

GW_WALKER_TARGET_TYPE_NONE = 0
GW_WALKER_TARGET_TYPE_POSITION = 1
GW_WALKER_TARGET_TYPE_HIDING_SPOT = 2

function ENT:SetupDataTables()

    self:NetworkVar("Int", 0, "LastAct")
    self:NetworkVar("Int", 1, "WalkerColorIndex")
    self:NetworkVar("Int", 2, "WalkerModelIndex")

end

function ENT:SetupColorAndModel()
    local models = GAMEMODE.GWConfig.HidingModels

    if SERVER then
        self:SetWalkerModelIndex(math.random(1, #models))
    end

    self:SetModel(models[self:GetWalkerModelIndex()])

    local walkerColors = GAMEMODE.GWConfig.WalkerColors

    if SERVER then
        self:SetWalkerColorIndex(math.random(1, #walkerColors))
    end

    self.walkerColor = Vector(
                           walkerColors[self:GetWalkerColorIndex()].r / 255,
                           walkerColors[self:GetWalkerColorIndex()].g / 255,
                           walkerColors[self:GetWalkerColorIndex()].b / 255
                       )

    self.GetPlayerColor = function()
        return self.walkerColor
    end

    self.lerpedAnimationVelocity = 0
end

function ENT:Initialize()
    GAMEMODE.GWStuckMessageCount = GAMEMODE.GWStuckMessageCount or 0


    self:SetupColorAndModel()

    self:SetHealth(100)

    if SERVER then
        self.walkSpeed = GetConVar("gw_hiding_walk_speed"):GetFloat()
        self.runSpeed = GetConVar("gw_hiding_run_speed"):GetFloat()

        self.boundsSize = 16 -- maybe 10?
        self.boundsHeight = 70
        self:SetCollisionBounds(
            Vector(-self.boundsSize, -self.boundsSize, 0),
            Vector(self.boundsSize, self.boundsSize, self.boundsHeight)
        )
        self.loco:SetStepHeight(18)
        self.loco:SetJumpHeight(82)
        self.loco:SetDesiredSpeed(self.walkSpeed)
        self.nextPossibleJump = CurTime() + 2 -- dont jump right after spawning
        self.nextPossibleSettingsChange = CurTime() + 10
        self.isDoging = false
        self.dogeUntil = CurTime()
        self.lastNPCContact = CurTime()
        self.NPCContactsInARow = 0
        self.noCollideEndTime = CurTime()
        self.isNoCollided = false
        self.dogePos = Vector()
        self.isJumping = false
        self.shouldCrouch = false
        self.isFirstPath = true
        self.currentPathMaxAge = 0
        self.isStuck = false
        self.stuckTime = CurTime()
        self.stuckPos = Vector()
        self.targetPos = Vector()
        self.targetType = GW_WALKER_TARGET_TYPE_NONE
        self.isSitting = false
        self.isIdle = false
        self.isDancing = false
        self.sitUntil = CurTime()

        self.behaviourTree = nil
        self.currentPath = nil
    end
end

function ENT:IsAlone(radius)
    local entsAround = ents.FindInSphere(self:GetPos(), radius)

    local walkersAround = {}
    for _, ent in pairs(entsAround) do
        if ent:GetClass() == self:GetClass() then
            table.insert(walkersAround, ent)
        end
    end

    local doorsAround = {}
    for _, ent in pairs(entsAround) do
        if ((ent:GetClass() == "func_door") or (ent:GetClass() == "func_door_rotating")) or
            (ent:GetClass() == "prop_door_rotating") then
            table.insert(doorsAround, ent)
        end
    end

    if ((#walkersAround) < 3) and ((#doorsAround) == 0) then
        return true
    end

    return false
end

function ENT:Sit(duration)
    if duration == nil then
        duration = math.random(10, 30)
    end

    self.isSitting = true
    self.sitUntil = CurTime() + duration

    self:SetSequence("sit_zen")
    self:SetCrouchCollision(true)
end

function ENT:StopSit()
    self:SetCrouchCollision(false)
    self.isSitting = false
end

function ENT:Dance()
    self.isDancing = true
end

function ENT:Idle(duration)
    if duration == nil then
        duration = math.random(10, 30)
    end

    self.isIdle = true
    self.idleUntil = CurTime() + duration
end

function ENT:StopIdle()
    self.isIdle = false
end

function ENT:SetCrouchCollision(state)
    if state then
        self:SetCollisionBounds(
            Vector(-self.boundsSize, -self.boundsSize, 0), Vector(self.boundsSize, self.boundsSize, 36)
        )
    else
        self:SetCollisionBounds(
            Vector(-self.boundsSize, -self.boundsSize, 0),
            Vector(self.boundsSize, self.boundsSize, self.boundsHeight)
        )
    end
end

function ENT:Doge(dogePos, maxDuration)
    if maxDuration == nil then
        maxDuration = 0.35
    end

    self.dogePos = dogePos
    self.dogeUntil = CurTime() + maxDuration
    self.isDoging = true
end

function ENT:Jump()
    if self.isJumping or (self.nextPossibleJump > CurTime()) then
        return
    end

    self.loco:Jump()
    self.isJumping = true
    self.nextPossibleJump = CurTime() + 1.5
end

function ENT:Think()
    if SERVER then
        local doors = ents.FindInSphere(self:GetPos(), 60)
        for _, door in pairs(doors) do
            local doorClass = door:GetClass()
            if ((doorClass == "func_door") or (doorClass == "func_door_rotating")) or
                (doorClass == "prop_door_rotating") then
                door:Fire("Unlock", "", 0)
                door:Fire("Open", "", 0.01)
                door:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
            end
        end

        -- try to resolve stuck after 5 seconds by nocolliding
        if (self.isStuck and (CurTime() - self.stuckTime > 10) and (CurTime() - self.stuckTime < 10.25)) then
            self:StartNoCollide(0.25)
        end

        if (self.isStuck and (CurTime() - self.stuckTime > 15)) and
            (self.stuckPos:DistToSqr(self:GetPos()) < 25) then
            local spawnPoints = GAMEMODE.GWRound.SpawnPoints
            local spawnPoint = spawnPoints[(math.random(#spawnPoints) - 1) + 1]:GetPos()
            self:SetPos(spawnPoint)
            self.isStuck = false
            self.targetType = GW_WALKER_TARGET_TYPE_NONE
            if (IsValid(self.currentPath)) then
                self.currentPath:Invalidate()
            end
            if GAMEMODE.GWStuckMessageCount <= 32 then
                MsgN(
                    "Nextbot [" .. self:EntIndex() .. "][" .. self:GetClass() .. "]" ..
                    "Got stuck for over 15 seconds and will be repositioned, if this error gets spammed " ..
                    "you might want to consider the following: Edit the navmesh or lower the walker amount."
                )
            end
            if GAMEMODE.GWStuckMessageCount == 32 then
                MsgN(
                    "Nextbot stuck message displayed 32 times, supressing future messages."
                )
            end
            GAMEMODE.GWStuckMessageCount = GAMEMODE.GWStuckMessageCount + 1
        end

        if self.isStuck and (self.stuckPos:DistToSqr(self:GetPos()) > 400) then
            self.isStuck = false
        end

        -- Reset solid mask if we are no longer stuck inside another npc
        if self.noCollideEndTime < CurTime() and self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY then
            local entsInBox = ents.FindInBox(
                                  self:GetPos() + Vector(-self.boundsSize, -self.boundsSize, 0),
                                  self:GetPos() + Vector(self.boundsSize, self.boundsSize, self.boundsHeight)
                              )
            local occupied = false
            for _, entInBox in pairs(entsInBox) do
                if (entInBox:GetClass() == GW_WALKER_CLASS) and (entInBox ~= self) or entInBox:IsPlayer() then
                    occupied = true
                end
            end
            if not occupied then
                self:SetSolidMask(MASK_NPCSOLID)
                self:SetCollisionGroup(COLLISION_GROUP_NPC)
                self.isNoCollided = false
            end
        end
    end

    return false
end

function ENT:RunBehaviour()
    self.behaviourTree = Behaviour.TreeBuilder()
        :Sequence()
        :Action(function()
            if self.nextPossibleSettingsChange > CurTime() then
                return Behaviour.Status.Success
            end

            local rand = math.random(1, 100)

            if (rand > 0) and (rand < 25) then
                self.loco:SetDesiredSpeed(self.runSpeed)
            elseif (rand > 25) and (rand < 38) then
                if self:IsAlone(350) then
                    self:Sit(math.random(10, 60))
                end
            else
                self.loco:SetDesiredSpeed(self.walkSpeed)
            end

            self.nextPossibleSettingsChange = CurTime() + 8

            return Behaviour.Status.Success
        end)
        :Action(function()
            if not self.isSitting then
                return Behaviour.Status.Success
            end

            if self.sitUntil < CurTime() then
                self:StopSit()
                return Behaviour.Status.Success
            end

            return Behaviour.Status.Running
        end)
        :Action(function()
            if not self.isIdle then
                return Behaviour.Status.Success
            end

            if self.idleUntil < CurTime() then
                self:StopIdle()
                return Behaviour.Status.Success
            end

            return Behaviour.Status.Running
        end)
        :Action(function()
            if IsValid(self.currentPath) then
                return Behaviour.Status.Success
            end

            local radius = 3200
            if self.isFirstPath then
                radius = 8000
            end

            local rand = math.random(1, 100)

            local allowedStepChange = 400

            if rand < 25 then
                self.targetPos = self:FindSpot("random", {type= "hiding", pos = self:GetPos(), radius = radius, stepup = allowedStepChange, stepdown = allowedStepChange})

                if (not self.targetPos) then
                    self.targetType = GW_WALKER_TARGET_TYPE_NONE
                    return Behaviour.Status.Failure
                end

                self.targetType = GW_WALKER_TARGET_TYPE_HIDING_SPOT
            else 
                local navs = navmesh.Find(self:GetPos(), radius, allowedStepChange, allowedStepChange)
                local nav = navs[(math.random(#navs) - 1) + 1]

                if not IsValid(nav) or nav:IsUnderwater() then
                    self.targetType = GW_WALKER_TARGET_TYPE_NONE
                    return Behaviour.Status.Failure
                end

                self.targetType = GW_WALKER_TARGET_TYPE_POSITION
                self.targetPos = nav:GetRandomPoint()
            end

            self.currentPath = Path("Follow")
            self.currentPath:SetMinLookAheadDistance(10)
            self.currentPath:SetGoalTolerance(42)
            local isValidPath = self.currentPath:Compute(self, self.targetPos)

            if isValidPath then
                if not IsValid(self.currentPath) then
                    return Behaviour.Status.Failure
                end

                if self.isFirstPath then
                    self.currentPathMaxAge = 30
                else
                    self.currentPathMaxAge = math.Clamp(self.currentPath:GetLength() / 90, 1, 25)
                end

                self.isFirstPath = false

                return Behaviour.Status.Success
            else
                return Behaviour.Status.Failure
            end
        end)
        :Action(function()
            if not IsValid(self.currentPath) then
                if (self.targetType == GW_WALKER_TARGET_TYPE_HIDING_SPOT and self.targetPos:Distance(self:GetPos()) < 50) and self:IsAlone(150) then
                    self:Idle(math.random(4, 10))
                end
                return Behaviour.Status.Success
            end

            if self.isDancing then
                local seqs = {
                    "taunt_robot",
                    "taunt_dance",
                    "taunt_muscle"
                }
                self:PlaySequenceAndWait(table.Random(seqs), 1)
                self.isDancing = false
                return Behaviour.Status.Failure
            end

            if (self.isDoging and not self.isJumping and (self.dogeUntil > CurTime())) and
                (self.dogePos:DistToSqr(self:GetPos()) > 100) then
                self.loco:FaceTowards(self.dogePos)
                self.loco:Approach(self.dogePos, 1)
                return Behaviour.Status.Running
            else
                self.isDoging = false
            end

            local goal = self.currentPath:GetCurrentGoal()
            local distToGoal = self:GetPos():Distance(goal.pos)

            local currentNavArea = navmesh.GetNearestNavArea(self:GetPos(), false)

            if not self.isJumping then

                if goal.type == 3 then

                    self.isJumping = true
                    self.loco:JumpAcrossGap(goal.pos, goal.forward)

                elseif IsValid(currentNavArea) and not currentNavArea:HasAttributes(bit.bor(NAV_MESH_NO_JUMP, NAV_MESH_STAIRS)) then

                    if currentNavArea:HasAttributes(NAV_MESH_JUMP) then

                        self:Jump()

                    elseif (goal.type == 2) and (distToGoal < 30) then

                        self:Jump()

                    else

                        local scanDist = math.max(30, 25 * self.loco:GetVelocity():Length2D() / 100)
                        local forward = self:GetForward()
                        local scanPointPath = self:GetPos() + (forward * scanDist)

                        local scanPointOnPath = self.currentPath:GetClosestPosition(scanPointPath)
                        --debugoverlay.Sphere(scanPointOnPath, 10, 0.1, Color(0, 255, 0))

                        local jumpBasedOnPathScan = self:GetPos().z < scanPointOnPath.z and math.abs(self:GetPos().z - scanPointOnPath.z) > self.loco:GetStepHeight() and (distToGoal < 100)

                        local jumpBasedOnNavScan = false
                        local scanPointNav = self:GetPos() + (forward * math.max(15, scanDist * 0.5)) + Vector(0, 0, self.loco:GetStepHeight() * 1.2)
                        --debugoverlay.Sphere(scanPointNav, 10, 0.1, Color(255, 255, 0))

                        local scanNavArea = navmesh.GetNearestNavArea(scanPointNav, false, scanDist * 2)

                        if not jumpBasedOnPathScan and IsValid(scanNavArea) then
                            if scanNavArea:HasAttributes(NAV_MESH_JUMP) then
                                jumpBasedOnNavScan = true
                            else
                                local scanPointOnNav = scanNavArea:GetClosestPointOnArea(scanPointNav)
                                if scanPointOnNav then
                                    --debugoverlay.Sphere(scanPointOnNav, 10, 0.1, Color(255, 0, 0))
                                    -- higher threshold for navareaBasejumps
                                    jumpBasedOnNavScan = self:GetPos().z < scanPointOnNav.z and math.abs(self:GetPos().z - scanPointOnNav.z) > self.loco:GetStepHeight() * 1.2
                                end
                            end
                        end

                        if (jumpBasedOnPathScan or jumpBasedOnNavScan)  then
                            self:Jump()
                        end

                    end
                end
            end

            self.currentPath:Update(self)

            if self.loco:IsStuck() then
                self:HandleStuck()
            end

            if self.currentPath:GetAge() > self.currentPathMaxAge then
                self.currentPath:Invalidate()
                return Behaviour.Status.Failure
            end

            return Behaviour.Status.Running
        end)
    :Finish()
    :Build()

    while true do
        self.behaviourTree:Tick()
        coroutine.yield()
    end
end

function ENT:BodyUpdate()
    local idealAct = ACT_HL2MP_IDLE
    local velocity = self:GetVelocity()
    self.lerpedAnimationVelocity = Lerp(0.2, self.lerpedAnimationVelocity, velocity:Length2D())

    if self.lerpedAnimationVelocity > self.walkSpeed * 1.05 then
        idealAct = ACT_HL2MP_RUN
    elseif self.lerpedAnimationVelocity > 5 then
        idealAct = ACT_HL2MP_WALK
    end

    if self.isJumping and (self:WaterLevel() <= 0) then
        idealAct = ACT_HL2MP_JUMP_SLAM
    end

    if ((self:GetActivity() ~= idealAct) and (not self.isSitting)) and (not self.isDancing) then
        self:StartActivity(idealAct)
    end

    if (idealAct == ACT_HL2MP_RUN) or (idealAct == ACT_HL2MP_WALK) then
        self:BodyMoveXY()
    end

    self:FrameAdvance()
end

function ENT:OnLandOnGround(ent)
    self.isJumping = false
    self:SetCrouchCollision(false)
end

function ENT:OnLeaveGround(ent)
    self.isJumping = true
    self:SetCrouchCollision(true)
end

local gwWalkerDogeAngle = 1 / math.sqrt(2)

function ENT:OnContact(ent)

    local curTime = CurTime()

    if (ent:GetClass() == self:GetClass()) then
        if curTime - self.lastNPCContact > 1.5 then
            self.NPCContactsInARow = 1
        elseif curTime - self.lastNPCContact > 0.5 then
            self.NPCContactsInARow = self.NPCContactsInARow + 1

            if self.NPCContactsInARow >= 5 then
                self:StartNoCollide(1)
                self.NPCContactsInARow = 0
            end
        end
        self.lastNPCContact = curTime
    end

    if not self.isNoCollided and (ent:GetClass() == self:GetClass()) or ent:IsPlayer() then
        if not self.isDoging and not self.isSitting then
            local dogeDirection = (ent:GetPos() - self:GetPos()):GetNormalized()

            local directionForwardDot = self:GetForward():Dot(dogeDirection)

            local isEntInFront = directionForwardDot > gwWalkerDogeAngle

            if isEntInFront then
                dogeDirection:Rotate(Angle(0, math.random(70, 80), 0))
                dogeDirection.z = 0

                local dogeTarget = self:GetPos() + (dogeDirection * 200)

                local navAreaInDogeDir = navmesh.GetNearestNavArea(dogeTarget, false, 400, true)
                if IsValid(navAreaInDogeDir) then
                    local dogeTargetOnNavArea = navAreaInDogeDir:GetClosestPointOnArea(dogeTarget)

                    if dogeTargetOnNavArea then
                        self:Doge(dogeTargetOnNavArea, math.random(0.4, 0.6))
                    end
                end
            end
        end
    end

    if (ent:GetClass() == "prop_physics_multiplayer") or ((ent:GetClass() == "prop_physics") and (not GetConVar("gw_propfreeze_enabled"):GetBool())) then
        local phys = ent:GetPhysicsObject()
        if not IsValid(phys) then
            return
        end
        local force = ((ent:GetPos() - self:GetPos()):GetNormalized() * 3) * self:GetVelocity():Length2D()
        force.z = 0
        phys:ApplyForceCenter(force)
        DropEntityIfHeld(ent)
    end

    if (ent:GetClass() == "func_breakable") or (ent:GetClass() == "func_breakable_surf") then
        ent:Fire("Shatter")
    end

    if self.isStuck and ((ent:GetClass() == self:GetClass()) or ent:IsPlayer()) then
        local thisMin = self:OBBMins() + self:GetPos()
        local thisMax = self:OBBMaxs() + self:GetPos()
        local entMin = ent:OBBMins() + ent:GetPos()
        local entMax = ent:OBBMaxs() + ent:GetPos()
        if not ((((thisMax.x < entMin.x) or (thisMin.x > entMax.x)) or (thisMax.y < entMin.y)) or (thisMin.y > entMax.y)) then
            self:StartNoCollide(0)
        end
    end

end

function ENT:StartNoCollide(duration)
    self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self.noCollideEndTime = CurTime() + duration
    self.isNoCollided = true
end

function ENT:OnStuck()

    if not self.isStuck then
        self.stuckTime = CurTime()
        self.isStuck = true
    end

    self.stuckPos = self:GetPos()
end

function ENT:OnUnStuck()
    if (self.stuckPos:DistToSqr(self:GetPos()) > 100) or self.isSitting then
        self.isStuck = false
    end
end

function ENT:Use(activator, caller, useType, value)
    if caller:GWIsHiding() and GetConVar("gw_changemodel_hiding"):GetBool() then
        caller:SetModel(self:GetModel())
    end
end

-- unused
function ENT:PathGenerator()
    return function(area, fromArea, ladder, elevator, length)
        if not IsValid(fromArea) then
            return 0
        end
        if not self.loco:IsAreaTraversable(area) then
            return -1
        end
        local dist = 0
        if IsValid(ladder) then
            dist = ladder:GetLength()
        elseif length > 0 then
            dist = length
        else
            dist = area:GetCenter():Distance(fromArea:GetCenter())
        end
        local cost = dist + fromArea:GetCostSoFar()
        local deltaZ = fromArea:ComputeAdjacentConnectionHeightChange(area)
        if deltaZ >= self.loco:GetStepHeight() then
            if deltaZ >= (self.loco:GetMaxJumpHeight() - 20) then
                return -1
            end
            cost = cost + deltaZ
        elseif deltaZ < (-self.loco:GetDeathDropHeight()) then
            return -1
        end
        return cost
    end
end