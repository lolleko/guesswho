SWEP.Base = "weapon_gwbase"
SWEP.Name = "Wall"

function SWEP:Ability()

    if CLIENT then return end

    local ply = self.Owner

    local trace = ply:GetEyeTrace()

    if !trace.Hit then return end

    local hitPos = trace.HitPos

    local spawnBlock = function(pos)
        local prop = ents.Create( "prop_physics" )
        if ( !IsValid( prop ) ) then return end
        prop:SetModel( "models/props_interiors/vendingmachinesoda01a.mdl" )
        prop:SetPos( pos )
        prop:Spawn()
        prop:GetPhysicsObject():EnableMotion( false )

        local ang = self.Owner:EyeAngles()
        ang.r = 90
        ang.p = 0

        prop:SetAngles(ang)

        SafeRemoveEntityDelayed( prop, 5 )
    end

    spawnBlock(hitPos + ply:GetRight() * 47.5 + Vector(0, 0, 25))
    spawnBlock(hitPos + ply:GetRight() * 47.5 + Vector(0, 0, 77))
    spawnBlock(hitPos + ply:GetRight() * -47.5 + Vector(0, 0, 25))
    spawnBlock(hitPos + ply:GetRight() * -47.5 + Vector(0, 0, 77))

end
