AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Deflect"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

SWEP.AbilityDuration = 12

SWEP.AbilityDescription = "Deflects all damage taken to the attacker.\nLasts $AbilityDuration seconds and should probably be called Reflect instead of Deflect."


function SWEP:Ability()
    self:GetOwner():GWSetDeflecting(true)
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
end

hook.Add("EntityTakeDamage", "gw_deflect_damage", function(target, dmgInfo)
    local attacker = dmgInfo:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() and IsValid(target) and target:IsPlayer() and target:GWIsDeflecting() then
        target:SetMaterial("models/props_combine/portalball001_sheet")
        timer.Simple(0.15, function()
            if IsValid(target) then
                target:SetMaterial("")
            end
        end)
        if SERVER then
            attacker:TakeDamage(dmgInfo:GetDamage(), target, target:GetActiveWeapon())
        end
        return true
    end
end )

function SWEP:AbilityCleanup()
    if IsValid(self:GetOwner()) then
        self:GetOwner():GWSetDeflecting(false)
    end
end