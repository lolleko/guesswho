AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "SUPER HOT"

SWEP.AbilityDuration = 8
SWEP.AbilityDescription = "Not quite like the original.\n\nSlow Motion for everyone, but yourself.\nLasts $AbilityDuration seconds."

local playerSuperHotNWVarName = "gwIsSuperHotEnabled"

function SWEP:Ability()
    local ply = self.Owner
    if SERVER then
        -- dont consume if already activated by someone else
        if GAMEMODE.AbilitySuperHotMode then
            return GW_ABILTY_CAST_ERROR_ALREADY_ACTIVE
        end

        GAMEMODE.AbilitySuperHotMode = true
        GAMEMODE.AbilitySuperHotModePly = ply
        GAMEMODE.AbilitySuperHotModeEndTime = RealTime() + self.AbilityDuration
        ply:SetWalkSpeed(ply:GetWalkSpeed() * 5)
        ply:SetRunSpeed(ply:GetRunSpeed() * 5)
        ply:SetNWBool(playerSuperHotNWVarName, true)
        game.SetTimeScale(0.3)
    end
end

local function endSuperHotMode()
    if SERVER then
        local ply = GAMEMODE.AbilitySuperHotModePly
        game.SetTimeScale(1)
        ply:SetWalkSpeed(ply:GetWalkSpeed() / 5)
        ply:SetRunSpeed(ply:GetRunSpeed() / 5)
        ply:SetNWBool(playerSuperHotNWVarName, false)

        GAMEMODE.AbilitySuperHotMode = false
        GAMEMODE.AbilitySuperHotModePly = nil
    end
end

function SWEP:AbilityCleanup()
    if IsValid(self.Owner) and self.Owner == GAMEMODE.AbilitySuperHotModePly then
        endSuperHotMode()
    end
end

if SERVER then
    hook.Add("Think", "SuperHotThink", function()
        if GAMEMODE.AbilitySuperHotMode then
            local ply = GAMEMODE.AbilitySuperHotModePly
            if not IsValid(ply) or not ply:Alive() or GAMEMODE.AbilitySuperHotModeEndTime < RealTime() then
                endSuperHotMode()
            end
        end
    end)
end

if CLIENT then
    hook.Add("HUDPaint", "gwSuperHotHudPaint", function()
        if IsValid(LocalPlayer()) and LocalPlayer():GetNWBool(playerSuperHotNWVarName) then
            local x = ScrW() / 2
            local y = ScrH() / 2 - 200
        
            local text = ""

            if math.floor(RealTime()) % 2 == 0 then
                surface.SetFont("gw_font_larger")
                text = "SUPER"
            else
                surface.SetFont("gw_font_huge")
                text = "HOT"
            end

            local w, h = surface.GetTextSize(text);

            surface.SetTextPos(x - w / 2, y - h / 2)
            surface.SetTextColor(clrs.white:Unpack())
            surface.DrawText(text)
        end
    end)
end

hook.Add( "EntityEmitSound", "", function( t )

    local p = t.Pitch

    if game.GetTimeScale() ~= 1 then
        p = p * game.GetTimeScale()
    end

    if p ~= t.Pitch then
        t.Pitch = math.Clamp( p, 0, 255 )
        return true
    end

    if CLIENT and engine.GetDemoPlaybackTimeScale() ~= 1 then
        t.Pitch = math.Clamp( t.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255 )
        return true
    end

end )
