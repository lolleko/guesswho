-- common grenade projectile code

AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

AccessorFunc( ENT, "thrower", "Thrower")

function ENT:SetupDataTables()
   self:NetworkVar("Float", 0, "ExplodeTime")
end

function ENT:Initialize()
   self:SetModel(self.Model)

   self:PhysicsInit(SOLID_VPHYSICS)
   self:SetMoveType(MOVETYPE_VPHYSICS)
   self:SetSolid(SOLID_BBOX)
   self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

   if SERVER then
      self:SetExplodeTime(0)
   end
end


function ENT:SetDetonateTimer(length)
   self:SetDetonateExact( CurTime() + length )
end

function ENT:SetDetonateExact(t)
   self:SetExplodeTime(t or CurTime())
end

function ENT:Explode(tr)
	if SERVER then
	    local pull = ents.Create( "gw_ability_wall" )
	    if not IsValid( pull ) then self:Remove() return end
	    pull:SetPos( self:GetPos() + Vector(0, 0, 75) )
	    pull:Spawn()
	    pull:Activate()

	    SafeRemoveEntityDelayed( pull, 5)
		self:Remove()
	end
end

function ENT:Think()
   local etime = self:GetExplodeTime() or 0
   if etime ~= 0 and etime < CurTime() then
      -- if thrower disconnects before grenade explodes, just don't explode
      if SERVER and not IsValid(self:GetThrower()) then
         self:Remove()
         etime = 0
         return
      end

      self:Explode()
   end
end
