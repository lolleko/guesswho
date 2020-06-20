local GWRound = {}

GM.GWRound = GWRound

function GWRound:GetRoundState() return self.RoundState end

function GWRound:IsCurrentState(state) return self.RoundState == state end

function GWRound:GetRoundLabel() return self.RoundLabel end

function GWRound:SetRoundLabel( lbl )
    self.RoundLabel = lbl
end

function GWRound:GetEndTime()
    return GetGlobalFloat( "gwEndTime", 0 )
end

function GWRound:RoundStateChange( old, new )

    if GW_ROUND_PRE_GAME == new then
        self:SetRoundLabel( GWLANG:Translate( "round_pre_game" ) )
        hook.Call( "GWPreGame", GAMEMODE  )
    elseif GW_ROUND_WAITING_PLAYERS == new then
        self:SetRoundLabel( GWLANG:Translate( "round_waiting_players" ) )
    elseif GW_ROUND_CREATING_NPCS == new then
        self:SetRoundLabel( GWLANG:Translate( "round_creating" ) )
        hook.Call( "GWCreating", GAMEMODE  )
    elseif GW_ROUND_HIDE == new then
        self:SetRoundLabel( GWLANG:Translate( "round_hide" ) )
        hook.Call( "GWHide", GAMEMODE  )
    elseif GW_ROUND_SEEK == new then
        self:SetRoundLabel( GWLANG:Translate( "round_seek" ) )
        hook.Call( "GWSeek", GAMEMODE  )
    elseif GW_ROUND_POST == new then
        self:SetRoundLabel( GWLANG:Translate( "round_post" ) )
        hook.Call( "GWPostRound", GAMEMODE  )
    elseif GW_ROUND_NAV_GEN == new then
        self:SetRoundLabel( GWLANG:Translate( "round_nav_gen" ) )
    else
        self:SetRoundLabel( "ERROR!" )
    end

end

local function ReceiveRoundState()

    local old = GAMEMODE.GWRound:GetRoundState()
    GAMEMODE.GWRound.RoundState = net.ReadUInt( 8 )

    if old ~= GAMEMODE.GWRound.RoundState then
        GAMEMODE.GWRound:RoundStateChange( old, GAMEMODE.GWRound.RoundState )
    end

end
net.Receive( "gwRoundState", ReceiveRoundState )
