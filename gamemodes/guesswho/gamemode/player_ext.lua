local plymeta = FindMetaTable( "Player" )
if ( !plymeta ) then return end

AccessorFunc( plymeta , "bStunned", "Stunned", FORCE_BOOL )

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

function plymeta:GetSeekerTouches()
    return self.iSeekerTouches or 0
end

function plymeta:SetSeekerTouches(val)
    self.iSeekerTouches = val
end

function plymeta:AddSeekerTouch()
    if (self.fLastSeekerTouch or 0) + 2 < CurTime() then
        self.iSeekerTouches = self:GetSeekerTouches() + 1
        self.fLastSeekerTouch = CurTime()
    end
end

function plymeta:ResetSeekerTouches()
    self.iSeekerTouches = 0
    self:StripWeapons()

    self:Give( GAMEMODE.Weapons[ math.random( 1, #GAMEMODE.Weapons ) ] )
end
