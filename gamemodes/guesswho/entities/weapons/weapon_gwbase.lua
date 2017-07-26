AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.Name = "NONAME"

SWEP.Spawnable			= false
SWEP.ViewModelFOV		= 54

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Damage			= 10
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.NumShots		= 1

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "gwAbility"

SWEP.ViewModel = ""
SWEP.WorldModel = "models/brokenglass_piece.mdl"

SWEP.HoldType = "normal"

SWEP.AbilityRange = 0

function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end

local CircleMat = Material( "SGM/playercircle" )

function SWEP:DrawWorldModel()
	if self:Clip2() > 0 and self.AbilityRange > 0 and self:IsCarriedByLocalPlayer() then
		local ply = self.Owner
		local color = Color(0,0,0,128)
		local radius = self.AbilityRange

		local trace = {}
		trace.start = ply:GetPos() + Vector(0,0,50)
		trace.endpos = trace.start + Vector(0,0,-300)
		trace.filter = ply
		local tr = util.TraceLine( trace )
		if !tr.HitWorld then
			tr.HitPos = ply:GetPos()
		end
		render.SetMaterial( CircleMat )
		render.DrawQuadEasy( tr.HitPos + tr.HitNormal * 10, Vector(0, 0, 1), radius * 2, radius * 2, color )
	end
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Equip()
	if SERVER and GAMEMODE:GetRoundState() == ROUND_HIDE and not self.Owner:GetReRolledAbility() then
		self.Owner:ChatPrint("Press Reload during hiding phase to reroll your ability. You can only do this once per round.")
	end
end

function SWEP:Reload()
	if SERVER and GAMEMODE:GetRoundState() == ROUND_HIDE and self:Clip2() == 1 and not self.Owner:GetReRolledAbility() then
		self.Owner:SetReRolledAbility(true)
		self.Owner:GiveRandomAbility()
	end
end

function SWEP:PrimaryAttack()

	self:SetNextPrimaryFire( CurTime() + 1.5 )

	if self.Owner.LagCompensation then
		self.Owner:LagCompensation(true)
	end
	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * 100)
	local tr = util.TraceLine( {start = spos, endpos = sdest, filter  = self.Owner, mask = MASK_SHOT_HULL} )
	self.Owner:LagCompensation(false)

	--print(tr.Entity)

	if tr.Hit and IsValid(tr.Entity) and (tr.Entity:GetClass() == "func_breakable" or tr.Entity:GetClass() == "func_breakable_surf") then

		if SERVER then tr.Entity:Fire("shatter") end

	end

end

function SWEP:SecondaryAttack()
	if ( !self:CanSecondaryAttack() ) then return end

	if self.AbilitySound and SERVER then
		local abilitySound
		if istable( self.AbilitySound ) then
			abilitySound = Sound( self.AbilitySound[ math.random( #self.AbilitySound ) ] )
		else
			abilitySound = Sound( self.AbilitySound )
		end
		if abilitySound then
			self.Owner:EmitSound( abilitySound )
		end
	end
	self:Ability()
	self:TakeSecondaryAmmo( 1 )
end

function SWEP:GiveSecondaryAmmo(amount)
	self.Owner:GiveAmmo(amount, "gwAbility", true)
	self:SetClip2( self:Clip2() + amount )
end
