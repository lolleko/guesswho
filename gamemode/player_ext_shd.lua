local plymeta = FindMetaTable( "Player" )
if ( !plymeta ) then return end

AccessorFunc( plymeta, "iOldTeam", "PreviousTeam", FORCE_NUMBER )

function plymeta:SetSpeed( spd )
	self:SetWalkSpeed(spd)
	self:SetRunSpeed(spd)
	self:SetMaxSpeed(spd)
end

