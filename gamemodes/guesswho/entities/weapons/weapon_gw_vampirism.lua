AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Vampirism"
SWEP.AbilitySound = "HealthKit.Touch"

SWEP.AbilityRange = 500
SWEP.AbilityDuration = 5
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityShowTargetHalosCheckLOS = true
SWEP.AbilityDamagePercentageString = "third"
SWEP.AbilityDamageSpeedBonusString = "twice"

SWEP.AbilityDescription = "Steals energy from nearby seekers. Adding a $AbilityDamagePercentageString of their health to your own. Fueled by your victims energy you will also be able to run $AbilityDamageSpeedBonusString as fast for $AbilityDuration seconds.\n\nTargets all seekers that are within $AbilityRange units and line of sight."

function SWEP:Ability()

    if not GAMEMODE.GWRound:IsCurrentState(GW_ROUND_SEEK) then
        return GW_ABILTY_CAST_ERROR_INVALID_ROUND_STATE
    end

    local targets = self:GetSeekersInRange(self.AbilityRange)
    -- dont use ability if no target was found
    if #targets == 0 then
        return GW_ABILTY_CAST_ERROR_NO_TARGET
    end

    if CLIENT then return end

    for _,v in pairs(targets) do    
        v:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")

        local effectdata = EffectData()
        effectdata:SetEntity( self:GetOwner() )
        effectdata:SetOrigin(v:GetPos() + v:OBBCenter() + Vector(0, 0, 10))
        effectdata:SetRadius( 10 )
        util.Effect("gw_vampirism", effectdata, true, true)

        local dmg =  v:Health() / 3
        v:TakeDamage(dmg, self:GetOwner(), self)

        self:GetOwner():SetRunSpeed(self:GetOwner():GetRunSpeed() * 2)
        self:GetOwner():SetWalkSpeed(self:GetOwner():GetWalkSpeed() * 2)

        self:AbilityTimerIfValidOwnerAndAlive(0.5, 4, true, function()
            self:GetOwner():SetHealth(self:GetOwner():Health() + dmg / 4)
        end)
    end

    self:AbilityTimerIfValidSWEP(self.AbilityDuration, 1, true, function()
        self:AbilityCleanup()
    end)
end

function SWEP:AbilityCleanup()
  if not IsValid( self:GetOwner() ) then return end
  self:GetOwner():SetRunSpeed(GetConVar("gw_hiding_run_speed"):GetFloat())
  self:GetOwner():SetWalkSpeed(GetConVar("gw_hiding_walk_speed"):GetFloat())
end
