local plymeta = FindMetaTable( "Player" )
if ( not plymeta ) then return end

AccessorFunc( plymeta, "iOldTeam", "PreviousTeam", FORCE_NUMBER )

function plymeta:SetSpeed( spd )
    self:SetWalkSpeed(spd)
    self:SetRunSpeed(spd)
end

function plymeta:IsSeeking()
    return ( self:Team() == GW_TEAM_SEEKING )
end

function plymeta:IsHiding()
    return ( self:Team() == GW_TEAM_HIDING )
end

function plymeta:SetStunned(state)
    self:SetNWBool("gwIsStunned", state)
end

function plymeta:GetStunned()
    return self:GetNWBool("gwIsStunned", false)
end

function plymeta:IsStunned()
    return self:GetStunned()
end

-- TOUCHES
function plymeta:GetSeekerTouches()
    return self:GetNWInt("gwSeekerTouches", 0)
end

function plymeta:SetSeekerTouches(val)
    self:SetNWInt("gwSeekerTouches", val)
end

function plymeta:GetLastSeekerTouch()
    return self:GetNWFloat("gwLastSeekerTouch", 0)
end

function plymeta:SetLastSeekerTouch(val)
    self:SetNWFloat("gwLastSeekerTouch", val)
end

function plymeta:AddSeekerTouch()
    if self:GetLastSeekerTouch() + 2 < CurTime() then
        self:SetSeekerTouches(self:GetSeekerTouches() + 1)
        self:SetLastSeekerTouch(CurTime())
        if SERVER then
            self:PlaySoundForPlayer("buttons/blip1.wav")
        end

        if self:GetSeekerTouches() >= GetConVar("gw_touches_required"):GetInt() then
            self:ResetSeekerTouches()
        end
    end
end

function plymeta:ResetSeekerTouches()
    self:SetSeekerTouches(0)

    if SERVER then
        self:GiveRandomAbility()
    end
end

function plymeta:SetDeflecting(state)
    self:SetNWBool("gwAbilityIsDeflecting", state)
end

function plymeta:IsDeflecting()
    return self:GetNWBool("gwAbilityIsDeflecting", false)
end

function plymeta:SetDisguised(state)
    self:SetNWBool("gwAbilityIsDisguised", state)
end

function plymeta:IsDisguised()
    return self:GetNWBool("gwAbilityIsDisguised", false)
end

function plymeta:SetHullNetworked(xy, z)
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
        LocalPlayer():SetHullNetworked(xy, z)
    end
end)
