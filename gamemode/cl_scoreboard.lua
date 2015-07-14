local clrs = { red = Color(231,77,60), blue = Color(53,152,219), green = Color(45,204,113), purple = Color(108,113,196), yellow = Color(241,196,16), lightgrey = Color(236,240,241), grey = Color(42,42,42), darkgrey = Color(26,26,26), black = Color(0,0,0)}

surface.CreateFont( "Roboto_Normal", {
	font = "Roboto",
	size = 48
} )

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
	HeaderLabel:SetSize( 245, 64 )
	HeaderLabel:SetPos( 0, 20 )
	HeaderLabel:SetFont("Roboto_Normal")
	HeaderLabel:SetTextColor( clrs.lightgrey )
	HeaderLabel:SetText(" GUESS WHO ")
	HeaderLabel:CenterHorizontal()
	function HeaderLabel:Paint( w, h )
		local x = 0
		local y = 0
		surface.SetDrawColor( clrs.lightgrey )
		for i=0, 5 - 1 do
			surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
		end
	end

	self.HidingHeader = vgui.Create("DLabel", self)
	self.HidingHeader:SetPos( 30, 90 )
	self.HidingHeader:SetFont("Info_Text")
	self.HidingHeader:SetTextColor( clrs.lightgrey )

	local HidingPanel = vgui.Create("DScrollPanel", self)
	HidingPanel:SetPos( 20, 120)
	HidingPanel:SetSize( 470, 580 )
	function HidingPanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
	end

	local HidingList = vgui.Create("DTeamPanel", HidingPanel)
	HidingList:SetSize( 470, 580 )
	HidingList:SetTeam( TEAM_HIDING )

	self.SeekingHeader = vgui.Create("DLabel", self)
	self.SeekingHeader:SetPos( 880, 90 )
	self.SeekingHeader:SetFont("Info_Text")
	self.SeekingHeader:SetTextColor( clrs.lightgrey )

	local SeekingPanel = vgui.Create("DScrollPanel", self)
	SeekingPanel:SetPos( 510, 120)
	SeekingPanel:SetSize( 470, 580 )
	function SeekingPanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
	end

	local SeekingList = vgui.Create("DTeamPanel", SeekingPanel)
	SeekingList:SetSize( 470, 580 )
	SeekingList:SetTeam( TEAM_SEEKING )
end

function SB:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgrey )
end

function SB:Think()
	self.HidingHeader:SetText("Hiding "..team.GetScore( TEAM_HIDING ))
	self.HidingHeader:SizeToContents()
	self.SeekingHeader:SetText("Seeking "..team.GetScore( TEAM_SEEKING ))
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
	self:SetSize( 470, 69 )

	self.AvatarButton = vgui.Create("DButton", self)
	self.AvatarButton:SetSize( 64, 64 )
	self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

	self.Avatar = vgui.Create( "AvatarImage", self.AvatarButton )
	self.Avatar:SetSize( 64, 64 )
	self.Avatar:SetMouseInputEnabled( false )

	self.Name = vgui.Create( "DLabel" , self )
	self.Name:SetPos( 68, 4)
	self.Name:SetFont( "Roboto_Normal" )
	self.Name:SetTextColor( clrs.lightgrey )
	self.Name:SetSize( 320, 48 )

	self.Score = vgui.Create( "DLabel" , self )
	self.Score:SetPos( 410, 4)
	self.Score:SetFont( "Roboto_Normal" )
	self.Score:SetTextColor( clrs.lightgrey )

	self.Mute = self:Add( "DImageButton" )
	self.Mute:SetSize( 24, 24 )
end

function PLAYERINFO:Paint( w, h)
	draw.RoundedBox( 0, 0, h-5, w, h, clrs.red )
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
	self.Avatar:SetPlayer( self.Player, 64 )
	self.Name:SetText( self.Player:Nick() )
	self.Score:SetText( self.Player:Frags() )
	self.Score:SizeToContents()

	if ( self.Muted == nil || self.Muted != self.Player:IsMuted() ) then

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