AddCSLuaFile()

SWEP.PrintName = "Crowbar"

if (CLIENT) then
    SWEP.ViewModelFlip = false
    SWEP.IconLetter = "y"
end
SWEP.Base = "weapon_base"
SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = 3
SWEP.Secondary.DefaultClip = 3
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "gwDashCharges"

SWEP.SwingSound = "Weapon_Crowbar.Single"
SWEP.HitSound = "Weapon_Crowbar.Melee_Hit"
SWEP.HitWorldSound = "Weapon_Crowbar.Melee_HitWorld"

SWEP.AllowDrop = false
SWEP.Kind = WEAPON_MELEE
SWEP.HoldType = "melee"

SWEP.Delay = 0.7
SWEP.Range = 85
SWEP.Damage = 20
SWEP.AutoSpawnable = false

SWEP.DashRestoreDelay = 3

if CLIENT then
    killicon.AddAlias("weapon_gw_seeker_crowbar", "weapon_crowbar")
end

function SWEP:Initialize()
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Deploy()
    self:SendWeaponAnim( ACT_VM_DRAW )
    return true
end

function SWEP:Equip()
    timer.Create("gwSeekerCrowbarRechargeThink" .. self.Owner:SteamID(), self.DashRestoreDelay, 0, function()
        if IsValid(self) and IsValid(self.Owner) then
            self:SetClip2(math.min(self:Clip2() + 1, self:GetMaxClip2()))
        end
    end)
end

function SWEP:OnDrop()
    self:OnRemove()
end

function SWEP:OnRemove()
    if IsValid(self.Owner) then
        timer.Remove("gwSeekerCrowbarRechargeThink" .. self.Owner:SteamID())
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Delay)

    self.Owner:LagCompensation(true)

    local trace = {}
    trace.start = self.Owner:GetShootPos()
    trace.endpos = trace.start + (self.Owner:GetAimVector() * self.Range)
    trace.filter = self.Owner
    local traceResult = util.TraceLine(trace)
    self.Owner:LagCompensation(false)

    if SERVER then self:EmitSound(self.SwingSound) end

    local hitEnt = traceResult.Entity

    if IsValid(hitEnt) or traceResult.HitWorld then
        self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

        if not CLIENT or IsFirstTimePredicted() then
            local impactEffect = EffectData()
            impactEffect:SetStart(trace.start)
            impactEffect:SetOrigin(traceResult.HitPos)
            impactEffect:SetNormal(traceResult.Normal)
            impactEffect:SetSurfaceProp(traceResult.SurfaceProps)
            impactEffect:SetHitBox(traceResult.HitBox)
            impactEffect:SetEntity(hitEnt)

            if IsValid(hitEnt) and (hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" or hitEnt:GetClass() == GW_WALKER_CLASS) then
                util.Effect("BloodImpact", impactEffect)
            else
                util.Effect("Impact", impactEffect)
            end

            if SERVER and IsValid(hitEnt) then
                if hitEnt:IsPlayer() then
                    hitEnt:TakeDamage(self.Damage * 2, self.Owner, self)
                else
                    hitEnt:TakeDamage(self.Damage * 3, self.Owner, self)
                end
                self:EmitSound(self.HitSound)
            end
        end
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    if SERVER then self.Owner:SetAnimation(PLAYER_ATTACK1) end

end

function SWEP:Reload()
    return false
end

function SWEP:Think()
    return false
end

local arrow = {
    { x = 50, y = 0 },
    { x = 100, y = 50 },
    { x = 75, y = 50 },
    { x = 50, y = 25 },
    { x = 25, y = 50 },
    { x = 0, y = 50 }
}

local function translate(tbl, x, y)
    tbl = table.Copy(tbl)
    for _, point in pairs(tbl) do
        point.x = point.x + x
        point.y = point.y + y
    end
    return tbl
end

function SWEP:DrawHUD()
    draw.NoTexture()
    local left = ScrW() - 120
    local bottom = ScrH() - 70

    surface.SetDrawColor(G_GWColors.darkgreybg)
    local offset2 = bottom
    for i = 1, self:GetMaxClip2() do
        surface.DrawPoly( translate(arrow, left, offset2) )
        offset2 = offset2 - 50
    end

    surface.SetDrawColor( team.GetColor(GW_TEAM_SEEKING) )
    local offset1 = bottom
    for i = 1, self:Clip2() do
        surface.DrawPoly( translate(arrow, left, offset1) )
        offset1 = offset1 - 50
    end


end

function SWEP:SecondaryAttack()
    if ( not self:CanSecondaryAttack() ) then return end

    local vel = self.Owner:GetForward()
    vel.z = 0
    vel:Normalize()
    if self.Owner:IsOnGround() then
        vel = vel * 800
        self.Owner:SetPos(self:GetPos() + Vector(0, 0, 1))
        vel.z = vel.z + 20
    else
        vel = vel * 350
    end
    if not self.Owner:IsOnGround() and self.Owner:GetVelocity().z < 0 then
        vel.z = self.Owner:GetVelocity().z * - 1
    end
    vel.z = vel.z + 90
    self.Owner:SetVelocity(vel)
    self:TakeSecondaryAmmo( 1 )
end
