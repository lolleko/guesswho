AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Disguise"

function SWEP:Ability()
    local ply = self.Owner
    timer.Create( "Ability.Effect.Disguise" .. ply:SteamID(), 25, 1, function() self:OnRemove() end )
    ply:SetDisguised(true)
    if SERVER then
        ply:SetModel( GAMEMODE.GWConfig.SeekerModels[ math.random( 1, #GAMEMODE.GWConfig.SeekerModels ) ] )
        ply:Give( "weapon_gw_smgdummy" )
        ply:SelectWeapon( "weapon_gw_smgdummy" )
    end
end

function SWEP:OnRemove()
    if !IsValid( self.Owner ) then return end
    local ply = self.Owner
    ply:SetDisguised(false)
    timer.Remove( "Ability.Effect.Disguise" .. ply:SteamID() )
    if SERVER then
        ply:StripWeapon( "weapon_gw_smgdummy" )
        ply:SetModel( GAMEMODE.GWConfig.HidingModels[ math.random( 1, #GAMEMODE.GWConfig.HidingModels ) ] )
    end
end
