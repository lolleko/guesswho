SWEP.Base = "weapon_gwbase"
SWEP.Name = "Graviton Surge"

-- Zarya Main 4 life
AccessorFunc(SWEP, "det_time", "DetTime")

function SWEP:Ability()

    local ply = self.Owner

    self:SetDetTime(CurTime() + 1.5)

    if CLIENT then
        return
    end

    if not IsValid(ply) then return end

    if self.was_thrown then return end

    self.was_thrown = true

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
   local gren = ents.Create("gw_surge_grenade")
   if not IsValid(gren) then return end

   gren:SetPos(src)
   gren:SetAngles(ang)

   --   gren:SetVelocity(vel)
   gren:SetOwner(ply)
   gren:SetThrower(ply)

   gren:SetGravity(0.4)
   gren:SetFriction(0.2)
   gren:SetElasticity(0.45)

   gren:Spawn()

   gren:PhysWake()

   local phys = gren:GetPhysicsObject()
   if IsValid(phys) then
      phys:SetVelocity(vel)
      phys:AddAngleVelocity(angimp)
   end

   gren:SetDetonateExact(self:GetDetTime())

   return gren
end
