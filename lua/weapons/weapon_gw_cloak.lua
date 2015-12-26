SWEP.Base = "weapon_gwbase"
SWEP.Name = "Cloak"

function SWEP:Ability()
    local ply = self.Owner
    timer.Create( "Ability.Effect." .. ply:SteamID(), 5, 1, function() self:OnRemove() end )
    ply:SetRenderMode(RENDERMODE_TRANSALPHA)
	ply:SetColor( Color(0, 0, 0, 15 ) )
end

function SWEP:OnRemove()
    if !IsValid( self.Owner ) then return end
    timer.Remove( "Ability.Effect." .. self.Owner:SteamID() )
    self.Owner:SetColor( Color(0, 0, 0, 255 ) )
end
