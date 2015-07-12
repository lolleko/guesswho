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
	self.Entity:SetCollisionBounds( Vector(-4,-4,0), Vector(4,4,64) ) 
	self.loco:SetStepHeight(20)
	self.loco:SetJumpHeight(58)

	self.Jumped = CurTime()
end

function ENT:Think()
	--shitty open door stuff needs rework at somepoint
	local doors = ents.FindInSphere(self:GetPos(),60)
	if doors then
		for k,v in pairs(doors) do
			if v:GetClass() == "func_door" or v:GetClass() == "func_door_rotating" then
				v:Fire("Unlock", "", 0)
				v:Fire("Open", "", 0.01)
				v:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
			end
		end
	end
	if CurTime() > self.Jumped + 3 then 
		local bodytrace = util.TraceLine( {
		start = self:GetPos() + Vector(0,0,30),
		endpos =  (self:GetPos() + Vector(0,0,30)) + self:EyeAngles():Forward() * 40,
		filter = self.Entity
		} )
		local eyetrace = util.TraceLine( {
		start = self:EyePos(),
		endpos =  self:EyePos() + self:EyeAngles():Forward() * 60,
		filter = self.Entity
		} )
		if bodytrace.Hit and !eyetrace.Hit then
			self.Jumped = CurTime() --delay next jump
			self.loco:Jump()
			self:SetVelocity(self:GetForward() * 1000)
		end
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
	self:MoveToPos( pos, { tolerance = 30, maxage = maxAge, lookahead = 10, repath = 3 })
	self:StartActivity( ACT_IDLE )
	self:SetLastAct( ACT_IDLE )
end

function ENT:MoveToSpot( type )
	local pos = self:FindSpot( "random", { type = type, radius = 5000 } )
	if ( pos ) then
			self:StartActivity( ACT_RUN )
			self:SetLastAct( ACT_RUN )											-- run anim
			self.loco:SetDesiredSpeed( 200 )										-- run speed
			self:MoveToPos( pos, { tolerance = 30, lookahead = 10, repath = 3 } )
			self:StartActivity( ACT_IDLE )														-- move to position (yielding)
			self:SetLastAct( ACT_IDLE )						
	end
end

function ENT:Sit()
	--self:PlaySequenceAndWait( "idle_to_sit_ground" )                        
    self:SetSequence( "sit_ground" )                                            
    coroutine.wait( math.Rand(10,60) )
    --self:PlaySequenceAndWait( "sit_ground_to_idle" )
    --coroutine.wait( math.Rand(0,1.5) )
end

function ENT:Use( act, call, type, value )
	if call:Team() == TEAM_HIDING then call:SetModel(self:GetModel()) end
end

function ENT:OnStuck()
end

function ENT:OnContact( ent )
	if ent:GetClass() == self:GetClass() or ent:IsPlayer() or ent:GetClass() == "prop_physics" then
		self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
	end
end

function ENT:OnLandOnGround( ent )
	self:StartActivity(self:GetLastAct())
end