GM.Name = "Guess Who"
GM.Author = "Lolleko"
GM.Email = "N/A"
GM.Website = "https://github.com/lolleko/guesswho"

GM.Version = "2.2 (76)"

GM.TeamBased = true

--Teams
GW_TEAM_HIDING = 1
GW_TEAM_SEEKING = 2

--Round states
GW_ROUND_PRE_GAME = 1
GW_ROUND_WAITING_PLAYERS = 2
GW_ROUND_CREATING_NPCS = 3
GW_ROUND_HIDE = 4
GW_ROUND_SEEK = 5
GW_ROUND_POST = 6
GW_ROUND_NAV_GEN = 9

GW_WALKER_CLASS = "gw_npc_walker"

--Shared CVars fallback
-- https://github.com/Facepunch/garrysmod-issues/issues/3323
local cVarFlags = {FCVAR_REPLICATED, FCVAR_ARCHIVE}
if CLIENT then
    cVarFlags = {FCVAR_REPLICATED}
end

CreateConVar("gw_target_finder_threshold", "700", cVarFlags, "The distance before the target finder will display nearby")
CreateConVar("gw_target_finder_enabled", "0", cVarFlags, "Wether target finder is enabled or not")
CreateConVar("gw_abilities_enabled", "1", cVarFlags, "Should hiding have abilities or not.")
CreateConVar("gw_touches_enabled", "1", cVarFlags, "Wether touching for weapons is enabled.")
CreateConVar("gw_touches_required", "3", cVarFlags, "The amount of seeker touches that are required for a hider to receive a new weapon.")
CreateConVar("gw_seeker_walk_speed", "100", cVarFlags, "Seeker Walk Speed")
CreateConVar("gw_seeker_run_speed", "200", cVarFlags, "Seeker Run Speed")
CreateConVar("gw_hiding_walk_speed", "100", cVarFlags, "Hiding Walk Speed")
CreateConVar("gw_hiding_run_speed", "200", cVarFlags, "Hiding Run Speed")
CreateConVar("gw_double_jump_enabled", "0", cVarFlags, "Wether Double Jumps are enabled or not")


game.AddAmmoType( {
    name = "gwDashCharges",
    dmgtype = DMG_GENERIC
} )

DeriveGamemode( "base" )

include("player_ext_shd.lua")
include("sh_config.lua")
include("sh_taunts.lua")
include("player_class/player_guess_who.lua")
include("player_class/player_hiding.lua")
include("player_class/player_seeker.lua")
include("sh_animations.lua")
include("sh_notifications.lua")

function GM:CreateTeams()
    team.SetUp( GW_TEAM_HIDING, "Hiding", self.GWConfig.TeamHidingColor )
    team.SetClass( GW_TEAM_HIDING, { "player_hiding" } )
    team.SetSpawnPoint( GW_TEAM_HIDING, "info_player_start" )
    team.SetSpawnPoint( GW_TEAM_HIDING, "info_player_deathmatch" )
    team.SetSpawnPoint( GW_TEAM_HIDING, "info_player_rebel" )
    team.SetSpawnPoint( GW_TEAM_HIDING, "info_player_combine" )
    team.SetSpawnPoint( GW_TEAM_HIDING, "info_player_counterterrorist" )
    team.SetSpawnPoint( GW_TEAM_HIDING, "info_player_terrorist" )

    team.SetUp( GW_TEAM_SEEKING, "Seekers", self.GWConfig.TeamSeekingColor )
    team.SetClass( GW_TEAM_SEEKING, { "player_seeker" } )
    team.SetSpawnPoint( GW_TEAM_SEEKING, "info_player_start" )
    team.SetSpawnPoint( GW_TEAM_SEEKING, "info_player_deathmatch" )
    team.SetSpawnPoint( GW_TEAM_SEEKING, "info_player_rebel" )
    team.SetSpawnPoint( GW_TEAM_SEEKING, "info_player_combine" )
    team.SetSpawnPoint( GW_TEAM_SEEKING, "info_player_counterterrorist" )
    team.SetSpawnPoint( GW_TEAM_SEEKING, "info_player_terrorist" )

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

    if ( (not ent1:IsPlayer() and ent1:IsPlayerHolding()) or (not ent1:IsPlayer() and ent2:IsPlayerHolding() )) then
        return false
    end

    if GetConVar( "gw_abilities_enabled" ):GetBool() and GetConVar("gw_touches_enabled"):GetBool() and GAMEMODE.GWRound:IsCurrentState(GW_ROUND_SEEK) then
        local hider, seeker
        if ent1:IsPlayer() and ent2:IsPlayer() then
            if ent1:GWIsHiding() and ent2:GWIsSeeking() then
                hider = ent1
                seeker = ent2
            elseif ent2:GWIsHiding() and ent1:GWIsSeeking() then
                hider = ent2
                seeker = ent1
            end

            if hider and hider:GWGetLastSeekerTouch() + 3 < CurTime() and hider:GetPos():Distance(seeker:GetPos()) < 40 then
                hider:GWAddSeekerTouch()
            end
        end
    end

    return true
end

function GM:PlayerFootstep( ply, vPos, iFoot, strSoundName, fVolume, pFilter )

    if ply:GWIsHiding() then

        return true

    end

end
