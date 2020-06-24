AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Ragdoll"

SWEP.AbilityDuration = 8
SWEP.AbilityDescription ="Pretty much what the name suggests.\nTransforms you into a ragdoll for $AbilityDuration seconds."

function SWEP:Ability()
    if CLIENT then return end

    local ply = self:GetOwner()
    self:AbilityTimerIfValidSWEP(self.AbilityDuration, 1, true, function()
        self:AbilityCleanup()
    end)


    local hunters = team.GetPlayers(GW_TEAM_SEEKING)
    local aliveHunters = {}
    for _, hunter in pairs(hunters) do
        if IsValid(hunter) and hunter:Alive() then
            table.insert(aliveHunters, hunter)
        end
    end

    local aliveHunter = aliveHunters[math.random(#aliveHunters)]

    if IsValid(aliveHunter) and IsValid(aliveHunter:GetActiveWeapon()) then
        net.Start( "PlayerKilledByPlayer" )

        net.WriteEntity(ply)
        net.WriteString(aliveHunter:GetActiveWeapon():GetClass())
        net.WriteEntity(aliveHunter)

        net.Broadcast()
    else
        net.Start("PlayerKilledSelf")
            net.WriteEntity( ply )
        net.Broadcast()
    end

    ply:GWStartRagdoll()
end

function SWEP:AbilityCleanup()
    if CLIENT then return end
    if not IsValid( self:GetOwner() ) then return end
    self:GetOwner():GWEndRagdoll()
end

if CLIENT then
    hook.Add( "OnEntityCreated", "gwRagdollPlayerColor", function( ent )
        if IsValid(ent) and ent:GetClass() == "prop_ragdoll" and IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer() then
            ent.GetPlayerColor = function(self) return self:GetOwner():GetPlayerColor() end
        end
    end)
end