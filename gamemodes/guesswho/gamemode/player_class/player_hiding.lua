AddCSLuaFile()

DEFINE_BASECLASS( "player_guess_who" )

local PLAYER = {}

PLAYER.WalkSpeed = GetConVar("gw_hiding_walk_speed"):GetFloat()
PLAYER.RunSpeed = GetConVar("gw_hiding_run_speed"):GetFloat()
PLAYER.JumpPower = 200
PLAYER.CanUseFlashlight = false

function PLAYER:SetModel()

    local models = GAMEMODE.GWConfig.HidingModels

    local rand = math.random(1, #models)

    util.PrecacheModel( models[rand] )
    self.Player:SetModel( models[rand] )

end

function PLAYER:Loadout()
    if GetConVar( "gw_abilities_enabled" ):GetBool() then
        if self.Player:GetGWDiedInPrep() then
            self.Player:Give(self.Player:GetGWPrepAbility())
        else
            self.Player:Give( GAMEMODE.GWConfig.ActiveAbilities[ math.random( 1, #GAMEMODE.GWConfig.ActiveAbilities ) ] )
        end
    else
        self.Player:Give( "weapon_gw_default" )
    end
end

function PLAYER:ShouldDrawLocal() return true end

function PLAYER:Spawn()
    local clr = GAMEMODE.GWConfig.WalkerColors[math.random(1, #GAMEMODE.GWConfig.WalkerColors)]
    self.Player:SetPlayerColor(Vector(clr.r / 255, clr.g / 255, clr.b / 255))
    self.Player:SetCustomCollisionCheck(true)
end


player_manager.RegisterClass( "player_hiding", PLAYER, "player_guess_who" )
