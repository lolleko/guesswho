SWEP.Base = "weapon_gwbase"
SWEP.Name = "Smokescreen"

function SWEP:Ability()
    local smoke = ents.Create( "smokescreen_particles")
    smoke:SetPos( self.Owner:GetPos() )
    smoke:Spawn()
    smoke:Activate()
end
