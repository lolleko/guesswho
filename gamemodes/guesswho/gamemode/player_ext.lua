local plymeta = FindMetaTable( "Player" )
if ( not plymeta ) then return end

AccessorFunc(plymeta, "gwReRolledAbility", "GWReRolledAbility", FORCE_BOOL)
AccessorFunc(plymeta, "gwDiedInPrep", "GWDiedInPrep", FORCE_BOOL)
AccessorFunc(plymeta, "gwPrepAbility", "GWPrepAbility", FORCE_STRING)

function plymeta:GWApplyStun( dur )

    local ply = self

    ply:GWSetStunned( true )

    ply:Freeze( true )

    local tname = ply:SteamID() .. ".Stunned"

    if timer.Exists( tname ) then
        timer.Adjust( tname, dur, 1, function() ply:Freeze( false ) ply:GWSetStunned( false ) end )
    else
        timer.Create( tname, dur, 1, function() ply:Freeze( false ) ply:GWSetStunned( false ) end )
    end

end

function plymeta:GWPlaySoundForPlayer(path)
    self:SendLua("surface.PlaySound('" .. path .. "')")
end

function plymeta:GWGiveRandomAbility()
    self:StripWeapons()

    self:Give( GAMEMODE.GWConfig.ActiveAbilities[ math.random( 1, #GAMEMODE.GWConfig.ActiveAbilities ) ] )
end
