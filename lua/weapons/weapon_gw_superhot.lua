SWEP.Base = "weapon_gwbase"
SWEP.Name = "SUPER HOT"

function SWEP:Ability()
    local ply = self.Owner
    if SERVER then
        GAMEMODE.AbilitySuperHotMode = true
        GAMEMODE.AbilitySuperHotModePly = ply
        GAMEMODE.AbilitySuperHotModeEndTime = RealTime() + 12
    end
end

local function endSuperHotMode()
    if SERVER then
        GAMEMODE.AbilitySuperHotMode = false
        GAMEMODE.AbilitySuperHotModePly = nill
        game.SetTimeScale(1)

        if math.random(1, 100) <= 4 then
            PrintMessage( HUD_PRINTCENTER, "BONUS SLOWMOTION" )
            timer.Simple(8, function() game.SetTimeScale(1) end)
            game.SetTimeScale(0.3)
        end
    end
end

function SWEP:OnRemove()
    if IsValid(self.Owner) and self.Owner == GAMEMODE.AbilitySuperHotModePly then
        endSuperHotMode()
    end
end

if SERVER then
    local function superHotThink()
        if GAMEMODE.AbilitySuperHotMode then
            local ply = GAMEMODE.AbilitySuperHotModePly
            if not IsValid(ply) or not ply:Alive() or GAMEMODE.AbilitySuperHotModeEndTime < RealTime() then
                endSuperHotMode()
            else
                PrintMessage( HUD_PRINTCENTER, "SUPER HOT" )
                local velLen = ply:GetVelocity():Length()
                local scale = math.Clamp(velLen / 200, 0.1, 1)
                game.SetTimeScale(scale)
            end
        end
    end

    hook.Add("Think", "SuperHotThink", superHotThink)
end

hook.Add( "EntityEmitSound", "", function( t )

    local p = t.Pitch

    if game.GetTimeScale() != 1 then
        p = p * game.GetTimeScale()
    end

    if p != t.Pitch then
        t.Pitch = math.Clamp( p, 0, 255 )
        return true
    end

    if CLIENT and engine.GetDemoPlaybackTimeScale() != 1 then
        t.Pitch = math.Clamp( t.Pitch * engine.GetDemoPlaybackTimeScale(), 0, 255 )
        return true
    end

end )
