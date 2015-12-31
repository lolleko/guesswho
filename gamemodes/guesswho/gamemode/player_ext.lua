local plymeta = FindMetaTable( "Player" )
if ( !plymeta ) then return end

function plymeta:ApplyStun( dur )

    local ply = self

    ply:Freeze( true )

    local tname = ply:SteamID() .. ".Stunned"

    if timer.Exists( tname ) then
        timer.Adjust( tname, dur, 1, function() ply:Freeze( false ) end )
    else
        timer.Create( tname, dur, 1, function() ply:Freeze( false ) end )
    end

end
