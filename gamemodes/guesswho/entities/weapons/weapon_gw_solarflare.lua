SWEP.Base = "weapon_gwbase"
SWEP.Name = "Solarflare"
SWEP.AbilitySound = "ambient/energy/zap1.wav"

SWEP.AbilityRange = 400
SWEP.AbilityDuration = 7

function SWEP:Ability()

	local ply = self.Owner

	local effectdata = EffectData()
	effectdata:SetEntity( ply )
	effectdata:SetRadius( self.AbilityRange )

	util.Effect( "gw_solarflare", effectdata, true, true )
	for _, v in pairs( player.GetAll() ) do
		if v:GetPos():Distance( ply:GetPos() ) < self.AbilityRange and v:IsSeeking() then
			timer.Simple(0.25, function() if IsValid(v) then v:SetNWFloat("gw_ability_solarflare_endtime", CurTime() + self.AbilityDuration) end end)
		end
	end
end

function SWEP:DrawHUD()
	local ply = LocalPlayer()
	local endTime = ply:GetNWFloat("gw_ability_solarflare_endtime")
	if endTime > CurTime() then
		local alpha = 255
		local durationRemaining = endTime - CurTime()
		-- leniar fade out
		if durationRemaining <= self.AbilityDuration / 2 then
			alpha = durationRemaining * 110
		end
		surface.SetDrawColor(255, 255, 255, math.Clamp(alpha, 0, 255))
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end
end
