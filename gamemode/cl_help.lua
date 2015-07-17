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

surface.CreateFont( "Roboto_Normal", {
	font = "Roboto",
	size = 36
} )

HELPPANEL = {}

local clrs = { red = Color(231,77,60), blue = Color(53,152,219), green = Color(45,204,113), purple = Color(108,113,196), yellow = Color(241,196,16), lightgrey = Color(236,240,241), grey = Color(42,42,42), darkgrey = Color(26,26,26), black = Color(0,0,0)}

function HELPPANEL:Init()
	self:ShowCloseButton(false)
	self:SetTitle("Press F1 again to hide!")

	local HeaderLabel = vgui.Create("DLabel", self)
	HeaderLabel:SetSize( 150,48 )
	HeaderLabel:SetPos( 125, 20 )
	HeaderLabel:SetFont("Info_Header")
	HeaderLabel:SetTextColor( clrs.lightgrey )
	HeaderLabel:SetText("Tutorial")

	local HidingHelpLabel = vgui.Create("DLabel", self)
	HidingHelpLabel:SetPos( 10, 82 )
	HidingHelpLabel:SetFont("Roboto_Normal")
	HidingHelpLabel:SetTextColor( clrs.lightgrey )
	HidingHelpLabel:SetText("Hiding")
	HidingHelpLabel:SizeToContents()

	local HelpLabel = vgui.Create("DLabel", self)
	HelpLabel:SetPos( 10, 134 )
	HelpLabel:SetFont("Info_Text")
	HelpLabel:SetTextColor( clrs.lightgrey )
	HelpLabel:SetText( "Press E on those guys:" )
	HelpLabel:SizeToContents()
	--(the key between \"W\" and \"R\" or whatever your USEKEY is set to)

	local HelpModel = vgui.Create( "DModelPanel", self )
	HelpModel:SetPos( 10, 142 )
	HelpModel:SetSize( 320, 320 )
	local models = {
		"odessa.mdl",
		"breen.mdl",
		"alyx.mdl",
		"barney.mdl",
		"gman.mdl",
		"eli.mdl",
		"kleiner.mdl",
		"mossman.mdl",
		"Humans/Group02/male_08.mdl",
		"Humans/Group02/female_03.mdl",
	}
	HelpModel:SetModel("models/"..models[math.random(1,#models)])
	
	local HelpLabel1 = vgui.Create("DLabel", self)
	HelpLabel1:SetPos( 10, 478 )
	HelpLabel1:SetSize( 380, 58 )
	HelpLabel1:SetFont("Info_Text")
	HelpLabel1:SetTextColor( clrs.lightgrey )
	HelpLabel1:SetWrap( true )
	HelpLabel1:SetText( "You should now use their model and will be able to blend in with the crowd." )

	local HelpLabel2 = vgui.Create("DLabel", self)
	HelpLabel2:SetPos( 10, 536 )
	HelpLabel2:SetSize( 380, 40 )
	HelpLabel2:SetFont("Button_Normal")
	HelpLabel2:SetTextColor( clrs.lightgrey )
	HelpLabel2:SetWrap( true )
	HelpLabel2:SetText( "Pressing E does nothing? Try the key you bound to \"use item\" and make sure you are close to the NPC." )

	local HuntingHelpLabel = vgui.Create("DLabel", self)
	HuntingHelpLabel:SetPos( 10, 600 )
	HuntingHelpLabel:SetFont("Roboto_Normal")
	HuntingHelpLabel:SetTextColor( clrs.lightgrey )
	HuntingHelpLabel:SetText("Hunter")
	HuntingHelpLabel:SizeToContents()

	local HelpLabel3 = vgui.Create("DLabel", self)
	HelpLabel3:SetPos( 10, 656 )
	HelpLabel3:SetSize( 380, 64 )
	HelpLabel3:SetFont("Info_Text")
	HelpLabel3:SetTextColor( clrs.lightgrey )
	HelpLabel3:SetWrap( true )
	HelpLabel3:SetText( "What is the job of the Hunters? Hunt obviously... find the persons that look like human controlled." )


end

function HELPPANEL:Paint( w, h)
	draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgrey )
end

vgui.Register( "DHelpPanel", HELPPANEL, "DFrame")

local function ShowGWHelp(ply, cmd, args)

	-- Is it better resource wise to destroy the panel on close since it wont be used that much?
	if ( !IsValid( g_Help ) ) then
		g_Help = vgui.Create("DHelpPanel")
  		g_Help:SetSize(400, ScrH() )
  		g_Help:SetVisible(false) -- we use the visible bool as toggle indicator because im to lazy for something fancy
	end

	if ( IsValid( g_Help ) ) then
		if g_Help:IsVisible() then
			g_Help:Hide()
			g_Help:SetVisible(false)
			g_Help:SetTitle("Press F1 again to hide!")
		else
			g_Help:Show()
			g_Help:SetVisible(true)
			timer.Simple(3, function() g_Help:SetTitle("") end)
		end
	end
end
concommand.Add("gw_helpscreen", ShowGWHelp)