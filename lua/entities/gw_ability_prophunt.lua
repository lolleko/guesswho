AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

if ( CLIENT ) then

	function ENT:Draw()
		self:DrawModel()
	end

end

function ENT:Think()
	if IsValid( self:GetOwner() ) and self:GetOwner():Alive() then
		self:SetPos(self:GetOwner():GetPos())
	else
		self:Remove()
	end
	self:NextThink(CurTime() + 0.05)
	return true
end
