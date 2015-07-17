--[[
	ROUND CONTROLLER
]]--

--Round settings
GM.MaxWalkers = GetConVar( "gw_maxwalkers" ):GetInt()
GM.PreGameDuration = GetConVar( "gw_pregameduration" ):GetInt()
GM.RoundDuration = GetConVar( "gw_roundduration" ):GetInt()
GM.HideDuration = GetConVar( "gw_hideduration" ):GetInt()
GM.PostRoundDuration = GetConVar( "gw_postroundduration" ):GetInt()
GM.MaxRounds = GetConVar( "gw_maxrounds" ):GetInt()
GM.MinHiding = GetConVar( "gw_minhiding" ):GetInt()
GM.MinSeeking = GetConVar( "gw_minseeking" ):GetInt()

function GM:InitPostEntity()
	
 	self:PreGame()

end

function GM:GetSpawnPoints()
	if ( !IsTableOfEntitiesValid( self.SpawnPoints ) ) then
	
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
		
		-- CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		
		-- DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		-- (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
		
		-- TF Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_teamspawn" ) )
		
		-- INS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "ins_spawnpoint" ) )

		-- AOC Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "aoc_spawnpoint" ) )

		-- Dystopia Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "dys_spawn_point" ) )

		-- PVKII Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_pirate" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_viking" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_knight" ) )

		-- DIPRIP Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_blue" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "diprip_start_team_red" ) )

		-- OB Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_red" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_blue" ) )

		-- SYN Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_coop" ) )

		-- ZPS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_human" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombie" ) )

		-- ZM Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_zombiemaster" ) )

	end

	local rand = math.random
	local n = #self.SpawnPoints

	while n > 2 do

		local k = rand(n) -- 1 <= k <= n

		self.SpawnPoints[n], self.SpawnPoints[k] = self.SpawnPoints[k], self.SpawnPoints[n]
		n = n - 1
 	end

end

function GM:PreGame()
	timer.Simple( self.PreGameDuration, function() self:PreRoundStart() end)
	SetGlobalFloat("EndTime", CurTime() + self.PreGameDuration )
	SetGlobalString("RoundState", PRE_GAME)
end


function GM:PreRoundStart()
	--do not start round without players or at least one player in each team
	if team.NumPlayers( TEAM_HIDING ) < self.MinHiding or team.NumPlayers( TEAM_SEEKING ) < self.MinSeeking then
		--check again after half a second second
		timer.Simple(0.5, function() self:PreRoundStart() end)
		--clear remaning npcs to save recources
		for k,v in pairs(ents.FindByClass("npc_walker")) do
    		v:Remove()
		end
		SetGlobalFloat("EndTime", CurTime() + 1 )
		SetGlobalString("RoundState", WAITING)
		return
	end

	SetGlobalString("RoundState", CREATING)

	for k,v in pairs(ents.FindByClass("npc_walker")) do
    	v:Remove()
	end

	self:GetSpawnPoints()

	local wave = 1

	self.WalkerCount = 0
	for k,v in pairs(self.SpawnPoints) do
		if self.WalkerCount == self.MaxWalkers then break end

		local occupied = false
		for _,ent in pairs(ents.FindInBox(v:GetPos() + Vector( -16, -16, 0 ), v:GetPos() + Vector( 16, 16, 64 ))) do
			if ent:GetClass() == "npc_walker" then occupied = true end
		end

		if !occupied then
			local walker = ents.Create("npc_walker")
			if !IsValid( walker ) then break end
			walker:SetPos( v:GetPos() )
			walker:Spawn()
			walker:Activate()
			self.WalkerCount = self.WalkerCount + 1
		end
	end

	if self.MaxWalkers > #self.SpawnPoints then
		wave = wave + 1
		timer.Simple(5, function()
			for k,v in pairs(self.SpawnPoints) do
				if self.WalkerCount == self.MaxWalkers then break end

				local occupied = false
				for _,ent in pairs(ents.FindInBox(v:GetPos() + Vector( -16, -16, 0 ), v:GetPos() + Vector( 16, 16, 64 ))) do
					if ent:GetClass() == "npc_walker" then occupied = true end
				end

				if !occupied then
					local walker = ents.Create("npc_walker")
					if !IsValid( walker ) then break end
					walker:SetPos( v:GetPos() )
					walker:Spawn()
					walker:Activate()
					self.WalkerCount = self.WalkerCount + 1
				end
			end
		end)
	end

	timer.Simple(5*wave, function()
		SetGlobalString("RoundState", PRE_ROUND)
		for k,v in pairs(team.GetPlayers( TEAM_HIDING )) do
			v:Spawn()
		end

	end)
	timer.Simple( 5 + (5*wave), function() for k,v in pairs(team.GetPlayers( TEAM_SEEKING )) do
		v:Spawn()
		v:SetPos(v:GetPos() + Vector(2,2,2)) --move them a little bit to make avoid players work
		v:Freeze( true )
		v:SetAvoidPlayers( true )
		end
	end)
	timer.Simple(self.HideDuration + (5*wave), function() self:RoundStart() end )
	SetGlobalFloat("EndTime", CurTime() + self.HideDuration + (5*wave) )
end

function GM:RoundStart()
	for k,v in pairs(team.GetPlayers( TEAM_SEEKING )) do
		v:Freeze( false )
		v:SetAvoidPlayers( false )
	end
	timer.Create( "RoundThink", 1, self.RoundDuration, function() self:RoundThink() end)
	self.RoundTime = 1
	SetGlobalFloat("EndTime", CurTime() + self.RoundDuration )
	SetGlobalInt( GetGlobalInt("RoundNumber", 0) + 1)
	SetGlobalString("RoundState", IN_ROUND)
end

--will be called every second
function GM:RoundThink()
	--end conditions
	self.RoundTime = self.RoundTime + 1

	if self.RoundTime == self.RoundDuration then self:RoundEnd( false ) end

	if team.NumPlayers( TEAM_HIDING ) < self.MinHiding or team.NumPlayers( TEAM_SEEKING ) < self.MinSeeking then
		self:RoundEnd()
	end

	local seekersWin = true
	for k,v in pairs(team.GetPlayers( TEAM_HIDING )) do
		if v:Alive() then seekersWin = false end
	end

	local hidingWin = true
	for k,v in pairs(team.GetPlayers( TEAM_SEEKING )) do
		if v:Alive() then hidingWin = false end
	end

	if seekersWin then
		self:RoundEnd(true)
	end

	if hidingWin then
		self:RoundEnd(false)
	end
end

function GM:RoundEnd( caught )
	if timer.Exists("RoundThink") then timer.Destroy("RoundThink") end
	--choose winner and stuff

	if caught then
		PrintMessage( HUD_PRINTCENTER, "The Hunters won." )
		team.AddScore( TEAM_SEEKING, 1)
	else
		PrintMessage( HUD_PRINTCENTER, "The Citiziens won." )
		for k,v in pairs(team.GetPlayers( TEAM_HIDING )) do
			if v:Alive() then v:AddFrags( 1 ) end --if still alive as hiding after round give them one point (frag)
		end
		team.AddScore( TEAM_HIDING, 1)
	end
	self:PostRound()
end

function GM:PostRound()
	
	game.CleanUpMap()

	timer.Simple( self.PostRoundDuration, function() self:PreRoundStart() end)
	SetGlobalFloat("EndTime", CurTime() + self.PostRoundDuration )
	SetGlobalString("RoundState", POST_ROUND)

	if GetGlobalInt("RoundNumber", 0) == self.MaxRounds then
		game.LoadNextMap()
	end
	--teamswap
	for k,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_SEEKING then
			v:SetTeam(TEAM_HIDING)
		elseif v:Team() == TEAM_HIDING then
			v:SetTeam(TEAM_SEEKING)
		end
		v:KillSilent()
	end
end