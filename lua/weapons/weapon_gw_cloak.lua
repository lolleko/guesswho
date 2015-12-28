SWEP.Base = "weapon_gwbase"
SWEP.Name = "Cloak"

function SWEP:Ability()
    local ply = self.Owner
    timer.Create( "Ability.Effect." .. ply:SteamID(), 7, 1, function() self:OnRemove() end )
    ply:SetRenderMode( RENDERMODE_TRANSALPHA )
    if SERVER then ply:Fire( "alpha", 10, 0 ) end
end

function SWEP:OnRemove()
    if !IsValid( self.Owner ) then return end
    local ply = self.Owner
    timer.Remove( "Ability.Effect." .. ply:SteamID() )
    ply:SetRenderMode( RENDERMODE_NORMAL )
    if SERVER then ply:Fire( "alpha", 255, 0 ) end
end
