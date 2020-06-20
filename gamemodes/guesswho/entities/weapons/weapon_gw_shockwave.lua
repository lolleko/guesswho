AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Shockwave"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

SWEP.AbilityRange = 300
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityDuration = 4
SWEP.AbilityCastTime = 0.5

SWEP.AbilityDescription = "Somehow you can emit a shockwave that stuns all seekers within $AbilityRange units for $AbilityDuration seconds."

function SWEP:Ability()
    local targets = self:GetSeekersInRange(self.AbilityRange, true)
    -- dont use ability if no target was found
    if #targets == 0 then
        return GW_ABILTY_CAST_ERROR_NO_TARGET
    end

    if not SERVER then return end
    
    local effectdata = EffectData()
    effectdata:SetEntity(self.Owner)
    effectdata:SetRadius(self.AbilityRange)
    effectdata:SetMagnitude(self.AbilityCastTime)
    util.Effect("gw_shockwave", effectdata, true, true)

    for _,v in pairs(targets) do    
        local distanceRatio = v:GetPos():Distance(self.Owner:GetPos()) / self.AbilityRange
        timer.Simple(distanceRatio * self.AbilityCastTime, function()
            local effect = EffectData()
            effect:SetEntity(v)
            effect:SetMagnitude(self.AbilityDuration)
            util.Effect("gw_stunned", effect, true, true)
            v:GWApplyStun(self.AbilityDuration)
        end)
    end
end
