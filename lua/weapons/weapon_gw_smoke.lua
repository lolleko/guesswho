SWEP.Base = "weapon_gwbase"
SWEP.Name = "Smokescreen"

function SWEP:Ability()
    if CLIENT and !game.SinglePlayer() then
        self:CreateSmoke( self.Owner:GetPos() + Vector( 0, 0, 10 ) )
    end
end

function SWEP:CreateSmoke(center)

   local smokeparticles = {
      Model("particle/particle_smokegrenade"),
      Model("particle/particle_noisesphere")
   };

  local em = ParticleEmitter(center)

  local r = 30
  for i=1, 200 do
     local prpos = VectorRand() * r
     local p = em:Add(table.Random(smokeparticles), center + prpos)
     if p then
        local gray = math.random(50, 100)
        p:SetColor(gray, gray, gray)
        p:SetStartAlpha(255)
        p:SetEndAlpha(255)
        p:SetVelocity(VectorRand() * math.Rand(800, 1000))
        p:SetLifeTime(0)

        p:SetDieTime(math.Rand(5, 10))

        p:SetStartSize(math.random(300, 350))
        p:SetEndSize(math.random(1, 20))
        p:SetRoll(math.random(-180, 180))
        p:SetRollDelta(math.Rand(-0.1, 0.1))
        p:SetAirResistance(100)

        p:SetCollide(true)
        p:SetBounce(0.3)

        p:SetLighting(false)
     end
  end

  em:Finish()
end
