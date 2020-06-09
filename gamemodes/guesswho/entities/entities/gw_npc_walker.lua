AddCSLuaFile()

local Behaviour = include("gw_behaviour_tree_lib.lua")

ENT.Base = "base_nextbot"

function ENT:SetupDataTables()

    self:NetworkVar("Int", 0, "LastAct")
    self:NetworkVar("Int", 1, "WalkerColorIndex")
    self:NetworkVar("Int", 2, "WalkerModelIndex")

    self:NetworkVar("Bool", 3, "isDoging")

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
    self:SetupColorAndModel()

    self:SetHealth(100)

    if SERVER then
        self.boundsSize = 16 -- maybe 10?
        self.boundsHeight = 70
        self:SetCollisionBounds(
            Vector(-self.boundsSize, -self.boundsSize, 0),
            Vector(self.boundsSize, self.boundsSize, self.boundsHeight)
        )
        self.loco:SetStepHeight(18)
        self.loco:SetJumpHeight(82)
        self.loco:SetDesiredSpeed(100)
        self.nextPossibleJump = CurTime() + math.random(2, 3)
        self.nextPossibleSettingsChange = CurTime() + 10
        self.isDoging = false
        self.dogeUntil = CurTime()
        self.dogePos = Vector()
        self.isJumping = false
        self.shouldCrouch = false
        self.isFirstPath = true
        self.hasPath = false
        self.currentPathMaxAge = 0
        self.isStuck = false
        self.stuckTime = CurTime()
        self.stuckPos = Vector()
        self.targetPos = Vector()
        self.isSitting = false
        self.isDancing = false
        self.sitUntil = CurTime()

        self.behaviourTree = nil
        self.currentPath = nil
    end
end

function ENT:Sit(duration)
    if duration == nil then
        duration = math.random(10, 30)
    end

    self.isSitting = true
    self.sitUntil = CurTime() + duration
end

function ENT:Dance()
    self.isDancing = true
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
    self.nextPossibleJump = CurTime() + 3
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

        if (self.isStuck and (CurTime() > (self.stuckTime + 15))) and
            (self.stuckPos:DistToSqr(self:GetPos()) < 25) then
            local spawnPoints = GWRound.SpawnPoints
            local spawnPoint = spawnPoints[(math.random(#spawnPoints) - 1) + 1]:GetPos()
            self:SetPos(spawnPoint)
            self.isStuck = false
            MsgN(
                "Nextbot [" .. self:EntIndex() .. "][" .. self:GetClass() .. "]" ..
                "Got Stuck for over 15 seconds and will be repositioned, if this error gets spammed" ..
                "you might want to consider the following: Edit the navmesh or lower the walker amount."
            )
        end

        if self.isStuck and (self.stuckPos:DistToSqr(self:GetPos()) > 400) then
            self.isStuck = false
        end

        -- Reset solid mask if we are no longer stuck inside another npc
        if self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY then
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

            if (rand > 0) and (rand < 15) then
                self.loco:SetDesiredSpeed(200)
            elseif (rand > 15) and (rand < 22) then
                local entsAround = ents.FindInSphere(self:GetPos(), 300)

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
                    self:Sit(math.random(10, 60))
                end
            else
                self.loco:SetDesiredSpeed(100)
            end

            self.nextPossibleSettingsChange = CurTime() + 5

            return Behaviour.Status.Success
        end)
        :Action(function()
            if not self.isSitting then
                return Behaviour.Status.Success
            end

            self:SetSequence("sit_zen")
            self:SetCrouchCollision(true)

            if self.sitUntil < CurTime() then
                self:SetCrouchCollision(false)
                self.isSitting = false
                return Behaviour.Status.Success
            end

            return Behaviour.Status.Running
        end)
        :Action(function()
            if self.hasPath and self.currentPath:IsValid() then
                return Behaviour.Status.Success
            end

            local radius = 2200
            if self.isFirstPath then
                radius = 8000
            end

            local navs = navmesh.Find(self:GetPos(), radius, 200, 200)
            local nav = navs[(math.random(#navs) - 1) + 1]

            if not IsValid(nav) then
                return Behaviour.Status.Failure
            end

            if nav:IsUnderwater() then
                return Behaviour.Status.Failure
            end

            self.targetPos = nav:GetRandomPoint()
            self.currentPath = Path("Follow")
            self.currentPath:SetMinLookAheadDistance(10)
            self.currentPath:SetGoalTolerance(30)
            self.currentPath:Compute(self, self.targetPos)

            if self.isFirstPath then
                self.currentPathMaxAge = 20
            else
                self.currentPathMaxAge = math.Clamp(self.currentPath:GetLength() / 90, 0.1, 12)
            end

            if not self.currentPath:IsValid() then
                return Behaviour.Status.Failure
            end

            self.isFirstPath = false
            self.hasPath = true

            return Behaviour.Status.Success
        end)
        :Action(function()
            if not self.currentPath:IsValid() then
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
                local dogeDirection = (self.dogePos - self:GetPos()):GetNormalized()
                self.loco:FaceTowards(self.dogePos)
                self.loco:Approach(self.dogePos, 1)
                return Behaviour.Status.Running
            else
                self.isDoging = false
            end

            local goal = self.currentPath:GetCurrentGoal()
            local distToGoal = self:GetPos():Distance(goal.pos)

            if goal.type == 3 then
                self.isJumping = true
                self.loco:JumpAcrossGap(goal.pos, goal.forward)
            elseif not goal.area:HasAttributes(bit.bor(NAV_MESH_NO_JUMP, NAV_MESH_STAIRS)) then
                if (goal.type == 2) and (distToGoal < 30) then
                    self:Jump()
                else
                    local scanDist = 25 * self.loco:GetVelocity():Length2D() / 100
                    local scanPoint = self:EyePos() + (self.loco:GetGroundMotionVector() * scanDist)

                    local scanPointOnPath = self.currentPath:GetClosestPosition(self:EyePos() + (self.loco:GetGroundMotionVector() * scanDist))
                    --debugoverlay.Sphere(scanPointOnPath, 10, 0.1, Color(0, 255, 0))

                    local jumpBasedOnPathScan = math.abs(self:GetPos().z - scanPointOnPath.z) > self.loco:GetStepHeight() and (distToGoal < 300)

                    local jumpBasedOnNavScan = false

                    local scanNavArea = navmesh.GetNearestNavArea(scanPoint, false, scanDist * 2)
                    if scanNavArea then
                        local scanPointOnNav = scanNavArea:GetClosestPointOnArea(scanPoint)
                        if scanPointOnNav then
                            -- debugoverlay.Sphere(scanPointOnNav, 10, 0.1, Color(255, 0, 0))
                            -- double threshold for navareaBasejumps
                            jumpBasedOnNavScan = math.abs(self:GetPos().z - scanPointOnNav.z) > self.loco:GetStepHeight() * 2
                        end
                    end

                    if self:GetPos().z < scanPoint.z and (jumpBasedOnPath or jumpBasedOnNavScan)  then
                        self:Jump()
                    end
                end
            end

            self.currentPath:Update(self)

            if self.loco:IsStuck() then
                self:HandleStuck()
            end

            if self.currentPath:GetAge() > self.currentPathMaxAge then
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

    if self.lerpedAnimationVelocity > 150 then
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

    if (ent:GetClass() == self:GetClass()) or ent:IsPlayer() then
        if not self.isDoging and not self.isSitting then
            local dogeDirection = (ent:GetPos() - self:GetPos()):GetNormalized()

            local directionForwardDot = self:GetForward():Dot(dogeDirection)

            local isEntInFront = directionForwardDot > gwWalkerDogeAngle

            if isEntInFront then
                dogeDirection:Rotate(Angle(0, math.random(70, 80), 0))
                dogeDirection.z = 0

                local dogeTarget = self:GetPos() + (dogeDirection * 200)

                local navAreaInDogeDir = navmesh.GetNearestNavArea(dogeTarget, false, 400, true)
                local dogeTargetOnNavArea = navAreaInDogeDir:GetClosestPointOnArea(dogeTarget)

                if dogeTargetOnNavArea then
                    self:Doge(dogeTargetOnNavArea, math.random(0.4, 0.7))
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
            self:SetSolidMask(MASK_NPCSOLID_BRUSHONLY)
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end
    end

end

function ENT:OnStuck()

    if not self.isStuck then
        self.stuckTime = CurTime()
        self.isStuck = true
    end

    self.stuckPos = self:GetPos()

    if (self.hasPath and (not self.isDoging)) and (self.loco:GetVelocity():Length2DSqr() < 0.1) then
        local randomDir = VectorRand() * 100
        randomDir.z = 0
        self:Doge(self:GetPos() + randomDir, 0.4)
    end

end

function ENT:OnUnStuck()
    if (self.stuckPos:DistToSqr(self:GetPos()) > 100) or self.isSitting then
        self.isStuck = false
    end
end

function ENT:Use(activator, caller, useType, value)
    if caller:IsHiding() and GetConVar("gw_changemodel_hiding"):GetBool() then
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