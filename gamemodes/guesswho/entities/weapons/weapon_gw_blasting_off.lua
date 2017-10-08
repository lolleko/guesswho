AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Blasting off (again)"

function SWEP:Ability()
	self.LaunchedEnts = {}

	for _,v in pairs(player.GetAll()) do
		if v:IsSeeking() then
			v:SetVelocity(Vector(0, 0, 5000))
			table.insert(self.LaunchedEnts, v)
			local tName = "gwLaunch" .. v:SteamID()
			if timer.Exists(tName) then
				timer.Remove(tName)
				v:SetGravity(1)
			end
			timer.Create(tName, 0.1, 15, function()
				if util.QuickTrace(v:EyePos(), Vector(0, 0, 30), v).HitWorld then
					timer.Remove(tName)
					v:SetGravity(-1)
					timer.Simple(3, function() v:SetGravity(1) end)
				end
			end)
		end
	end

end

if CLIENT then
	local function GetEmitter(self, Pos)
		if ( self.Emitter ) then
			if self.EmitterTime > CurTime() then
				return self.Emitter
			else
				self.Emitter:Finish()
				self.Emitter = nil
			end
		end

		self.Emitter = ParticleEmitter(Pos)
		self.EmitterTime = CurTime() + 10
		return self.Emitter

	end

	local function Trail(self)
		self.SmokeTimer = self.SmokeTimer or 0
		if ( self.SmokeTimer > CurTime() ) then return end

		self.SmokeTimer = CurTime() + 0.05

		local vOffset = self:GetPos() + Vector( math.Rand( -3, 3 ), math.Rand( -3, 3 ), math.Rand( -3, 3 ) )
		local vNormal = ( vOffset - self:GetPos() ):GetNormalized()

		local emitter = GetEmitter( self, vOffset )

		local particle = emitter:Add( "particles/smokey", vOffset )
		if ( not particle ) then return end

		particle:SetVelocity( vNormal * math.Rand( 10, 30 ) )
		particle:SetDieTime( 3.0 )
		particle:SetStartAlpha( math.Rand( 50, 150 ) )
		particle:SetStartSize( math.Rand( 32, 64 ) )
		particle:SetEndSize( math.Rand( 128, 312 ) )
		particle:SetRoll( math.Rand( -0.2, 0.2 ) )
		particle:SetColor( 200, 200, 210 )
	end


	function SWEP:Think()
		if self.LaunchedEnts then
			for k,v in pairs(self.LaunchedEnts) do
				Trail(v)
			end
			timer.Simple(4.5, function() self.LaunchedEnts = nil end)
		end
	end
end
