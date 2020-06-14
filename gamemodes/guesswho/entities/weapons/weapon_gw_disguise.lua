AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Disguise"

SWEP.AbilityDuration = 20
SWEP.AbilityDescription = "Transforms you into a seeker for $AbilityDuration seconds."

function SWEP:Ability()
    local ply = self.Owner
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
    ply:SetDisguised(true)
    local seekers = team.GetPlayers(GW_TEAM_SEEKING)
    if #seekers > 0 then
        ply:SetDisguiseName(seekers[math.random(1, #seekers)]:Nick())
    else
        ply:SetDisguiseName(ply:Nick())
    end
    if SERVER then
        ply:SetModel(GAMEMODE.GWConfig.SeekerModels[math.random(1, #GAMEMODE.GWConfig.SeekerModels)])
        ply:Give("weapon_gw_smgdummy")
        ply:SelectWeapon("weapon_gw_smgdummy")
    end
end

function SWEP:AbilityCleanup()
    if not IsValid( self.Owner ) then return end
    local ply = self.Owner
    ply:SetDisguised(false)
    if SERVER then
        ply:StripWeapon("weapon_gw_smgdummy")
        ply:SetModel(GAMEMODE.GWConfig.HidingModels[math.random(1, #GAMEMODE.GWConfig.HidingModels)])
    end
end
