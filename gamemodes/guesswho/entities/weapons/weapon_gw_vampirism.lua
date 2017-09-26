SWEP.Base = "weapon_gwbase"
SWEP.Name = "Vampirism"
SWEP.AbilitySound = "HealthKit.Touch"

SWEP.AbilityRange = 500
SWEP.AbilityDuration = 3.5

function SWEP:Ability()

    if CLIENT then return end

    local ply = self.Owner

    for _,v in pairs( player.GetAll() ) do
        if v:Alive() and v:GetPos():Distance( ply:GetPos() ) < self.AbilityRange and v:IsSeeking() then

            v:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")

            local effectdata = EffectData()
            effectdata:SetEntity( ply )
            effectdata:SetOrigin(v:GetPos() + v:OBBCenter() + Vector(0, 0, 10))
            effectdata:SetRadius( 10 )

            util.Effect( "gw_vampirism", effectdata, true, true )

            local dmg =  v:Health() / 2.5
            v:TakeDamage(dmg, ply, self)

            self.Owner:SetRunSpeed(self.Owner:GetRunSpeed() * 2)
            self.Owner:SetWalkSpeed(self.Owner:GetWalkSpeed() * 2)

            timer.Create( "gw.vamp." .. ply:EntIndex() .. "." .. v:EntIndex(), 0.25, 4, function()
                if IsValid(ply) and ply:Alive() then
                    ply:SetHealth(ply:Health() + dmg / 4)
                end
            end)
        end
    end

    timer.Create( "Ability.Effect.Shrink" .. self.Owner:SteamID(), self.AbilityDuration, 1, function() self:OnRemove() end )
end

function SWEP:OnRemove()
  if not IsValid( self.Owner ) then return end
  self.Owner:SetRunSpeed(GetConVar("gw_hiding_run_speed"):GetFloat())
  self.Owner:SetWalkSpeed(GetConVar("gw_hiding_walk_speed"):GetFloat())
end
