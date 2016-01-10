--[[---------------------------------------------------------
   Name: gamemode:ShowTeam()
   Desc:
-----------------------------------------------------------]]
function GM:ShowTeam()

    if ( IsValid( self.TeamSelectFrame ) ) then return end

    -- Simple team selection box
    self.TeamSelectFrame = vgui.Create( "DPanel" )
    self.TeamSelectFrame:SetPos(0,0)
    self.TeamSelectFrame:SetSize( ScrW(), ScrH() )

    local links = { { gwlang.translate( "teamselect_workshop_ref" ), "http://steamcommunity.com/sharedfiles/filedetails/?id=480998235" },
                    { gwlang.translate( "teamselect_workshop_changelog" ), "http://steamcommunity.com/sharedfiles/filedetails/changelog/480998235" },
                    { gwlang.translate( "teamselect_workshop_bug" ), "http://steamcommunity.com/workshop/filedetails/discussion/480998235/523897653307060068/" },
                    --{ gwlang.translate( "teamselect_workshop_contact" ), "http://steamcommunity.com/id/lolleko/" }
                  }

    local linkOffsetY = 180

    for _, v in pairs( links ) do
        local LinkButton = vgui.Create( "DButton", self.TeamSelectFrame )
        LinkButton:SetPos( ScrW() / 2 - 620, linkOffsetY )
        LinkButton:SetSize( 280, 40 )
        LinkButton:SetFont("robot_small")
        LinkButton:SetText( v[1] )
        LinkButton:SetTextColor( clrs.lightgrey )
        function LinkButton.DoClick() gui.OpenURL( v[2] ) end
        function LinkButton:Paint( w, h)
            draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
        end
        linkOffsetY = linkOffsetY + 80
    end

    local controls = {}
    if input.LookupBinding( "duck" ) then table.insert( controls, { string.upper( input.LookupBinding( "duck" ) ), gwlang.translate( "teamselect_controls_sit" ) } ) end
    if input.LookupBinding( "attack2" ) then table.insert( controls, { string.upper( input.LookupBinding( "attack2" ) ), gwlang.translate( "teamselect_controls_ability" ) } ) end
    if input.LookupBinding( "gm_showhelp" ) then table.insert( controls, { string.upper( input.LookupBinding( "gm_showhelp" ) ), gwlang.translate( "teamselect_controls_settings" ) } ) end
    if input.LookupBinding( "gm_showteam" ) then table.insert( controls, { string.upper( input.LookupBinding( "gm_showteam" ) ), gwlang.translate( "teamselect_controls_team" ) } ) end
    if input.LookupBinding( "gm_showspare2" ) then table.insert( controls, { string.upper( input.LookupBinding( "gm_showspare2" ) ), gwlang.translate( "teamselect_controls_random" ) } ) end
    if input.LookupBinding( "menu" ) && input.LookupBinding( "menu_context" ) then table.insert( controls, { string.upper( input.LookupBinding( "menu" ) ) .. " + " .. string.upper( input.LookupBinding( "menu_context" ) ), gwlang.translate( "teamselect_controls_taunts" ) } ) end

    local controlsOffsetY = 180

    for _, v in pairs( controls ) do
        local ControlKey = vgui.Create( "DLabel", self.TeamSelectFrame )
        ControlKey:SetPos( ScrW() / 2 + 340, controlsOffsetY )
        ControlKey:SetSize( 80, 40 )
        ControlKey:SetFont("robot_smaller")
        ControlKey:SetText( v[1] )
        ControlKey:SetTextColor( clrs.lightgrey )
        ControlKey:SetContentAlignment( 5 )
        function ControlKey:Paint( w, h)
            draw.RoundedBox( 0, 0, 0, w, h, clrs.red )
        end

        local ControlDesc = vgui.Create( "DLabel", self.TeamSelectFrame )
        ControlDesc:SetPos( ScrW() / 2 + 420, controlsOffsetY )
        ControlDesc:SetSize( 200, 40 )
        ControlDesc:SetFont("robot_small")
        ControlDesc:SetText( v[2] )
        ControlDesc:SetTextColor( clrs.lightgrey )
        ControlDesc:SetContentAlignment( 5 )
        function ControlDesc:Paint( w, h)
            draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
        end

        controlsOffsetY = controlsOffsetY + 80
    end

    local HeaderImage = vgui.Create("DImage", self.TeamSelectFrame)
    HeaderImage:SetSize( 285, 96 )
    HeaderImage:SetPos( 0, 60 )
    HeaderImage:SetImage( "vgui/gw/logo_main.png" )
    HeaderImage:CenterHorizontal()

    --Hiding Button
    local TeamHidingPanel = vgui.Create( "DPanel", self.TeamSelectFrame )
    TeamHidingPanel:SetPos( ScrW() / 2 - 300, 180 )
    TeamHidingPanel:SetSize( 280, 280 )
    function TeamHidingPanel:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, team.GetColor(TEAM_HIDING) )
    end

    local TeamHidingModel = vgui.Create( "DModelPanel", TeamHidingPanel )
    TeamHidingModel:SetSize( 280, 280 )
    TeamHidingModel:SetModel( GAMEMODE.Models[math.random(1,#GAMEMODE.Models)] )
    local seq, dur = TeamHidingModel.Entity:LookupSequence("gesture_wave")
    TeamHidingModel.Entity:SetSequence(seq)
    TeamHidingModel.Entity:SetAngles( Angle( 0, 70, 0 ) )
    TeamHidingModel.Entity:DrawShadow(true)
    timer.Simple(dur-0.2,function() if !TeamHidingModel.Entity then return end TeamHidingModel.Entity:SetSequence("idle_all_01") TeamHidingModel.Entity:SetAngles( Angle( 0, 0, 0 ) ) end)
    function TeamHidingModel:LayoutEntity( ent )
        self:RunAnimation()
    end

    local TeamHidingButton = vgui.Create( "DButton", TeamHidingPanel )
    function TeamHidingButton.DoClick()
        if self:IsBalancedToJoin(TEAM_HIDING) then
            self:HideTeam() RunConsoleCommand( "changeteam", TEAM_HIDING )
        end
    end
    TeamHidingButton:SetFont( "robot_normal" )
    TeamHidingButton:SetTextColor( clrs.lightgrey )
    TeamHidingButton:SetText( gwlang.translate( "team_hiding" ) .. "(" .. team.NumPlayers( TEAM_HIDING ) .. ")" )
    TeamHidingButton:SetSize( 280, 280 )
    function TeamHidingButton:Paint( w, h )
        return
    end
    function TeamHidingButton:Think()
        self:SetText( gwlang.translate( "team_hiding" ) .. "(" .. team.NumPlayers( TEAM_HIDING ) .. ")" )
    end

    --Seeking Button
    local TeamSeekingPanel = vgui.Create( "DPanel", self.TeamSelectFrame )
    TeamSeekingPanel:SetPos( ScrW() / 2 + 20, 180 )
    TeamSeekingPanel:SetSize( 280, 280 )
    function TeamSeekingPanel:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, team.GetColor(TEAM_SEEKING) )
    end

    local TeamSeekingModel = vgui.Create( "DModelPanel", TeamSeekingPanel )
    TeamSeekingModel:SetSize( 280, 280 )
    TeamSeekingModel:SetModel( "models/player/combine_super_soldier.mdl" )
    function TeamSeekingModel:LayoutEntity( ent )
        ent:SetAngles( Angle( 0, 30, 0 ) )
    end

    local TeamSeekingButton = vgui.Create( "DButton", TeamSeekingPanel )
    function TeamSeekingButton.DoClick()
        if self:IsBalancedToJoin(TEAM_SEEKING) then
            self:HideTeam() RunConsoleCommand( "changeteam", TEAM_SEEKING )
        end
    end
    TeamSeekingButton:SetFont( "robot_normal" )
    TeamSeekingButton:SetTextColor( clrs.lightgrey )
    TeamSeekingButton:SetText( gwlang.translate( "team_seeking" ) .. "(" .. team.NumPlayers( TEAM_SEEKING ) .. ")" )
    TeamSeekingButton:SetSize( 280, 280 )
    function TeamSeekingButton:Paint( w, h )
        return
    end
    function TeamSeekingButton:Think()
        self:SetText( gwlang.translate( "team_seeking" ) .. "(" .. team.NumPlayers( TEAM_SEEKING ) .. ")" )
    end

    --spectate and auto buttons
    local TeamSpectateButton = vgui.Create( "DButton", self.TeamSelectFrame )
    TeamSpectateButton:SetPos( ScrW() / 2 - 300, 500 )
    TeamSpectateButton:SetSize( 600, 40 )
    TeamSpectateButton:SetFont("robot_small")
    TeamSpectateButton:SetText( gwlang.translate( "teamselect_buttons_spectate" ) )
    TeamSpectateButton:SetTextColor( clrs.lightgrey )
    function TeamSpectateButton.DoClick() self:HideTeam() RunConsoleCommand( "changeteam", TEAM_SPECTATOR ) end
    function TeamSpectateButton:Paint( w, h)
        draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
    end

    local TeamAutoButton = vgui.Create( "DButton", self.TeamSelectFrame )
    TeamAutoButton:SetPos( ScrW() / 2 - 300, 580 )
    TeamAutoButton:SetSize( 600, 40 )
    TeamAutoButton:SetFont("robot_small")
    TeamAutoButton:SetText( gwlang.translate( "teamselect_buttons_auto" ) )
    TeamAutoButton:SetTextColor( clrs.lightgrey )
    function TeamAutoButton.DoClick() self:HideTeam() RunConsoleCommand( "changeteam", team.BestAutoJoinTeam() ) end
    function TeamAutoButton:Paint( w, h)
        draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
    end

    self.TeamSelectFrame:SetSize( ScrW(), ScrH() )
    self.TeamSelectFrame:Center()
    self.TeamSelectFrame:MakePopup()
    self.TeamSelectFrame:SetKeyboardInputEnabled( false )

    function self.TeamSelectFrame:Paint(w,h)
        return
    end

    function self.TeamSelectFrame:Think()
        if GAMEMODE:GetRoundState() == NAV_GEN then
            self:Remove()
            self = nil
        end
    end

end

function GM:IsBalancedToJoin( teamid )

    if LocalPlayer():Team() == teamid then return true end

    if teamid == TEAM_SEEKING then
        if team.NumPlayers( TEAM_SEEKING ) > team.NumPlayers( TEAM_HIDING ) or (LocalPlayer():Team() == TEAM_HIDING && team.NumPlayers( TEAM_SEEKING ) == team.NumPlayers( TEAM_HIDING )) then
            return false
        end
    elseif teamid == TEAM_HIDING then
        if team.NumPlayers( TEAM_HIDING ) > team.NumPlayers( TEAM_SEEKING ) or (LocalPlayer():Team() == TEAM_SEEKING && team.NumPlayers( TEAM_SEEKING ) == team.NumPlayers( TEAM_HIDING )) then
            return false
        end
    end
    return true
end

function GM:HideTeam()

    if ( IsValid(self.TeamSelectFrame) ) then
        self.TeamSelectFrame:Remove()
        self.TeamSelectFrame = nil
    end

end
