SWEP.Base = "weapon_gwbase"
SWEP.Name = "Deflect"

function SWEP:Ability()
	local ply = self.Owner

	ply:SetDeflect(true)
	timer.Simple(3, function() ply:SetDeflect(false) end)
end

hook.Add("EntityTakeDamage", "gw_deflect_damage", function(target, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and IsValid(target) and target:IsPlayer() and target:GetDeflect() then
		attacker:TakeDamage(dmgInfo:GetDamage(), target, target:GetActiveWeapon())
		return true
	end
end )
