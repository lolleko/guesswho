EFFECT.Mat = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Entity = data:GetEntity()

	self.Life = 0

end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )

	self.Life = self.Life + FrameTime() * 2.5

	if !IsValid( self.Entity ) then return false end

	local em = ParticleEmitter( self.Entity:GetPos() + Vector( 0, 0, 10 ) )

	local p = em:Add( table.Random( self.Mat ), self.Entity:GetPos() + Vector( 0, 0, 10 ) )
	if p then
        local gray = math.random(30, 70)
        p:SetColor(gray, gray, gray)
        p:SetStartAlpha(255)
        p:SetEndAlpha(255)
        p:SetVelocity(VectorRand() * math.Rand(800, 1000))
        p:SetLifeTime(0)

        p:SetDieTime(math.Rand(9, 15))

        p:SetStartSize(math.random(250, 350))
        p:SetEndSize(math.random(1, 20))
        p:SetRoll(math.random(-180, 180))
        p:SetRollDelta(math.Rand(-0.1, 0.1))
        p:SetAirResistance(100)

        p:SetCollide(true)
        p:SetBounce(0.4)

        p:SetLighting(false)
	end

	em:Finish()

	return ( self.Life < 10 )

end
