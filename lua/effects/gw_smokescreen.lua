EFFECT.Mat = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}

function EFFECT:Init( data )
	local pos = data:GetEntity():GetPos() + Vector( 0, 0, 10 )

	local em = ParticleEmitter( pos )
		for i=0, 75 do
			local p = em:Add( table.Random( self.Mat ), pos )
			if p then
		        local gray = math.random(30, 70)
		        p:SetColor(gray, gray, gray)
		        p:SetStartAlpha(255)
		        p:SetEndAlpha(255)
		        p:SetVelocity(VectorRand() * math.Rand(2000, 2300))
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
		end
	em:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
	return false
end
