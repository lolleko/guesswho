AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Vampirism"
SWEP.AbilitySound = "HealthKit.Touch"

SWEP.AbilityRange = 500
SWEP.AbilityDuration = 5
SWEP.AbilityShowTargetHalos = true
SWEP.AbilityTargetHalosRequireLOS = true
SWEP.AbilityDamagePercentageString = "quarter"
SWEP.AbilityDamageSpeedBonusString = "twice"

SWEP.AbilityDescription = "\"Borrows\" energy from nearby seekers. Adding a $AbilityDamagePercentageString of their health to your own. Fueled by your victims energy you will also be able to run $AbilityDamageSpeedBonusString as fast for $AbilityDuration seconds.\nTargets all seekers that are within $AbilityRange units and line of sight."

function SWEP:Ability()
    if CLIENT then return end

    if not GWRound:IsCurrentState(GW_ROUND_SEEK) then
        return true
    end

    local validTargetFound = false

    for _,v in pairs( player.GetAll() ) do
        if v:Alive() and v:GetPos():Distance( self.Owner:GetPos() ) < self.AbilityRange and v:IsSeeking() then
            if self:AbilityIsTargetInLOS(v) then
                validTargetFound = true
            
                v:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")

                local effectdata = EffectData()
                effectdata:SetEntity( self.Owner )
                effectdata:SetOrigin(v:GetPos() + v:OBBCenter() + Vector(0, 0, 10))
                effectdata:SetRadius( 10 )
                util.Effect("gw_vampirism", effectdata, true, true)

                local dmg =  v:Health() / 4
                v:TakeDamage(dmg, self.Owner, self)

                self.Owner:SetRunSpeed(self.Owner:GetRunSpeed() * 2)
                self.Owner:SetWalkSpeed(self.Owner:GetWalkSpeed() * 2)

                self:AbilityTimerIfValidPlayerAndAlive(0.5, 4, true, function()
                    self.Owner:SetHealth(self.Owner:Health() + dmg / 4)
                end)
            end
        end
    end

    -- dont use ability if no target was found
    if not validTargetFound then
        return true
    end

    self:AbilityTimerIfValidSWEP(self.AbilityDuration, 1, true, function()
        self:AbilityCleanup()
    end)
end

function SWEP:AbilityCleanup()
  if not IsValid( self.Owner ) then return end
  self.Owner:SetRunSpeed(GetConVar("gw_hiding_run_speed"):GetFloat())
  self.Owner:SetWalkSpeed(GetConVar("gw_hiding_walk_speed"):GetFloat())
end
