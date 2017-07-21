GM.GWConfig = {}

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
    "models/player/Group03m/Female_06.mdl",
    "models/player/Group03m/Male_01.mdl",
    --rebels
    "models/player/Group03/Female_06.mdl",
    "models/player/Group03/Male_06.mdl",
    --Citiziens
    "models/player/Group01/Male_08.mdl",
    "models/player/Group01/Female_03.mdl",
}

GM.GWConfig.SeekerModels = {
    "models/player/combine_super_soldier.mdl"
}

GM.GWConfig.Weapons = {
    "weapon_gw_prophunt",
    "weapon_gw_surge",
    "weapon_gw_shockwave",
    "weapon_gw_cloak",
    --"weapon_gw_smoke",
    "weapon_gw_shrink",
    "weapon_gw_decoy",
    "weapon_gw_sudoku",
    "weapon_gw_disguise",
    "weapon_gw_vampirism",
    "weapon_gw_ragdoll",
    "weapon_gw_superhot",
    "weapon_gw_dance_party",
    "weapon_gw_blasting_off",
    "weapon_gw_decoy2",
    "weapon_gw_teleport",
    "weapon_gw_deflect"
}

GM.GWConfig.TeamSeekingColor = Color(138, 155, 15)
GM.GWConfig.TeamHidingColor = Color(23, 89, 150)

GM.GWConfig.WalkerColors = {
    Color(61, 87, 105), -- original blue
    Color(240, 240, 240), --Black/dark grey
    Color(50, 50, 50), -- white /lightgrey
    Color(139, 115, 85), --Brown
    Color(241, 169, 101), --bright orange
    Color(75, 97, 34), --olive
    Color(157, 107, 0), --gold
    Color(159, 205, 234 ), --light blue
    Color(94, 25, 34) --dark red
}

--load config from disk if exists
if file.Exists("guesswho/config.txt", "DATA") then
    GM.GWConfig = util.JSONToTable(file.Read("guesswho/config.txt"))
end

file.Write("guesswho/config.txt", util.TableToJSON(GM.GWConfig))

PrintTable(GM.GWConfig)
--send config to clients on connect
