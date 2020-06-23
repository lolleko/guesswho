CHHUD = {}
CHHUD.AbilityIcons = {}

local iconDir = "materials/vgui/gw/abilityicons/"
local icons = file.Find(iconDir .. "*.png", "GAME")
for _, icon in pairs(icons) do
    local iconPath = "vgui/gw/abilityicons/" .. icon
    local abilityName = string.StripExtension(icon)
    CHHUD.AbilityIcons[abilityName] = Material(iconPath, "noclamp smooth")
end

function CHHUD:CreateHead()
    if not self.HeadModel and not IsValid(self.HeadModel) and GetConVar("gw_hud_showhead"):GetInt() == 1 then
        self.HeadModel = vgui.Create( "DModelPanel" )
        self.HeadModel:SetPos( 22, ScrH() - 180 )
        self.HeadModel:SetSize( 96, 100 )
        self.HeadModel.LayoutEntity = function() end
        self.HeadModel:ParentToHUD()
    end
end

function HideHUD(name) -- Removing the default HUD
    for k, v in pairs({"CHudCrosshair", "CHudHealth", "CHudAmmo", "CHudSecondaryAmmo"}) do
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

function CHHUD:DrawPanel( x, y, w, h, clr)
    surface.SetDrawColor( color( clr ) )
    surface.DrawRect( x, y, w, h )
end

function CHHUD:DrawUnderLinedPanel( x, y, w, h, clr)
    local teamColor = team.GetColor(LocalPlayer():Team())
    CHHUD:DrawPanel( x, y, w, h, G_GWColors.darkgreybg )
    CHHUD:DrawPanel( x, y + h - 5, w, 5, teamColor )
end

function CHHUD:DrawCircle( x, y, radius, seg, clr)

    if radius == 0 then return end

    surface.SetDrawColor( clr )

    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * - 360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is need for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

function CHHUD:DrawAbilityIcon(ability, x, y)
    if self.AbilityIcons[ability] then
        if team.Valid(GW_TEAM_HIDING) then
            local hidingColor = team.GetColor(GW_TEAM_HIDING)
            self.AbilityIcons[ability]:SetVector("$color", Vector(hidingColor.r / 255, hidingColor.g / 255, hidingColor.b / 255))
        end
        local w = 128
        local h = 128
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( self.AbilityIcons[ability] )
        surface.DrawTexturedRect( x, y, w, h )
    end
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
    if not ply:Alive() and IsValid(ply:GetObserverTarget()) then
        ply = ply:GetObserverTarget()
    end
    local time = string.ToMinutesSeconds( GAMEMODE.GWRound:GetEndTime() - CurTime())
    local teamColor = team.GetColor(ply:Team())
    local label = GAMEMODE.GWRound:GetRoundLabel() or "ERROR"

    CHHUD:DrawUnderLinedPanel( ScrW() / 2 - 100, 0, 200, 50, G_GWColors.darkgreybg)
    CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize(time, "gw_font_normal") / 2), 5, time, "gw_font_normal", G_GWColors.white )
    CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize( label, "gw_font_small" ) / 2 ), 26, label, "gw_font_small", G_GWColors.white )

    -- spectator
    if IsValid(LocalPlayer():GetObserverTarget()) then
        local specEnt = LocalPlayer():GetObserverTarget()
        if IsValid(specEnt) and specEnt:IsPlayer() then
            local nick = specEnt:Nick()
            CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize(nick, "gw_font_large") / 2), ScrH() - 40, nick, "gw_font_normal", G_GWColors.white )
        end
    end

    --Health
    local health = ply:Health()

    if ply:Alive() and ( ply:GWIsHiding() or ply:GWIsSeeking() ) and health > 0 then

        CHHUD:DrawUnderLinedPanel( 20, ScrH() - 80, 100, 60, G_GWColors.darkgreybg)
        CHHUD:DrawText( 70 - (CHHUD:TextSize(health, "gw_font_large") / 2), ScrH() - 75, health, "gw_font_large", G_GWColors.white )

    end

    if (GetConVar("gw_hud_showhead"):GetInt() == 0 or ply:Team() == TEAM_SPECTATOR or ply:Team() == TEAM_UNASSIGNED or not ply:Alive()) and CHHUD.HeadModel then

        CHHUD.HeadModel:Remove()
        CHHUD.HeadModel = nil

    elseif GetConVar("gw_hud_showhead"):GetInt() == 1 and (ply:Team() == GW_TEAM_HIDING or ply:Team() == GW_TEAM_SEEKING) and ply:Alive() then

        if not CHHUD.HeadModel then
            CHHUD:CreateHead()
        end

        CHHUD.HeadModel:SetModel( ply:GetModel() )
        function CHHUD.HeadModel.Entity:GetPlayerColor() return LocalPlayer():GetPlayerColor() end

        if CHHUD.HeadModel.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) then
            local headBone = CHHUD.HeadModel.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
            local headpos = CHHUD.HeadModel.Entity:GetBonePosition(headBone)
            if headpos then
                CHHUD.HeadModel:SetLookAt( headpos )
                CHHUD.HeadModel:SetCamPos( headpos - Vector( -18, 0, 0 ) )
            end
        end
    end

    if LocalPlayer():Alive() and (LocalPlayer():GWIsSeeking() or IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().DrawGWCrossHair) then
        CHHUD:Crosshair()
    end

    --Ammo
    if ply:Alive() and #ply:GetWeapons() > 0 and IsValid( ply:GetActiveWeapon() ) then

        local clipLeft = ply:GetActiveWeapon():Clip1()
        local clipExtra = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
        local secondaryAmmo = ply:GetAmmoCount(ply:GetActiveWeapon():GetSecondaryAmmoType())

        if ply:GWIsSeeking() then

            if clipLeft ~= -1 then
                CHHUD:DrawUnderLinedPanel( ScrW() - 220, ScrH() - 80, 200, 60, G_GWColors.darkgreybg)
                CHHUD:DrawText( ScrW() - 120 - (CHHUD:TextSize(clipLeft.. "/" .. clipExtra, "gw_font_large") / 2), ScrH() - 75, clipLeft .. "/" .. clipExtra, "gw_font_large", G_GWColors.white )
            end

            if secondaryAmmo > 0 then
                CHHUD:DrawPanel( ScrW() - 320, ScrH() - 40, 90, 20, teamColor)
                CHHUD:DrawText( ScrW() - 315, ScrH() - 38, "Nuke ready!", "gw_font_small", G_GWColors.white )
            end

        end

        if ply:GWIsHiding() and ply:GetActiveWeapon().GetIsAbilityUsed and not ply:GetActiveWeapon():GetIsAbilityUsed() then
            draw.RoundedBoxEx(64, ScrW() - 148, ScrH() - 168, 128, 128, G_GWColors.abilitybg, true, true)
            CHHUD:DrawPanel( ScrW() - 148, ScrH() - 40, 128, 20, G_GWColors.darkgreybg)
            CHHUD:DrawAbilityIcon(ply:GetActiveWeapon():GetClass(), ScrW() - 148, ScrH() - 168)
            CHHUD:DrawText( ScrW() - ( 84 + CHHUD:TextSize( ply:GetActiveWeapon().Name, "gw_font_small" ) / 2 ), ScrH() - 38, ply:GetActiveWeapon().Name, "gw_font_small", G_GWColors.white )
        end

    end

    --TargetFinder
    if ply:Alive() and ply:GWIsSeeking() and GetConVar("gw_target_finder_enabled"):GetBool() then
        local distance = ply:GetNWFloat("gwClosestTargetDistance", - 1)

        local distanceThreshold = GetConVar( "gw_target_finder_threshold" ):GetInt()
        local maxRadius = 50
        local circleRadius
        if distance == 0 then
            circleRadius = maxRadius
        elseif distance == -1 then
            circleRadius = 0
        else
            circleRadius = distanceThreshold / distance * maxRadius
        end
        CHHUD:DrawCircle( ScrW() / 2, ScrH() - 75, maxRadius, 32, G_GWColors.darkgreybg )
        CHHUD:DrawCircle( ScrW() / 2, ScrH() - 75, circleRadius, 32, teamColor )

        local distanceText = "No Target"
        if distance ~= -1 then
            if distance == 0 then
                distanceText = "Nearby"
            else
                distanceText = math.ceil(distance)
            end
        end
        CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize( distanceText, "gw_font_small" ) / 2), ScrH() - 83, distanceText, "gw_font_small", G_GWColors.white )
    end

    -- TOUCHES
    if ply:Alive() and ply:GWIsHiding() and GetConVar("gw_touches_enabled"):GetBool() then

        for i = 1, GetConVar("gw_touches_required"):GetInt() do
            CHHUD:DrawPanel( 110 + i * 20, ScrH() - 50, 10, 30, G_GWColors.darkgreybg)
        end

        for i = 1, ply:GWGetSeekerTouches() do
            CHHUD:DrawPanel( 110 + i * 20, ScrH() - 50, 10, 30, teamColor)
        end


    end

    --draw weapon hud if spectating
    if LocalPlayer() ~= ply and IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon().DrawHUD then
        ply:GetActiveWeapon():DrawHUD()
    end
end
hook.Add( "HUDPaint", "CHuntHUD", CHuntHUD)

function GM:HUDDrawTargetID()

    local tr = util.GetPlayerTrace( LocalPlayer() )
    local trace = util.TraceLine( tr )
    if ( not trace.Hit ) then return end
    if ( not trace.HitNonWorld ) then return end

    local text
    local font = "gw_font_medium"

    if LocalPlayer():Alive() and ( trace.Entity:IsPlayer() and ( trace.Entity:Team() == LocalPlayer():Team() or LocalPlayer():GWIsHiding() or trace.Entity:GWIsDisguised() ) ) then
        if trace.Entity:GWIsDisguised() then
            text = trace.Entity:GWGetDisguiseName()
        else
            text = trace.Entity:Nick()
        end
    end

    if not text then return end

    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )

    local MouseX, MouseY = gui.MousePos()

    if ( MouseX == 0 and MouseY == 0 ) then

        MouseX = ScrW() / 2
        MouseY = ScrH() / 2

    end

    local x = MouseX
    local y = MouseY

    local teamColor = self:GetTeamColor( trace.Entity )
    if trace.Entity:IsPlayer() and trace.Entity:GWIsDisguised() then teamColor = self:GetTeamColor(LocalPlayer()) end

    x = x - w / 2
    y = y + 30

    -- The fonts internal drop shadow looks lousy with AA on
    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, teamColor)

    y = y + h + 5

    text = trace.Entity:Health() .. "%"
    font = "gw_font_small"

    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )
    local x = MouseX - w / 2

    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, teamColor )
end

function GM:HUDDrawPickupHistory()

    if ( self.PickupHistory == nil ) then return end

    local x, y = ScrW() - self.PickupHistoryWide - 20, self.PickupHistoryTop
    local tall = 0
    local wide = 0

    local ply = LocalPlayer()
    local teamColor = team.GetColor(ply:Team())

    if not IsValid(ply) then return end
    for k, v in pairs( self.PickupHistory ) do

        if ( not istable( v ) ) then

            Msg( tostring( v ) .. "\n" )
            PrintTable( self.PickupHistory )
            self.PickupHistory[ k ] = nil
            return
        end

        if ( v.time < CurTime() ) then

            if ( v.y == nil ) then v.y = y end

            v.y = ( v.y * 5 + y ) / 6

            local delta = ( v.time + v.holdtime ) - CurTime()
            delta = delta / v.holdtime

            local alpha = 255
            local colordelta = math.Clamp( delta, 0.6, 0.7 )

            -- Fade in/out
            local ratio = 1
            if ( delta > 1 - v.fadein ) then
                ratio = math.Clamp( ( 1.0 - delta ) * ( 1 / v.fadein ), 0, 1)
                alpha = ratio * 255
            elseif ( delta < v.fadeout ) then
                ratio = math.Clamp( delta * ( 1 / v.fadeout ), 0, 1)
                alpha = ratio * 255
            end

            v.x = x + self.PickupHistoryWide - ( self.PickupHistoryWide * ( alpha / 255 ) )

            
            local pickupText

            if ply:GWIsHiding() and IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() ~= "weapon_gw_smgdummy" then
                pickupText = GWLANG:Translate("hud_ability_pickup")
            else
                pickupText = v.name
            end
            
            CHHUD:DrawUnderLinedPanel(ScrW() - (240 * ratio), y - 125, 240, 40, Color(G_GWColors.darkgreybg.r, G_GWColors.darkgreybg.g, G_GWColors.darkgreybg.b , alpha))
            CHHUD:DrawText(ScrW() - (230 * ratio), y - 125 + 5, pickupText, "gw_font_normal", Color(G_GWColors.white.r, G_GWColors.white.g, G_GWColors.white.b , alpha))

            y = y + ( v.height + 32 )
            tall = tall + v.height + 18
            wide = math.max( wide, v.width + v.height + 24 )

            if ( alpha == 0 ) then self.PickupHistory[ k ] = nil end

        end

    end

    self.PickupHistoryTop = ( self.PickupHistoryTop * 5 + ( ScrH() * 0.75 - tall ) / 2 ) / 6
    self.PickupHistoryWide = ( self.PickupHistoryWide * 5 + wide ) / 6

end
