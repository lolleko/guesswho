SWEP.Base = "weapon_gwbase"
SWEP.Name = "Shockwave"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

function SWEP:Ability()

    local ply = self.Owner
    local stunDur = 3.5

    local effectdata = EffectData()
    effectdata:SetEntity( ply )
    effectdata:SetRadius( 10 )

    util.Effect( "gw_shockwave", effectdata, true, true )
    for _,v in pairs( player.GetAll() ) do
        if v:GetPos():Distance( ply:GetPos() ) < 300 and v:IsSeeking() then
            local effect = EffectData()
            effect:SetEntity( v )
            effect:SetMagnitude( stunDur )
            util.Effect( "gw_stunned", effect, true, true )
            v:ApplyStun( stunDur )
        end
    end
end
