local ActsFrame = {}

local DefaultActs1 = {
    "dance",
    "muscle",
    "wave",
    "salute",
    "bow",
    "laugh",
    "pers",
    "cheer"
}

local DefaultActs2 = {
    "agree",
    "disagree",
    "zombie",
    "robot",
    "halt",
    "group",
    "forward",
    "becon"
}

function ActsFrame:Init()

    self:SetPos( 0, 0 )
    self:SetSize(200, 400)
    self:CenterVertical()
    self:SetName("Select your Taunt!")
    self:Hide()

    self:MakePopup()

    self:SetMouseInputEnabled( false )
    self:SetKeyboardInputEnabled( true )

end

function ActsFrame:Paint(w,h)
    draw.RoundedBox( 0, 0, 0, w, h, clrs.darkgreybg )
    local clr = team.GetColor(LocalPlayer():Team())
    draw.RoundedBox( 0, 0, 0, w, h-(h-20), clr )
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
    else return end

    if self.actstable[actnmbr] then
        RunConsoleCommand("act" , self.actstable[actnmbr])
    end


end

function ActsFrame:SetActs( index )
    self.actstable = {}

    if index == 2 then
        self.actstable = DefaultActs2
    else
        self.actstable = DefaultActs1
    end

    for i, value in pairs(self.actstable) do
        local pnl = vgui.Create("DLabel", self)
        pnl:SetText(i .. ". " .. value)
        self:AddItem(pnl)
    end
end

vgui.Register("DActFrame", ActsFrame, "DForm")

function GM:ActMenuOneOpen()
    if ( !IsValid( g_Acts ) ) then
        g_Acts = vgui.Create("DActFrame")
    end

    if ( IsValid( g_Acts ) and LocalPlayer():Alive() and LocalPlayer():Team() ~= TEAM_SPECTATOR ) then
        g_Acts:Clear()
        g_Acts:SetActs(1)
        g_Acts:Show()
    end

    return true
end

function GM:ActMenuTwoOpen()
    if ( !IsValid( g_Acts ) ) then
        g_Acts = vgui.Create("DActFrame")
    end

    if ( IsValid( g_Acts) and LocalPlayer():Alive() and LocalPlayer():Team() ~= TEAM_SPECTATOR ) then
        g_Acts:Clear()
        g_Acts:SetActs(2)
        g_Acts:Show()
    end

    return true
end


function GM:ActMenuClose()
     if ( IsValid( g_Acts ) ) then
        g_Acts:Hide()
    end
end

concommand.Add( "+menu", function() hook.Call( "ActMenuOneOpen", GAMEMODE ) end, nil, "Opens the actnmenu one", { FCVAR_DONTRECORD } )
concommand.Add( "-menu", function() if ( input.IsKeyTrapping() ) then return end hook.Call( "ActMenuClose", GAMEMODE ) end, nil, "Closes the actmenu", { FCVAR_DONTRECORD } )

concommand.Add( "+menu_context", function() hook.Call( "ActMenuTwoOpen", GAMEMODE ) end, nil, "Opens the actnmenu two", { FCVAR_DONTRECORD } )
concommand.Add( "-menu_context", function() if ( input.IsKeyTrapping() ) then return end hook.Call( "ActMenuClose", GAMEMODE ) end, nil, "Closes the actmenu", { FCVAR_DONTRECORD } )
