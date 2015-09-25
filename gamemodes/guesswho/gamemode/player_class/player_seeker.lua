DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed            = 200
PLAYER.RunSpeed             = 300
PLAYER.JumpPower            = 200
PLAYER.CanUseFlashlight     = true

function PLAYER:SetModel()
    util.PrecacheModel( "models/player/combine_super_soldier.mdl" )
    self.Player:SetModel("models/player/combine_super_soldier.mdl" )
end

function PLAYER:Loadout()
    self.Player:Give( "weapon_smg1" )
    self.Player:GiveAmmo( 200, "smg1", true )
    self.Player:GiveAmmo( 1, "smg1_grenade", true )
    self.Player:Give( "weapon_357" )
    self.Player:GiveAmmo( 20, "357", true )
    self.Player:Give( "weapon_crowbar" )
end

function PLAYER:GetHandsModel()

    return { model = "models/weapons/c_arms_combine.mdl", skin = 1, body = "0100000" }

end


player_manager.RegisterClass( "player_seeker", PLAYER, "player_default" )