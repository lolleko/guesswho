GM.GWConfig = {}
GM.GWConfigStatic = {}

GM.GWConfig.Version = GM.Version

-- define default config
GM.GWConfig.HidingModels = {
    --Characters
    "models/player/alyx.mdl",
    "models/player/breen.mdl",
    "models/player/barney.mdl",
    "models/player/eli.mdl",
    "models/player/gman_high.mdl",
    "models/player/kleiner.mdl",
    "models/player/monk.mdl",
    "models/player/odessa.mdl",
    "models/player/magnusson.mdl",
    "models/player/p2_chell.mdl",
    "models/player/mossman_arctic.mdl",
    --medics
    --rebels
    --Citiziens
}



GM.GWConfig.SeekerModels = {
    "models/player/combine_super_soldier.mdl"
}

GM.GWConfig.ActiveAbilities = {
    "weapon_gw_prophunt",
    "weapon_gw_surge",
    "weapon_gw_shockwave",
    "weapon_gw_cloak",
    "weapon_gw_shrink",
    "weapon_gw_decoy",
    "weapon_gw_sudoku",
    "weapon_gw_disguise",
    "weapon_gw_vampirism",
    "weapon_gw_ragdoll",
    "weapon_gw_superhot",
    "weapon_gw_blasting_off",
    "weapon_gw_teleport",
    "weapon_gw_deflect",
    "weapon_gw_timelapse",
    "weapon_gw_solarflare",
    "weapon_gw_mind_transfer",
    "weapon_gw_tumble"
}

GM.GWConfigStatic.AllAbilities = {
    "weapon_gw_prophunt",
    "weapon_gw_surge",
    "weapon_gw_shockwave",
    "weapon_gw_cloak",
    "weapon_gw_shrink",
    "weapon_gw_decoy",
    "weapon_gw_sudoku",
    "weapon_gw_disguise",
    "weapon_gw_vampirism",
    "weapon_gw_ragdoll",
    "weapon_gw_superhot",
    "weapon_gw_blasting_off",
    "weapon_gw_teleport",
    "weapon_gw_deflect",
    "weapon_gw_timelapse",
    "weapon_gw_solarflare",
    "weapon_gw_mind_transfer",
    "weapon_gw_tumble"
}

GM.GWConfig.TeamSeekingColor = Color(155, 143, 48)
GM.GWConfig.TeamHidingColor = Color(48, 96, 155)

GM.GWConfig.WalkerColors = {
    Color(61, 87, 105), -- original blue
    Color(240, 240, 240), --Black/dark grey
    Color(50, 50, 50), -- white /lightgrey
    Color(139, 115, 85), --Brown
    Color(241, 169, 101), --bright orange
    Color(75, 97, 34), --olive
    Color(157, 107, 0), --gold
    Color(159, 205, 234), --light blue
    Color(94, 25, 34) --dark red
}

GM.GWConfig.ServerName = "Official Guess Who Discord"
GM.GWConfig.ServerUrl = "https://discord.gg/3Pb6hcJ"

GM.GWConfig.News = "2.2 The Final Guess Who update has been released. Packing a lot of bug fixes and new content."

--load config from disk if exists
if SERVER then
    if file.Exists("guesswho/config.txt", "DATA") then
        local configData = util.JSONToTable(file.Read("guesswho/config.txt"))
        -- dont laod outdated configs
        if configData.Version and configData.Version == GM.Version then
            GM.GWConfig = configData
        else
            print("GW existing config is for a different version => regenerating config.")
        end
    end

    if not file.Exists("guesswho", "DATA") then
        file.CreateDir("guesswho")
    end

    file.Write("guesswho/config.txt", util.TableToJSON(GM.GWConfig))

    --send config to clients on connect
    local function sendConfig(ply)
        net.Start("gwSendConfig")
        net.WriteTable(GAMEMODE.GWConfig)
        net.Send(ply)
    end
    hook.Add("PlayerInitialSpawn", "gwInitialConfigSend", sendConfig)

    net.Receive("gwRequestUpdateConfig", function(len, ply)
        if not ply:IsSuperAdmin() then return end
        print("GW Server updating config!")
        local config = net.ReadTable()
        GAMEMODE.GWConfig = config
        file.Write("guesswho/config.txt", util.TableToJSON(GAMEMODE.GWConfig))

        net.Start("gwSendConfig")
        net.WriteTable(GAMEMODE.GWConfig)
        net.Broadcast(ply)
    end )
end

if CLIENT then
    net.Receive("gwSendConfig", function(len, ply)
        print("GW Client updating config!")

        local config = net.ReadTable()
        GAMEMODE.GWConfig = config
        team.SetColor(GW_TEAM_HIDING, GAMEMODE.GWConfig.TeamHidingColor)
        team.SetColor(GW_TEAM_SEEKING, GAMEMODE.GWConfig.TeamSeekingColor)
    end)
end
