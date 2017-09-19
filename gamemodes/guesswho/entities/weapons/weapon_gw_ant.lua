SWEP.Base = "weapon_gwbase"
SWEP.Name = "Touch The Ant"
SWEP.AbilitySound = "gwabilities/smb2_shrink.wav"

SWEP.AbilityDuration = 8

function SWEP:Ability()
	for _, ply in pairs( player.GetAll() ) do
		if ply:IsSeeking() then
			ply:SetNWFloat("gw_ability_ant_endtime", CurTime() + self.AbilityDuration)
			ply:SetRunSpeed( ply:GetRunSpeed() * 0.1 )
			ply:SetWalkSpeed( ply:GetWalkSpeed() * 0.1 )
			ply:SetModelScale( 0.1, 0.5 )

			local xy = math.Round(math.Max(ply:OBBMaxs().x - ply:OBBMins().x, ply:OBBMaxs().y - ply:OBBMins().y) / 2)
			local z = math.Round(ply:OBBMaxs().z - ply:OBBMins().z)

			ply:SetHull(Vector(-xy, - xy, 0), Vector(xy, xy, z))
			ply:SetHullDuck(Vector(-xy, - xy, 0), Vector(xy, xy, z))
			ply:SetViewOffset(Vector(0, 0, 64 * 0.1))

			if SERVER then
				net.Start( "gwPlayerHull" )
				net.WriteFloat( xy )
				net.WriteFloat( z )
				net.Send( ply )
			end
		end
	end
end

if SERVER then
	hook.Add("ShouldCollide", "gw_ability_ant_damage",
		function(ent1, ent2)
			local target
			local attacker
			if ent1:IsPlayer() and ent1:IsSeeking() and ent1:GetNWFloat("gw_ability_ant_endtime") > CurTime() then
				target = ent1
			end
			if ent2:IsPlayer() and ent2:IsSeeking() and ent2:GetNWFloat("gw_ability_ant_endtime") > CurTime() then
				target = ent2
			end
			if ent1:IsPlayer() and ent1:IsHiding() then
				attacker = ent1
			end
			if ent2:IsPlayer() and ent2:IsHiding() then
				attacker = ent1
			end
			if target and attacker then
				if target:GetPos().z + 10 <= attacker:GetPos().z and target:GetPos():Distance(attacker:GetPos()) < 30 then
					if target:GetNWFloat("gw_ability_ant_next_posible_damage", 0) <= CurTime() then
						target:TakeDamage(20, attacker, attacker)
						target:SetNWFloat("gw_ability_ant_next_posible_damage", CurTime() + 1)
					end
				end
			end
	end)
end

if SERVER then
	hook.Add("ScalePlayerDamage", "gw_ability_ant_damage_scale",
		function(ply, hitgroup, dmginfo)
			local attacker = dmginfo:GetAttacker()
			if IsValid(attacker) and attacker:IsPlayer() and attacker:IsSeeking() and attacker:GetNWFloat("gw_ability_ant_endtime") > CurTime() then
				dmginfo:SetScale(0.1)
			end
	end)
end

if SERVER then
	local function resetAntMode(ply)
		ply:SetRunSpeed(GetConVar("gw_seeker_run_speed"):GetFloat())
		ply:SetWalkSpeed(GetConVar("gw_seeker_walk_speed"):GetFloat())
		ply:SetModelScale( 1, 1 )
		ply:SetViewOffset(Vector(0, 0, 64))
	end
	hook.Add("PlayerPostThink", "gw_ability_ant_think",
		function(ply)
			if ply:GetNWFloat("gw_ability_ant_endtime") <= CurTime() then
				resetAntMode(ply)
			end
	end)

	hook.Add("PlayerDeath", "gw_ability_ant_death",
		function(ply)
			if ply:GetNWFloat("gw_ability_ant_endtime") > CurTime() then
				resetAntMode(ply)
			end
	end)
end
