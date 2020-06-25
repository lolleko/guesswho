AddCSLuaFile()

EFFECT.Mat = Material( "sprites/physbeama" )

function EFFECT:Init( data )
    self.Caster = data:GetEntity()
    self.TargetPos = data:GetOrigin()
    self.Duration = data:GetMagnitude()

    self.EndTime = CurTime() + self.Duration
end

function EFFECT:Think()
    return (CurTime() < self.EndTime)
end

function EFFECT:Render()
    render.SetMaterial(self.Mat)

    local startPos = self.Caster:GetPos() + self.Caster:OBBCenter() + Vector(0, 0, 10)
    local endPos = self.TargetPos + Vector(0, 0, 5)
    local texcoord = math.Rand( 0, 1 )

    render.DrawBeam(
        startPos,
        endPos,
        30,
        texcoord,
        texcoord + ((startPos - endPos):Length() / 128),
        team.GetColor(GW_TEAM_HIDING)
    )
end
