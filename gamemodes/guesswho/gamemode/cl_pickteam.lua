local logoMaterial = Material("vgui/gw/logo_main.png", "smooth")

local function CreateTeamJoinButton(teamID, teamLangKey, parent, offsetX, offsetY, modelTable)
    local TeamPanel = vgui.Create("DPanel", parent)
    TeamPanel:SetPos(offsetX, offsetY)
    TeamPanel:SetSize(280, 280)
    function TeamPanel:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, team.GetColor(teamID))
    end

    local TeamModel = vgui.Create("DModelPanel", TeamPanel)
    TeamModel:SetSize(280, 240)
    TeamModel:SetModel(modelTable[math.random(1,#modelTable)])
   
    if teamID == GW_TEAM_HIDING then
        TeamModel.Entity:SetAngles(Angle(0, 70, 0))
        local seq, dur = TeamModel.Entity:LookupSequence("gesture_wave")
        TeamModel.Entity:SetSequence(seq)
        timer.Simple(dur - 0.15, function()
            if not TeamModel.Entity then return end
            TeamModel.Entity:SetSequence("idle_all_01")
            TeamModel.Entity:SetAngles(Angle(0, 0, 0))
        end)
    else
        TeamModel.Entity:SetAngles(Angle(0, 40, 0))
    end

    function TeamModel:LayoutEntity(ent)
        self:RunAnimation()
    end

    local TeamButton = vgui.Create("DButton", TeamPanel)
    function TeamButton.DoClick()
        if GAMEMODE:IsBalancedToJoin(teamID) then
            GAMEMODE:HideTeam()
            RunConsoleCommand("changeteam", teamID)
        end
    end
    TeamButton:SetText("")
    TeamButton:SetSize(280, 280)
    function TeamButton:Paint(w, h) return end

    local TeamName = vgui.Create("DLabel", TeamPanel)
    TeamName:SetSize(280, 40)
    TeamName:AlignBottom()
    TeamName:SetContentAlignment(5)
    function TeamName:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, clrs.grey)
    end
    TeamName:SetFont("gw_font_small")
    TeamName:SetTextColor(clrs.lightgrey)
    TeamName:SetText(GWLANG:Translate(teamLangKey) .. "(" ..
                                 team.NumPlayers(teamID) .. ")")
    function TeamName:Think()
        self:SetText(GWLANG:Translate(teamLangKey) .. "(" ..
                            team.NumPlayers(teamID) .. ")")
    end
end

function GM:ShowTeam()

    if (IsValid(self.TeamSelectFrame)) then return end

    -- Simple team selection box
    local TeamSelectFrame = vgui.Create("DPanel")
    self.TeamSelectFrame = TeamSelectFrame
    TeamSelectFrame:SetPos(0, 0)
    TeamSelectFrame:SetSize(ScrW(), ScrH())
    TeamSelectFrame:Center()
    TeamSelectFrame:MakePopup()
    TeamSelectFrame:SetKeyboardInputEnabled(false)
    TeamSelectFrame.startTime = SysTime()

    function TeamSelectFrame:Paint(w, h)
        Derma_DrawBackgroundBlur(self, self.startTime)
    end

    function TeamSelectFrame:Think()
        if GWRound:IsCurrentState(GW_ROUND_NAV_GEN) then
            GAMEMODE:HideTeam()
        end
    end

    local topOffset = 240

    local links = {
        {
            GWLANG:Translate("teamselect_workshop_ref"),
            "http://steamcommunity.com/sharedfiles/filedetails/?id=480998235"
        }, {
            GWLANG:Translate("teamselect_workshop_changelog"),
            "http://steamcommunity.com/sharedfiles/filedetails/changelog/480998235"
        }, {
            GWLANG:Translate("teamselect_workshop_bug"),
            "http://steamcommunity.com/workshop/filedetails/discussion/480998235/523897653307060068/"
        },
        {GAMEMODE.GWConfig.ServerName, GAMEMODE.GWConfig.ServerUrl}
    }

    local linkOffsetY = topOffset

    for _, v in pairs(links) do
        local LinkButton = vgui.Create("DButton", TeamSelectFrame)
        LinkButton:SetPos(ScrW() / 2 - 620, linkOffsetY)
        LinkButton:SetSize(280, 40)
        LinkButton:SetFont("gw_font_small")
        LinkButton:SetText(v[1])
        LinkButton:SetTextColor(clrs.lightgrey)
        function LinkButton.DoClick() gui.OpenURL(v[2]) end
        function LinkButton:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, clrs.grey)
        end
        linkOffsetY = linkOffsetY + 80
    end

    local InfoBox = vgui.Create("DPanel", TeamSelectFrame)
    InfoBox:SetPos(ScrW() / 2 - 620, linkOffsetY)
    InfoBox:SetSize(280, 120)
    function InfoBox:Paint(w, h) draw.RoundedBox(0, 0, 0, w, h, clrs.grey) end

    local InfoTitle = vgui.Create("DLabel", TeamSelectFrame)
    InfoTitle:SetContentAlignment(5)
    InfoTitle:SetPos(ScrW() / 2 - 620, linkOffsetY)
    InfoTitle:SetSize(280, 40)
    InfoTitle:SetFont("gw_font_medium")
    InfoTitle:SetText("News")
    InfoTitle:SetTextColor(clrs.lightgrey)

    local InfoDescription = vgui.Create("DTextEntry", TeamSelectFrame)
    InfoDescription:SetPos(ScrW() / 2 - 620 + 5, linkOffsetY + 40)
    InfoDescription:SetSize(270, 160)
    InfoDescription:SetContentAlignment(5)
    InfoDescription:SetText(GAMEMODE.GWConfig.News)
    InfoDescription:SetPaintBackground(false)
    InfoDescription:SetMultiline(true)
    InfoDescription:SetFont("gw_font_small")
    InfoDescription:SetTextColor(clrs.lightgrey)

    local controls = {}
    if input.LookupBinding("duck") then
        table.insert(controls, {
            string.upper(input.LookupBinding("duck")),
            GWLANG:Translate("teamselect_controls_sit")
        })
    end
    if input.LookupBinding("attack2") then
        table.insert(controls, {
            string.upper(input.LookupBinding("attack2")),
            GWLANG:Translate("teamselect_controls_ability")
        })
    end
    if input.LookupBinding("gm_showhelp") then
        table.insert(controls, {
            string.upper(input.LookupBinding("gm_showhelp")),
            GWLANG:Translate("teamselect_controls_settings")
        })
    end
    if input.LookupBinding("gm_showteam") then
        table.insert(controls, {
            string.upper(input.LookupBinding("gm_showteam")),
            GWLANG:Translate("teamselect_controls_team")
        })
    end
    if input.LookupBinding("gm_showspare2") then
        table.insert(controls, {
            string.upper(input.LookupBinding("gm_showspare2")),
            GWLANG:Translate("teamselect_controls_random")
        })
    end
    if input.LookupBinding("menu") and input.LookupBinding("menu_context") then
        table.insert(controls, {
            string.upper(input.LookupBinding("menu")) .. " / " ..
                string.upper(input.LookupBinding("menu_context")),
            GWLANG:Translate("teamselect_controls_taunts")
        })
    end

    local controlsOffsetY = topOffset

    for _, v in pairs(controls) do
        local ControlKey = vgui.Create("DLabel", TeamSelectFrame)
        ControlKey:SetPos(ScrW() / 2 + 540, controlsOffsetY)
        ControlKey:SetSize(80, 40)
        ControlKey:SetFont("gw_font_smaller")
        ControlKey:SetText(v[1])
        ControlKey:SetTextColor(clrs.lightgrey)
        ControlKey:SetContentAlignment(5)
        function ControlKey:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, clrs.red)
        end

        local ControlDesc = vgui.Create("DLabel", TeamSelectFrame)
        ControlDesc:SetPos(ScrW() / 2 + 340, controlsOffsetY)
        ControlDesc:SetSize(200, 40)
        ControlDesc:SetFont("gw_font_small")
        ControlDesc:SetText(v[2])
        ControlDesc:SetTextColor(clrs.lightgrey)
        ControlDesc:SetContentAlignment(5)
        function ControlDesc:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, clrs.grey)
        end

        controlsOffsetY = controlsOffsetY + 80
    end

    local HeaderImage = vgui.Create("DImage", TeamSelectFrame)
    HeaderImage:SetSize(600, 100)
    HeaderImage:SetPos(0, 60)
    HeaderImage:SetMaterial(logoMaterial)
    HeaderImage:CenterHorizontal()

    -- Hiding Button
    CreateTeamJoinButton(GW_TEAM_HIDING, "team_hiding", TeamSelectFrame, ScrW() / 2 - 300, topOffset, GAMEMODE.GWConfig.HidingModels)

    -- Seeking Button
    CreateTeamJoinButton(GW_TEAM_SEEKING, "team_seeking", TeamSelectFrame, ScrW() / 2 + 20, topOffset, GAMEMODE.GWConfig.SeekerModels)

    -- spectate and auto buttons
    local TeamSpectateButton = vgui.Create("DButton", TeamSelectFrame)
    TeamSpectateButton:SetPos(ScrW() / 2 - 300, topOffset + 320)
    TeamSpectateButton:SetSize(600, 40)
    TeamSpectateButton:SetFont("gw_font_small")
    TeamSpectateButton:SetText(GWLANG:Translate("teamselect_buttons_spectate"))
    TeamSpectateButton:SetTextColor(clrs.lightgrey)
    function TeamSpectateButton.DoClick()
        self:HideTeam()
        RunConsoleCommand("changeteam", TEAM_SPECTATOR)
    end
    function TeamSpectateButton:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, clrs.grey)
    end

    local TeamAutoButton = vgui.Create("DButton", TeamSelectFrame)
    TeamAutoButton:SetPos(ScrW() / 2 - 300, topOffset + 320 + 80)
    TeamAutoButton:SetSize(600, 40)
    TeamAutoButton:SetFont("gw_font_small")
    TeamAutoButton:SetText(GWLANG:Translate("teamselect_buttons_auto"))
    TeamAutoButton:SetTextColor(clrs.lightgrey)
    function TeamAutoButton.DoClick()
        self:HideTeam()
        RunConsoleCommand("changeteam", team.BestAutoJoinTeam())
    end
    function TeamAutoButton:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, clrs.grey)
    end

    local CloseButton = vgui.Create("DButton", TeamSelectFrame)
    CloseButton:SetPos(ScrW() - 80, 40)
    CloseButton:SetSize(40, 40)
    CloseButton:SetFont("gw_font_medium")
    CloseButton:SetText("X")
    CloseButton:SetTextColor(clrs.lightgrey)
    function CloseButton.DoClick() TeamSelectFrame:Remove() end
    function CloseButton:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, clrs.grey)
    end

    local GMVersion = vgui.Create("DLabel", TeamSelectFrame)
    GMVersion:SetPos(ScrW() - 400, ScrH() - 40)
    GMVersion:SetSize(400, 40)
    GMVersion:SetFont("gw_font_medium")
    GMVersion:SetText("Version " .. GAMEMODE.Version)
    GMVersion:SetTextColor(clrs.lightgrey)
    GMVersion:SetContentAlignment(6)
    function GMVersion:Paint(w, h) return end

end

function GM:IsBalancedToJoin(teamid)

    if LocalPlayer():Team() == teamid then return true end

    if teamid == GW_TEAM_SEEKING then
        if team.NumPlayers(GW_TEAM_SEEKING) > team.NumPlayers(GW_TEAM_HIDING) or
            (LocalPlayer():Team() == GW_TEAM_HIDING and
                team.NumPlayers(GW_TEAM_SEEKING) == team.NumPlayers(GW_TEAM_HIDING)) then
            return false
        end
    elseif teamid == GW_TEAM_HIDING then
        if team.NumPlayers(GW_TEAM_HIDING) > team.NumPlayers(GW_TEAM_SEEKING) or
            (LocalPlayer():Team() == GW_TEAM_SEEKING and
                team.NumPlayers(GW_TEAM_SEEKING) == team.NumPlayers(GW_TEAM_HIDING)) then
            return false
        end
    end
    return true
end

function GM:HideTeam()
    if (IsValid(self.TeamSelectFrame)) then
        self.TeamSelectFrame:Remove()
        self.TeamSelectFrame = nil
    end
end
