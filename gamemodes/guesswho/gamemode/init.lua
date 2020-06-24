AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_lang.lua")
AddCSLuaFile("player_ext_shd.lua")
AddCSLuaFile("player_class/player_hiding.lua")
AddCSLuaFile("player_class/player_seeker.lua")
AddCSLuaFile("sh_animations.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_taunts.lua")
AddCSLuaFile("sh_notifications.lua")

--translations
for _,locale in pairs(file.Find("gamemodes/guesswho/gamemode/lang/*", "GAME")) do
    AddCSLuaFile("lang/" .. locale)
end
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_pickteam.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_settings.lua")
AddCSLuaFile("cl_acts.lua")
AddCSLuaFile("cl_round.lua")

include("shared.lua")
include("player.lua")
include("player_ext.lua")
include("round.lua")
include("propfreeze.lua")
include("targetfinder.lua")

util.AddNetworkString("gwRoundState")
util.AddNetworkString("gwPlayerHull")
util.AddNetworkString("gwSendConfig")
util.AddNetworkString("gwRequestUpdateConfig")
util.AddNetworkString("gwSendNotification")
util.AddNetworkString("gwServerStartTauntForClient")
util.AddNetworkString("gwClientRequestTaunt")

-- Disable Enhanced playermodel selector
if GetConVar("sv_playermodel_selector_force") and GetConVar("sv_playermodel_selector_force"):GetBool() then
    local warningString = "[Warning] Enhanced Player Model Selector detected! This addon is not compatible with Guess Who, either remove/disable the addon or set \"sv_playermodel_selector_force\" to 0 (Requires map change or restart)!"
    timer.Create("gwPlayermodelSelectorWarning", 30, 0, function()
        PrintMessage(HUD_PRINTTALK, warningString)
    end)
    print(warningString)
end

function GM:Initialize()
    timer.Create("gw.player.distance.update.think", 0.1, 0, self.TargetFinderThink)
end

hook.Add("OnEntityWaterLevelChanged", "gwDisableSwimmingForMaps", function(ent, oldLevel, newLevel)
    -- disable swimming on some maps
    if IsValid(ent) and ent:IsPlayer() and ent:Alive() and game.GetMap() == "gm_coast10" and newLevel == 3 then
        timer.Simple(0.1, function()
            if IsValid(ent) then
                ent:Kill()
            end
        end)
    end
end)

--Take Damage if innocent NPC damaged
function GM:EntityTakeDamage(target, dmginfo)

    local attacker = dmginfo:GetAttacker()

    if GAMEMODE.GWRound:IsCurrentState(GW_ROUND_SEEK) and target and target:GetClass() == GW_WALKER_CLASS and not target:IsPlayer() and attacker and attacker:IsPlayer() and attacker:Team() == GW_TEAM_SEEKING and attacker:Alive() then

        attacker:TakeDamage(GetConVar("gw_damageonfailguess"):GetInt() , target, attacker:GetActiveWeapon())

    end

end

function GM:DoPlayerDeath(ply, attacker, dmginfo)

    ply:CreateRagdoll()

    ply:AddDeaths(1)

    if (attacker:IsValid() and attacker:IsPlayer()) then

        if attacker == ply then
            return
        end

        if attacker:Team() == GW_TEAM_SEEKING then
            attacker:AddFrags(1)
            if attacker:Health() + GetConVar("gw_damageonfailguess"):GetInt() * 2 > 100 then
                attacker:Health(100)
            else
                attacker:SetHealth(attacker:Health() + GetConVar("gw_damageonfailguess"):GetInt() * 2)
            end
        end

    end

end

function GM:OnNPCKilled(ent, attacker, inflictor)

    -- Don't spam the killfeed with scripted stuff
    if (ent:GetClass() == "npc_bullseye" or ent:GetClass() == "npc_launcher") then return end

    if (IsValid(attacker) and attacker:GetClass() == "trigger_hurt") then attacker = ent end

    if (IsValid(attacker) and attacker:IsVehicle() and IsValid(attacker:GetDriver())) then
        attacker = attacker:GetDriver()
    end

    if (not IsValid(inflictor) and IsValid(attacker)) then
        inflictor = attacker
    end

    -- Convert the inflictor to the weapon that they're holding if we can.
    if (IsValid(inflictor) and attacker == inflictor and (inflictor:IsPlayer() or inflictor:IsNPC())) then

        inflictor = inflictor:GetActiveWeapon()
        if (not IsValid(attacker)) then inflictor = attacker end

    end

    local InflictorClass = "worldspawn"
    local AttackerClass = "worldspawn"

    if (IsValid(inflictor)) then InflictorClass = inflictor:GetClass() end
    if (IsValid(attacker)) then

        AttackerClass = attacker:GetClass()

        if (attacker:IsPlayer()) then

            if ent:GetClass() == GW_WALKER_CLASS then

                attacker:TakeDamage(GetConVar("gw_damageonfailguess"):GetInt() * 2, ent, attacker:GetActiveWeapon())

            end

            net.Start("PlayerKilledNPC")

                net.WriteString(ent:GetClass())
                net.WriteString(InflictorClass)
                net.WriteEntity(attacker)

            net.Broadcast()

            return
        end

    end

    if (ent:GetClass() == "npc_turret_floor") then AttackerClass = ent:GetClass() end

    net.Start("NPCKilledNPC")

        net.WriteString(ent:GetClass())
        net.WriteString(InflictorClass)
        net.WriteString(AttackerClass)

    net.Broadcast()

end
