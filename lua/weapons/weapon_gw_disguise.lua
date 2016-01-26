SWEP.Base = "weapon_gwbase"
SWEP.Name = "Disguise"

function SWEP:Ability()
    local ply = self.Owner
    timer.Create( "Ability.Effect." .. ply:SteamID(), 15, 1, function() self:OnRemove() end )
    if SERVER then
        ply:SetModel( GAMEMODE.SeekerModels[ math.random( 1, #GAMEMODE.SeekerModels ) ] )
        ply:Give( "weapon_gw_smgdummy" )
        ply:SelectWeapon( "weapon_gw_smgdummy" )
    end
end

function SWEP:OnRemove()
    if !IsValid( self.Owner ) then return end
    local ply = self.Owner
    timer.Remove( "Ability.Effect." .. ply:SteamID() )
    if SERVER then
        ply:StripWeapon( "weapon_gw_smgdummy" )
        ply:SetModel( GAMEMODE.Models[ math.random( 1, #GAMEMODE.Models ) ] )
    end
end
