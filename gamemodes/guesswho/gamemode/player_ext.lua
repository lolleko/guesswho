local plymeta = FindMetaTable( "Player" )
if ( !plymeta ) then return end

AccessorFunc(plymeta, "gwReRolledAbility", "ReRolledAbility", FORCE_BOOL)
AccessorFunc(plymeta, "gwDiedInPrep", "DiedInPrep", FORCE_BOOL)


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

function plymeta:PlaySoundForPlayer(path)
    self:SendLua("surface.PlaySound('" .. path .. "')")
end

function plymeta:GiveRandomAbility()
    self:StripWeapons()

    self:Give( GAMEMODE.GWConfig.ActiveAbilities[ math.random( 1, #GAMEMODE.GWConfig.ActiveAbilities ) ] )
end
