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
	
	-- Old Header Stil in here for some reason im attached to it maybe
	/*local HeaderLabel = vgui.Create("DLabel", self.TeamSelectFrame)
	HeaderLabel:SetSize( 245, 80 )
	HeaderLabel:SetPos( 0, 40 )
	HeaderLabel:SetFont("robot_large")
	HeaderLabel:SetTextColor( clrs.lightgrey )
	HeaderLabel:SetText(" GUESS WHO ")
	HeaderLabel:CenterHorizontal()
	function HeaderLabel:Paint( w, h )
		/*local x = 0
		local y = 0
		surface.SetDrawColor( clrs.lightgrey )
		for i=0, 5 - 1 do
			surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
		end
	end*/

	local HeaderImage = vgui.Create("DImage", self.TeamSelectFrame)
	HeaderImage:SetSize( 380, 128 )
	HeaderImage:SetPos( 0, 20 )
	HeaderImage:SetImage( "vgui/gw/logo_main.png" )
	HeaderImage:CenterHorizontal()

	--Hiding Button
	local TeamHidingPanel = vgui.Create( "DPanel", self.TeamSelectFrame )
	TeamHidingPanel:SetPos( ScrW()/2-340, 180 )
	TeamHidingPanel:SetSize( 300, 400 )
	function TeamHidingPanel:Paint( w, h )
		local x = 0
		local y = 0
		surface.SetDrawColor( clrs.red )
		for i=0, 5 - 1 do
			surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
		end
	end

	local TeamHidingModel = vgui.Create( "DModelPanel", TeamHidingPanel )
	TeamHidingModel:SetSize( 300, 400 )
	TeamHidingModel:SetModel( GAMEMODE.Models[math.random(1,#GAMEMODE.Models)] )
	TeamHidingModel.Entity:SetSequence("Wave")
	function TeamHidingModel:LayoutEntity( ent ) 
		ent:SetAngles( Angle( 0, 70, 0 ) )

		self:RunAnimation()
	end

	local TeamHidingButton = vgui.Create( "DButton", TeamHidingPanel )
	function TeamHidingButton.DoClick() 
		if self:IsBalancedToJoin(TEAM_HIDING) or LocalPlayer():Team() == TEAM_HIDING then
			self:HideTeam() RunConsoleCommand( "changeteam", TEAM_HIDING )
		end
	end
	TeamHidingButton:SetFont( "robot_normal" )
	TeamHidingButton:SetTextColor( clrs.lightgrey )
	TeamHidingButton:SetText( team.GetName( TEAM_HIDING ).."("..team.NumPlayers( TEAM_HIDING )..")" )
	TeamHidingButton:SetSize( 300, 400 )
	function TeamHidingButton:Paint( w, h )
		return
	end
	function TeamHidingButton:Think()
		self:SetText( team.GetName( TEAM_HIDING ).."("..team.NumPlayers( TEAM_HIDING )..")" )
	end

	--Seeking Button
	local TeamSeekingPanel = vgui.Create( "DPanel", self.TeamSelectFrame )
	TeamSeekingPanel:SetPos( ScrW()/2+40, 180 )
	TeamSeekingPanel:SetSize( 300, 400 )
	function TeamSeekingPanel:Paint( w, h )
		local x = 0
		local y = 0
		surface.SetDrawColor( clrs.red )
		for i=0, 5 - 1 do
			surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
		end
	end

	local TeamSeekingModel = vgui.Create( "DModelPanel", TeamSeekingPanel )
	TeamSeekingModel:SetSize( 300, 400 )
	TeamSeekingModel:SetModel( "models/player/combine_super_soldier.mdl" )
	function TeamSeekingModel:LayoutEntity( ent ) 
		ent:SetAngles( Angle( 0, 30, 0 ) )
	end

	local TeamSeekingButton = vgui.Create( "DButton", TeamSeekingPanel )
	function TeamSeekingButton.DoClick()
		if self:IsBalancedToJoin(TEAM_SEEKING) or LocalPlayer():Team() == TEAM_SEEKING then
			self:HideTeam() RunConsoleCommand( "changeteam", TEAM_SEEKING )
		end
	end
	TeamSeekingButton:SetFont( "robot_normal" )
	TeamSeekingButton:SetTextColor( clrs.lightgrey )
	TeamSeekingButton:SetText( team.GetName( TEAM_SEEKING ).."("..team.NumPlayers( TEAM_SEEKING )..")" )
	TeamSeekingButton:SetSize( 300, 400 )
	function TeamSeekingButton:Paint( w, h )
		return
	end
	function TeamSeekingButton:Think()
		self:SetText( team.GetName( TEAM_SEEKING ).."("..team.NumPlayers( TEAM_SEEKING )..")" )
	end

	--spectate and auto buttons
	local TeamSpectateButton = vgui.Create( "DButton", self.TeamSelectFrame )
	TeamSpectateButton:SetPos( ScrW()/2 -340, 620 )
	TeamSpectateButton:SetSize( 680, 40 )
	TeamSpectateButton:SetFont("robot_small")
	TeamSpectateButton:SetText( "Spectate" )
	TeamSpectateButton:SetTextColor( clrs.lightgrey )
	function TeamSpectateButton.DoClick() self:HideTeam() RunConsoleCommand( "changeteam", TEAM_SPECTATOR ) end
	function TeamSpectateButton:Paint( w, h)
		draw.RoundedBox( 0, 0, 0, w, h, clrs.grey )
	end

	local TeamAutoButton = vgui.Create( "DButton", self.TeamSelectFrame )
	TeamAutoButton:SetPos( ScrW()/2 -340, 680 )
	TeamAutoButton:SetSize( 680, 40 )
	TeamAutoButton:SetFont("robot_small")
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

function GM:HideTeam()

	if ( IsValid(self.TeamSelectFrame) ) then
		self.TeamSelectFrame:Remove()
		self.TeamSelectFrame = nil
	end

end