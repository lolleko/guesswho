AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "PropOffset")
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    if IsValid(self:GetOwner()) and self:GetOwner():Alive() then
        self:SetPos(self:GetOwner():GetPos() + self:GetPropOffset())
    else
        if SERVER then
            self:Remove()
        end
    end
    self:NextThink(CurTime() + 0.05)
    return true
end
