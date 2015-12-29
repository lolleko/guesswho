GM.Name = "Guess Who"
GM.Author = "Lolleko"
GM.Email = "N/A"
GM.Website = "https://github.com/lolleko"

GM.TeamBased    = true

DeriveGamemode( "base" )

include( "player_ext_shd.lua")
include( "sh_config.lua")
include( "sh_taunts.lua")
include( "player_class/player_hiding.lua")
include( "player_class/player_seeker.lua")

include( "sh_animations.lua")
--Globals

TEAM_HIDING = 1
TEAM_SEEKING = 2

--Round states

--Really shouldnt use strings here but i'm really lazy

PRE_GAME = "Preparing Game"
CREATING = "Creating NPCs"
PRE_ROUND = "Hide"
IN_ROUND = "Seek"
POST_ROUND = "Next round soon"
WAITING = "Waiting for more players"
NAV_GEN = "Genearating Navmesh!"

function GM:CreateTeams()

    team.SetUp( TEAM_HIDING, "Hiding", self.TeamHidingColor )
    team.SetClass( TEAM_HIDING, { "player_hiding" } )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_start" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_deathmatch" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_rebel" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_combine" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_counterterrorist" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_terrorist" )

    team.SetUp( TEAM_SEEKING, "Seekers", self.TeamSeekingColor )
    team.SetClass( TEAM_SEEKING, { "player_seeker" } )
    team.SetSpawnPoint( TEAM_SEEKING, "info_player_start" )
    team.SetSpawnPoint( TEAM_SEEKING, "info_player_deathmatch" )
    team.SetSpawnPoint( TEAM_SEEKING, "info_player_rebel" )
    team.SetSpawnPoint( TEAM_SEEKING, "info_player_combine" )
    team.SetSpawnPoint( TEAM_SEEKING, "info_player_counterterrorist" )
    team.SetSpawnPoint( TEAM_SEEKING, "info_player_terrorist" )

    team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" )
end

function GM:GetRoundState()
    return GetGlobalString("RoundState", IN_ROUND)
end

function GM:InRound()
    return GetGlobalString("RoundState", IN_ROUND) == IN_ROUND
end

function GM:PlayerShouldTakeDamage( ply, victim )
    if ply:IsPlayer() and victim:IsPlayer() then
        if ply:Team() == victim:Team() then
            return false
        end
    end

    return true
end

function GM:ShouldCollide( ent1, ent2 )
    if ( ent1:IsPlayerHolding() or ent2:IsPlayerHolding() ) and (ent1:GetClass() == "npc_walker" or ent2:GetClass() == "npc_walker" or ( ent1:IsPlayer() and ent1:Team() == TEAM_HIDING ) or( ent2:IsPlayer() and ent2:Team() == TEAM_HIDING )  ) then
        DropEntityIfHeld( ent1 )
        DropEntityIfHeld( ent2 )
    end
    return true
end
