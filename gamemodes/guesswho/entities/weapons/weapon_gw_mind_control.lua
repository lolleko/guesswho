SWEP.Base = "weapon_gwbase"
SWEP.Name = "Mind Control"

SWEP.DrawGWCrossHair = true
SWEP.AbilityDuration = 10

function SWEP:Ability()
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	local hitEnt = tr.Entity
	if IsValid(hitEnt) and hitEnt:GetClass() == "npc_walker" then
		if SERVER then
			local oldModel = ply:GetModel()
			local oldPos = ply:GetPos()
			local oldAngles = ply:GetAngles()
			local oldColor = hitEnt:GetPlayerColor()
			ply:SetModel(hitEnt:GetModel())
			ply:SetPos(hitEnt:GetPos())
			ply:SetAngles(hitEnt:GetAngles())
			hitEnt:Remove()
			local fake = ents.Create( "gw_mind_control_fake" )
			fake:Spawn()
			fake:Activate()
			fake:SetPos(oldPos)
			fake:SetAngles(oldAngles)
			fake:SetPlayer(ply)
			ply:SetPlayerColor(oldColor)
			timer.Simple(0.01, function()
				fake:SetModel(oldModel)
				fake:SetCollisionBounds( Vector(-8, - 8, 0), Vector(8, 8, 36) )
			end)
			self.remnant = fake
			hook.Add("ScalePlayerDamage", "gw_ability_mind_control_prevent_death" .. ply:SteamID(), function(pl, hitgroup, dmginfo)
				dmginfo:SetScale(0)
			end)
			timer.Create( "Ability.Effect.Mind.Control" .. ply:SteamID(), self.AbilityDuration, 1,
				function()
					if IsValid(self.remnant) then
						local effect = EffectData()
						effect:SetStart(ply:GetPos() + Vector(0, 0, 64))
						effect:SetOrigin(ply:GetPos() + Vector(0, 0, 64))
						effect:SetNormal(ply:GetAngles():Up())
						util.Effect("ManhackSparks", effect, true, true)

						local effect2 = EffectData()
						effect2:SetOrigin(ply:GetPos() + Vector(0, 0, 64))
						util.Effect("cball_explode", effect2)

						ply:SetPos(self.remnant:GetPos())
						ply:SetAngles(self.remnant:GetAngles())
						ply:SetPlayerColor(self.remnant:GetPlayerColor())

						local walker = ents.Create("npc_walker")
						if !IsValid( walker ) then return end
						walker:SetPos(self.remnant:GetPos())
						walker:SetModel(self.remnant:GetModel())
						walker:Spawn()
						walker:SetAngles(self.remnant:GetAngles())
						walker:Activate()
						self.remnant:Remove()
					end
			end)
		end
	else
		return true
	end
end

function SWEP:OnRemove()
	if SERVER then
		local ply = self.Owner
		timer.Remove( "Ability.Effect.Mind.Control" .. ply:SteamID() )
		hook.Remove("ScalePlayerDamage", "gw_ability_mind_control_prevent_death" .. ply:SteamID())
		if IsValid(self.remnant) then self.remnant:Remove() end
	end
end

function SWEP:DrawHUD()
	if self:Clip2() == 0 then self.DrawGWCrossHair = false return end
	local tr = LocalPlayer():GetEyeTrace()
	local hitEnt = tr.Entity
	if IsValid(hitEnt) and hitEnt:GetClass() == "npc_walker" then
		halo.Add( {hitEnt}, Color(255, 0, 0), 3, 3, 5)
	end
end
