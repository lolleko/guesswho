SWEP.Base = "weapon_gwbase"
SWEP.Name = "Vampirism"

function SWEP:Ability()

	if CLIENT then return end

	local ply = self.Owner

	local trace = ply:GetEyeTrace()

	if !trace.Hit then return end

	local hitEnt = trace.Entity
	local hitPos = trace.HitPos

	if IsValid(hitEnt) and hitEnt:IsPlayer() and hitEnt:IsSeeking() then
		if hitPos:Distance(ply:GetPos()) < 50 then
			local dmg =  hitEnt:Health() / 3
			hitEnt:TakeDamage(dmg, ply, self)
			ply:SetHealth(ply:Health() + dmg)
		else
			ply:ChatPrint("Target not close enough!")
			self:GiveSecondaryAmmo(1)
		end
	else
		ply:ChatPrint("Please target a seeker!")
		self:GiveSecondaryAmmo(1)
	end
end
