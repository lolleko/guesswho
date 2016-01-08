AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

if ( CLIENT ) then

	function ENT:Draw()
		self:DrawModel()
	end

end

function ENT:Think()
	if IsValid(self:GetOwner()) then
		self:SetPos(self:GetOwner():GetPos())
	end
	self:NextThink(CurTime() + 0.05)
	return true
end
