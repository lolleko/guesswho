CHHUD = {}

function CHHUD:CreateHead()
    if !self.HeadModel and !IsValid(self.HeadModel) and GetConVar("gw_hud_showhead"):GetInt() == 1 then
        self.HeadModel = vgui.Create( "DModelPanel" )
        self.HeadModel:SetPos( 22, ScrH() - 180 )
        self.HeadModel:SetSize( 96, 100 )
        self.HeadModel.LayoutEntity = function() end
    end
end

function HideHUD(name) -- Removing the default HUD
    for k, v in pairs({"CHudCrosshair","CHudHealth","CHudAmmo","CHudSecondaryAmmo"}) do
        if name == v then return false end
    end
end
hook.Add("HUDShouldDraw", "HideDefaultHUD", HideHUD)

local function color( clr ) return clr.r, clr.g, clr.b, clr.a end --not equal to "Color()"

function CHHUD:DrawText(x, y, text, font, clr)
    surface.SetFont( font )

    surface.SetTextPos( x, y )
    surface.SetTextColor( color( clr ) )
    surface.DrawText( text )
end

function CHHUD:TextSize( text, font )

    surface.SetFont( font )
    return surface.GetTextSize( text );

end

function CHHUD:DrawPanel( x, y, w, h, clrs, brdwidth)

    local b

    if !brdwidth then b = 1 else b = brdwidth end

    if clrs.border then
        surface.SetDrawColor( color( clrs.border ) )

        for i = 0, b - 1 do
            surface.DrawOutlinedRect( x + i - b, y + i - b , w + b * 2 - i * 2, h + b * 2 - i * 2 ) --What a mess (TIDY?)
        end

    end

    surface.SetDrawColor( color( clrs.background ) )
    surface.DrawRect( x, y, w, h )

end

function CHHUD:Crosshair()
    local x = ScrW() / 2
    local y = ScrH() / 2

    for w = 1, 5 do
        surface.DrawCircle( x, y, w, Color(255 / w, 255 / w, 255 / w, 10) )
    end
end

function CHuntHUD()
    if GetConVar("cl_drawhud"):GetInt() == 0 then
        if CHHUD.HeadModel then
            CHHUD.HeadModel:Remove()
            CHHUD.HeadModel = nil
        end
        return
    end
    local ply = LocalPlayer()
    local time = string.ToMinutesSeconds(GetGlobalFloat("EndTime", 0) - CurTime())
    local teamColor = team.GetColor(ply:Team())

    CHHUD:DrawPanel( ScrW() / 2 - 85, 0, 170, 50, {background = clrs.darkgreybg})
    CHHUD:DrawPanel( ScrW() / 2 - 85, 45, 170, 5, {background = teamColor})
    CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize(time, "robot_normal") / 2), 5, time, "robot_normal", clrs.white )
    CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize(GAMEMODE:GetRoundState(), "robot_small") / 2), 26, GAMEMODE:GetRoundState() , "robot_small", clrs.white )

    --Health
    local health = ply:Health()

    if ply:Team() != TEAM_SPECTATOR and health > 0 then
        CHHUD:DrawPanel( 20, ScrH() - 80, 100, 60, {background = clrs.darkgreybg})
        CHHUD:DrawPanel( 20, ScrH() - 25, 100, 5, {background = teamColor})
        CHHUD:DrawText( 70 - (CHHUD:TextSize(health, "robot_large") / 2), ScrH() - 75, health, "robot_large", clrs.white )
    end
    if (GetConVar("gw_hud_showhead"):GetInt() == 0 or ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED or !ply:Alive()) and CHHUD.HeadModel then
        CHHUD.HeadModel:Remove()
        CHHUD.HeadModel = nil
    elseif GetConVar("gw_hud_showhead"):GetInt() == 1 and (ply:Team() == TEAM_HIDING or ply:Team() == TEAM_SEEKING) and ply:Alive() then

        if !CHHUD.HeadModel then
            CHHUD:CreateHead()
        end

        CHHUD.HeadModel:SetModel( ply:GetModel() )
        function CHHUD.HeadModel.Entity:GetPlayerColor() return LocalPlayer():GetPlayerColor() end

        local headpos = CHHUD.HeadModel.Entity:GetBonePosition( CHHUD.HeadModel.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) )
        if headpos then
            CHHUD.HeadModel:SetLookAt( headpos )
            CHHUD.HeadModel:SetCamPos( headpos-Vector( -15, 0, 0 ) )
        end
    end

    if ply:Team() == TEAM_SEEKING then CHHUD:Crosshair() end

    --Ammo
    if #ply:GetWeapons() > 0 then
        local clipLeft = ply:GetActiveWeapon():Clip1()
        local clipExtra = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
        local secondaryAmmo = ply:GetAmmoCount(ply:GetActiveWeapon():GetSecondaryAmmoType())

        if clipLeft != -1 then
                CHHUD:DrawPanel( ScrW() - 220, ScrH() - 80, 200, 60, {background = clrs.darkgreybg})
                CHHUD:DrawPanel( ScrW() - 220, ScrH() - 25, 200, 5, {background = teamColor})
                CHHUD:DrawText( ScrW() - 120 - (CHHUD:TextSize(clipLeft.. "/" .. clipExtra, "robot_large") / 2), ScrH() - 75, clipLeft .. "/" .. clipExtra, "robot_large", clrs.white )
        end
        if secondaryAmmo > 0 then
            CHHUD:DrawPanel( ScrW() - 310, ScrH() - 40, 80, 20, {background = teamColor})
             CHHUD:DrawText( ScrW() - 305, ScrH() - 38, "Nuke ready!", "robot_small", clrs.white )
        end
    end
end
hook.Add( "HUDPaint", "CHuntHUD", CHuntHUD)

function GM:HUDDrawTargetID()

    local tr = util.GetPlayerTrace( LocalPlayer() )
    local trace = util.TraceLine( tr )
    if ( !trace.Hit ) then return end
    if ( !trace.HitNonWorld ) then return end

    local text = "ERROR"
    local font = "robot_medium"

    if ( trace.Entity:IsPlayer() and (trace.Entity:Team() == LocalPlayer():Team() or LocalPlayer():Team() == TEAM_HIDING )) then
        text = trace.Entity:Nick()
    else
        return
        --text = trace.Entity:GetClass()
    end

    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )

    local MouseX, MouseY = gui.MousePos()

    if ( MouseX == 0 and MouseY == 0 ) then

        MouseX = ScrW() / 2
        MouseY = ScrH() / 2

    end

    local x = MouseX
    local y = MouseY

    x = x - w / 2
    y = y + 30

    -- The fonts internal drop shadow looks lousy with AA on
    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )

    y = y + h + 5

    local text = trace.Entity:Health() .. "%"
    local font = "robot_small"

    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )
    local x = MouseX - w / 2

    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
end