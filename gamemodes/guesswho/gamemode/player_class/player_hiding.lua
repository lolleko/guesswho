DEFINE_BASECLASS( "player_default" )

local PLAYER = {}

PLAYER.WalkSpeed            = 100
PLAYER.RunSpeed             = 230
PLAYER.JumpPower            = 200
PLAYER.CanUseFlashlight     = false

function PLAYER:SetModel()

    local models = GAMEMODE.Models

    local rand = math.random(1,#models)

    util.PrecacheModel( models[rand] )
    self.Player:SetModel( models[rand] )

end

function PLAYER:Loadout()
    if GetConVar( "gw_abilities_enabled" ):GetBool() then
        self.Player:Give( GAMEMODE.Weapons[ math.random( 1, #GAMEMODE.Weapons ) ] )
    else
        self.Player:Give( "weapon_gw_default" )
    end
end

function PLAYER:ShouldDrawLocal() return true end

function PLAYER:Spawn()
    local clr = GAMEMODE.WalkerColors[math.random(1,#GAMEMODE.WalkerColors)]
    self.Player:SetPlayerColor(Vector(clr.r / 255, clr.g / 255, clr.b / 255))
end


player_manager.RegisterClass( "player_hiding", PLAYER, "player_default" )
