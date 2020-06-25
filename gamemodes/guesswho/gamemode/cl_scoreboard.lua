function GM:ScoreboardShow()
    if ( not IsValid( G_GWScoreboard ) ) then
        G_GWScoreboard = vgui.Create( "DScoreboard" )
    end

    if ( IsValid( G_GWScoreboard ) ) then
        G_GWScoreboard:Show()
        G_GWScoreboard:MakePopup()
        G_GWScoreboard:SetKeyboardInputEnabled( false )
    end
end

function GM:ScoreboardHide()

    if ( IsValid( G_GWScoreboard ) ) then
        G_GWScoreboard:Hide()
    end

end

local SB = {}

function SB:Init()
    self:SetSize( 1000, 720 )
    self:Center()

    local HeaderLabel = vgui.Create("DLabel", self)
    HeaderLabel:SetSize( 200, 64 )
    HeaderLabel:SetPos( 0, 0 )
    HeaderLabel:SetFont("gw_font_medium")
    HeaderLabel:SetTextColor( G_GWColors.lightgrey )
    HeaderLabel:SetText("Guess Who?")
    HeaderLabel:CenterHorizontal()
    function HeaderLabel:Paint( w, h )
    end

    local Header1Label = vgui.Create("DLabel", self)
    Header1Label:SetSize( 200, 64 )
    Header1Label:SetPos( 560, 4 )
    Header1Label:SetFont("gw_font_small")
    Header1Label:SetTextColor( G_GWColors.lightgrey )
    Header1Label:SetText("by Lolle")

    local Header2Label = vgui.Create("DLabel", self)
    Header2Label:SetSize( 980, 64 )
    Header2Label:SetPos( 20, 15 )
    Header2Label:SetFont("gw_font_small")
    Header2Label:SetTextColor( G_GWColors.lightgrey )
    Header2Label:SetText( GWLANG:Translate( "scoreboard_server" ) .. ": " .. GetHostName() )
    function Header2Label:Think() self:SetText( GWLANG:Translate( "scoreboard_server" ) .. ": " .. GetHostName() ) end
    Header2Label:CenterHorizontal()

    local Header3Label = vgui.Create("DLabel", self)
    Header3Label:SetSize( 980, 64 )
    Header3Label:SetPos( 20, 35 )
    Header3Label:SetFont("gw_font_small")
    Header3Label:SetTextColor( G_GWColors.lightgrey )
    Header3Label:SetText( GWLANG:Translate( "scoreboard_map" ) .. ": " .. game.GetMap())
    function Header3Label:Think() self:SetText( GWLANG:Translate( "scoreboard_map" ) .. ": " .. game.GetMap() ) end
    Header3Label:CenterHorizontal()

    local Header4Label = vgui.Create("DLabel", self)
    Header4Label:SetSize( 980, 64 )
    Header4Label:SetPos( 20, 15 )
    Header4Label:SetFont("gw_font_small")
    Header4Label:SetTextColor( G_GWColors.lightgrey )
    Header4Label:SetText( GWLANG:Translate( "scoreboard_online" ) .. ": " .. #player.GetHumans() ..  "/" .. game.MaxPlayers())
    function Header4Label:Think() self:SetText( GWLANG:Translate( "scoreboard_online" ) .. ": " .. #player.GetHumans() ..  "/" .. game.MaxPlayers()) end
    Header4Label:CenterHorizontal()
    Header4Label:SetContentAlignment(6)

    local Header5Label = vgui.Create("DLabel", self)
    Header5Label:SetSize( 980, 64 )
    Header5Label:SetPos( 20, 35 )
    Header5Label:SetFont("gw_font_small")
    Header5Label:SetTextColor( G_GWColors.lightgrey )
    Header5Label:SetText( GWLANG:Translate( "scoreboard_spectators" ) .. ": " .. team.NumPlayers(TEAM_UNASSIGNED) + team.NumPlayers(TEAM_SPECTATOR))
    function Header5Label:Think() self:SetText( GWLANG:Translate( "scoreboard_spectators" ) .. ": " .. team.NumPlayers(TEAM_UNASSIGNED) + team.NumPlayers(TEAM_SPECTATOR)) end
    Header5Label:CenterHorizontal()
    Header5Label:SetContentAlignment(6)

    self.HidingHeader = vgui.Create("DLabel", self)
    self.HidingHeader:SetPos( 30, 90 )
    self.HidingHeader:SetFont("gw_font_normal")
    self.HidingHeader:SetTextColor( G_GWColors.lightgreybg )

    local HidingPanel = vgui.Create("DScrollPanel", self)
    HidingPanel:SetPos( 20, 120)
    HidingPanel:SetSize( 470, 580 )
    function HidingPanel:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, G_GWColors.greybg )
    end

    local HidingList = vgui.Create("DTeamPanel", HidingPanel)
    HidingList:SetSize( 470, 580 )
    HidingList:SetTeam( GW_TEAM_HIDING )

    self.SeekingHeader = vgui.Create("DLabel", self)
    self.SeekingHeader:SetPos( 880, 90 )
    self.SeekingHeader:SetFont("gw_font_normal")
    self.SeekingHeader:SetTextColor( G_GWColors.lightgrey )

    local SeekingPanel = vgui.Create("DScrollPanel", self)
    SeekingPanel:SetPos( 510, 120)
    SeekingPanel:SetSize( 470, 580 )
    function SeekingPanel:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, G_GWColors.greybg )
    end

    local SeekingList = vgui.Create("DTeamPanel", SeekingPanel)
    SeekingList:SetSize( 470, 580 )
    SeekingList:SetTeam( GW_TEAM_SEEKING )
end

function SB:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, G_GWColors.darkgreybg )
    draw.RoundedBox( 0, 0, 0, w, 80, G_GWColors.red )
end

function SB:Think()
    self.HidingHeader:SetText( GWLANG:Translate( "team_hiding" ) .. " " .. team.GetScore( GW_TEAM_HIDING ))
    self.HidingHeader:SizeToContents()
    self.SeekingHeader:SetText( GWLANG:Translate( "team_seeking" ) .. " "  .. team.GetScore( GW_TEAM_SEEKING ))
    self.SeekingHeader:SizeToContents()
end

vgui.Register("DScoreboard", SB)

local TEAMPANEL = {}

function TEAMPANEL:Init()
    self:SetSize( 470, 580 )
    self:SetSpaceY( 10 )
end

function TEAMPANEL:SetTeam( teamid)
    self.TeamID = teamid
    self:Think()
end

function TEAMPANEL:Think()
    for k,v in pairs(team.GetPlayers(self.TeamID)) do
        if ( IsValid( v.ScoreEntry ) ) then continue end

        v.ScoreEntry = vgui.Create( "DPlayerInfo", self )
        v.ScoreEntry:Setup( v, self.TeamID )
        self:Add(v.ScoreEntry)

    end
end

vgui.Register("DTeamPanel", TEAMPANEL, "DIconLayout")

local PLAYERINFO = {}

function PLAYERINFO:Init()
    self:SetSize( 470, 32 )

    self.AvatarButton = vgui.Create("DButton", self)
    self.AvatarButton:SetSize( 32, 64 )
    self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

    self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
    self.Avatar:SetSize( 32, 32 )
    self.Avatar:SetMouseInputEnabled( false )

    self.Name = vgui.Create( "DLabel" , self )
    self.Name:SetPos( 68, 0)
    self.Name:SetFont( "gw_font_normal" )
    self.Name:SetTextColor( G_GWColors.darkgrey )
    self.Name:SetSize( 320, 32 )

    self.Score = vgui.Create( "DLabel" , self )
    self.Score:SetPos( 380, 4)
    self.Score:SetSize( 60, 48 )
    self.Score:SetFont( "gw_font_normal" )
    self.Score:SetTextColor( G_GWColors.darkgrey )

    self.Ping = vgui.Create( "DLabel" , self )
    self.Ping:SetPos( 450, 8 )
    self.Ping:SetWidth( 50 )
    self.Ping:SetFont( "gw_font_small" )
    self.Ping:SetTextColor( G_GWColors.darkgrey )

    self.Mute = self:Add( "DImageButton" )
    self.Mute:SetSize( 24, 24 )
    self.Mute:SetPos( self.Avatar:GetWide() + 8, 4 )
end

function PLAYERINFO:Paint( w, h)
    if self.Player then
        draw.RoundedBox( 0, 0, 0, w, h, team.GetColor(self.Player:Team()) )
    end
end

function PLAYERINFO:Setup( ply, teamid )
    self.Player = ply
    self.TeamID = teamid

    self:Think()
end

function PLAYERINFO:Think()
    if not IsValid(self.Player) or self.Player:Team() ~= self.TeamID then
        self:Remove()
        return
    end

    local txtClr = G_GWColors.grey
    if self.Player:Alive() or self.Player:GWIsRagdolled() then txtClr = G_GWColors.lightgrey end

    if ( self.NumPing == nil or self.NumPing ~= self.Player:Ping() ) then
    self.NumPing = self.Player:Ping()
    self.Ping:SetText( self.NumPing )
    end

    self.Avatar:SetPlayer( self.Player, 64 )
    self.Name:SetText( self.Player:Nick() )
    self.Score:SetText( self.Player:Frags() )
    self.Score:SizeToContents()
    self.Ping:SizeToContents()
    self.Name:SetTextColor( txtClr )
    self.Score:SetTextColor( txtClr )
    self.Ping:SetTextColor( txtClr )

    if ( self.Muted == nil or self.Muted ~= self.Player:IsMuted() ) then

        self.Muted = self.Player:IsMuted()
        if ( self.Muted ) then
            self.Mute:SetImage( "icon32/muted.png" )
        else
            self.Mute:SetImage( "icon32/unmuted.png" )
        end

        self.Mute.DoClick = function() self.Player:SetMuted( not self.Muted ) end

    end
end

vgui.Register("DPlayerInfo", PLAYERINFO, "DPanel")
