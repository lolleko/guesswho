SWEP.Base = "weapon_gwbase"
SWEP.Name = "Barricade"

function SWEP:Ability()

    if CLIENT then return end

    local trace = self.Owner:GetEyeTrace()

    if !trace.Hit then return end

    local models = {
        "models/props_c17/furnituretoilet001a.mdl",
        "models/props_c17/furniturefridge001a.mdl",
        "models/props_c17/canister02a.mdl",
        "models/props_wasteland/controlroom_filecabinet002a.mdl",
        "models/props_wasteland/laundry_cart002.mdl",
        "models/props_wasteland/buoy01.mdl",
        "models/props_interiors/vendingmachinesoda01a.mdl",
        "models/props_c17/oildrum001.mdl",
    }

    local model = models[ math.random( 1, #models ) ]

    local prop = ents.Create( "prop_physics" )
    if ( !IsValid( prop ) ) then return end
    prop:SetModel( model )
    local pos = trace.HitPos
    pos.z = pos.z + prop:OBBMaxs().z + 5
    prop:SetPos( pos )
    prop:Spawn()

    SafeRemoveEntityDelayed( prop, 30 )

end
