function GM:ScoreboardShow()
    if ( !IsValid( g_Scoreboard ) ) then
        g_Scoreboard = vgui.Create( "DScoreboard" )
    end

    if ( IsValid( g_Scoreboard ) ) then
        g_Scoreboard:Show()
        g_Scoreboard:MakePopup()
        g_Scoreboard:SetKeyboardInputEnabled( false )
    end
end

function GM:ScoreboardHide()

    if ( IsValid( g_Scoreboard ) ) then
        g_Scoreboard:Hide()
    end

end

local SB = {}

function SB:Init()
    self:SetSize( 1000, 720 )
    self:Center()

    local HeaderLabel = vgui.Create("DLabel", self)
    HeaderLabel:SetSize( 200, 64 )
    HeaderLabel:SetPos( 0, 0 )
    HeaderLabel:SetFont("robot_medium")
    HeaderLabel:SetTextColor( clrs.lightgrey )
    HeaderLabel:SetText("Guess Who?")
    HeaderLabel:CenterHorizontal()
    function HeaderLabel:Paint( w, h )
        /*local x = 0
        local y = 0
        surface.SetDrawColor( clrs.lightgrey )
        for i=0, 5 - 1 do
            surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
        end*/
    end

    local Header2Label = vgui.Create("DLabel", self)
    Header2Label:SetSize( 980, 64 )
    Header2Label:SetPos( 20, 15 )
    Header2Label:SetFont("robot_small")
    Header2Label:SetTextColor( clrs.lightgrey )
    Header2Label:SetText("Server: " .. GetHostName())
    Header2Label:CenterHorizontal()

    local Header3Label = vgui.Create("DLabel", self)
    Header3Label:SetSize( 980, 64 )
    Header3Label:SetPos( 20, 35 )
    Header3Label:SetFont("robot_small")
    Header3Label:SetTextColor( clrs.lightgrey )
    Header3Label:SetText("Map: " .. game.GetMap())
    Header3Label:CenterHorizontal()

    local Header4Label = vgui.Create("DLabel", self)
    Header4Label:SetSize( 980, 64 )
    Header4Label:SetPos( 20, 15 )
    Header4Label:SetFont("robot_small")
    Header4Label:SetTextColor( clrs.lightgrey )
    Header4Label:SetText("Online: " .. #player.GetHumans() ..  "/" .. game.MaxPlayers())
    Header4Label:CenterHorizontal()
    Header4Label:SetContentAlignment(6)

    local Header5Label = vgui.Create("DLabel", self)
    Header5Label:SetSize( 980, 64 )
    Header5Label:SetPos( 20, 35 )
    Header5Label:SetFont("robot_small")
    Header5Label:SetTextColor( clrs.lightgrey )
    Header5Label:SetText("Spectators: " .. team.NumPlayers(TEAM_UNASSIGNED) + team.NumPlayers(TEAM_SPECTATOR))
    Header5Label:CenterHorizontal()
    Header5Label:SetContentAlignment(6)

    self.HidingHeader = vgui.Create("DLabel", self)
    self.HidingHeader:SetPos( 30, 90 )
    self.HidingHeader:SetFont("robot_normal")
    self.HidingHeader:SetTextColor( clrs.lightgreybg )

    local HidingPanel = vgui.Create("DScrollPanel", self)
    HidingPanel:SetPos( 20, 120)
    HidingPanel:SetSize( 470, 580 )
    function HidingPanel:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, clrs.greybg )
    end

    local HidingList = vgui.Create("DTeamPanel", HidingPanel)
    HidingList:SetSize( 470, 580 )
    HidingList:SetTeam( TEAM_HIDING )

    self.SeekingHeader = vgui.Create("DLabel", self)
    self.SeekingHeader:SetPos( 880, 90 )
    self.SeekingHeader:SetFont("robot_normal")
    self.SeekingHeader:SetTextColor( clrs.lightgrey )

    local SeekingPanel = vgui.Create("DScrollPanel", self)
    SeekingPanel:SetPos( 510, 120)
    SeekingPanel:SetSize( 470, 580 )
    function SeekingPanel:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, clrs.greybg )
    end

    local SeekingList = vgui.Create("DTeamPanel", SeekingPanel)
    SeekingList:SetSize( 470, 580 )
    SeekingList:SetTeam( TEAM_SEEKING )
end

function SB:Paint( w, h )
    draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgreybg )
    draw.RoundedBox( 0, 0, 0, w, 80, clrs.red )
end

function SB:Think()
    self.HidingHeader:SetText("Hiding " .. team.GetScore( TEAM_HIDING ))
    self.HidingHeader:SizeToContents()
    self.SeekingHeader:SetText("Seeking " .. team.GetScore( TEAM_SEEKING ))
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
    self:SetSize( 470, 64 )

    self.AvatarButton = vgui.Create("DButton", self)
    self.AvatarButton:SetSize( 64, 64 )
    self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

    self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
    self.Avatar:SetSize( 64, 64 )
    self.Avatar:SetMouseInputEnabled( false )

    self.Name = vgui.Create( "DLabel" , self )
    self.Name:SetPos( 68, 8)
    self.Name:SetFont( "robot_large" )
    self.Name:SetTextColor( clrs.darkgrey )
    self.Name:SetSize( 320, 48 )

    self.Score = vgui.Create( "DLabel" , self )
    self.Score:SetPos( 410, 8)
    self.Score:SetSize( 60, 48 )
    self.Score:SetFont( "robot_large" )
    self.Score:SetTextColor( clrs.darkgrey )

    self.Mute = self:Add( "DImageButton" )
    self.Mute:SetSize( 24, 24 )
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
    if !IsValid(self.Player) or self.Player:Team() != self.TeamID then
        self:Remove()
        return
    end

    local txtClr = clrs.grey
    if self.Player:Alive() then txtClr = clrs.lightgrey end

    self.Avatar:SetPlayer( self.Player, 64 )
    self.Name:SetText( self.Player:Nick() )
    self.Score:SetText( self.Player:Frags() )
    self.Score:SizeToContents()
    self.Name:SetTextColor( txtClr )
    self.Score:SetTextColor( txtClr )

    if ( self.Muted == nil or self.Muted != self.Player:IsMuted() ) then

        self.Muted = self.Player:IsMuted()
        if ( self.Muted ) then
            self.Mute:SetImage( "icon32/muted.png" )
        else
            self.Mute:SetImage( "icon32/unmuted.png" )
        end

        self.Mute.DoClick = function() self.Player:SetMuted( !self.Muted ) end

    end
end

vgui.Register("DPlayerInfo", PLAYERINFO, "DPanel")