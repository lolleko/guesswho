AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "player_ext_shd.lua")
AddCSLuaFile( "player_class/player_hiding.lua")
AddCSLuaFile( "player_class/player_seeker.lua")
AddCSLuaFile( "sh_animations.lua")
AddCSLuaFile( "sh_config.lua")
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_pickteam.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
include( "shared.lua" )
include( "player.lua" )
include( "round.lua" )

--resources
resource.AddFile( "materials/vgui/gw/logo_main.png" )

--[[
	GAMEMODE HOOKS
]]--

--Convars
GM.DamageOnFail = GetConVar( "gw_damageonfailguess" ):GetInt()

--Take Damage if innocent NPC damaged
function GM:EntityTakeDamage(target, dmginfo)

	attacker = dmginfo:GetAttacker()

	if GAMEMODE:InRound() && target && target:GetClass() == "npc_walker" && !target:IsPlayer() && attacker && attacker:IsPlayer() && attacker:Team() == TEAM_SEEKING && attacker:Alive() then
	
		attacker:TakeDamage( self.DamageOnFail , target, attacker:GetActiveWeapon())
			
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
				attacker:SetHealth(attacker:Health() + self.DamageOnFail*2) 
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
				
				attacker:TakeDamage( self.DamageOnFail*2 , ent, attacker:GetActiveWeapon())

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