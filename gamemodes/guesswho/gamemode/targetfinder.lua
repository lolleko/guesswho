function GM:TargetFinderThink()
	for _, ply in pairs(player.GetAll()) do
		if ply:IsSeeking() then
			local minDist = -1
			for _, target in pairs( team.GetPlayers(TEAM_HIDING) ) do
				local dist = ply:GetPos():Distance(target:GetPos())
				if minDist == -1 or dist < minDist then
					minDist = dist

					-- if target is to close dont show actual distance jsut show "close" clientside
					if dist < GetConVar( "gw_target_finder_threshold" ):GetInt() then
						minDist = 0
					end
				end
			end
			ply:SetNWFloat("gwClosestTargetDistance", minDist)
		end
	end
end

function GM:ShouldCollide(ent1, ent2)

	if GetConVar( "gw_abilities_enabled" ):GetBool() and GetConVar("gw_touches_enabled"):GetBool() then
		local hider
		local seeker
	    if ent1:IsPlayer() and ent2:IsPlayer() then
			if ent1:IsHiding() then
				hider = ent1
				seeker = ent2
			elseif ent1:IsSeeking() then
				hider = ent2
				seeker = ent1
			end

			if hider and seeker then
				hider:AddSeekerTouch()

				if hider:GetSeekerTouches() >= GetConVar("gw_touches_required"):GetInt() then
					hider:ChatPrint("You received a new ability.")
					hider:ResetSeekerTouches()
				else
					hider:ChatPrint("Touch " .. hider:GetSeekerTouches() - GetConVar("gw_touches_required"):GetInt() .. " more seekers to recieve a new ability.")
				end
			end
		end
	end

	return true
end
