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
	--self.Entity:SetCollisionBounds( Vector(-4,-4,0), Vector(4,4,64) ) 

end

function ENT:Think()
	if self.loco:IsStuck() then
		self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.Rand(300, 2000),2)
	end
end

function ENT:RunBehaviour()
	while ( true ) do
		self.loco:SetDesiredSpeed( 100 )		-- Walk speed
		/*sspecs = {}
		sspecs.pos = self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * math.Rand(200, 500)
		sspecs.radius = math.Rand(500,1000)
		local spots = self:FindSpots( sspecs )
		local spotcount = table.Count(spots)
		if spotcount > 200 then
			self:MoveToPos(spots[math.random(1,spotcount)].vector, {draw = true})
		else*/
		self:MoveSomeWhere() --walk somewhere random

		if math.random(1, 22) == 10 then
			if self:BuddiesNear(400) <= 4 then
				self:PlaySequenceAndWait( "idle_to_sit_ground" )                        
		        self:SetSequence( "sit_ground" )                                            
		        coroutine.wait( math.Rand(10,60) )
		        self:PlaySequenceAndWait( "sit_ground_to_idle" )
		        coroutine.wait( math.Rand(0,1.5) )
		        self:MoveSomeWhere() --walk somewhere random
		    end
	    end
		if math.random(1,15) == 1 then
			if self:BuddiesNear(300) <= 3 then
				coroutine.wait( math.Rand(10,40) )
			end
		end
		
	end

end

function ENT:MoveSomeWhere()
	self:StartActivity( ACT_WALK )	
	local nav = navmesh.Find(self:GetPos(), 1000, 40, 40)
	local pos = nav[math.random(1,table.Count(nav))]:GetRandomPoint()
	local maxAge = math.Clamp(pos:Distance(self:GetPos())/120,0.1,10)
	self:MoveToPos( pos, { tolerance = 30, maxage = maxAge, lookahead = 10, repath = 3 })
	self:StartActivity( ACT_IDLE ) --for some reason wee need todo this twice since some models will stuck in walk aniamtions if we dont
	self:StartActivity( ACT_IDLE )
end

function ENT:Use( act, call, type, value )
	if call:Team() == TEAM_HIDING then call:SetModel(self:GetModel()) end
end

function ENT:OnStuck()
end

function ENT:OnContact( ent )
	--If i contact exists prevent blocking by moving them around

	if ent:GetClass() == self:GetClass() or ent:IsPlayer() or ent:GetClass() == "prop_physics" then
		self.loco:Approach( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
	end

end

function ENT:BuddiesNear( range )
	/*local entsNear = ents.FindInSphere( self:GetPos(), range )
	local i = 0
	for k,v in pairs(entsNear) do
		if v:GetClass() == self:GetClass() then
			i = i+1
		end
	end*/
	return 1
end