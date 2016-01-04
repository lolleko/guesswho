function GM:GetRoundState() return GAMEMODE.RoundState end

function GM:GetRoundLabel() return GAMEMODE.RoundLabel end

function GM:SetRoundLabel( lbl )
    self.RoundLabel = lbl
end

function GM:GetEndTime()
	return GetGlobalFloat( "gwEndTime", 0 )
end

function GM:RoundStateChange( old, new )

    if ROUND_PRE_GAME == new then
        self:SetRoundLabel( gwlang.translate( "round_pre_game" ) )
    elseif ROUND_WAITING_PLAYERS == new then
        self:SetRoundLabel( gwlang.translate( "round_waiting_players" ) )
    elseif ROUND_CREATING == new then
        self:SetRoundLabel( gwlang.translate( "round_creating" ) )
    elseif ROUND_HIDE == new then
        self:SetRoundLabel( gwlang.translate( "round_hide" ) )
    elseif ROUND_SEEK == new then
        self:SetRoundLabel( gwlang.translate( "round_seek" ) )
    elseif ROUND_POST == new then
        self:SetRoundLabel( gwlang.translate( "round_post" ) )
    elseif ROUND_NAV_GEN == new then
        self:SetRoundLabel( gwlang.translate( "round_nav_gen" ) )
    else
        self:SetRoundLabel( "ERROR!" )
    end

end

local function ReceiveRoundState()

    local old = GAMEMODE:GetRoundState()
	GAMEMODE.RoundState = net.ReadUInt( 3 )

	if old != GAMEMODE.RoundState then
	  GAMEMODE:RoundStateChange( old, GAMEMODE.RoundState )
	end

end
net.Receive( "gwRoundState", ReceiveRoundState )
