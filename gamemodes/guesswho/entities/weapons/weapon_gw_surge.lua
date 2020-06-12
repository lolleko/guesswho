AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Graviton Surge"

SWEP.AbilitySound = "vo/npc/vortigaunt/surge.wav"
SWEP.AbilityDuration = 1.5
SWEP.AbilityDescription = "Launch a grenade that spawns a gravity well after $AbilityDuration seconds.\n\nDraws in nearby players and props and deals a small amount of damage."

-- Zarya Main 4 life
function SWEP:Ability()

   local ply = self.Owner

   self.DetonationTime = CurTime() + self.AbilityDuration

   if CLIENT then
      return
   end

   if not IsValid(ply) then return end

   local ang = ply:EyeAngles()
   local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())+ (ang:Forward() * 8) + (ang:Right() * 10)
   local target = ply:GetEyeTraceNoCursor().HitPos
   local tang = (target-src):Angle() -- A target angle to actually throw the grenade to the crosshair instead of fowards
   -- Makes the grenade go upgwards
   if tang.p < 90 then
      tang.p = -10 + tang.p * ((90 + 10) / 90)
   else
      tang.p = 360 - tang.p
      tang.p = -10 + tang.p * -((90 + 10) / 90)
   end
   tang.p = math.Clamp(tang.p,-90,90) -- Makes the grenade not go backwards :/
   local vel = math.min(800, (90 - tang.p) * 6)
   local thr = tang:Forward() * vel + ply:GetVelocity()
   self:CreateGrenade(src, Angle(0,0,0), thr, Vector(600, math.random(-1200, 1200), 0), ply)
end


function SWEP:CreateGrenade(src, ang, vel, angimp, ply)
   local grenade = ents.Create("gw_surge_grenade")
   if not IsValid(grenade) then return end

   grenade:SetPos(src)
   grenade:SetAngles(ang)

   --   grenade:SetVelocity(vel)
   grenade:SetOwner(ply)
   grenade:SetThrower(ply)

   grenade:SetGravity(0.4)
   grenade:SetFriction(0.2)
   grenade:SetElasticity(0.45)

   grenade:Spawn()

   grenade:PhysWake()

   local phys = grenade:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   grenade:SetDetonateExact(self.DetonationTime)

   return grenade
end
