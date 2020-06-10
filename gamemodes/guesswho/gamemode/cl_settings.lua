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
    title:SetFont("gw_font_small")
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
        if (not v.Tab) then continue end
        local left = 0
        v.Tab.Paint = function(self, w1, h1)
            if k == 1 then left = 8 end
            if v.Tab == GW_SETTINGS_PANEL.sheet:GetActiveTab() then
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
    introtext:SetFont("gw_font_medium")
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

        self:SetFontInternal( "gw_font_normal" )
        self:SetFGColor( clrs.black )

    end

    local outrotext = vgui.Create( "DLabel", self.tutorial )
    outrotext:DockMargin(0, 5, 0, 5)
    outrotext:Dock( BOTTOM )
    outrotext:SetTall(32)
    outrotext:SetFont("gw_font_medium")
    outrotext:SetTextColor(clrs.black)
    outrotext:SetContentAlignment( 5 )
    outrotext:SetText("Can you win?")

end

local MODELCATEGORY = {}

function MODELCATEGORY:SetModels(updateTable)
    local modelList = vgui.Create("DIconLayout", self)
    modelList:Dock(FILL)
    modelList:SetSpaceY(3)
    modelList:SetSpaceX(3)
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
                for i = 0, 2 do
                    surface.DrawOutlinedRect( i, i, modelIcon:GetWide() - i * 2, modelIcon:GetTall() - i * 2)
                end
            else
                surface.SetDrawColor(clrs.red)
                for i = 0, 1 do
                    surface.DrawOutlinedRect( i, i, modelIcon:GetWide() - i * 2, modelIcon:GetTall() - i * 2)
                end
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
        modelLabel:SetFont("gw_font_smaller")
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
    saveButton:SetText("Save changes (may require map change/restart)")
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
    abilityList:SetSpaceY(3)
    abilityList:SetSpaceX(3)
    abilitiesCategory:SetContents(abilityList)

    for _, wepName in pairs(GAMEMODE.GWConfigStatic.AllAbilities) do
        local abilityIcon = vgui.Create( "DImageButton" )
        abilityIcon:SetImage("vgui/gw/abilityicons/" .. wepName .. ".png")
        abilityIcon:SetSize( 80, 80 )
        abilityIcon:SetTooltip( wepName )

        abilityIcon.PaintOver = function()
            if table.HasValue(GAMEMODE.GWConfig.ActiveAbilities, wepName) then
                surface.SetDrawColor(clrs.green)
                for i = 0, 2 do
                    surface.DrawOutlinedRect( i, i, abilityIcon:GetWide() - i * 2, abilityIcon:GetTall() - i * 2)
                end
            else
                surface.SetDrawColor(clrs.red)
                for i = 0, 1 do
                    surface.DrawOutlinedRect( i, i, abilityIcon:GetWide() - i * 2, abilityIcon:GetTall() - i * 2)
                end
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
        abilityLabel:SetFont("gw_font_smaller")
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
    colorsCategory:SetLabel("Team Colors")

    local seekerColorLabel = vgui.Create("DLabel", colorsCategory)
    seekerColorLabel:SetText("Team Seeker Color")
    seekerColorLabel:SetFont("gw_font_normal")
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
    hidingColorLabel:SetFont("gw_font_normal")
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

    local serverCategory = vgui.Create( "DCollapsibleCategory", configScroll)
    serverCategory:SetExpanded( 0 )
    serverCategory:Dock(TOP)
    serverCategory:SetLabel("Team select screen (F2) customization")

    local pickScreenLink = vgui.Create("DLabel", serverCategory)
    pickScreenLink:SetText("Custom team select server link")
    pickScreenLink:SetFont("gw_font_small")
    pickScreenLink:Dock(TOP)
    pickScreenLink:SetContentAlignment(4)
    pickScreenLink:SetTall(24)
    pickScreenLink:SetTextColor(clrs.darkgrey)

    local pickScreenLinkInput = vgui.Create("DTextEntry", serverCategory)
    pickScreenLinkInput:Dock(TOP)
    pickScreenLinkInput:SetContentAlignment(4)
    pickScreenLinkInput:SetTall(24)
    pickScreenLinkInput:SetValue(GAMEMODE.GWConfig.ServerUrl)
    function pickScreenLinkInput:OnValueChange(text)
        GAMEMODE.GWConfig.ServerUrl = text
    end

    local pickScreenLinkLabel = vgui.Create("DLabel", serverCategory)
    pickScreenLinkLabel:SetText("Custom team select server label")
    pickScreenLinkLabel:SetFont("gw_font_small")
    pickScreenLinkLabel:Dock(TOP)
    pickScreenLinkLabel:SetContentAlignment(4)
    pickScreenLinkLabel:SetTall(24)
    pickScreenLinkLabel:SetTextColor(clrs.darkgrey)

    local pickScreenLinkLabelInput = vgui.Create("DTextEntry", serverCategory)
    pickScreenLinkLabelInput:Dock(TOP)
    pickScreenLinkLabelInput:SetContentAlignment(4)
    pickScreenLinkLabelInput:SetTall(24)
    pickScreenLinkLabelInput:SetValue(GAMEMODE.GWConfig.ServerName)
    function pickScreenLinkLabelInput:OnValueChange(text)
        GAMEMODE.GWConfig.ServerName = text
    end

    local pickScreenNewsLabel = vgui.Create("DLabel", serverCategory)
    pickScreenNewsLabel:SetText("Custom team select news message")
    pickScreenNewsLabel:SetFont("gw_font_small")
    pickScreenNewsLabel:Dock(TOP)
    pickScreenNewsLabel:SetContentAlignment(4)
    pickScreenNewsLabel:SetTall(24)
    pickScreenNewsLabel:SetTextColor(clrs.darkgrey)

    local pickScreenNewsLabelInput = vgui.Create("DTextEntry", serverCategory)
    pickScreenNewsLabelInput:Dock(TOP)
    pickScreenNewsLabelInput:SetContentAlignment(4)
    pickScreenNewsLabelInput:SetTall(48)
    pickScreenNewsLabelInput:SetMultiline(true)
    pickScreenNewsLabelInput:SetValue(GAMEMODE.GWConfig.News)
    function pickScreenNewsLabelInput:OnValueChange(text)
        GAMEMODE.GWConfig.News = text
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
    LabelLang:SetFont("gw_font_small")
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

    for _, locale in pairs( GWLANG:GetLocaleList() ) do
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
    print("yolo?")
    -- Is it better resource wise to destroy the panel on close since it wont be used that much?
    if (not IsValid(GW_SETTINGS_PANEL)) then
        GW_SETTINGS_PANEL = vgui.Create("DGuessWhoSettingsPanel")
        GW_SETTINGS_PANEL:Show()
        GW_SETTINGS_PANEL:MakePopup()
        gui.EnableScreenClicker(true)
    else
        gui.EnableScreenClicker( false )
        GW_SETTINGS_PANEL:Remove()
        GW_SETTINGS_PANEL = nil
    end
end
concommand.Add("gw_settings", showSettings)
