SWEP.Base = "weapon_gwbase"
SWEP.Name = "Timelapse"
SWEP.AbilitySound = "gwabilities/timelapse.mp3"

SWEP.AbilityDuration = 15

function SWEP:Deploy()
	local timerName = "gwAbilityTimelapseThink" .. self:EntIndex()
	self.TimelapseData = {}
	if not timer.Exists(timerName) then
		timer.Create(timerName, 0.2, 0, function() if IsValid(self) then self:TimelapseThink() end end)
	end
end

function SWEP:TimelapseThink()
	if not IsValid(self.Owner) then return end

	local data = {
		pos = self.Owner:GetPos(),
		ang = self.Owner:EyeAngles(),
		health = self.Owner:Health()
	}
	table.insert(self.TimelapseData, 1, data)

	if #self.TimelapseData > self.AbilityDuration * 5 then
		table.remove(self.TimelapseData)
	end
end

function SWEP:Ability()
	if SERVER then
		local startSize = 80
		local endSize = 0

		timer.Remove("gwAbilityTimelapseThink" .. self:EntIndex())

		for i, data in pairs(self.TimelapseData) do
			if self.TimelapseData[i + 1] and data.pos == self.TimelapseData[i + 1].pos then
				table.remove(self.TimelapseData, i)
			end
		end

		if #self.TimelapseData ~= 0 then
			self.TimeLapseTrail = util.SpriteTrail(self.Owner, 0, Color(255, 255, 255), false, startSize, endSize, 2, 1 / ( ( startSize + endSize ) * 0.5 ), "trails/physbeam.vmt")
			timer.Create("gwAbilityTimelapseActive" .. self:EntIndex(), 0.001, #self.TimelapseData, function()
				local data = self.TimelapseData[1]
				self.Owner:SetPos(data.pos)
				local ang = data.ang
				self.Owner:SetEyeAngles(ang)
				self.Owner:SetHealth(data.health)
				table.remove(self.TimelapseData, 1)

				if #self.TimelapseData <= 18 then
					ang:RotateAroundAxis(Vector(0, 0, 1), (18 - #self.TimelapseData) * 10)
					self.Owner:SetEyeAngles(ang)
				end

				if #self.TimelapseData == 0 then
					SafeRemoveEntityDelayed(self.TimeLapseTrail, 2)
				end
			end)
		end
	end
end

function SWEP:OnRemove()
	if SERVER then
		SafeRemoveEntity(self.TimeLapseTrail)
		timer.Remove("gwAbilityTimelapseThink" .. self:EntIndex())
		timer.Remove("gwAbilityTimelapseActive" .. self:EntIndex())
	end
end
