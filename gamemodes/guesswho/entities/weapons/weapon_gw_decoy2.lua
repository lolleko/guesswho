SWEP.Base = "weapon_gwbase"
SWEP.Name = "Decoy 2.0"

function SWEP:Ability()
	if SERVER then
		local walker = ents.Create("npc_walker")
		if !IsValid( walker ) then return end
		walker:SetPos( self.Owner:GetEyeTrace().HitPos )
		walker:Spawn()
		walker:Activate()
		timer.Simple(math.random(0.1, 1), function() walker:Dance() end)
	end
end
