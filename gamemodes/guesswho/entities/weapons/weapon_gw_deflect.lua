AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Deflect"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

SWEP.AbilityDuration = 12

SWEP.AbilityDescription = "Deflects all damage taken to the attacker.\nLasts $AbilityDuration seconds and should probably be called Reflect instead of Deflect."


function SWEP:Ability()
    self.Owner:SetDeflecting(true)
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
end

hook.Add("ScalePlayerDamage", "gw_deflect_damage", function(target, hitgroup, dmgInfo)
    local attacker = dmgInfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() and IsValid(target) and target:IsPlayer() and target:IsDeflecting() then
        target:SetMaterial("models/props_combine/portalball001_sheet")
        timer.Simple(0.1, function() target:SetMaterial("") end)
        attacker:TakeDamage(dmgInfo:GetDamage(), target, target:GetActiveWeapon())
        return true
    end
end )

function SWEP:AbilityCleanup()
    if IsValid(self.Owner) then
        self.Owner:SetDeflecting(false)
    end
end