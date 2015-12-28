
AddCSLuaFile()

ENT.Type = "anim"

function ENT:Initialize()
    SafeRemoveEntityDelayed( self, 10 )
    self:SetNoDraw( true )
    if CLIENT then self:CreateSmoke() end
end

if CLIENT then
    function ENT:CreateSmoke()

        local center = self:GetPos()

       local smokeparticles = {
          Model("particle/particle_smokegrenade"),
          Model("particle/particle_noisesphere")
       };

      local em = ParticleEmitter(center)

      local r = 30
      for i=1, 100 do
         local prpos = VectorRand() * r
         local p = em:Add(table.Random(smokeparticles), center + prpos)
         if p then
            local gray = math.random(30, 70)
            p:SetColor(gray, gray, gray)
            p:SetStartAlpha(255)
            p:SetEndAlpha(255)
            p:SetVelocity(VectorRand() * math.Rand(800, 1000))
            p:SetLifeTime(0)

            p:SetDieTime(math.Rand(8, 20))

            p:SetStartSize(math.random(250, 350))
            p:SetEndSize(math.random(1, 20))
            p:SetRoll(math.random(-180, 180))
            p:SetRollDelta(math.Rand(-0.1, 0.1))
            p:SetAirResistance(100)

            p:SetCollide(true)
            p:SetBounce(0.4)

            p:SetLighting(false)
         end
      end

      em:Finish()
    end

end
