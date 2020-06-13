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

SWEP.AbilityRange = 0
SWEP.AbilityShowTargetHalos = false
SWEP.AbilityShowTargetHalosCheckLOS = false
SWEP.AbilityDuration = 0
SWEP.AbilityStartTime = 0
SWEP.AbilityDescription = ""

GW_ABILTY_CAST_ERROR_NO_TARGET = 1
GW_ABILTY_CAST_ERROR_INVALID_TARGET = 2

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsAbilityUsed")
    self:AbilitySetupDataTables()
end


function SWEP:AbilitySetupDataTables()
end

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)

    self:SetIsAbilityUsed(false)

    self.currentTimerID = 0
    self.activeTimers = {}

    if CLIENT and GWRound:IsCurrentState(GW_ROUND_HIDE) then
        local description = self.AbilityDescription

        if (description) then
            description = string.gsub(description, "$(%w+)", function(specialValue)
                return "<font=gw_font_small_bold>" .. tostring(self[specialValue]) .. "</font>"
            end)
        end

        GWNotifications:Add("gwAbility", "<font=gw_font_normal>Ability: " .. self.Name .. "</font>", "<font=gw_font_small>" .. description .. "</font>", (GWRound:GetEndTime() - CurTime()) / 2)
    end

    self:AbilityCreated()
end

function SWEP:AbilityCreated()

end

function SWEP:DrawWorldModel()
    if not self:GetIsAbilityUsed() and self.AbilityShowTargetHalos and self.AbilityRange > 0 and self:IsCarriedByLocalPlayer() then
        local ply = self.Owner
        for _, v in pairs( player.GetAll() ) do
          if v:GetPos():Distance( ply:GetPos() ) < self.AbilityRange and v:Alive() and v:IsSeeking() then
            if not self.AbilityShowTargetHalosCheckLOS or self:AbilityIsTargetInLOS(v) then
                halo.Add( {v}, Color(255, 0, 0), 3, 3, 5)
            end
          end
        end
    end
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Equip()
    if SERVER then
        if GWRound:IsCurrentState(GW_ROUND_HIDE) then
            self.Owner:SetPrepAbility(self:GetClass())
            if not self.Owner:GetReRolledAbility() then
                self.Owner:ChatPrint("Press Reload during hiding phase to reroll your ability. You can only do this once per round.")
            end
        end
    end
end

function SWEP:Reload()
    if SERVER and GWRound:IsCurrentState(GW_ROUND_HIDE) and not self:GetIsAbilityUsed() and not self.Owner:GetReRolledAbility() then
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
    local tr = util.TraceLine( {start = spos, endpos = sdest, filter = self.Owner, mask = MASK_SHOT_HULL} )
    self.Owner:LagCompensation(false)

    if tr.Hit and IsValid(tr.Entity) and (tr.Entity:GetClass() == "func_breakable" or tr.Entity:GetClass() == "func_breakable_surf") then

        if SERVER then tr.Entity:Fire("shatter") end

    end

end

function SWEP:SecondaryAttack()
    if self:GetIsAbilityUsed() then return end

    self.AbilityStartTime = CurTime()

    local abilityError = self:Ability()
    
    if not abilityError then
        if self.AbilitySound and SERVER then
            local abilitySound
            if istable( self.AbilitySound ) then
                abilitySound = Sound( self.AbilitySound[ math.random( #self.AbilitySound ) ] )
            else
                abilitySound = Sound( self.AbilitySound )
            end
            if abilitySound then
                self:EmitSound( abilitySound )
            end
        end
        self:SetIsAbilityUsed(true)
    else
        if CLIENT then
            self:EmitSound(Sound("WallHealth.Deny"))
            if IsFirstTimePredicted() then
                if abilityError == GW_ABILTY_CAST_ERROR_NO_TARGET then
                    self.Owner:PrintMessage(HUD_PRINTTALK, "Ability Failed: No target!")
                elseif abilityError == GW_ABILTY_CAST_ERROR_INVALID_TARGET then
                    self.Owner:PrintMessage(HUD_PRINTTALK, "Ability Failed: Invalid target!")
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
    if not IsValid(self) or not IsValid(self.Owner) or not self.Owner:Alive() then return false end

    local losTrace = util.TraceLine({
        start = self.Owner:GetPos() + self.Owner:OBBCenter(),
        endpos = target:GetPos() + target:OBBCenter(),
        filter = self.Owner,
        mask = mask or MASK_SOLID_BRUSHONLY
    })

    return not losTrace.Hit
end

function SWEP:GetSeekersInRange(range, ignoreLOS)
    local result = {}
    for _,v in pairs( player.GetAll() ) do
        if v:Alive() and v:GetPos():Distance(self.Owner:GetPos()) < range and v:IsSeeking() and (ignoreLOS or self:AbilityIsTargetInLOS(v)) then
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

function SWEP:AbilityTimerIfValidOwner(dur, reps, remove, fn)
    return self:AbilityTimer(dur, reps, removeTimerWithSwep, function()
        if not IsValid(self) or not IsValid(self.Owner) then return end
        fn()
    end)
end

function SWEP:AbilityTimerIfValidOwnerAndAlive(dur, reps, removeTimerWithSwep, fn)
    return self:AbilityTimer(dur, reps, removeTimerWithSwep, function()
        if not IsValid(self) or not IsValid(self.Owner) or not self.Owner:Alive() then return end
        fn()
    end)
end
