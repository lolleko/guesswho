AddCSLuaFile()

ENT.Base 			= "base_nextbot"

function ENT:SetupDataTables()
   self:NetworkVar("Int", 0, "RandomInt") --we need to generate the same random for both client and server
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
end

function ENT:Think()
	--TODO find doors
end

function ENT:RunBehaviour()
	while ( true ) do
		local rand = math.random(1,100)
		if rand > 0 and rand < 10 then
			self:MoveToSpot( "hiding" )
		elseif rand > 10 and rand < 15 then
			self:Sit()
		else
			self:MoveSomeWhere()
		end
	end

end

function ENT:MoveSomeWhere()
	self:StartActivity( ACT_WALK )
	self.loco:SetDesiredSpeed( 100 )	
	local navs = navmesh.Find(self:GetPos(), 1000, 40, 40)
	local pos = navs[math.random(1,#navs)]:GetRandomPoint()
	local maxAge = math.Clamp(pos:Distance(self:GetPos())/120,0.1,10)
	self:MoveToPos( pos, { tolerance = 30, maxage = maxAge, lookahead = 10, repath = 3 })
	self:StartActivity( ACT_IDLE )
end

function ENT:MoveToSpot( type )
	local pos = self:FindSpot( "random", { type = type, radius = 5000 } )
	if ( pos ) then
			self:StartActivity( ACT_RUN )											-- run anim
			self.loco:SetDesiredSpeed( 200 )										-- run speed
			self:MoveToPos( pos, { tolerance = 30, lookahead = 10, repath = 3 } )
			self:StartActivity( ACT_IDLE )														-- move to position (yielding)
			coroutine.wait(math.random(1,10))										-- play a fear animation
													-- when we finished, go into the idle anim
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
