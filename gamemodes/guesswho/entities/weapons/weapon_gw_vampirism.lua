SWEP.Base = "weapon_gwbase"
SWEP.Name = "Vampirism"
SWEP.AbilitySound = "HealthKit.Touch"

function SWEP:Ability()

    if CLIENT then return end

    local ply = self.Owner

    for _,v in pairs( player.GetAll() ) do
        if v:Alive() and v:GetPos():Distance( ply:GetPos() ) < 350 and v:IsSeeking() then

            v:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav")

            local effectdata = EffectData()
            effectdata:SetEntity( ply )
            effectdata:SetOrigin(v:GetPos() + v:OBBCenter() + Vector(0, 0, 10))
            effectdata:SetRadius( 10 )

            util.Effect( "gw_vampirism", effectdata, true, true )

            local dmg =  v:Health() / 3
            v:TakeDamage(dmg, ply, self)
            timer.Create( "gw.vamp." .. ply:EntIndex() .. "." .. v:EntIndex(), 0.25, 4, function()
                if IsValid(ply) and ply:Alive() then
                    ply:SetHealth(ply:Health() + dmg / 4)
                end
            end)
        end
    end
end
