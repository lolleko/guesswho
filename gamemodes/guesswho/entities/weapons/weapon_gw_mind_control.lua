AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Mind Transfer"

SWEP.DrawGWCrossHair = true
SWEP.AbilityDuration = 10

function SWEP:Ability()
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	local hitEnt = tr.Entity
	if IsValid(hitEnt) and hitEnt:GetClass() == GW_WALKER_CLASS then
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
			fake:SetAngles(Angle(0, oldAngles.yaw, 0))
			fake:SetPlayer(ply)
			ply:SetPlayerColor(oldColor)
			timer.Simple(0.01, function()
				fake:SetModel(oldModel)
				fake:SetCollisionBounds( Vector(-8, - 8, 0), Vector(8, 8, 36) )
			end)
		end
	else
		return true
	end
end

function SWEP:DrawHUD()
	if self:GetIsAbilityUsed() then self.DrawGWCrossHair = false return end
	local tr = LocalPlayer():GetEyeTrace()
	local hitEnt = tr.Entity
	if IsValid(hitEnt) and hitEnt:GetClass() == GW_WALKER_CLASS then
		halo.Add( {hitEnt}, Color(255, 0, 0), 3, 3, 5)
	end
end
