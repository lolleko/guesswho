SWEP.Base = "weapon_gwbase"
SWEP.Name = "Cloak"

function SWEP:Ability()
    local ply = self.Owner
    timer.Create( "Ability.Effect." .. ply:SteamID(), 5, 1, function() self:OnRemove() end )
    ply:SetRenderMode( RENDERMODE_TRANSALPHA )
    ply:Fire( "alpha", 15, 0 )
end

function SWEP:OnRemove()
    if !IsValid( self.Owner ) then return end
    timer.Remove( "Ability.Effect." .. self.Owner:SteamID() )
    ply:SetRenderMode( RENDERMODE_NORMAL )
    ply:Fire( "alpha", 255, 0 )
end
