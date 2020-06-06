AddCSLuaFile()

DEFINE_BASECLASS( "player_guess_who" )

local PLAYER = {}

PLAYER.WalkSpeed = GetConVar("gw_seeker_walk_speed"):GetFloat()
PLAYER.RunSpeed = GetConVar("gw_seeker_run_speed"):GetFloat()
PLAYER.JumpPower = 250
PLAYER.CanUseFlashlight = true

function PLAYER:SetModel()

    local model = GAMEMODE.SeekerModel

    if GetConVar( "gw_disguise_seeker" ):GetBool() then
        local models = GAMEMODE.GWConfig.HidingModels

        local rand = math.random(1, #models)

        model = models[rand]
    else

        model = GAMEMODE.GWConfig.SeekerModels[ math.random( 1, #GAMEMODE.GWConfig.SeekerModels ) ]

    end

    util.PrecacheModel( model )
    self.Player:SetModel( model )
end

function PLAYER:Loadout()
    self.Player:Give( "weapon_gw_seeker_crowbar" )
    self.Player:Give( "weapon_smg1" )
    self.Player:GiveAmmo( 200, "smg1", true )
    self.Player:GiveAmmo( 1, "smg1_grenade", true )
end

player_manager.RegisterClass( "player_seeker", PLAYER, "player_guess_who" )
