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
    return self.iSeekerTouches or 0
end

function plymeta:SetSeekerTouches(val)
    self.iSeekerTouches = val
end

function plymeta:GetLastSeekerTouch()
    return self.fLastSeekerTouch or 0
end

function plymeta:AddSeekerTouch()
    if self:GetLastSeekerTouch() + 2 < CurTime() then
        self.iSeekerTouches = self:GetSeekerTouches() + 1
        self.fLastSeekerTouch = CurTime()
    end
end

function plymeta:ResetSeekerTouches()
    self.iSeekerTouches = 0

    if SERVER then
        self:StripWeapons()

        self:Give( GAMEMODE.Weapons[ math.random( 1, #GAMEMODE.Weapons ) ] )
    end
end
