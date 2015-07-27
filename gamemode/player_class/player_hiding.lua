DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed 			= 100
PLAYER.RunSpeed				= 200
PLAYER.JumpPower			= 200
PLAYER.CanUseFlashlight		= false

function PLAYER:SetModel()

	local models = GAMEMODE.Models

	local rand = math.random(1,#models)

	util.PrecacheModel( "models/"..models[rand] )
	self.Player:SetModel( "models/"..models[rand] )

end

function PLAYER:Loadout()
	self.Player:Give( "weapon_destroy" )
end

function PLAYER:ShouldDrawLocal() return true end


player_manager.RegisterClass( "player_hiding", PLAYER, "player_default" )