AddCSLuaFile()
ENT.Base            = "base_nextbot"

function ENT:SetupDataTables()
   self:NetworkVar("Int", 0, "RandomInt") --we need to generate the same random for both client and server
   self:NetworkVar("Int", 0, "LastAct") --Act should be known for client and server
   self:NetworkVar("Vector", 0 , "WalkerColor")
end


function ENT:Initialize()
    local models = GAMEMODE.Models

    if SERVER then self:SetRandomInt(math.random(1,#models)) end

    self:SetModel(models[self:GetRandomInt()])
    self:SetWalkerColor(Vector(math.random(),math.random(),math.random()))
    self:SetHealth(100)
    self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,70) )
    self.loco:SetStepHeight(22)
    self.loco:SetJumpHeight(54)
    self.Jumped = CurTime() + 5 -- prevent jumping for the first 6 seconds since the spawn is crowded
    self.IsJumping = false
    self.IsDuck = false

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
    /*if CurTime() > self.Jumped + 2 and self:GetActivity() == ACT_HL2MP_WALK or self:GetActivity() == ACT_HL2MP_RUN then
        local bodytrace = util.TraceHull({
        start = self:GetPos() + Vector(0,0,25),
        endpos =  (self:GetPos() + Vector(0,0,25)) + self:EyeAngles():Forward() * 40,
        mins = Vector(8,0,0),
        maxs = Vector(8,0,33),
        mask = MASK_NPCSOLID_BRUSHONLY,
        filter = self.Entity
        })
        local eyetrace = util.TraceHull({
        start = self:GetPos() + Vector(0,0,59),
        endpos =  (self:GetPos() + Vector(0,0,55)) + self:EyeAngles():Forward() * 60,
        mins = Vector(16,0,0),
        maxs = Vector(16,0,15),
        mask = MASK_NPCSOLID_BRUSHONLY,
        filter = self.Entity
        })
        if bodytrace.Hit and !eyetrace.Hit then
            self.Jumped = CurTime() --delay next jump
            self.loco:Jump()
            self:SetVelocity(self:GetForward() * 10000)
        end
    end*/
    if self.Stucked and CurTime() > self.Stucked + 15 and self.StuckAt:Distance(self:GetPos()) < 5 then
        self:SetPos(GAMEMODE.SpawnPoints[math.random(1,#GAMEMODE.SpawnPoints)]:GetPos())
        self.Stucked = nil
        if SERVER then MsgN("Nextbot [",tostring(self:EntIndex()),"][",self:GetClass(),"] Got Stuck for over 15 seconds and will be repositioned, if this error gets spammed you might want to consider the following: Edit the navmesh or lower the walker amount.") end
    end
    /*local nav = navmesh.GetNavArea(self:GetPos(), 10)
    if nav:HasAttributes( NAV_MESH_JUMP ) then
        self.loco:Jump()
    end*/
    if !self.IsJumping and self:GetSolidMask() == MASK_NPCSOLID_BRUSHONLY then
        local occupied = false
        for _,ent in pairs(ents.FindInBox(self:GetPos() + Vector( -16, -16, 0 ), self:GetPos() + Vector( 16, 16, 70 ))) do
            if ent:GetClass() == "npc_walker" and ent != self then occupied = true end
        end
        if !occupied then self:SetSolidMask(MASK_NPCSOLID) end
    end

end

function ENT:RunBehaviour()
    --Scatter them after spawn
    self:MoveSomeWhere(10000)
    while ( true ) do
        local rand = math.random(1,100)
        if rand > 0 and rand < 10 then
            self:MoveToSpot( "hiding" )
            coroutine.wait(math.random(1,10))
        elseif rand > 10 and rand < 15 then
            self:Sit()
            coroutine.wait(1)
            self:StartActivity( ACT_HL2MP_IDLE )
        else
            self:MoveSomeWhere()
            coroutine.wait(1)
            self:StartActivity( ACT_HL2MP_IDLE )
        end
    end

end

function ENT:MoveSomeWhere(distance)
    self:StartActivity( ACT_HL2MP_WALK )
    self:SetLastAct( ACT_HL2MP_WALK )
    distance = distance or 1000
    self.loco:SetDesiredSpeed( 100 )
    local navs = navmesh.Find(self:GetPos(), distance, 120, 120)
    local nav = navs[math.random(1,#navs)]
    if !IsValid(nav) then return end
    if nav:IsUnderwater() then return end -- we dont want them to go into water
    local pos = nav:GetRandomPoint()
    local maxAge = math.Clamp(pos:Distance(self:GetPos())/120, 0.1,10)
    self:MoveToPos( pos, { tolerance = 30, maxage = maxAge, lookahead = 10, repath = 2 })
    self:StartActivity( ACT_HL2MP_IDLE )
    self:SetLastAct( ACT_HL2MP_IDLE )
end

function ENT:MoveToSpot( type )
    local pos = self:FindSpot( "random", { type = type, radius = 5000 } )
    if ( pos ) then
        local nav = navmesh.GetNavArea(pos, 20)
        if !IsValid(nav) then return end
        if !nav:IsUnderwater() then
            self:StartActivity( ACT_HL2MP_RUN )
            self:SetLastAct( ACT_HL2MP_RUN )
            self.loco:SetDesiredSpeed( 200 )
            self:MoveToPos( pos, { tolerance = 30, lookahead = 10, repath = 2 } )
            self:StartActivity( ACT_HL2MP_IDLE )
            self:SetLastAct( ACT_HL2MP_IDLE )
        end
    end
end

function ENT:Sit()
    --self:PlaySequenceAndWait( "idle_to_sit_ground" )     --broken for clients so removed
    self:SetSequence( "sit_zen" )
    self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,36) )
    coroutine.wait( math.Rand(10,60) )
    self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,70) )
    --self:PlaySequenceAndWait( "sit_ground_to_idle" )
    --coroutine.wait( math.Rand(0,1.5) )
end

function ENT:OnStuck()
    self.Stucked = CurTime()
    self.StuckAt = self:GetPos()
end

function ENT:OnUnStuck()
    self.Stucked = nil
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
    end
    if ent:GetClass() == "func_breakable" or ent:GetClass() == "func_breakable_surf" then
        ent:Fire("Shatter")
    end
end

function ENT:OnLandOnGround( ent )
    self:StartActivity(self:GetLastAct())
    self.loco:SetStepHeight(22)
    self.IsJumping = false
    if self:GetLastAct() == ACT_HL2MP_RUN then self.loco:SetDesiredSpeed(200) elseif self:GetLastAct() == ACT_HL2MP_WALK then self.loco:SetDesiredSpeed(100) end
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
        local scanDist = (self.loco:GetVelocity():Length() * 0.075) + 20 -- shitty approximation
        --print(scanDist)
        if path:IsValid() and ((self:GetPos().z - path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist).z < 0 and (math.abs(path:GetClosestPosition(self:EyePos() + self:EyeAngles():Forward() * scanDist).z - self:GetPos().z) > 22)) or (self:GetPos().z - path:GetPositionOnPath(path:GetCursorPosition() +scanDist).z < 0 and math.abs(path:GetPositionOnPath(path:GetCursorPosition() + scanDist).z - self:GetPos().z) > 22)) then
            self:Jump()
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
function ENT:Jump()
    if CurTime() < self.Jumped + 1 or navmesh.GetNavArea(self:GetPos(), 50):HasAttributes( NAV_MESH_NO_JUMP ) then return end
    self:StartActivity(ACT_HL2MP_JUMP_SLAM)
    self.Jumped = CurTime()
    self.IsJumping = true
    self:SetSolidMask( MASK_NPCSOLID_BRUSHONLY )
    self.loco:SetStepHeight(64)
    self.loco:Jump()
end

function ENT:Duck( state )
    if state then self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,30) ) self.IsDuck = true else self:SetCollisionBounds( Vector(-8,-8,0), Vector(8,8,70) ) self.IsDuck = false end
end

function ENT:BodyUpdate()

    local act = self:GetActivity()

    --
    -- This helper function does a lot of useful stuff for us.
    -- It sets the bot's move_x move_y pose parameters, sets their animation speed relative to the ground speed, and calls FrameAdvance.
    --
    --

    --if act != self:GetLastAct() then act = self:GetLastAct() self:StartActivity(act) end

    local velocity = self:GetVelocity()


    if ( act == ACT_HL2MP_RUN || act == ACT_HL2MP_WALK ) then
        if velocity:Length2D() < 0.6 then
            return
        end

        self:BodyMoveXY()


    end

   /* local velocity = self:GetVelocity()
    local len = velocity:Length()
    local movement = 1.0

    if ( len > 0.2 ) then
        movement = ( len / self:GetSequenceGroundSpeed( self:GetActivity() ) )
    end

    local rate = math.min( movement, 2 )

     self:SetPlaybackRate(rate)

    if ( act == ACT_HL2MP_WALK ) then
        local fwd = self:GetRight()
        local dp = fwd:Dot( Vector(0,0,1) )
        local dp2 = fwd:Dot( velocity )
        //DebugInfo(4, "Right Velecoty "..tostring(dp2))
        DebugInfo(4, tostring(dp2))
        if ( dp2 > 150 ) then
            self:SetPoseParameter( "move_y", dp2/149.85  )
            DebugInfo(5, tostring(dp2/149.85))
        elseif ( dp2 > 0.5 ) then
            self:SetPoseParameter( "move_y", dp2/51.91  )
            DebugInfo(5, tostring(dp2/51.91))
        else
            self:SetPoseParameter( "move_y", 0 )
            DebugInfo(5, tostring(0))
        end
        //self:SetPoseParameter( "move_y", dp2/149.85  )

        local fwd = self:GetForward()
        local dp = fwd:Dot( Vector(0,0,1) )
        local dp2 = fwd:Dot( velocity )
        if ( dp2 > 150 ) then
            self:SetPoseParameter( "move_x", dp2/207.43  )
        elseif ( dp2 > 0.5 ) then
            self:SetPoseParameter( "move_x", dp2/78.78  )
        end
    end*/

    --
    -- If we're not walking or running we probably just want to update the anim system
    --
    self:FrameAdvance()

end