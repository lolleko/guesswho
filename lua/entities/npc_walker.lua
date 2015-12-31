AddCSLuaFile()
ENT.Base            = "base_nextbot"

function ENT:SetupDataTables()
   self:NetworkVar("Int", 0, "RandomInt") --we need to generate the same random for both client and server
   self:NetworkVar("Int", 0, "LastAct") --Act should be known for client and server
end

function ENT:Initialize()
    local models = GAMEMODE.Models

    if SERVER then self:SetRandomInt(math.random(1,#models)) end

    self:SetModel(models[self:GetRandomInt()])
    self:SetHealth(100)
    self:SetCollisionBounds( Vector(-9,-9,0), Vector(9,9,70) )
    self.loco:SetStepHeight(22)
    self.Jumped = CurTime() + 5 -- prevent jumping for the first 6 seconds since the spawn is crowded
    self.IsJumping = false
    self.IsDuck = false
    self:SetColor(GAMEMODE.WalkerColors[math.random(1, #GAMEMODE.WalkerColors)])

end

function ENT:Think()
    --shitty open door stuff needs rework at somepoint
    local doors = ents.FindInSphere(self:GetPos(),60)
    if doors then
        for k,v in pairs(doors) do
            if v:GetClass() == "func_door" or v:GetClass() == "func_door_rotating" or v:GetClass() == "prop_door_rotating" then
                v:Fire("Unlock", "", 0)
                v:Fire("Open", "", 0.01)
                v:SetCollisionGroup( COLLISION_GROUP_DEBRIS ) -- we need to no colide doors sadly since rotating doors mess up the navmesh
            end
        end
    end
    if self.Stucked && CurTime() > self.Stucked + 20 && self.StuckAt:Distance(self:GetPos()) < 5 then
        self:SetPos(GAMEMODE.SpawnPoints[math.random(1,#GAMEMODE.SpawnPoints)]:GetPos())
        self.Stucked = nil
        if SERVER && !self.IsJumping then MsgN("Nextbot [",tostring(self:EntIndex()),"][",self:GetClass(),"] Got Stuck for over 20 seconds and will be repositioned, if this error gets spammed you might want to consider the following: Edit the navmesh or lower the walker amount.") end
    end
    if self.Stucked && self.StuckAt:Distance(self:GetPos()) > 10 then self.Stucked = nil end --Reset stuck state when moved
    if !self.IsJumping && self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY then
        local occupied = false
        for _,ent in pairs(ents.FindInBox(self:GetPos() + Vector( -16, -16, 0 ), self:GetPos() + Vector( 16, 16, 70 ))) do
            if ent:GetClass() == "npc_walker" && ent != self then occupied = true end
        end
        if !occupied then self:SetSolidMask(MASK_NPCSOLID) end
    end

end

function ENT:RunBehaviour()
    --Scatter them after spawn
    self:MoveSomeWhere(10000)
    while ( true ) do
        local rand = math.random(1,100)
        if rand > 0 && rand < 10 then
            self:MoveToSpot( "hiding" )
            coroutine.wait(math.random(1,10))
        elseif rand > 10 && rand < 15 then
            self:Sit()
            coroutine.wait(1)
        else
            self:MoveSomeWhere()
            coroutine.wait(1)
        end
    end

end

function ENT:MoveSomeWhere(distance)
    distance = distance or 1000
    self.loco:SetDesiredSpeed( 100 )
    local navs = navmesh.Find(self:GetPos(), distance, 120, 120)
    local nav = navs[math.random(1,#navs)]
    if !IsValid(nav) then return end
    if nav:IsUnderwater() then return end -- we dont want them to go into water
    local pos = nav:GetRandomPoint()
    local maxAge = math.Clamp(pos:Distance(self:GetPos()) / 120, 0.1,10)
    self:MoveToPos( pos, { tolerance = 30, maxage = maxAge, lookahead = 10, repath = 2 })
end

function ENT:MoveToSpot( type )
    local pos = self:FindSpot( "random", { type = type, radius = 5000 } )
    if ( pos ) then
        local nav = navmesh.GetNavArea(pos, 20)
        if !IsValid(nav) then return end
        if !nav:IsUnderwater() then
            self.loco:SetDesiredSpeed( 230 )
            self:MoveToPos( pos, { tolerance = 30, lookahead = 10, repath = 2 } )
        end
    end
end

function ENT:Sit()
    --self:PlaySequenceAndWait( "idle_to_sit_ground" )     --broken for clients so removed
    self:SetSequence( "sit_zen" )
    self.Siting = true
    self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,36) )
    coroutine.wait( math.Rand(10,60) )
    self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,70) )
    self.Siting = false
    --self:PlaySequenceAndWait( "sit_ground_to_idle" )
    --coroutine.wait( math.Rand(0,1.5) )
end

function ENT:OnStuck()
    --debugoverlay.Cross( self:GetPos() + Vector(0,0,70), 10, 20, Color(0,255,255), true )
    if !self.Stucked then self.Stucked = CurTime() end
    self.StuckAt = self:GetPos()
end

function ENT:OnUnStuck()
    if self.StuckAt:Distance(self:GetPos()) > 10 or self.Siting then self.Stucked = nil end
end

function ENT:Use( act, call, type, value )
    if call:Team() == TEAM_HIDING then
        call:SetModel(self:GetModel())
    end
end

function ENT:OnNavAreaChanged( old, new)
    /*if new:HasAttributes( NAV_MESH_JUMP ) then
        self:Jump()
    end*/
    if new:HasAttributes( NAV_MESH_CROUCH ) then self:Duck(true) end
    if self.IsDuck and !new:HasAttributes( NAV_MESH_CROUCH ) then self:Duck(false) end
end

function ENT:OnContact( ent )
    if ent:GetClass() == self:GetClass() or ent:IsPlayer() then
        self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
        if math.abs(self:GetPos().z - ent:GetPos().z) > 30 then self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY ) end
    end
    if ent:GetClass() == "prop_physics_multiplayer" or ent:GetClass() == "prop_physics" then
        --self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
        local phys = ent:GetPhysicsObject()
        if !IsValid(phys) then return end
        phys:ApplyForceCenter( self:GetPos() - ent:GetPos() * 1.2 )
        DropEntityIfHeld( ent )
    end
    if ent:GetClass() == "func_breakable" or ent:GetClass() == "func_breakable_surf" then
        ent:Fire("Shatter")
    end
end

function ENT:OnLandOnGround( ent )
    self.IsJumping = false
    if self:GetLastAct() == ACT_HL2MP_RUN then self.loco:SetDesiredSpeed(230) self.loco:SetAcceleration(400) else self.loco:SetDesiredSpeed(100) self.loco:SetAcceleration(400) end
end

function ENT:OnLeaveGround( ent )
    self.IsJumping = true
end

---my attempt on improved pathing (with jumping)
function ENT:MoveToPos( pos, options )

    local options = options or {}

    local path = Path( "Follow" )
    path:SetMinLookAheadDistance( options.lookahead or 300 )
    path:SetGoalTolerance( options.tolerance or 20 )
    path:Compute( self, pos )

    if ( !path:IsValid() ) then return "failed" end

    while ( path:IsValid() ) do

        path:Update( self )

        if ( options.draw ) then
            path:Draw()
        end

        --the jumping part simple and buggy if you have a smarter solution tell me please
        --local scanDist = (self.loco:GetVelocity():Length()^2)/(2*900) + 15
        local scanDist
        if self:GetVelocity():Length2D() > 150 then scanDist = 30 else scanDist = 20 end

        --debugoverlay.Line( self:GetPos(),  path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist), 0.1, Color(255,0,0,0), true )
        --debugoverlay.Line( self:GetPos(),  path:GetPositionOnPath(path:GetCursorPosition() + scanDist), 0.1, Color(0,255,0,0), true )
        if path:IsValid() and ((self:GetPos().z - path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist).z < 0 and (math.abs(path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist).z - self:GetPos().z) > 22))) then
            self:Jump(path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist), scanDist)
        end

        -- If we're stuck then call the HandleStuck function and abandon
        if ( self.loco:IsStuck() ) then

            self:HandleStuck();

            return "stuck"

        end

        --
        -- If they set maxage on options then make sure the path is younger than it
        --
        if ( options.maxage ) then
            if ( path:GetAge() > options.maxage ) then return "timeout" end
        end

        --
        -- If they set repath then rebuild the path every x seconds
        --
        if ( options.repath ) then
            if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
        end

        coroutine.yield()

    end

    return "ok"

end

--we do our own jump since the loco one is a bit weird.
function ENT:Jump(goal, scanDist)
    if CurTime() < self.Jumped + 1 or navmesh.GetNavArea(self:GetPos(), 50):HasAttributes( NAV_MESH_NO_JUMP ) then return end
    if !self:IsOnGround() then return end
    local tr = util.TraceLine( {
        start = self:EyePos() + Vector(0,0,30),
        endpos = self:EyePos() + Vector(0,0,94),
        filter = self
    } )
    local tr2 = util.TraceLine( {
        start = self:EyePos() + Vector(0,0,30) + self:EyeAngles():Forward() * scanDist,
        endpos = self:EyePos() + self:EyeAngles():Forward() * scanDist + Vector(0,0,94),
        filter = self
    } )
    --debugoverlay.Line(self:EyePos() + Vector(0,0,30), self:EyePos() + Vector(0,0,94), 5, Color(255,255,0), true)
    --debugoverlay.Line(self:EyePos() + Vector(0,0,30) + self:EyeAngles():Forward() * scanDist, self:EyePos() + self:EyeAngles():Forward() * scanDist + Vector(0,0,94), 5, Color(255,255,0), true)
    local jmpHeight
    if tr.Hit then jmpHeight = tr.StartPos:Distance(tr.HitPos) else jmpHeight = 64 end
    if tr2.Hit and !tr.Hit then jmpHeight = tr2.StartPos:Distance(tr2.HitPos) end
    self.loco:SetJumpHeight(jmpHeight)
    self.loco:SetDesiredSpeed( 450 )
    self.loco:SetAcceleration( 5000 )
    self:SetLastAct(self:GetActivity())
    self.Jumped = CurTime()
    self.IsJumping = true
    self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY )
    self.loco:Jump()
    self.loco:Approach(goal, 1000)
end

function ENT:Duck( state )
    if state then self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,30) ) self.IsDuck = true else self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,70) ) self.IsDuck = false end
end

function ENT:BodyUpdate()

    local act = self:GetActivity()

    self.CalcIdeal = ACT_HL2MP_IDLE

    --
    -- This helper function does a lot of useful stuff for us.
    -- It sets the bot's move_x move_y pose parameters, sets their animation speed relative to the ground speed, and calls FrameAdvance.
    --
    --

    --if act != self:GetLastAct() then act = self:GetLastAct() self:StartActivity(act) end

    local velocity = self:GetVelocity()

    local len2d = velocity:Length2D()

    if ( len2d > 150 ) then self.CalcIdeal = ACT_HL2MP_RUN elseif ( len2d > 10 ) then self.CalcIdeal = ACT_HL2MP_WALK end

    if ( self.IsJumping && self:WaterLevel() <= 0 && (self.Jumped < CurTime() && self.Jumped + 1 > CurTime()) ) then
        self.CalcIdeal = ACT_HL2MP_JUMP_SLAM
    end

    if self:GetActivity() != self.CalcIdeal && !self.Siting then self:StartActivity(self.CalcIdeal) end

    if ( self.CalcIdeal == ACT_HL2MP_RUN || self.CalcIdeal == ACT_HL2MP_WALK ) then

        self:BodyMoveXY()

    end

    self:FrameAdvance()

end
