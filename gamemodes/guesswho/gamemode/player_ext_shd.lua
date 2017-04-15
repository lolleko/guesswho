local plymeta = FindMetaTable( "Player" )
if ( !plymeta ) then return end

AccessorFunc( plymeta, "iOldTeam", "PreviousTeam", FORCE_NUMBER )
AccessorFunc( plymeta , "bStunned", "Stunned", FORCE_BOOL )

function plymeta:SetSpeed( spd )
    self:SetWalkSpeed(spd)
    self:SetRunSpeed(spd)
end

function plymeta:IsSeeking()
    return ( self:Team() == TEAM_SEEKING )
end

function plymeta:IsHiding()
    return ( self:Team() == TEAM_HIDING )
end

function plymeta:ApplyStun( dur )

    local ply = self

    ply:SetStunned( true )

    ply:Freeze( true )

    local tname = ply:SteamID() .. ".Stunned"

    if timer.Exists( tname ) then
        timer.Adjust( tname, dur, 1, function() ply:Freeze( false ) ply:SetStunned( false ) end )
    else
        timer.Create( tname, dur, 1, function() ply:Freeze( false ) ply:SetStunned( false ) end )
    end

end

function plymeta:IsStunned()
    return self:GetStunned()
end


-- TOUCHES
function plymeta:GetSeekerTouches()
    return self:GetNWInt("seeker_touches", 0)
end

function plymeta:SetSeekerTouches(val)
    self:SetNWInt("seeker_touches", val)
end

function plymeta:GetLastSeekerTouch()
    return self:GetNWFloat("last_seeker_touch", 0)
end

function plymeta:SetLastSeekerTouch(val)
    self:SetNWFloat("last_seeker_touch", val)
end


function plymeta:AddSeekerTouch()
    if self:GetLastSeekerTouch() + 2 < CurTime() then
        self:SetSeekerTouches(self:GetSeekerTouches() + 1)
        self:SetLastSeekerTouch(CurTime())
    end
end

function plymeta:ResetSeekerTouches()
    self:SetSeekerTouches(0)

    if SERVER then
        self:StripWeapons()

        self:Give( GAMEMODE.Weapons[ math.random( 1, #GAMEMODE.Weapons ) ] )
    end
end

function plymeta:SetDeflect(state)
    self.deflect = state
    if state then
        self:SetMaterial("models/props_combine/portalball001_sheet")
    else
        self:SetMaterial("")
    end
end

function plymeta:GetDeflect()
    return self.deflect or false
end
