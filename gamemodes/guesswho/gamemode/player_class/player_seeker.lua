DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed            = 160
PLAYER.RunSpeed             = 260
PLAYER.JumpPower            = 200
PLAYER.CanUseFlashlight     = true

function PLAYER:SetModel()

    local model = GAMEMODE.SeekerModel

    if GetConVar( "gw_disguise_seeker" ):GetBool() then
          local models = GAMEMODE.Models

          local rand = math.random(1,#models)

          model = models[rand]
    else

      model = GAMEMODE.SeekerModels[ math.random( 1, #GAMEMODE.SeekerModels ) ]

    end

    util.PrecacheModel( model )
    self.Player:SetModel( model )

end

function PLAYER:Loadout()
    self.Player:Give( "weapon_smg1" )
    self.Player:GiveAmmo( 200, "smg1", true )
    self.Player:GiveAmmo( 1, "smg1_grenade", true )
    self.Player:Give( "weapon_357" )
    self.Player:GiveAmmo( 20, "357", true )
    self.Player:Give( "weapon_crowbar" )
end

player_manager.RegisterClass( "player_seeker", PLAYER, "player_default" )
