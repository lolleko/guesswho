SWEP.Base = "weapon_gwbase"
SWEP.Name = "Shrink"

function SWEP:Ability()
    timer.Create( "Ability.Effect." .. self.Owner:SteamID(), 7, 1, function() self:OnRemove() end )
    self.Owner:SetRunSpeed( self.Owner:GetRunSpeed() * 2 )
    self.Owner:SetWalkSpeed( self.Owner:GetWalkSpeed() * 2 )
    self.Owner:SetModelScale( self.Owner:GetModelScale() / 2.5, 1 )
    self.Owner:SetHealth( self.Owner:Health() / 2.5 )
end

function SWEP:OnRemove()
    if !IsValid( self.Owner ) then return end
    timer.Remove( "Ability.Effect." .. self.Owner:SteamID() )
    self.Owner:SetRunSpeed( 200 )
    self.Owner:SetWalkSpeed( 100 )
    self.Owner:SetModelScale( 1, 1 )
end
