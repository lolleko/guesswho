AddCSLuaFile()

SWEP.Base = "weapon_base"
SWEP.Name = "NONAME"

SWEP.Spawnable = false
SWEP.ViewModelFOV = 54

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.Damage = 10
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.NumShots = 1

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = ""
SWEP.WorldModel = "models/brokenglass_piece.mdl"

SWEP.HoldType = "normal"

SWEP.DrawWeaponInfoBox = false

SWEP.AbilityRange = 0
SWEP.AbilityShowTargetHalos = false
SWEP.AbilityShowTargetHalosCheckLOS = false
SWEP.AbilityDuration = 0
SWEP.AbilityStartTime = 0
SWEP.AbilityDescription = ""

GW_ABILTY_CAST_ERROR_NO_TARGET = 1
GW_ABILTY_CAST_ERROR_INVALID_TARGET = 2
GW_ABILTY_CAST_ERROR_INVALID_ROUND_STATE = 3
GW_ABILTY_CAST_ERROR_ALREADY_ACTIVE = 4

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsAbilityUsed")

    self:AbilitySetupDataTables()
end

function SWEP:AbilitySetupDataTables()
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    if self.IsNoAbility then
        self:SetIsAbilityUsed(true)
    else
        self:SetIsAbilityUsed(false)
    end

    self.currentTimerID = 0
    self.activeTimers = {}

    if CLIENT and not self.IsNoAbility and LocalPlayer() == self:GetOwner() and GAMEMODE.GWRound:IsCurrentState(GW_ROUND_HIDE) then
        local description = self.AbilityDescription

        if (description) then
            description = string.gsub(description, "$(%w+)", function(specialValue)
                return "<font=gw_font_small_bold>" .. tostring(self[specialValue]) .. "</font>"
            end)
        end

        GWNotifications:Add("gwAbility", "<font=gw_font_normal>Ability: " .. self.Name .. "</font>", "<font=gw_font_small>" .. description .. "</font>", (GAMEMODE.GWRound:GetEndTime() - CurTime()) / 2)
    end

    self:AbilityCreated()
end

function SWEP:AbilityCreated()

end

function SWEP:DrawWorldModel()
    if not self:GetIsAbilityUsed() and self.AbilityShowTargetHalos and self.AbilityRange and self.AbilityRange > 0 and self:IsCarriedByLocalPlayer() then
        for _, v in pairs(self:GetSeekersInRange(self.AbilityRange, not self.AbilityShowTargetHalosCheckLOS)) do
            if not v:GWIsRagdolled() then
                halo.Add({v}, Color(255, 0, 0), 3, 3, 5)
            end
        end
    end
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Equip()
    if SERVER then
        if GAMEMODE.GWRound:IsCurrentState(GW_ROUND_HIDE) then
            self:GetOwner():SetGWPrepAbility(self:GetClass())
            if not self:GetOwner():GetGWReRolledAbility() then
                self:GetOwner():ChatPrint("Press Reload during hiding phase to reroll your ability. You can only do this once per round.")
            end
        end
    end
end

function SWEP:Reload()
    if SERVER and GAMEMODE.GWRound:IsCurrentState(GW_ROUND_HIDE) and not self:GetIsAbilityUsed() and not self:GetOwner():GetGWReRolledAbility() then
        self:GetOwner():SetGWReRolledAbility(true)
        self:GetOwner():GWGiveRandomAbility()
    end
end

function SWEP:PrimaryAttack()

    self:SetNextPrimaryFire(CurTime() + 1.5)

    if self:GetOwner().LagCompensation then
        self:GetOwner():LagCompensation(true)
    end
    local spos = self:GetOwner():GetShootPos()
    local sdest = spos + (self:GetOwner():GetAimVector() * 100)
    local tr = util.TraceLine({start = spos, endpos = sdest, filter = self:GetOwner(), mask = MASK_SHOT_HULL})
    self:GetOwner():LagCompensation(false)

    if tr.Hit and IsValid(tr.Entity) and (tr.Entity:GetClass() == "func_breakable" or tr.Entity:GetClass() == "func_breakable_surf") then

        if SERVER then tr.Entity:Fire("shatter") end

    end

end

function SWEP:SecondaryAttack()
    if self:GetIsAbilityUsed() then return end

    self.AbilityStartTime = CurTime()

    local abilityError = self:Ability()
    
    if not abilityError then
        if self.AbilitySound then
            local abilitySound
            if istable(self.AbilitySound) then
                abilitySound = Sound(self.AbilitySound[math.random(#self.AbilitySound)])
            else
                abilitySound = Sound(self.AbilitySound)
            end
            if abilitySound then
                self:EmitSound(abilitySound)
            end
        end
        self:SetIsAbilityUsed(true)
    else
        if CLIENT then
            self:EmitSound(Sound("WallHealth.Deny"))
            if IsFirstTimePredicted() then
                if abilityError == GW_ABILTY_CAST_ERROR_NO_TARGET then
                    self:GetOwner():PrintMessage(HUD_PRINTTALK, "Ability cast cancelled: No target!")
                elseif abilityError == GW_ABILTY_CAST_ERROR_INVALID_TARGET then
                    self:GetOwner():PrintMessage(HUD_PRINTTALK, "Ability cast cancelled: Invalid target!")
                elseif abilityError == GW_ABILTY_CAST_ERROR_INVALID_ROUND_STATE then
                    self:GetOwner():PrintMessage(HUD_PRINTTALK, "Ability cast cancelled: Can't use during hiding phase!")
                elseif abilityError == GW_ABILTY_CAST_ERROR_ALREADY_ACTIVE then
                    self:GetOwner():PrintMessage(HUD_PRINTTALK, "Ability cast cancelled: Another instance is already active")
                end
            end
        end
    end
end

function SWEP:OnRemove()
    for timerName, shouldRemove in pairs(self.activeTimers) do 
        if (shouldRemove) then
            timer.Remove(timerName)
        end
    end
    if (self.AbilityStartTime + self.AbilityDuration > CurTime()) then
        self:AbilityCancelled()
    end

    self:AbilityCleanup()
end

function SWEP:AbilityCancelled()

end

function SWEP:AbilityCleanup()

end

function SWEP:AbilityIsTargetInLOS(target, mask)
    if not IsValid(self) or not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return false end

    local losTrace = util.TraceLine({
        start = self:GetOwner():GetPos() + self:GetOwner():OBBCenter(),
        endpos = target:GetPos() + target:OBBCenter(),
        filter = self:GetOwner(),
        mask = mask or MASK_SOLID_BRUSHONLY
    })

    return not losTrace.Hit
end

function SWEP:GetSeekersInRange(range, ignoreLOS)
    local result = {}
    for _,v in pairs(player.GetAll()) do
        if v:Alive() and v:GWIsSeeking() and v:GetPos():Distance(self:GetOwner():GetPos()) < range and (ignoreLOS or self:AbilityIsTargetInLOS(v)) then
            table.insert(result, v)
        end
    end
    return result
end

function SWEP:AbilityTimer(dur, reps, remove, fn)
    local timerName = "gwAbility" .. "." .. self:EntIndex() .. "." .. self.currentTimerID
    self.currentTimerID = self.currentTimerID + 1

    timer.Create(timerName, dur, reps, fn)

    self.activeTimers[timerName] = remove

    return timerName
end

function SWEP:AbilityTimerIfValidSWEP(dur, reps, removeTimerWithSwep, fn)
    return self:AbilityTimer(dur, reps, removeTimerWithSwep, function()
        if not IsValid(self) then return end
        fn()
    end)
end

function SWEP:AbilityTimerIfValidOwner(dur, reps, removeTimerWithSwep, fn)
    return self:AbilityTimer(dur, reps, removeTimerWithSwep, function()
        if not IsValid(self) or not IsValid(self:GetOwner()) then return end
        fn()
    end)
end

function SWEP:AbilityTimerIfValidOwnerAndAlive(dur, reps, removeTimerWithSwep, fn)
    return self:AbilityTimer(dur, reps, removeTimerWithSwep, function()
        if not IsValid(self) or not IsValid(self:GetOwner()) or not self:GetOwner():Alive() then return end
        fn()
    end)
end
