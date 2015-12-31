SWEP.Base = "weapon_gwbase"
SWEP.Name = "Shockwave"

function SWEP:Ability()

    local ply = self.Owner
    local stunDur = 3.5

    local effectdata = EffectData()
    effectdata:SetEntity( ply )
    effectdata:SetRadius( 10 )

    util.Effect( "gw_shockwave", effectdata, true, true )
    for _,v in pairs( player.GetAll() ) do
        if v:GetPos():Distance( ply:GetPos() ) < 300 and v:Team() == TEAM_SEEKING then
            local effect = EffectData()
            effect:SetEntity( v )
            effect:SetMagnitude( stunDur )
            util.Effect( "gw_stunned", effect, true, true )
            if SERVER then v:ApplyStun( stunDur ) end
        end
    end
end
