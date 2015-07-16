AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "player_ext_shd.lua")
AddCSLuaFile( "player_class/player_hiding.lua")
AddCSLuaFile( "player_class/player_seeker.lua")
AddCSLuaFile( "sh_animations.lua")
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_pickteam.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
include( "shared.lua" )
include( "player.lua" )

util.AddNetworkString("CleanUp")

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

	self.WalkerCount = 0

	--shuffle spawnpoints (thx ttt)
	local rand = math.random
	local n = #self.SpawnPoints

	while n > 2 do

		local k = rand(n) -- 1 <= k <= n

		self.SpawnPoints[n], self.SpawnPoints[k] = self.SpawnPoints[k], self.SpawnPoints[n]
		n = n - 1
 	end

 	self:PreGame()
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

	timer.Simple(5*wave, function()
		SetGlobalString("RoundState", PRE_ROUND)
		for k,v in pairs(team.GetPlayers( TEAM_HIDING )) do
			v:Spawn()
		end

	end)
	timer.Simple( 5 + (5*wave), function() for k,v in pairs(team.GetPlayers( TEAM_SEEKING )) do
		v:Spawn()
		v:SetPos(2,2,2) --move them a little bit to make avoid players work
		v:Freeze( true )
		v:SetAvoidPlayers( true )
		end
	end)
	timer.Simple(self.HideDuration + (5*wave), function() self:RoundStart() end )
	SetGlobalFloat("EndTime", CurTime() + self.HideDuration + 5 + (5*wave) )
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
	net.Start("CleanUp")
	net.Broadcast()
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

--[[
	GAMEMODE HOOKS
]]--

--Convars
GM.DamageOnFail = GetConVar( "gw_damageonfailguess" ):GetInt()

--Take Damage if innocent NPC damaged
function GM:EntityTakeDamage(target, dmginfo)

	attacker = dmginfo:GetAttacker()

	if GAMEMODE:InRound() && target && target:GetClass() == "npc_walker" && !target:IsPlayer() && attacker && attacker:IsPlayer() && attacker:Team() == TEAM_SEEKING && attacker:Alive() then
	
		attacker:SetHealth(attacker:Health() - self.DamageOnFail)
		
		if attacker:Health() <= 0 then
		
			attacker:Kill()
			
		end
		
	end
	
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )

	ply:CreateRagdoll()
	
	ply:AddDeaths( 1 )
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
		
		if attacker == ply then
			return
		end

		if attacker:Team() == TEAM_SEEKING then
			attacker:AddFrags( 1 )
			if attacker:Health() + self.DamageOnFail*4 > 100 then
				attacker:Health(100)
			else
				attacker:Health(attacker:Health() + self.DamageOnFail*4) 
			end
		end
	
	end

end

function GM:OnNPCKilled( ent, attacker, inflictor )

	-- Don't spam the killfeed with scripted stuff
	if ( ent:GetClass() == "npc_bullseye" || ent:GetClass() == "npc_launcher" ) then return end

	if ( IsValid( attacker ) && attacker:GetClass() == "trigger_hurt" ) then attacker = ent end
	
	if ( IsValid( attacker ) && attacker:IsVehicle() && IsValid( attacker:GetDriver() ) ) then
		attacker = attacker:GetDriver()
	end

	if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
		inflictor = attacker
	end
	
	-- Convert the inflictor to the weapon that they're holding if we can.
	if ( IsValid( inflictor ) && attacker == inflictor && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then
	
		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( attacker ) ) then inflictor = attacker end
	
	end
	
	local InflictorClass = "worldspawn"
	local AttackerClass = "worldspawn"
	
	if ( IsValid( inflictor ) ) then InflictorClass = inflictor:GetClass() end
	if ( IsValid( attacker ) ) then

		AttackerClass = attacker:GetClass()
	
		if ( attacker:IsPlayer() ) then

			if ent:GetClass() == "npc_walker" then
				
				attacker:SetHealth(attacker:Health() - self.DamageOnFail*2)
			
				if attacker:Health() <= 0 then
				
					attacker:Kill()
					
				end

			end

			net.Start( "PlayerKilledNPC" )
		
				net.WriteString( ent:GetClass() )
				net.WriteString( InflictorClass )
				net.WriteEntity( attacker )
		
			net.Broadcast()

			return
		end

	end

	if ( ent:GetClass() == "npc_turret_floor" ) then AttackerClass = ent:GetClass() end

	net.Start( "NPCKilledNPC" )
	
		net.WriteString( ent:GetClass() )
		net.WriteString( InflictorClass )
		net.WriteString( AttackerClass )
	
	net.Broadcast()

end