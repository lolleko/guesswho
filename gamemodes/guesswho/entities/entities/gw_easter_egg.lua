AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/props_phx/misc/egg.mdl")

local HealSound = Sound("HealthKit.Touch")
local DenySound = Sound("WallHealth.Deny")

ENT.EggEventsAll = {
	function(egg, ply)
		ply:SetHealth(ply:Health() + math.random(1, 40))
		ply:EmitSound(HealSound)
	end,
	function(egg, ply)
		local d = DamageInfo()
		d:SetDamage(math.random(1, 20))
		d:SetAttacker(egg)
		d:SetDamagePosition(ply:GetPos() + ply:OBBCenter())
		d:SetDamageType(DMG_BLAST)

		ply:TakeDamageInfo( d )
		ply:EmitSound(DenySound)
	end,
	function(egg, ply)
		local stunDur = 2.5

		local effect = EffectData()
		effect:SetEntity(ply)
		effect:SetMagnitude(stunDur)
		util.Effect("gw_stunned", effect, true, true)

		if SERVER then
			ply:ApplyStun(stunDur)
		end

		egg:EmitSound("ambient/energy/zap1.wav")
	end,
	function(egg, ply)
		if SERVER then
			local explode = ents.Create("env_explosion")
			explode:SetPos(egg:GetPos())
			explode:SetOwner(egg:GetPos())
			explode:Spawn()
			explode:SetKeyValue( "iMagnitude", "" .. math.random(40, 70) )
			explode:Fire( "Explode", 0, 0 )
			explode:EmitSound( "BaseExplosionEffect.Sound", 100, 100 )
	    end
	end,
	function(egg, ply)
		if SERVER then
			egg:EmitSound("vo/npc/vortigaunt/surge.wav")

			local gren = ents.Create("gw_surge_grenade")
		    if not IsValid(gren) then return end

		    gren:SetPos(egg:GetPos())

		    gren:SetOwner(ply)
		    gren:SetThrower(ply)

		    gren:Spawn()

		    gren:PhysWake()
		    gren:SetDetonateExact(CurTime() + 2.5)
		end
	end,
}

ENT.EggEventsHiding = {
	function(egg, ply) ply:ResetSeekerTouches() end,
	function(egg, ply) ply:AddSeekerTouch() end
}

ENT.EggEventsSeeking = {
	function(egg, ply)
		local wep = ply:Give("weapon_rpg")
		--ply:GiveAmmo( 2, "RPG_Round", true )
		ply:SetActiveWeapon(wep)
	end,
	function(egg, ply)
		local wep = ply:Give("weapon_crossbow")
		ply:GiveAmmo(4, "XBowBolt", true)
		ply:SetActiveWeapon(wep)
	end,
	function(egg, ply)
		local wep = ply:Give("weapon_shotgun")
		ply:GiveAmmo(6, "Buckshot", true)
		ply:SetActiveWeapon(wep)
	end
}

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))

	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:PhysWake()
end

function ENT:Use(activator, caller)
	if IsValid(caller) and caller:IsPlayer() and caller:Alive() and not self.EggUsed then
		local events = table.Copy(self.EggEventsAll)
		if caller:IsHiding() then
			table.Add(events, self.EggEventsHiding)
		elseif caller:IsSeeking() then
			table.Add(events, self.EggEventsSeeking)
		end
		local eggFunction = events[math.random(#events)]
		eggFunction(self, caller)
	end
	self.EggUsed = true
	SafeRemoveEntity(self)
end
