AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Dance Party"
SWEP.AbilitySound = {"vo/coast/odessa/female01/nlo_cheer01.wav", "vo/coast/odessa/female01/nlo_cheer02.wav", "vo/coast/odessa/female01/nlo_cheer03.wav"}

SWEP.AbilityRange = 800
SWEP.AbilityShowTargetHalos = true

function SWEP:Ability()
	local ply = self.Owner

	for _, ent in pairs( ents.FindInSphere(ply:GetPos(), self.AbilityRange) ) do
		local effect = EffectData()
		effect:SetStart(ent:GetPos())
		effect:SetOrigin(ent:GetPos())
		effect:SetNormal(ent:GetAngles():Up())
		util.Effect("ManhackSparks", effect, true, true)

		local effect2 = EffectData()
		effect2:SetOrigin(ent:GetPos())
		util.Effect("cball_explode", effect2)
		if SERVER and ent:GetClass() == GW_WALKER_CLASS then
			timer.Simple(math.random(0.1, 0.4), function() ent:Dance() end)
		end

		if ent:IsPlayer() and ent:IsSeeking() then
			ent:ConCommand("act cheer")
			if SERVER then ent:ApplyStun(2.5) end
		end

		if ent:IsPlayer() and ent:IsHiding() then
			ent:ConCommand("act dance")
		end
	end
end
