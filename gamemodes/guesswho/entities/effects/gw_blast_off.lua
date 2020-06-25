function EFFECT:Init(data)
    self.Owner = data:GetEntity()
    self.Duration = data:GetMagnitude()
    self.FadeoutTime = 3
    self.EndTime = CurTime() + self.Duration + self.FadeoutTime
    self.Emitter = ParticleEmitter(self.Owner:GetPos())
end

function EFFECT:Think()
    if self.EndTime < CurTime() or not IsValid(self.Owner) then
        self.Emitter:Finish()
        return false
    end

    local vOffset = self.Owner:GetPos() + Vector(math.Rand(-6, 6), math.Rand(-6, 6), math.Rand(-6, 6))
    local vNormal = (vOffset - self.Owner:GetPos()):GetNormalized()

    local particle = self.Emitter:Add("particles/smokey", vOffset)
    if not particle then return end

    particle:SetVelocity(vNormal * math.Rand( 10, 30 ) + VectorRand() * 40)
    particle:SetDieTime(3.0)
    particle:SetStartAlpha(math.Rand(50, 150))
    particle:SetStartSize(math.Rand(48, 64 ))
    particle:SetEndSize(math.Rand(128, 312 ))
    particle:SetRoll(math.Rand(-0.2, 0.2 ))
    particle:SetColor(200, 200, 210)

    return true
end
