AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Vampirism"
SWEP.AbilitySound = "HealthKit.Touch"

SWEP.AbilityRange = 500
SWEP.AbilityDuration = 3.5
SWEP.AbilityShowTargetHalos = false

function SWEP:Ability()
    if CLIENT then return end

    for _,v in pairs( player.GetAll() ) do
        if v:Alive() and v:GetPos():Distance( self.Owner:GetPos() ) < self.AbilityRange and v:IsSeeking() then

            v:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")

            local effectdata = EffectData()
            effectdata:SetEntity( self.Owner )
            effectdata:SetOrigin(v:GetPos() + v:OBBCenter() + Vector(0, 0, 10))
            effectdata:SetRadius( 10 )
            util.Effect("gw_vampirism", effectdata, true, true)

            local dmg =  v:Health() / 3
            v:TakeDamage(dmg, self.Owner, self)

            self.Owner:SetRunSpeed(self.Owner:GetRunSpeed() * 2)
            self.Owner:SetWalkSpeed(self.Owner:GetWalkSpeed() * 2)

            self:AbilityTimerIfValidPlayerAndAlive(0.25, 4, true, function()
                self.Owner:SetHealth(self.Owner:Health() + dmg / 4)
			end
		)
        end
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
