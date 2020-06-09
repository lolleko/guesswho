AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Teleport"

SWEP.AbilityDuration = 1.5

function SWEP:SetupDataTables()
    self:NetworkVar("Vector", 0, "CalculatedTeleportDestination")
end

function SWEP:AbilityCreated()
	self.ClientCalculatedTeleportDestination = Vector(0, 0, 0)
	
	if CLIENT then
		self.destinationModel = ClientsideModel(self.Owner:GetModel(), RENDERGROUP_TRANSLUCENT)
		self.destinationModel:SetupBones()
		self.destinationModel:SetColor(Color( 255, 255, 255, 150))
		self.destinationModel:SetRenderMode(RENDERMODE_TRANSALPHA)

		self.haloHookName = "gwTeleportHalo" .. self:EntIndex()
		hook.Add("PreDrawHalos", self.haloHookName, function()
			halo.Add({self.destinationModel}, Color(150, 150, 150), 5, 5, 2 )
		end)
		print("hello")
	end
end

function SWEP:Ability()
	local ply = self.Owner

	if SERVER then ply:ApplyStun(2) end

	local fadeOut = EffectData()
	fadeOut:SetEntity(ply)
	fadeOut:SetMagnitude(self.AbilityDuration)
	fadeOut:SetScale(-1)
	util.Effect("gw_spawn", fadeOut)

	self:AbilityTimerIfValidPlayerAndAlive(self.AbilityDuration, 1, true, function()
			local fadeIn = EffectData()
			fadeIn:SetEntity(ply)
			fadeIn:SetMagnitude(self.AbilityDuration)
			fadeOut:SetScale(1)
			util.Effect("gw_spawn", fadeIn)
			if SERVER then
				ply:SetPos(self:CalcTeleportDestination())
			end
		end
	)

end

function SWEP:Think()
	if SERVER then
		self:SetCalculatedTeleportDestination(self:CalcTeleportDestination())
	end
end

function SWEP:DrawHUD()
	if self:Clip2() <= 0 then
		self:AbilityCleanup()
		return
	end

	if self.destinationModel ~= self.Owner:GetModel() then
		self.destinationModel:SetModel(self.Owner:GetModel())
	end

	local teleportDestination = self:GetCalculatedTeleportDestination()

	self.ClientCalculatedTeleportDestination = LerpVector(math.Clamp(FrameTime() * 60, 0, 1), self.ClientCalculatedTeleportDestination, teleportDestination)

	self.destinationModel:SetAngles(Angle(0, self.Owner:GetAngles().yaw, 0))
	self.destinationModel:SetPos(self.ClientCalculatedTeleportDestination)
end

function SWEP:CalcTeleportDestination()
	local forwardWithoutZ = self.Owner:GetForward()
	forwardWithoutZ.z = 0

	local eyeTraceStart = self.Owner:GetPos() + Vector(0, 0, 100) + self.Owner:GetRight() * 35

	local eyeTrace = util.TraceLine( {
		start = eyeTraceStart,
		endpos = eyeTraceStart +  forwardWithoutZ * 1500
	} )

	local tpDistance = 1500

	if eyeTrace.Hit then
		tpDistance = math.Clamp((eyeTrace.HitPos - self.Owner:GetPos()):Length(), 100, 1500) + 120
	end

	local aimVector = self.Owner:GetAimVector()

	local trace = util.TraceLine({
		start = eyeTraceStart,
		endpos = eyeTraceStart + aimVector * tpDistance
	})

	local secondTraceStart = trace.HitPos - (trace.Normal * 64)

	local secondTrace = util.TraceLine({
		start = secondTraceStart,
		endpos = secondTraceStart - Vector(0, 0, 1000)
	})

	local result = secondTrace.HitPos

	local navArea = navmesh.GetNearestNavArea(secondTrace.HitPos + secondTrace.HitNormal, false, 10000, true)
	if IsValid(navArea) then
		local navAreaClosestPoint = navArea:GetClosestPointOnArea(secondTrace.HitPos)
		result = navAreaClosestPoint
	end

	return result
end

function SWEP:AbilityCleanup()
	if self.destinationModel then
		hook.Remove("PreDrawHalos", self.haloHookName)
		SafeRemoveEntity(self.destinationModel)
		self.destinationModel = nil
	end
end
