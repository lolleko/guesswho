GM.Name = "Guess Who"
GM.Author = "Lolleko"
GM.Email = "N/A"
GM.Website = "https://github.com/lolleko/guesswho"

GM.Version = "1.6.5 (59)"

GM.TeamBased = true

DeriveGamemode( "base" )

include("player_ext_shd.lua")
include("sh_config.lua")
include("sh_taunts.lua")
include("player_class/player_hiding.lua")
include("player_class/player_seeker.lua")
include("sh_animations.lua")

--Globals

--Teams
TEAM_HIDING = 1
TEAM_SEEKING = 2

--Round states
ROUND_PRE_GAME = 1
ROUND_WAITING_PLAYERS = 2
ROUND_CREATING = 3
ROUND_HIDE = 4
ROUND_SEEK = 5
ROUND_POST = 6
ROUND_NAV_GEN = 9

--Shared CVars fallback
CreateConVar("gw_target_finder_threshold", "700", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "The distance before the target finder will display nearby")
CreateConVar("gw_target_finder_enabled", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Wether target finder is enabled or not")
CreateConVar("gw_abilities_enabled", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Should hiding have abilities or not.")
CreateConVar("gw_touches_enabled", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Wether touching for weapons is enabled.")
CreateConVar("gw_touches_required", "3", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "The amount of seeker touches that are required for a hider to receive a new weapon.")


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

function GM:PlayerShouldTakeDamage( ply, victim )
    if ply:IsPlayer() and victim:IsPlayer() then
        if ply:Team() == victim:Team() then
            return false
        end
    end

    return true
end

function GM:ShouldCollide( ent1, ent2 )

    if ( (!ent1:IsPlayer() and ent1:IsPlayerHolding()) or (!ent1:IsPlayer() and ent2:IsPlayerHolding() )) then
        return false
    end

    if GetConVar( "gw_abilities_enabled" ):GetBool() and GetConVar("gw_touches_enabled"):GetBool() and self:GetRoundState() == ROUND_SEEK then
        local hider, seeker
        if ent1:IsPlayer() and ent2:IsPlayer() then
            if ent1:IsHiding() and ent2:IsSeeking() then
                hider = ent1
                seeker = ent2
            elseif ent2:IsHiding() and ent1:IsSeeking()  then
                hider = ent2
                seeker = ent1
            end

            if hider and hider:GetLastSeekerTouch() + 3 < CurTime() and hider:GetPos():Distance(seeker:GetPos()) < 40  then
                hider:AddSeekerTouch()
            end
        end
    end

    return true
end

function GM:PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter )

    if ply:IsHiding() then

        return true

    end

end
