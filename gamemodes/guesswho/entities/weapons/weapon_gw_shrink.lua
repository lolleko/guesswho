AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Shrink"
SWEP.AbilitySound = "gwabilities/smb2_shrink.wav"
SWEP.AbilityDuration = 7
SWEP.AbilityDamagePercentageString = "60%"
SWEP.AbilityDamageSpeedBonusString = "twice"

SWEP.AbilityDescription = "Shrinks you and your health by $AbilityDamagePercentageString for $AbilityDuration seconds.\n\nFor some reason you are also $AbilityDamageSpeedBonusString as fast while shrunk."

function SWEP:Ability()
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end )
    self.Owner:SetRunSpeed(self.Owner:GetRunSpeed() * 1.75)
    self.Owner:SetWalkSpeed(self.Owner:GetWalkSpeed() * 1.75)
    self.Owner:SetModelScale(self.Owner:GetModelScale() / 2.5, 1)
    self.Owner:SetHealth(self.Owner:Health() / 2.5)
end

function SWEP:AbilityCleanup()
    if not IsValid(self.Owner) then return end
    self.Owner:SetRunSpeed(GetConVar("gw_hiding_run_speed"):GetFloat())
    self.Owner:SetWalkSpeed(GetConVar("gw_hiding_walk_speed"):GetFloat())
    self.Owner:SetModelScale(1, 1)
end
