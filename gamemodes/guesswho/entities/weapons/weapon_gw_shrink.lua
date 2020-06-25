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
    self:GetOwner():SetRunSpeed(self:GetOwner():GetRunSpeed() * 1.75)
    self:GetOwner():SetWalkSpeed(self:GetOwner():GetWalkSpeed() * 1.75)
    self:GetOwner():SetModelScale(self:GetOwner():GetModelScale() / 2.5, 1)
    self:GetOwner():SetHealth(self:GetOwner():Health() / 2.5)
end

function SWEP:AbilityCleanup()
    if not IsValid(self:GetOwner()) then return end
    self:GetOwner():SetRunSpeed(GetConVar("gw_hiding_run_speed"):GetFloat())
    self:GetOwner():SetWalkSpeed(GetConVar("gw_hiding_walk_speed"):GetFloat())
    self:GetOwner():SetModelScale(1, 1)
end
