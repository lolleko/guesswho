SWEP.Base = "weapon_gwbase"
SWEP.Name = "Smokescreen"

function SWEP:Ability()
    if not IsFirstTimePredicted() then return end
    local effectdata = EffectData()
    effectdata:SetEntity( self.Owner )
    util.Effect( "gw_smokescreen", effectdata, true, true )
end
