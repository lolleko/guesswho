AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Cloak"

SWEP.AbilityDuration = 7
SWEP.AbilityDescription = "Disappear almost completly for $AbilityDuration seconds."

function SWEP:Ability()
    local ply = self.Owner
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end )
    ply:SetRenderMode( RENDERMODE_TRANSALPHA )
    if SERVER then ply:Fire( "alpha", 4, 0 ) end
end

function SWEP:AbilityCleanup()
    if not IsValid( self.Owner ) then return end
    local ply = self.Owner
    ply:SetRenderMode( RENDERMODE_NORMAL )
    if SERVER then ply:Fire( "alpha", 255, 0 ) end
end
