AddCSLuaFile()

ENT.Base = "base_point"

function ENT:Initialize()

end

function ENT:Think()
	local radius = 500

	for _, target in pairs(ents.FindInSphere(self:GetPos(), radius)) do

		if target:IsSolid() && !target:GetMoveParent() && target:GetMoveType() == MOVETYPE_VPHYSICS or target:GetMoveType() == MOVETYPE_WALK or target:GetMoveType() == MOVETYPE_STEP then

			local pushDir
			if target.BodyTarget then
				pushDir = target:BodyTarget(self:GetPos() , false) - self:GetPos()
			else
				pushDir = target:GetPos() - self:GetPos()
			end
			local magnitude = -3

			if target:GetMoveType() == MOVETYPE_VPHYSICS then

				local phys = target:GetPhysicsObject();
				if IsValid(phys) then
					phys:ApplyForceCenter( magnitude * 100 * pushDir * phys:GetMass() * FrameTime() )
					return
				end

			else

				if target:GetMoveType() == MOVETYPE_STEP then
					pushDir.z = 0
				end

				local vecPush = magnitude * pushDir
				if bit.band(target:GetFlags(), FL_BASEVELOCITY) != 0 then
					vecPush = vecPush + target:GetBaseVelocity()
				end
				if ( vecPush.z > 0 && bit.band(target:GetFlags(), FL_ONGROUND) != 0 ) then
					target:SetGroundEntity( nil )
					local origin = target:GetPos()
					origin.z = origin.z + 1
					target:SetPos( origin )
				end
				target:SetVelocity( vecPush )
				target:TakeDamage( math.ceil(5 / pushDir:Length()), self, nil)

			end

		end
	end

	self:NextThink(CurTime() + 0.05)

end
