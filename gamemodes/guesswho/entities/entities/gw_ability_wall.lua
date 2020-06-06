AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Radius = 350

ENT.MaterialLight = Material("sprites/light_ignorez")
ENT.MaterialGlow = Material("models/effects/comball_glow1")

if CLIENT then
    function ENT:Draw()
        render.SetMaterial(self.MaterialGlow)
        render.DrawSprite( self:GetPos(), self.Radius / 2, self.Radius / 2, Color( 180, 150, 255, 255) )
        render.SetMaterial(self.MaterialLight)
        render.DrawSprite( self:GetPos(), self.Radius, self.Radius, Color( 200, 55, 150, 255) )

        if not self.dlight then
            local dlight = DynamicLight( self:EntIndex() )
            if dlight then
                local col = Color(255, 100 , 200)
                dlight.pos = self:GetPos()
                dlight.r = col.r
                dlight.g = col.g
                dlight.b = col.b
                dlight.brightness = 2
                dlight.Size = 128
                dlight.style = 2
                dlight.DieTime = CurTime() + 6
            end
            self.dlight = dlight
        end
    end
end

function ENT:Initialize()

    if SERVER then
        local tesla = ents.Create("point_tesla")

        if IsValid( tesla ) then
            tesla:SetPos( self:GetPos() )

            tesla:SetKeyValue("m_Color", "255 100 200")
            tesla:SetKeyValue("m_flRadius", tostring(self.Radius / 2))
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

            tesla:SetParent(self)
        end
    end
end

function ENT:Think()

    for _, target in pairs(ents.FindInSphere(self:GetPos(), self.Radius)) do

        if target:IsSolid() then

            local pushDir
            if target.BodyTarget then
                pushDir = target:BodyTarget(self:GetPos() , false) - self:GetPos()
            else
                pushDir = target:GetPos() - self:GetPos()
            end
            local magnitude = -5

            if target:GetMoveType() == MOVETYPE_VPHYSICS then

                local phys = target:GetPhysicsObject();
                if IsValid(phys) then
                    phys:ApplyForceCenter( magnitude * 100 * pushDir * phys:GetMass() * FrameTime() + (VectorRand() * 10) )
                end

            else

                if target:GetMoveType() == MOVETYPE_STEP then
                    pushDir.z = 0
                end

                local vecPush = magnitude * pushDir
                if bit.band(target:GetFlags(), FL_BASEVELOCITY) ~= 0 then
                    vecPush = vecPush + target:GetBaseVelocity()
                end
                if ( vecPush.z > 0 and bit.band(target:GetFlags(), FL_ONGROUND) ~= 0 ) then
                    target:SetGroundEntity( nil )
                    local origin = target:GetPos()
                    origin.z = origin.z + 1
                    target:SetPos( origin )
                end
                target:SetVelocity( vecPush )

                if SERVER then
                    target:TakeDamage( math.ceil(5 / pushDir:Length()), self, nil)
                end
            end

        end

    end

    self:NextThink(CurTime() + 0.02)

end
