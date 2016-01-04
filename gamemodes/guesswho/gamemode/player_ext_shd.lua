local plymeta = FindMetaTable( "Player" )
if ( !plymeta ) then return end

AccessorFunc( plymeta, "iOldTeam", "PreviousTeam", FORCE_NUMBER )

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
