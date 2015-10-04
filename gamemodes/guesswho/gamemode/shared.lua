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

function GM:CreateTeams()

    team.SetUp( TEAM_HIDING, "Hiding", self.TeamHidingColor )
    team.SetClass( TEAM_HIDING, { "player_hiding" } )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_start" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_deathmatch" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_rebel" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_combine" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_counterterrorist" )
    team.SetSpawnPoint( TEAM_HIDING, "info_player_terrorist" )

    team.SetUp( TEAM_SEEKING, "Hunter", self.TeamSeekingColor )
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

function GM:OnEntityCreated(ent)
    if ent:GetClass() == "npc_walker" then
        ent.WalkerColor = Vector(ent:GetColor().r / 255, ent:GetColor().g / 255, ent:GetColor().b / 255)
        function ent:GetPlayerColor() return self.WalkerColor end
        ent:SetColor(Color(255, 255, 255, 255))
    end
end