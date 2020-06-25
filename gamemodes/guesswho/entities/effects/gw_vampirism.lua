AddCSLuaFile()

EFFECT.Mat = Material( "sprites/physbeama" )

function EFFECT:Init( data )

    self.Entity = data:GetEntity()
    self:SetPos( self.Entity:GetPos() )
    self.TargetPos = data:GetOrigin()

    self.EndTime = CurTime() + 2
end

function EFFECT:GenerateArc(startPos, endPos, branchChance, detail)
    -- MidPoint Displacement for arc lines
    local points = {}
    local maxPoints = 2^detail

    if maxPoints % 2 ~= 0 then
        maxPoints = maxPoints + 1
    end

    points[0] = startPos

    local randVec = VectorRand() * 10

    randVec.z = math.Clamp(randVec.z, 0, 10)

    points[maxPoints] = endPos + randVec

    local i = 1

    while i < maxPoints do
        local j = (maxPoints / i) / 2
        while j < maxPoints do
            points[j] = ((points[j - (maxPoints / i) / 2] + points[j + (maxPoints / i) / 2]) / 2);
            points[j] = points[j] + VectorRand() * 5
            if math.Rand(0,1) < branchChance then
                points[#points + 1] = self:GenerateArc(points[j], points[j] + VectorRand() * 5, branchChance / 1.3, detail)
            end
            j = j + maxPoints / i
        end
        i = i * 2
    end

    points.size = math.random(10,30)
    points.color = Color(math.random(50, 100), math.random(230, 255), math.random(50, 100))

    return points
end

function EFFECT:Think()

    self:SetPos( self.Entity:GetPos() + self.Entity:OBBCenter() + Vector(0, 0, 10) )

    return ( CurTime() < self.EndTime )

end

function EFFECT:Render()

    render.SetMaterial( self.Mat )

    local function renderArc(arc)
        for j = 1, #arc - 1 do
            if istable(arc[j]) then
                renderArc(arc[j])
            elseif not istable(arc[j + 1]) then

                local texcoord = math.Rand( 0, 1 )

                local startPos = arc[j]
                local endPos = arc[j + 1]

                render.DrawBeam(
                    startPos,
                    endPos,
                    arc.size,
                    texcoord,
                    texcoord + ((startPos - endPos):Length() / 128),
                    arc.color
                )
            end
        end
    end

    renderArc(self:GenerateArc(self:GetPos(), self.TargetPos, 0.05, 4))
end
