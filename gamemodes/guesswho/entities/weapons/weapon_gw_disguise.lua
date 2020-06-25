AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Disguise"

SWEP.AbilityDuration = 20
SWEP.AbilityDescription = "Transforms you into a seeker for $AbilityDuration seconds."

function SWEP:Ability()
    local ply = self:GetOwner()
    self:AbilityTimerIfValidOwner(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)
    ply:GWSetDisguised(true)
    local seekers = team.GetPlayers(GW_TEAM_SEEKING)
    if #seekers > 0 then
        ply:GWSetDisguiseName(seekers[math.random(1, #seekers)]:Nick())
    else
        ply:GWSetDisguiseName(ply:Nick())
    end
    if SERVER then
        ply:SetModel(GAMEMODE.GWConfig.SeekerModels[math.random(1, #GAMEMODE.GWConfig.SeekerModels)])
        ply:Give("weapon_gw_smgdummy")
        ply:SelectWeapon("weapon_gw_smgdummy")
    end
end

function SWEP:AbilityCleanup()
    if not IsValid( self:GetOwner() ) then return end
    local ply = self:GetOwner()
    ply:GWSetDisguised(false)
    if SERVER then
        ply:StripWeapon("weapon_gw_smgdummy")
        ply:SetModel(GAMEMODE.GWConfig.HidingModels[math.random(1, #GAMEMODE.GWConfig.HidingModels)])
    end
end

if CLIENT then
    hook.Add("HUDPaint", "gwDisguiseInfoHUDPaint", function()
        local ply = LocalPlayer()
        if not ply:Alive() and IsValid(ply:GetObserverTarget()) then
            ply = ply:GetObserverTarget()
        end
        if IsValid(ply) and ply:GWIsDisguised() then
      
            local text = "Disguised as: " .. ply:GWGetDisguiseName()

            surface.SetFont("gw_font_normal")

            local w, h = surface.GetTextSize(text);

            local x = ScrW() / 2
            local y = ScrH() - h - 10

            surface.SetTextPos(x - w / 2, y - h / 2)
            surface.SetTextColor(G_GWColors.white:Unpack())
            surface.DrawText(text)
        end
    end)
end