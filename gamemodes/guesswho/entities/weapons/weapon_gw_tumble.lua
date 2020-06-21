AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Tumble"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

SWEP.AbilityRange = 500
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityDuration = 3
SWEP.AbilityCastTime = 0.5

SWEP.AbilityDescription = "Looks like somebody forgot to tie their shoe laces.\n\nHurls all Seekers within $AbilityRange units forward."

function SWEP:Ability()
    local targets = self:GetSeekersInRange(self.AbilityRange, true)
    -- dont use ability if no target was found
    if #targets == 0 then
        return GW_ABILTY_CAST_ERROR_NO_TARGET
    end

    if not SERVER then return end

    for _, target in pairs(targets) do
        local effectdata = EffectData()
        effectdata:SetEntity(self.Owner)
        effectdata:SetOrigin(target:GetPos() + target:GetVelocity() / 2)
        effectdata:SetMagnitude(self.AbilityCastTime)
        util.Effect("gw_tumble", effectdata, true, true)

        timer.Simple(self.AbilityCastTime, function()
            if IsValid(target) and target:Alive() then
                target:GWStartRagdoll(Vector(0, 0, 50), 8)
            end
        end)

        timer.Simple(self.AbilityDuration, function()
            if IsValid(target) then
                target:GWEndRagdoll()
            end
        end)
    end

    return true
end
