SWEP.Base = "weapon_gwbase"
SWEP.Name = "Graviton Surge"

-- Zarya Main 4 life

function SWEP:Ability()

    local ply = self.Owner

    local trace = ply:GetEyeTrace()

    if !trace.Hit then return end

    local hitPos = trace.HitPos + Vector(0, 0, 50)

    if CLIENT then
        local dlight = DynamicLight( self:EntIndex() )
        if dlight then
            local col = Color(255, 100 , 200)
            dlight.pos = hitPos
            dlight.r = col.r
            dlight.g = col.g
            dlight.b = col.b
            dlight.brightness = 2
            dlight.Size = 128
            dlight.style = 2
            dlight.DieTime = CurTime() + 6
        end

        return
    end


    local pull = ents.Create( "gw_ability_wall" )
    if ( !IsValid( pull ) ) then return end
    pull:SetPos( hitPos )
    pull:Spawn()
    pull:Activate()

    local tesla = ents.Create("point_tesla")

    if !IsValid( tesla ) then return end
    tesla:SetPos( hitPos )

    tesla:SetKeyValue("m_Color", "255 100 200")
    tesla:SetKeyValue("m_flRadius", "50")
    tesla:SetKeyValue("interval_min", "0.1")
    tesla:SetKeyValue("interval_max", "0.3")
    tesla:SetKeyValue("beamcount_min", "20")
    tesla:SetKeyValue("beamcount_max", "40")
    tesla:SetKeyValue("thick_min", "5")
    tesla:SetKeyValue("thick_max", "15")
    tesla:SetKeyValue("lifetime_min", "0.3")
    tesla:SetKeyValue("lifetime_max", "1")

    tesla:Spawn()
    tesla:Activate()

    tesla:Fire("TurnOn", "", 0)

    SafeRemoveEntityDelayed( tesla, 5 )
    SafeRemoveEntityDelayed( pull, 5)

end
