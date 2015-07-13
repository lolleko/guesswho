DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed 			= 100
PLAYER.RunSpeed				= 200
PLAYER.JumpPower			= 200
PLAYER.CanUseFlashlight		= false

function PLAYER:SetModel()
	--TODO RANDOM MODEL
	util.PrecacheModel( "models/Humans/Group01/female_02.mdl" )
	self.Player:SetModel("models/Humans/Group01/female_02.mdl" )
end

function PLAYER:Loadout()

end

function PLAYER:ShouldDrawLocal() return true end


player_manager.RegisterClass( "player_hiding", PLAYER, "player_default" )