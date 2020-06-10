AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Shockwave"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

SWEP.AbilityRange = 300
SWEP.AbilityShowTargetHalos = true

function SWEP:Ability()

    local ply = self.Owner
    local stunDur = 4

    local effectdata = EffectData()
    effectdata:SetEntity( ply )
    effectdata:SetRadius( self.AbilityRange )

    util.Effect( "gw_shockwave", effectdata, true, true )
    for _,v in pairs( player.GetAll() ) do
        if v:GetPos():Distance( ply:GetPos() ) < self.AbilityRange and v:IsSeeking() then
            local effect = EffectData()
            effect:SetEntity( v )
            effect:SetMagnitude( stunDur )
            util.Effect( "gw_stunned", effect, true, true )
            if SERVER then v:ApplyStun( stunDur ) end
        end
    end
end
