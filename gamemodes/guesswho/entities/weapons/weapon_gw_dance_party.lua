SWEP.Base = "weapon_gwbase"
SWEP.Name = "Dance Party"
SWEP.AbilitySound = {"vo/coast/odessa/female01/nlo_cheer01.wav", "vo/coast/odessa/female01/nlo_cheer02.wav", "vo/coast/odessa/female01/nlo_cheer03.wav"}


function SWEP:Ability()
	local ply = self.Owner

	for _, ent in pairs( ents.FindInSphere(ply:GetPos(), 600) ) do
		local effect = EffectData()
		effect:SetStart(ent:GetPos())
		effect:SetOrigin(ent:GetPos())
		effect:SetNormal(ent:GetAngles():Up())
		util.Effect("ManhackSparks", effect, true, true)

		local effect2 = EffectData()
		effect2:SetOrigin(ent:GetPos())
		util.Effect("cball_explode", effect2)
		if SERVER and ent:GetClass() == "npc_walker" then
			timer.Simple(math.random(0.1, 0.7), function() ent:Dance() end)
		end

		if ent:IsPlayer() and ent:IsSeeking() then
			ent:ConCommand("act cheer")
			ent:ApplyStun(2)
		end
	end
end
