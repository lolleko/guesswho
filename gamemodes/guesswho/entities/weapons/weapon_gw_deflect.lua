SWEP.Base = "weapon_gwbase"
SWEP.Name = "Deflect"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

function SWEP:Ability()
	local ply = self.Owner

	ply:SetDeflect(true)
	timer.Simple(5, function() ply:SetDeflect(false) end)
end

hook.Add("ScalePlayerDamage", "gw_deflect_damage", function(target, hitgroup, dmgInfo)
	local attacker = dmgInfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and IsValid(target) and target:IsPlayer() and target:GetDeflect() then
		target:SetMaterial("models/props_combine/portalball001_sheet")
		timer.Simple(0.1, function() target:SetMaterial("") end)
		attacker:TakeDamage(dmgInfo:GetDamage(), target, target:GetActiveWeapon())
		return true
	end
end )
