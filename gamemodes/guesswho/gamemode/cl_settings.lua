--Needs some tidying and recoding atm im just happy its working

local SETTINGSPANEL = {}

function SETTINGSPANEL:Init()
	self:SetSize(ScrW() / 2, ScrH() / 2 )
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)
	self:SetTitle("")

	--hack for title
	local title = vgui.Create( "DLabel", self )
	title:SetPos( 10, 3 )
	title:SetWide(self:GetWide())
	title:SetFont("robot_small")
	title:SetTextColor(clrs.white)
	title:SetText( "Settings" )

	self.sheet = vgui.Create( "DPropertySheet", self )
	self.sheet:Dock( FILL )

	if LocalPlayer():IsSuperAdmin() then
		self.config = vgui.Create( "DPanel", self.sheet )
		self:Config()
		self.sheet:AddSheet( "Server Config", self.config, "icon16/cog.png" )
	end

	self.tutorial = vgui.Create( "DPanel", self.sheet )
	self:Tutorial()
	self.sheet:AddSheet( "Tutorial", self.tutorial, "icon16/book_open.png" )

	self.taunts = vgui.Create( "DPanel", self.sheet )
	self:Taunts()
	self.sheet:AddSheet( "Taunts", self.taunts, "icon16/tux.png" )

	self.general = vgui.Create( "DPanel", self.sheet )
	self:General()
	self.sheet:AddSheet( "General", self.general, "icon16/wrench.png" )

	function self.sheet:Paint(w, h)
		draw.RoundedBox( 0, 8, 28, w - 16, h - 36, clrs.lightgrey )
		draw.RoundedBox( 0, 8, 0, w - 16, 28, clrs.grey )
		draw.RoundedBox( 0, 8, 23, w - 16, 5, clrs.redbg )
		return
	end

	for k, v in pairs(self.sheet.Items) do
		if (!v.Tab) then continue end
		local left = 0
		v.Tab.Paint = function(self, w1, h1)
			if k == 1 then left = 8 end
			if v.Tab == g_Settings.sheet:GetActiveTab() then
				draw.RoundedBox( 0, left, h1 - 5, w1 - left, 5, clrs.red )
			end
		end
	end

end

function SETTINGSPANEL:Paint(w, h)
	draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgreybg )
end

function SETTINGSPANEL:Tutorial()
	function self.tutorial:Paint(w, h)
		return
	end

	local introtext = vgui.Create( "DLabel", self.tutorial )
	introtext:DockMargin(0, 5, 0, 5)
	introtext:Dock( TOP )
	introtext:SetTall(32)
	introtext:SetFont("robot_medium")
	introtext:SetTextColor(clrs.black)
	introtext:SetContentAlignment( 5 )
	introtext:SetText("It’s all about spotting the odd one out.")

	local maintext = vgui.Create( "RichText", self.tutorial )
	maintext:DockMargin(10, 5, 10, 5)
	maintext:Dock( FILL )
	maintext:SetWrap(true)
	maintext:SetContentAlignment( 5 )
	maintext:AppendText("The Hider will have to act as one with the NPC crowd and to make sure they are not caught out by the Seeker.\nTo change to a different NPC's model press E or your \"use\" key while looking at a NPC.\n\nThe Seeker must search for the hiding player and kill them all in order to win. When a Seeker shots a NPC they will lose health.\nThe Hider must survive the time limit in order to win.")
	maintext:AppendText("\n\nPress C or Q (Spawnmenu and Contextmenu binds) to open the body taunt menu,\ngoto the Taunts tab to learn about voice taunts.")
	maintext:SetVerticalScrollbarEnabled( true )
	function maintext:PerformLayout()

		self:SetFontInternal( "robot_normal" )
		self:SetFGColor( clrs.black )

	end

	local outrotext = vgui.Create( "DLabel", self.tutorial )
	outrotext:DockMargin(0, 5, 0, 5)
	outrotext:Dock( BOTTOM )
	outrotext:SetTall(32)
	outrotext:SetFont("robot_medium")
	outrotext:SetTextColor(clrs.black)
	outrotext:SetContentAlignment( 5 )
	outrotext:SetText("Can you win?")

end

local MODELCATEGORY = {}

function MODELCATEGORY:SetModels(updateTable)
	local modelList = vgui.Create("DIconLayout", self)
	modelList:Dock(FILL)
	modelList:SetSpaceY(2)
	modelList:SetSpaceX(2)
	self:SetContents(modelList)

	for name, model in SortedPairs( player_manager.AllValidModels() ) do
		local modelIcon = vgui.Create( "SpawnIcon" )
		modelIcon:SetModel( model )
		modelIcon:SetSize( 80, 80 )
		modelIcon:SetTooltip( modelIcon:GetModelName() )
		modelIcon.playermodel = name

		modelIcon.PaintOver = function()
			if table.HasValue(updateTable, modelIcon:GetModelName()) then
				surface.SetDrawColor(clrs.green)
			else
				surface.SetDrawColor(clrs.red)
			end
			for i = 0, 1 do
				surface.DrawOutlinedRect( i, i, modelIcon:GetWide() - i * 2, modelIcon:GetTall() - i * 2)
			end
		end

		modelIcon.DoClick = function()
			if table.HasValue(updateTable, modelIcon:GetModelName()) then
				table.RemoveByValue(updateTable, modelIcon:GetModelName())
			else
				table.insert(updateTable, modelIcon:GetModelName())
			end
		end

		local modelLabel = vgui.Create("DLabel", modelIcon)
		modelLabel:SetText(name)
		modelLabel:SetFont("robot_smaller")
		modelLabel:SetTextColor(clrs.lightgrey)
		function modelLabel:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgreybg)
		end
		modelLabel:Dock(BOTTOM)
		modelLabel:SetContentAlignment(5)
		modelList:Add(modelIcon)

	end
end
vgui.Register( "DGuessWhoConfigModelCategory", MODELCATEGORY, "DCollapsibleCategory")


function SETTINGSPANEL:Config()
	function self.config:Paint(w, h)
		return
	end

	local saveButton = vgui.Create("DButton", self.config)
	saveButton:SetText("Save changes")
	saveButton.DoClick = function()
		self:SendConfigUpdateRequest()
	end
	saveButton:Dock(BOTTOM)

	local configScroll = vgui.Create("DScrollPanel", self.config)
	configScroll:Dock(FILL)

	local modelHidingCategory = vgui.Create( "DGuessWhoConfigModelCategory", configScroll)
	modelHidingCategory:SetModels(GAMEMODE.GWConfig.HidingModels)
	modelHidingCategory:SetExpanded( 0 )
	modelHidingCategory:Dock(TOP)
	modelHidingCategory:SetLabel( "Models Hiding" )

	local modelSeekingCategory = vgui.Create( "DGuessWhoConfigModelCategory", configScroll)
	modelSeekingCategory:SetModels(GAMEMODE.GWConfig.SeekerModels)
	modelSeekingCategory:SetExpanded( 0 )
	modelSeekingCategory:Dock(TOP)
	modelSeekingCategory:SetLabel( "Models Seekers" )

	local abilitiesCategory = vgui.Create( "DCollapsibleCategory", configScroll)
	abilitiesCategory:SetExpanded( 0 )
	abilitiesCategory:Dock(TOP)
	abilitiesCategory:SetLabel( "Abilities" )

	local abilityList = vgui.Create("DIconLayout", abilitiesCategory)
	abilityList:Dock(FILL)
	abilityList:SetSpaceY(2)
	abilityList:SetSpaceX(2)
	abilitiesCategory:SetContents(abilityList)

	for _, wepName in pairs(GAMEMODE.GWConfigStatic.AllAbilities) do
		local abilityIcon = vgui.Create( "DImageButton" )
		abilityIcon:SetImage("vgui/gw/abilityicons/" .. wepName .. ".png")
		abilityIcon:SetSize( 80, 80 )
		abilityIcon:SetTooltip( wepName )

		abilityIcon.PaintOver = function()
			if table.HasValue(GAMEMODE.GWConfig.ActiveAbilities, wepName) then
				surface.SetDrawColor(clrs.green)
			else
				surface.SetDrawColor(clrs.red)
			end
			for i = 0, 1 do
				surface.DrawOutlinedRect( i, i, abilityIcon:GetWide() - i * 2, abilityIcon:GetTall() - i * 2)
			end
		end

		abilityIcon.DoClick = function()
			if table.HasValue(GAMEMODE.GWConfig.ActiveAbilities, wepName) then
				table.RemoveByValue(GAMEMODE.GWConfig.ActiveAbilities, wepName)
			else
				table.insert(GAMEMODE.GWConfig.ActiveAbilities, wepName)
			end
		end

		local abilityLabel = vgui.Create("DLabel", abilityIcon)
		abilityLabel:SetText(weapons.Get(wepName).Name)
		abilityLabel:SetFont("robot_smaller")
		abilityLabel:SetTextColor(clrs.lightgrey)
		function abilityLabel:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgreybg)
		end
		abilityLabel:Dock(BOTTOM)
		abilityLabel:SetContentAlignment(5)

		abilityList:Add(abilityIcon)

	end

	local colorsCategory = vgui.Create( "DCollapsibleCategory", configScroll)
	colorsCategory:SetExpanded( 0 )
	colorsCategory:Dock(TOP)
	colorsCategory:SetLabel("Colors")

	local seekerColorLabel = vgui.Create("DLabel", colorsCategory)
	seekerColorLabel:SetText("Team Seeker Color")
	seekerColorLabel:SetFont("robot_normal")
	seekerColorLabel:Dock(TOP)
	seekerColorLabel:SetContentAlignment(5)
	seekerColorLabel:SetTall(24)
	seekerColorLabel:SetTextColor(clrs.darkgrey)

	local seekerColor = vgui.Create("DColorMixer", colorsCategory)
	seekerColor:SetPalette(false)
	seekerColor:Dock(TOP)
	seekerColor:SetTall(100)
	seekerColor:SetColor(GAMEMODE.GWConfig.TeamSeekingColor)
	function seekerColor:ValueChanged(color)
		GAMEMODE.GWConfig.TeamSeekingColor = color
	end

	local hidingColorLabel = vgui.Create("DLabel", colorsCategory)
	hidingColorLabel:SetText("Team Hiding Color")
	hidingColorLabel:SetFont("robot_normal")
	hidingColorLabel:Dock(TOP)
	hidingColorLabel:SetContentAlignment(5)
	hidingColorLabel:SetTall(24)
	hidingColorLabel:SetTextColor(clrs.darkgrey)

	local hidingColor = vgui.Create("DColorMixer", colorsCategory)
	hidingColor:SetPalette(false)
	hidingColor:Dock(TOP)
	hidingColor:SetTall(100)
	hidingColor:SetColor(GAMEMODE.GWConfig.TeamHidingColor)
	function hidingColor:ValueChanged(color)
		GAMEMODE.GWConfig.TeamHidingColor = color
	end

end

function SETTINGSPANEL:General()
	function self.general:Paint(w, h)
		return
	end

	local CheckShowHead = vgui.Create( "DCheckBoxLabel", self.general )
	CheckShowHead:SetPos( 10, 10 )
	CheckShowHead:SetText( "Show character portrait?" )
	CheckShowHead:SetTextColor(clrs.black)
	CheckShowHead:SetConVar( "gw_hud_showhead" ) -- ConCommand must be a 1 or 0 value
	CheckShowHead:SizeToContents()

	local LabelLang = vgui.Create( "DLabel", self.general )
	LabelLang:SetPos( 10, 45 )
	LabelLang:SetWide( self:GetWide() - 45 )
	LabelLang:SetFont("robot_small")
	LabelLang:SetTextColor(clrs.black)
	LabelLang:SetText("Language:")

	local PanelLang = vgui.Create( "DPanel", self.general )
	PanelLang:SetPos( 10, 80 )
	PanelLang:SetWide( self:GetWide() - 45 )
	PanelLang:SetTall( 40 )

	function PanelLang:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w - 5, h, Color( 0, 0, 0, 220 ) )
	end

	local p = vgui.Create( "DIconLayout", PanelLang )
	p:Dock( FILL )
	p:SetBorder( 5 )
	p:SetSpaceY( 5 )
	p:SetSpaceX( 5 )

	for _, locale in pairs( gwlang:getLocaleList() ) do
		local f = p:Add( "DImageButton" )
		f:SetImage( "../resource/localization/" .. locale .. ".png" )
		f:SetSize( 16, 12 )
		f.DoClick = function() RunConsoleCommand( "gw_selectlanguage", locale )end
	end

end

function SETTINGSPANEL:Taunts()

	function self.taunts:Paint(w, h)
		return
	end

	local soundList = vgui.Create( "DListView", self.taunts )
	soundList:SetMultiSelect( false )
	soundList:SetWidth(self:GetWide() - 26)
	soundList:DockMargin(0, 0, 0, 25)
	soundList:Dock(RIGHT)

	soundList:AddColumn( "Sound" )

	local bindSound = vgui.Create( "DButton", self.taunts )
	bindSound:SetText("Bind sound")
	bindSound:SetSize((self:GetWide() - 26) / 2, 25)
	bindSound:SetPos(0, self:GetTall() - 95)
	bindSound.DoClick = function()
		if soundList:GetLine(soundList:GetSelectedLine()) == nil then Derma_Message( "Please select an item from the list above!", "Alert", "OK" ) return end
		local sound = soundList:GetLine(soundList:GetSelectedLine()):GetValue(1)
		Derma_StringRequest(
			"Taunt Hotkey",
			"Enter the key you want to bind the taunt to.",
			"",
			function( text ) command("bind " .. text .. " \"gw_voicetaunt " .. sound .. "\"", "Command", "OK") end,
			function( text ) end,
			"Generate"
		)
		function command(cmd)
			Derma_StringRequest(
				"Console Print",
				"Execute in your console to generate keybinding for your taunt.",
				cmd,
				function( text ) SetClipboardText(cmd) end,
				function( text ) end,
				"Copy to Clipboard"
			)
		end
	end

	local helpBtn = vgui.Create( "DButton", self.taunts )
	helpBtn:SetText("Help")
	helpBtn:SetPos(0 + bindSound:GetWide(), self:GetTall() - 95)
	helpBtn:SetSize((self:GetWide() - 26) / 2, 25)
	helpBtn.DoClick = function()
		Derma_Message( "NOTE: This is a temporary solution a easier voice taunt menu will be added soon.\nYou can preview voice taunts here. For that just select an item from the list.\nIf you decided which voice taunt you want to use select it from list and click the button below the list to generate a bind command.\nYou can use that command in the console to bind the taunt to a key.\nFor that you will need to have your console enabled. If you don't have your console enabled go to Options > Keyboard > Advanced and Check \"Enable developer console.\"", "Taunt Help", "OK, understood!" )
	end

	local files = file.Find( "sound/gwtaunts/*", "GAME" )
	for _, sound in pairs(files) do
		soundList:AddLine(string.Explode(".", sound)[1])
	end

	function soundList:OnRowSelected( lineID, line )

		surface.PlaySound("gwtaunts/" .. line:GetValue(1) .. ".mp3")

	end

end

function SETTINGSPANEL:OnClose()
	gui.EnableScreenClicker( false )
end

function SETTINGSPANEL:SendConfigUpdateRequest()
	net.Start("gwRequestUpdateConfig")
		net.WriteTable(GAMEMODE.GWConfig)
	net.SendToServer()
end

vgui.Register( "DGuessWhoSettingsPanel", SETTINGSPANEL, "DFrame")

local function showSettings(ply, cmd, args)
	-- Is it better resource wise to destroy the panel on close since it wont be used that much?
	if ( !IsValid( g_Settings ) ) then
		g_Settings = vgui.Create("DGuessWhoSettingsPanel")
		g_Settings:SetVisible(false) -- use the visible bool as toggle indicator
	end

	if ( IsValid( g_Settings ) ) then
		if g_Settings:IsVisible() then
			g_Settings:Hide()
			gui.EnableScreenClicker( false )
			g_Settings:SetVisible(false)
			g_Settings:Remove()
		else
			g_Settings:Show()
			gui.EnableScreenClicker( true )
			g_Settings:SetVisible(true)
		end
	end
end
concommand.Add("gw_settings", showSettings)

net.Receive("gwSendConfig", function(len, ply)
	local config = net.ReadTable()
	GAMEMODE.GWConfig = config
	team.SetColor(TEAM_HIDING, GAMEMODE.GWConfig.TeamHidingColor)
	team.SetColor(TEAM_SEEKING, GAMEMODE.GWConfig.TeamSeekingColor)
end)
