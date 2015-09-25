--Needs some tidying and recoding atm im just happy its working

local SETTINGSPANEL = {}

function SETTINGSPANEL:Init()
    self:SetSize(ScrW() / 2, ScrH() / 2 )
    self:SetPos(ScrW() / 2-self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2)
    self:SetTitle("")

    --hack for title
    local title = vgui.Create( "DLabel", self )
    title:SetPos( 10, 3 )
    title:SetWide(self:GetWide())
    title:SetFont("robot_small")
    title:SetTextColor(clrs.white)
    title:SetText( "Client Settings" )

    self.sheet = vgui.Create( "DPropertySheet", self )
    self.sheet:Dock( FILL )

    self.tutorial = vgui.Create( "DPanel", self.sheet )
    self:Tutorial()
    self.sheet:AddSheet( "Tutorial", self.tutorial, "icon16/book_open.png" )

    self.taunts = vgui.Create( "DPanel", self.sheet )
    self:Taunts()
    self.sheet:AddSheet( "Taunts", self.taunts, "icon16/tux.png" )

    self.general = vgui.Create( "DPanel", self.sheet )
    self:General()
    self.sheet:AddSheet( "General", self.general, "icon16/wrench.png" )

    function self.sheet:Paint(w,h)
        draw.RoundedBox( 0, 8, 28, w-16, h-36, clrs.lightgrey )
        draw.RoundedBox( 0, 8, 0, w-16, h-(h-28), clrs.grey )
        draw.RoundedBox( 0, 8, 23, w-16, h-(h-5), clrs.redbg )
        return
    end

    for k, v in pairs(self.sheet.Items) do
        if (!v.Tab) then continue end
        local left = 0
        v.Tab.Paint = function(self, w, h)
            if k == 1 then left = 8 end
            if v.Tab == g_Settings.sheet:GetActiveTab() then
                draw.RoundedBox( 0, left, h-5, w-left , 5, clrs.red )
            end
        end
    end

end

function SETTINGSPANEL:Paint(w,h)
    draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgreybg )
end

function SETTINGSPANEL:Tutorial()
    function self.tutorial:Paint(w,h)
        return
    end

    local introtext = vgui.Create( "DLabel", self.tutorial )
    introtext:DockMargin(0,5,0,5)
    introtext:Dock( TOP )
    introtext:SetTall(32)
    introtext:SetFont("robot_medium")
    introtext:SetTextColor(clrs.black)
    introtext:SetContentAlignment( 5 )
    introtext:SetText("It’s all about spotting the odd one out.")

    local maintext = vgui.Create( "DLabel", self.tutorial )
    maintext:DockMargin(10,5,10,5)
    maintext:Dock( FILL )
    maintext:SetWrap(true)
    maintext:SetFont("robot_normal")
    maintext:SetTextColor(clrs.black)
    maintext:SetContentAlignment( 5 )
    maintext:SetText("The Hider will have to act as one with the NPC crowd and to make sure they are not caught out by the Seeker.\nTo change to a different NPC's model press E or your \"use\" key while looking at a NPC.\nThe Seeker must search for the hiding player and kill them all in order to win. When a Seeker shots a NPC they will lose health.\nThe Hider must survive the time limit in order to win.")

    local outrotext = vgui.Create( "DLabel", self.tutorial )
    outrotext:DockMargin(0,5,0,5)
    outrotext:Dock( BOTTOM )
    outrotext:SetTall(32)
    outrotext:SetFont("robot_medium")
    outrotext:SetTextColor(clrs.black)
    outrotext:SetContentAlignment( 5 )
    outrotext:SetText("Can you win?")

end

function SETTINGSPANEL:General()
    function self.general:Paint(w,h)
        return
    end

    local CBShowHead = vgui.Create( "DCheckBoxLabel", self.general )
    CBShowHead:SetPos( 10,10 )
    CBShowHead:SetText( "Show character portrait?" )
    CBShowHead:SetTextColor(clrs.black)
    CBShowHead:SetConVar( "gw_hud_showhead" ) -- ConCommand must be a 1 or 0 value
    CBShowHead:SizeToContents()
end

function SETTINGSPANEL:Taunts()

    function self.taunts:Paint(w,h)
        return
    end

    local sequenceList = vgui.Create( "DListView", self.taunts )
    sequenceList:SetMultiSelect( false )
    sequenceList:SetWidth(self:GetWide() / 3 - 20)
    sequenceList:DockMargin(0,0,0,25)
    sequenceList:Dock(LEFT)

    sequenceList:AddColumn( "Sequence" )
    sequenceList:AddColumn( "Available" )

    local ply = LocalPlayer()

    local bindSequence = vgui.Create( "DButton", self.taunts )
    bindSequence:SetText("Bind sequence")
    bindSequence:SetPos(0,self:GetTall() - 95)
    bindSequence:SetSize(self:GetWide() / 3 - 20, 25)
    bindSequence.DoClick = function()
        if sequenceList:GetLine(sequenceList:GetSelectedLine()) == nil then Derma_Message( "Please select an item from the list above!", "Alert", "OK" )  return end
        local seq = sequenceList:GetLine(sequenceList:GetSelectedLine()):GetValue(1)
        Derma_StringRequest(
            "Taunt Hotkey",
            "Enter the key you want to bind the taunt to.",
            "",
            function( text ) command("bind " .. text .. " \"gw_bodytaunt " .. seq .. "\"", "Command", "OK") end,
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

    self.taunts.selectedModel = ply:GetModel()

    self.taunts.previewModel = vgui.Create( "DModelPanel", self.taunts )
    self.taunts.previewModel:SetWidth(self:GetWide() / 3 + 15)
    self.taunts.previewModel:SetHeight(self:GetTall() - 120)
    self.taunts.previewModel:SetPos(self:GetWide() / 3 - 20, 20)
    self.taunts.previewModel:SetModel( self.taunts.selectedModel )

    function self.taunts.previewModel:LayoutEntity( ent )
        ent:SetAngles( Angle( 0, 50, 0 ) )

        self:RunAnimation()
    end

    for _,seq in pairs(GAMEMODE.ValidSequences) do
        sequenceList:AddLine(seq, tostring(table.HasValue(self.taunts.previewModel.Entity:GetSequenceList(), seq)))
    end

    function sequenceList:OnRowSelected( lineID, line )

        resetPreview(line)

    end

    function resetPreview(line)
        if g_Settings.taunts.previewModel then g_Settings.taunts.previewModel:Remove() g_Settings.taunts.previewModel = nil end
        local previewModel = vgui.Create( "DModelPanel", g_Settings.taunts )
        previewModel:SetWidth(g_Settings:GetWide() / 3 + 15)
        previewModel:SetHeight(g_Settings:GetTall() - 120)
        previewModel:SetPos(g_Settings:GetWide() / 3 - 20, 20)
        previewModel:SetModel( g_Settings.taunts.selectedModel )
        if line && table.HasValue(previewModel.Entity:GetSequenceList(), line:GetValue(1)) then
            previewModel.Entity:ResetSequence(line:GetValue(1))
        end
        function previewModel:LayoutEntity( ent )
            ent:SetAngles( Angle( 0, 50, 0 ) )

            self:RunAnimation()
        end

        g_Settings.taunts.previewModel = previewModel

    end

    local modelSelect = vgui.Create( "DComboBox", self.taunts )
    modelSelect:SetPos(self:GetWide() / 3 - 20, 0)
    modelSelect:SetSize( self:GetWide() / 3 + 15, 20 )
    modelSelect:SetValue( self.taunts.selectedModel )
    for _,mdl in pairs(GAMEMODE.Models) do
        modelSelect:AddChoice(mdl)
    end
    modelSelect.OnSelect = function( panel, index, value )
        self.taunts.selectedModel = value
        resetPreview()
        sequenceList:Clear()
        for _,seq in pairs(GAMEMODE.ValidSequences) do
            sequenceList:AddLine(seq, tostring(table.HasValue(self.taunts.previewModel.Entity:GetSequenceList(), seq)))
        end
    end

    local helpBtn = vgui.Create( "DButton", self.taunts )
    helpBtn:SetText("Help")
    helpBtn:SetPos(self:GetWide() / 2 - 35,self:GetTall() - 95)
    helpBtn:SetSize(50,25)
    helpBtn.DoClick = function()
        Derma_Message( "You can preview body and voice taunts here. For that just select an item from the list and listen/watch what it does.\nNote that not every body taunt works for every model you can check the availabilty by switching the model in the dropdown at the top.\nIf you decieded which taunt you want to use select it from one of the lists and click the button below the list to generate a bind command.\nYou can use that command in the console to bind the taunt to a key.\nFor that you will need to have your console enabled. If you don't have your console enabled go to Options > Keyboard > Advanced and Check \"Enable developer console.\"", "Taunt Help", "OK, understood!" )
    end

    local soundList = vgui.Create( "DListView", self.taunts )
    soundList:SetMultiSelect( false )
    soundList:SetWidth(self:GetWide() / 3 -20)
    soundList:DockMargin(0,0,0,25)
    soundList:Dock(RIGHT)

    soundList:AddColumn( "Sound" )

    local bindSound = vgui.Create( "DButton", self.taunts )
    bindSound:SetText("Bind sound")
    bindSound:SetSize(self:GetWide() / 3 -20,25)
    bindSound:SetPos(self:GetWide() - bindSound:GetWide() - 26,self:GetTall() - 95)
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

    local files = file.Find( "sound/gwtaunts/*", "GAME" )
    for _,sound in pairs(files) do
        soundList:AddLine(string.Explode(".", sound)[1])
    end

    function soundList:OnRowSelected( lineID, line )

        surface.PlaySound("gwtaunts/" .. line:GetValue(1) .. ".mp3")

    end

end

function SETTINGSPANEL:OnClose()
    gui.EnableScreenClicker( false )
end

vgui.Register( "DSettingsPanel", SETTINGSPANEL, "DFrame")

local function showSettings(ply, cmd, args)
    -- Is it better resource wise to destroy the panel on close since it wont be used that much?
    if ( !IsValid( g_Settings ) ) then
        g_Settings = vgui.Create("DSettingsPanel")
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