AddCSLuaFile()

ENT.Base 			= "base_nextbot"

function ENT:SetupDataTables()
   self:NetworkVar("Int", 0, "RandomInt") --we need to generate the same random for both client and server
   self:NetworkVar("Int", 0, "LastAct")
end

function ENT:Initialize()

	local models = {
		--mains
		"odessa.mdl",
		"breen.mdl",
		"alyx.mdl",
		"barney.mdl",
		"gman.mdl",
		"eli.mdl",
		"kleiner.mdl",
		"mossman.mdl",
		--mdics broken
		--"Humans/Group03m/male_01.mdl",
		--"Humans/Group03m/female_01.mdl",
		--rebels broken
		--"Humans/Group03/female_06.mdl",
		--"Humans/Group03/male_06.mdl",
		--citiziens white clothes
		"Humans/Group02/male_08.mdl",
		--blue clothes
		"Humans/Group02/female_03.mdl",
	}
	if SERVER then self:SetRandomInt(math.random(1,#models)) end

	self:SetModel("models/"..models[self:GetRandomInt()])
	self:SetHealth(100)
	self.Entity:SetCollisionBounds( Vector(-6,-6,0), Vector(6,6,70) ) 
	self.loco:SetStepHeight(22)
	self.loco:SetJumpHeight(58)

	self.Jumped = CurTime()
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
	/*if CurTime() > self.Jumped + 2 and self:GetActivity() == ACT_WALK or self:GetActivity() == ACT_RUN then 
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
	local eyetrace = util.TraceHull({
			start  = self:EyePos(),
			endpos = self:GetPos() + self:EyeAngles():Forward() * 30,
			filter = self.Entity
		})
	local nav = navmesh.GetNavArea(eyetrace.HitPos, 10)
	local nav2 = navmesh.GetNavArea(self:GetPos(), 10)
	if nav:HasAttributes( NAV_MESH_JUMP ) or nav2:HasAttributes( NAV_MESH_JUMP ) then
		self.loco:Approach(self:GetPos() + self:EyeAngles():Forward() * 30, 1000)
		if CurTime() > self.Jumped + 2 then
			self.Jumped = CurTime()
			self.loco:Jump()
		end
	end
	if self.Stucked and CurTime() > self.Stucked + 15 and self.StuckAt:Distance(self:GetPos()) < 5 then
		self:SetPos(GAMEMODE.SpawnPoints[math.random(1,#GAMEMODE.SpawnPoints)]:GetPos())
		self.Stucked = nil
		if SERVER then print("["..self:GetClass().."]["..tostring(self:EntIndex()).."] Got Stuck for over 15 seconds and will be repositioned, if this error gets spammed you might want to consider the following: Edit the navmesh or lower the walker amount.") end
	end

end

function ENT:RunBehaviour()
	while ( true ) do
		local rand = math.random(1,100)
		if rand > 0 and rand < 10 then
			self:MoveToSpot( "hiding" )
			coroutine.wait(math.random(1,10))		
		elseif rand > 10 and rand < 15 then
			self:Sit()
		else
			self:MoveSomeWhere()
		end
	end

end

function ENT:MoveSomeWhere()
	self:StartActivity( ACT_WALK )
	self:SetLastAct( ACT_WALK )
	self.loco:SetDesiredSpeed( 100 )	
	local navs = navmesh.Find(self:GetPos(), 1000, 40, 40)
	local nav = navs[math.random(1,#navs)]
	if nav:IsUnderwater() then return end -- we dont want them to go into water
	local pos = nav:GetRandomPoint()
	local maxAge = math.Clamp(pos:Distance(self:GetPos())/120,0.1,10)
	self:MoveToPos( pos, { tolerance = 30, maxage = maxAge, lookahead = 10, repath = 2 })
	self:StartActivity( ACT_IDLE )
	self:SetLastAct( ACT_IDLE )
end

function ENT:MoveToSpot( type )
	local pos = self:FindSpot( "random", { type = type, radius = 5000 } )
	if ( pos ) then
		local nav = navmesh.GetNavArea(pos, 20)
		if !nav:IsUnderwater() then
			self:StartActivity( ACT_RUN )
			self:SetLastAct( ACT_RUN )											-- run anim
			self.loco:SetDesiredSpeed( 200 )										-- run speed
			self:MoveToPos( pos, { tolerance = 30, lookahead = 10, repath = 2 } )
			self:StartActivity( ACT_IDLE )														-- move to position (yielding)
			self:SetLastAct( ACT_IDLE )						
		end
	end
end

function ENT:Sit()
	--self:PlaySequenceAndWait( "idle_to_sit_ground" )                        
    self:SetSequence( "sit_ground" )                                           
    coroutine.wait( math.Rand(10,60) )
    --self:PlaySequenceAndWait( "sit_ground_to_idle" )
    --coroutine.wait( math.Rand(0,1.5) )
end

function ENT:OnStuck()
	self.Stucked = CurTime()
	self.StuckAt = self:GetPos()
end

function ENT:Use( act, call, type, value )
	if call:Team() == TEAM_HIDING then call:SetModel(self:GetModel()) end
end

function ENT:OnNavAreaChanged( old, new)
	if new:HasAttributes( NAV_MESH_JUMP ) and CurTime() > self.Jumped + 2  then 
		self.loco:Jump()
	end
end

function ENT:OnContact( ent )
	if ent:GetClass() == self:GetClass() or ent:IsPlayer() or ent:GetClass() == "prop_physics" then
		self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
	end
end

function ENT:OnLandOnGround( ent )
	self:StartActivity(self:GetLastAct())
end

function ENT:Draw()
	self:DrawModel()
	local start = self:GetPos() + Vector(0,0,59)
	local endpos =  (self:GetPos() + Vector(0,0,55)) + self:EyeAngles():Forward() * 60
	local mins = Vector(16,0,0)
	local maxs = Vector(16,0,15)
	render.DrawWireframeBox( start, Angle( 0, 0, 0 ), mins, maxs, Color( 255, 255, 255 ), true )
end