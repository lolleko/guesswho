AddCSLuaFile()

SWEP.Base = "weapon_base"

SWEP.Spawnable          = false
SWEP.ViewModelFOV       = 54

SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.Primary.Damage         = 10
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Primary.NumShots       = 1

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "ability"

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Cooldown = 30

function SWEP:Initialize()

    self:SetHoldType( "normal" )

end


function SWEP:PrimaryAttack()

    self.Weapon:SetNextPrimaryFire( CurTime() + 1.5 )

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
    self:Ability()
    self:TakeSecondaryAmmo( 1 )
end
