local ActsFrame = {}

local DefaultActs1 = {
    {name = "Dance", act = ACT_GMOD_TAUNT_DANCE},
    {name = "Muscle", act = ACT_GMOD_TAUNT_MUSCLE},
    {name = "Robot", act = ACT_GMOD_TAUNT_ROBOT},
    {name = "Wave", act = ACT_GMOD_GESTURE_WAVE},
    {name = "Salute", act = ACT_GMOD_TAUNT_SALUTE},
    {name = "Persistence", act = ACT_GMOD_TAUNT_PERSISTENCE},
    {name = "Laugh", act = ACT_GMOD_TAUNT_LAUGH},
    {name = "Cheer", act = ACT_GMOD_TAUNT_CHEER},
}

local DefaultActs2 = {
    {name = "Agree", act = ACT_GMOD_GESTURE_AGREE},
    {name = "Disagree", act = ACT_GMOD_GESTURE_DISAGREE},
    {name = "Zombie", act = ACT_GMOD_GESTURE_TAUNT_ZOMBIE},
    {name = "Bow", act = ACT_GMOD_GESTURE_BOW},
    {name = "Halt", act = ACT_SIGNAL_HALT},
    {name = "Group", act = ACT_SIGNAL_GROUP},
    {name = "Forward", act = ACT_SIGNAL_FORWARD},
    {name = "Becon", act = ACT_GMOD_GESTURE_BECON},
}

function ActsFrame:Init()
    local height = 300
    local width = 150

    self:SetPos(0, 0)
    self:SetSize(width, height)
    self:CenterVertical()

    self.HeaderContainer = vgui.Create("DPanel", self)
    self.HeaderContainer:DockPadding(8, 8, 8, 8)
    self.HeaderContainer:Dock(TOP)
    self.HeaderContainer:SetSize(width, 32)

    local header = vgui.Create("DLabel", self.HeaderContainer)
    header:SetFont("gw_font_normal")
    header:SetText("Select taunt!")
    header:Dock(FILL)

    function self.HeaderContainer:Paint(w,h)
        local clr = team.GetColor(LocalPlayer():Team())
        draw.RoundedBox( 0, 0, 0, w, h, clr )
    end

    self.ActsContainer = vgui.Create("DPanel", self)
    self.ActsContainer:DockPadding(8, 8, 8, 8)
    self.ActsContainer:Dock(TOP)

    function self.ActsContainer:Paint(w,h)
        draw.RoundedBox( 0, 0, 0, w, h, G_GWColors.darkgreybg )
    end


    self:MakePopup()

    self:SetMouseInputEnabled( false )
    self:SetKeyboardInputEnabled( true )

    self:Hide()
end

function ActsFrame:Paint(w,h)

end

function ActsFrame:OnKeyCodePressed( keycode )
    local actnmbr

    if keycode == KEY_1 then
        actnmbr = 1
    elseif keycode == KEY_2 then
        actnmbr = 2
    elseif keycode == KEY_3 then
        actnmbr = 3
    elseif keycode == KEY_4 then
        actnmbr = 4
    elseif keycode == KEY_5 then
        actnmbr = 5
    elseif keycode == KEY_6 then
        actnmbr = 6
    elseif keycode == KEY_7 then
        actnmbr = 7
    elseif keycode == KEY_8 then
        actnmbr = 8
    elseif keycode == KEY_9 then
        actnmbr = 9
    else
        return false
    end

    if self.actstable[actnmbr] then
        LocalPlayer():GWClientRequestTaunt(self.actstable[actnmbr].act)
        return true
    end


end

function ActsFrame:SetActs( index )
    
    self.actstable = {}

    if index == 2 then
        self.actstable = DefaultActs2
    else
        self.actstable = DefaultActs1
    end

    self.ActsContainer:Clear()

    local pnl
    for i, actInfo in pairs(self.actstable) do
        pnl = vgui.Create("DLabel", self.ActsContainer)
        pnl:SetFont("gw_font_small")
        pnl:SetText(i .. ". " .. actInfo.name)
        pnl:Dock(TOP)
    end

    local _, paddingTop, _, paddingBottom = self.ActsContainer:GetDockPadding();
    self.ActsContainer:SetTall((pnl:GetTall() * #self.actstable) + paddingTop + paddingBottom)
end

vgui.Register("DActFrame", ActsFrame, "DPanel")

function GM:ActMenuOneOpen()
    if ( not IsValid( G_GWActsMenu ) ) then
        G_GWActsMenu = vgui.Create("DActFrame")
    end

    if ( IsValid( G_GWActsMenu ) and LocalPlayer():Alive() and LocalPlayer():Team() ~= TEAM_SPECTATOR ) then
        G_GWActsMenu:SetActs(1)
        G_GWActsMenu:Show()
    end

    return true
end

function GM:ActMenuTwoOpen()
    if ( not IsValid( G_GWActsMenu ) ) then
        G_GWActsMenu = vgui.Create("DActFrame")
    end

    if ( IsValid( G_GWActsMenu) and LocalPlayer():Alive() and LocalPlayer():Team() ~= TEAM_SPECTATOR ) then
        G_GWActsMenu:SetActs(2)
        G_GWActsMenu:Show()
    end

    return true
end


function GM:ActMenuClose()
     if ( IsValid( G_GWActsMenu ) ) then
        G_GWActsMenu:Hide()
    end
end

concommand.Add( "+menu", function() hook.Call( "ActMenuOneOpen", GAMEMODE ) end, nil, "Opens the actnmenu one", { FCVAR_DONTRECORD } )
concommand.Add( "-menu", function() if ( input.IsKeyTrapping() ) then return end hook.Call( "ActMenuClose", GAMEMODE ) end, nil, "Closes the actmenu", { FCVAR_DONTRECORD } )

concommand.Add( "+menu_context", function() hook.Call( "ActMenuTwoOpen", GAMEMODE ) end, nil, "Opens the actnmenu two", { FCVAR_DONTRECORD } )
concommand.Add( "-menu_context", function() if ( input.IsKeyTrapping() ) then return end hook.Call( "ActMenuClose", GAMEMODE ) end, nil, "Closes the actmenu", { FCVAR_DONTRECORD } )
