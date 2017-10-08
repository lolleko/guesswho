AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Teleport"

SWEP.DrawGWCrossHair = true

function SWEP:Ability()
	local ply = self.Owner

	local effect = EffectData()
	effect:SetStart(ply:GetPos() + Vector(0, 0, 64))
	effect:SetOrigin(ply:GetPos() + Vector(0, 0, 64))
	effect:SetNormal(ply:GetAngles():Up())
	util.Effect("ManhackSparks", effect, true, true)

	local effect2 = EffectData()
	effect2:SetOrigin(ply:GetPos() + Vector(0, 0, 64))
	util.Effect("cball_explode", effect2)

	if SERVER then ply:ApplyStun(2) end

	timer.Simple(1.5, function() ply:SetPos(self:CalcTeleportDestination()) end)
end

function SWEP:DrawHUD()
	if self:Clip2() <= 0 then
		if self.destinationModel then
			SafeRemoveEntity(self.destinationModel)
			self.destinationModel = nil
		end
		return
	end
	if not self.destinationModel then
		self.destinationModel = ClientsideModel(self.Owner:GetModel())
		self.destinationModel:SetupBones()

		self.destinationModel:SetColor(Color( 255, 255, 255, 130))
		self.destinationModel:SetRenderMode(RENDERMODE_TRANSALPHA)
	end
	if self.destinationModel ~= self.Owner:GetModel() then
		self.destinationModel:SetModel(self.Owner:GetModel())
	end
	self.destinationModel:SetPos(self:CalcTeleportDestination())
	local textPos = self.destinationModel:GetPos():ToScreen()
	draw.DrawText( "TP Destination", "robot_small", textPos.x, textPos.y, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:CalcTeleportDestination()
	local forwardWithoutZ = self.Owner:GetForward()
	forwardWithoutZ.z = 0
	local eyeTrace = util.TraceLine( {
		start = self.Owner:GetPos() + Vector(0, 0, 100),
		endpos = self.Owner:GetPos() + Vector(0, 0, 100) +  forwardWithoutZ * 1500
	} )

	local tpDistance = 1500

	if eyeTrace.Hit then
		tpDistance = math.Clamp((eyeTrace.HitPos - self.Owner:GetPos()):Length(), 100, 1500) + 120
	end

	local aimVector = self.Owner:GetAimVector()

	local trace = util.TraceLine( {
		start = self.Owner:GetPos() + Vector(0, 0, 100),
		endpos = self.Owner:GetPos() + Vector(0, 0, 100) + aimVector * tpDistance
	} )


	local secondTraceStart = trace.HitPos - (trace.Normal * 64)

	local secondTrace = util.TraceLine( {
		start = secondTraceStart,
		endpos = secondTraceStart - Vector(0, 0, 1000)
	} )

	return secondTrace.HitPos
end

function SWEP:OnRemove()
	if self.destinationModel then
		SafeRemoveEntity(self.destinationModel)
	end
end
