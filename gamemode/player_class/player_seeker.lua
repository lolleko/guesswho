DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 300
PLAYER.JumpPower			= 200
PLAYER.CanUseFlashlight		= true

function PLAYER:SetModel()
	util.PrecacheModel( "models/player/combine_super_soldier.mdl" )
	self.Player:SetModel("models/player/combine_super_soldier.mdl" )
end

function PLAYER:Loadout()
	self.Player:Give( "weapon_smg1" )
	self.Player:GiveAmmo( 1000, "smg1", true )
	self.Player:GiveAmmo( 1, "smg1_grenade", true )
end


player_manager.RegisterClass( "player_seeker", PLAYER, "player_default" )