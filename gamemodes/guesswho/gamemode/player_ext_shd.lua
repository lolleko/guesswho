local plymeta = FindMetaTable( "Player" )
if ( not plymeta ) then return end

AccessorFunc( plymeta, "iOldTeam", "PreviousTeam", FORCE_NUMBER )

function plymeta:GWIsSeeking()
    return ( self:Team() == GW_TEAM_SEEKING )
end

function plymeta:GWIsHiding()
    return ( self:Team() == GW_TEAM_HIDING )
end

function plymeta:GWSetStunned(state)
    self:SetNWBool("gwIsStunned", state)
end

function plymeta:GWGetStunned()
    return self:GetNWBool("gwIsStunned", false)
end

function plymeta:GWIsStunned()
    return self:GWGetStunned()
end

-- TOUCHES
function plymeta:GWGetSeekerTouches()
    return self:GetNWInt("gwSeekerTouches", 0)
end

function plymeta:GWSetSeekerTouches(val)
    self:SetNWInt("gwSeekerTouches", val)
end

function plymeta:GWGetLastSeekerTouch()
    return self:GetNWFloat("gwLastSeekerTouch", 0)
end

function plymeta:GWSetLastSeekerTouch(val)
    self:SetNWFloat("gwLastSeekerTouch", val)
end

function plymeta:GWAddSeekerTouch()
    if self:GWGetLastSeekerTouch() + 2 < CurTime() then
        self:GWSetSeekerTouches(self:GWGetSeekerTouches() + 1)
        self:GWSetLastSeekerTouch(CurTime())
        if SERVER then
            self:GWPlaySoundForPlayer("buttons/blip1.wav")
        end

        if self:GWGetSeekerTouches() >= GetConVar("gw_touches_required"):GetInt() then
            self:GWResetSeekerTouches()
        end
    end
end

function plymeta:GWResetSeekerTouches()
    self:GWSetSeekerTouches(0)

    if SERVER then
        self:GWGiveRandomAbility()
    end
end

function plymeta:GWSetDeflecting(state)
    self:SetNWBool("gwAbilityIsDeflecting", state)
end

function plymeta:GWIsDeflecting()
    return self:GetNWBool("gwAbilityIsDeflecting", false)
end

function plymeta:GWSetDisguised(state)
    self:SetNWBool("gwAbilityIsDisguised", state)
end

function plymeta:GWIsDisguised()
    return self:GetNWBool("gwAbilityIsDisguised", false)
end

function plymeta:GWSetDisguiseName(name)
    self:SetNWString("gwAbilityDisguiseName", string.sub(name, 1, math.min(#name, 64)))
end

function plymeta:GWGetDisguiseName()
    return self:GetNWString("gwAbilityDisguiseName", "")
end

function plymeta:GWSetRagdolled(state)
    self:SetNWBool("gwAbilityIsRagdolled", state)
end

function plymeta:GWIsRagdolled()
    return self:GetNWBool("gwAbilityIsRagdolled", false)
end

function plymeta:GWSetHullNetworked(xy, z)
    self:SetHull(Vector(-xy, -xy, 0), Vector(xy, xy, z))
    self:SetHullDuck(Vector(-xy, -xy, 0), Vector(xy, xy, z))

    if SERVER then
        net.Start("gwPlayerHull")
        net.WriteFloat( xy )
        net.WriteFloat( z )
        net.Send(self)
    end
end

net.Receive("gwPlayerHull", function(len, ply)
    local xy = net.ReadFloat()
    local z = net.ReadFloat()

    if ply == LocalPlayer() then
        LocalPlayer():GWSetHullNetworked(xy, z)
    end
end)
