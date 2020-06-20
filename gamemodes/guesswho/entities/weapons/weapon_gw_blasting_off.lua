AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Blast Off"

SWEP.AbilityDuration = 3
SWEP.AbilityDescription = "Launches all seekers into the air after a short delay.\n The seekers are stuck in the air for at least $AbilityDuration seconds.\n\nDoes not work well indoors."

function SWEP:Ability()
    if SERVER then
        for _, ply in pairs(player.GetAll()) do
            if ply:IsAlive() and ply:IsSeeking() then
                timer.Simple(0.5, function() ply:SetVelocity(Vector(0, 0, 2500)) end)
                local effect = EffectData()
                effect:SetEntity(ply)
                effect:SetMagnitude(3)
                util.Effect("gw_blast_off", effect, true, true)

                local tName = "gwLaunch" .. ply:SteamID()
                timer.Create(tName, 0.1, 15, function()
                    if util.QuickTrace(ply:EyePos(), Vector(0, 0, 30), ply).HitWorld then
                        timer.Remove(tName)
                        ply:SetGravity(-1)
                        timer.Simple(self.AbilityDuration, function() ply:SetGravity(1) end)
                    end
                end)
            end
        end
    end
end
