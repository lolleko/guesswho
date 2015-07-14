surface.CreateFont( "Info_Header", {
	font = "Roboto",
	size = 48
} )

surface.CreateFont( "Info_Text", {
	font = "Roboto",
	size = 24
} )

surface.CreateFont( "Button_Normal", {
	font = "Roboto",
	size = 16
} )

surface.CreateFont( "Button_Small", {
	font = "Roboto",
	size = 12
} )

--[[---------------------------------------------------------
   Name: gamemode:ShowTeam()
   Desc:
-----------------------------------------------------------]]
function GM:ShowTeam()

	local clrs = { red = Color(231,77,60), blue = Color(53,152,219), green = Color(45,204,113), purple = Color(108,113,196), yellow = Color(241,196,16), lightgrey = Color(236,240,241), grey = Color(42,42,42), darkgrey = Color(26,26,26), black = Color(0,0,0)}

	if ( IsValid( self.TeamSelectFrame ) ) then return end
	
	-- Simple team selection box
	self.TeamSelectFrame = vgui.Create( "DPanel" )
	self.TeamSelectFrame:SetPos(0,0)
	self.TeamSelectFrame:SetSize( ScrW(), ScrH() )
	
	--Header
	local HeaderLabel = vgui.Create("DLabel", self.TeamSelectFrame)
	HeaderLabel:SetSize( 245, 80 )
	HeaderLabel:SetPos( 0, 40 )
	HeaderLabel:SetFont("Info_Header")
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

	--signature you can remove it but you really shouldnt :(
	local SignatureLabel = vgui.Create("DLabel", self.TeamSelectFrame)
	SignatureLabel:SetPos( HeaderLabel:GetPos() + 15, 123 )
	SignatureLabel:SetFont("Button_Small")
	SignatureLabel:SetTextColor( clrs.lightgrey )
	SignatureLabel:SetText("")

	--Hiding Button
	local TeamHidingPanel = vgui.Create( "DPanel", self.TeamSelectFrame )
	TeamHidingPanel:SetPos( ScrW()/2-340, 180 )
	TeamHidingPanel:SetSize( 300, 400 )
	function TeamHidingPanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
		draw.RoundedBox( 0, 0, h-5, w, h, clrs.red )
	end

	local TeamHidingModel = vgui.Create( "DModelPanel", TeamHidingPanel )
	TeamHidingModel:SetSize( 300, 400 )
	TeamHidingModel:SetModel( "models/player/Group01/female_02.mdl" )
	function TeamHidingModel:LayoutEntity( ent ) 
		return
	end

	local TeamHidingButton = vgui.Create( "DButton", TeamHidingPanel )
	function TeamHidingButton.DoClick() 
		if self:IsBalancedToJoin(TEAM_HIDING) or LocalPlayer():Team() == TEAM_HIDING then
			self:HideTeam() RunConsoleCommand( "changeteam", TEAM_HIDING )
		end
	end
	TeamHidingButton:SetFont( "Info_Text" )
	TeamHidingButton:SetTextColor( clrs.lightgrey )
	TeamHidingButton:SetText( team.GetName( TEAM_HIDING ).."("..team.NumPlayers( TEAM_HIDING )..")" )
	TeamHidingButton:SetSize( 300, 400 )
	function TeamHidingButton:Paint( w, h )
		return
	end

	--Seeking Button
	local TeamSeekingPanel = vgui.Create( "DPanel", self.TeamSelectFrame )
	TeamSeekingPanel:SetPos( ScrW()/2+40, 180 )
	TeamSeekingPanel:SetSize( 300, 400 )
	function TeamSeekingPanel:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
		draw.RoundedBox( 0, 0, h-5, w, h, clrs.red )
	end

	local TeamSeekingModel = vgui.Create( "DModelPanel", TeamSeekingPanel )
	TeamSeekingModel:SetSize( 300, 400 )
	TeamSeekingModel:SetModel( "models/player/combine_super_soldier.mdl" )
	function TeamSeekingModel:LayoutEntity( ent ) 
		return
	end

	local TeamSeekingButton = vgui.Create( "DButton", TeamSeekingPanel )
	function TeamSeekingButton.DoClick()
		if self:IsBalancedToJoin(TEAM_SEEKING) or LocalPlayer():Team() == TEAM_SEEKING then
			self:HideTeam() RunConsoleCommand( "changeteam", TEAM_SEEKING )
		end
	end
	TeamSeekingButton:SetFont( "Info_Text" )
	TeamSeekingButton:SetTextColor( clrs.lightgrey )
	TeamSeekingButton:SetText( team.GetName( TEAM_SEEKING ).."("..team.NumPlayers( TEAM_SEEKING )..")" )
	TeamSeekingButton:SetSize( 300, 400 )
	function TeamSeekingButton:Paint( w, h )
		return
	end

	--spectate and auto buttons
	local TeamSpectateButton = vgui.Create( "DButton", self.TeamSelectFrame )
	TeamSpectateButton:SetPos( ScrW()/2 -340, 620 )
	TeamSpectateButton:SetSize( 680, 40 )
	TeamSpectateButton:SetFont("Button_Normal")
	TeamSpectateButton:SetText( "Spectate" )
	TeamSpectateButton:SetTextColor( clrs.lightgrey )
	function TeamSpectateButton.DoClick() self:HideTeam() RunConsoleCommand( "changeteam", TEAM_SPECTATOR ) end
	function TeamSpectateButton:Paint( w, h)
		draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
	end

	local TeamAutoButton = vgui.Create( "DButton", self.TeamSelectFrame )
	TeamAutoButton:SetPos( ScrW()/2 -340, 680 )
	TeamAutoButton:SetSize( 680, 40 )
	TeamAutoButton:SetFont("Button_Normal")
	TeamAutoButton:SetText( "Auto Join" )
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
		draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgrey )
	end

end

function GM:IsBalancedToJoin( teamid )
	if teamid == TEAM_SEEKING then
		if team.NumPlayers( TEAM_SEEKING ) > team.NumPlayers( TEAM_HIDING ) then
			return false
		end
	elseif teamid == TEAM_HIDING then
		if team.NumPlayers( TEAM_HIDING ) > team.NumPlayers( TEAM_SEEKING ) then
			return false
		end
	end
	
	return true
end