SWEP.Base = "weapon_gwbase"
SWEP.Name = "Graviton Surge"

-- Zarya Main 4 life

function SWEP:Ability()

    local ply = self.Owner

    local trace = util.TraceLine( {
    	start = ply:EyePos(),
        endpos = ply:EyePos() + ply:GetAimVector() * 500,
        filter  = ply
    } )

    local hitPos
    if trace.Hit then
        hitPos = trace.HitPos + Vector(0, 0, 50)
    else
        hitPos = ply:EyePos() + ply:GetAimVector() * 500
    end

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

    SafeRemoveEntityDelayed( pull, 5)

end
