CHHUD = {}
CHHUD.AbilityIcons = {}

local icons = file.Find("materials/vgui/gw/abilityicons/*.png", "GAME")
for _, icon in pairs(icons) do
    CHHUD.AbilityIcons[string.StripExtension(icon)] = Material("materials/vgui/gw/abilityicons/" .. icon, "noclamp smooth")
end

function CHHUD:CreateHead()
    if !self.HeadModel and !IsValid(self.HeadModel) and GetConVar("gw_hud_showhead"):GetInt() == 1 then
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

function CHHUD:DrawPanel( x, y, w, h, clrs, brdwidth)

    local b

    if !brdwidth then b = 1 else b = brdwidth end

    if clrs.border then
        surface.SetDrawColor( color( clrs.border ) )

        for i = 0, b - 1 do
            surface.DrawOutlinedRect( x + i - b, y + i - b, w + b * 2 - i * 2, h + b * 2 - i * 2 ) --What a mess (TIDY?)
        end

    end

    surface.SetDrawColor( color( clrs.background ) )
    surface.DrawRect( x, y, w, h )

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

function CHHUD:DrawAbilityIcon(ability, x, y, w, h)
    if self.AbilityIcons[ability] then
        w = w or 128
        h = h or 128
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
    if !ply:Alive() and IsValid(ply:GetObserverTarget()) then
        ply = ply:GetObserverTarget()
    end
    local time = string.ToMinutesSeconds( GWRound:GetEndTime() - CurTime())
    local teamColor = team.GetColor(ply:Team())
    local label = GWRound:GetRoundLabel() or "ERROR"

    CHHUD:DrawPanel( ScrW() / 2 - 100, 0, 200, 50, {background = clrs.darkgreybg})
    CHHUD:DrawPanel( ScrW() / 2 - 100, 45, 200, 5, {background = teamColor})
    CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize(time, "robot_normal") / 2), 5, time, "robot_normal", clrs.white )
    CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize( label, "robot_small" ) / 2 ), 26, label, "robot_small", clrs.white )

    -- spectator
    if IsValid(LocalPlayer():GetObserverTarget()) then
        local specEnt = LocalPlayer():GetObserverTarget()
        if IsValid(specEnt) and specEnt:IsPlayer() then
            local nick = specEnt:Nick()
            CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize(nick, "robot_large") / 2), ScrH() - 40, nick, "robot_normal", clrs.white )
        end
    end

    --Health
    local health = ply:Health()

    if ply:Alive() and ( ply:IsHiding() or ply:IsSeeking() ) and health > 0 then

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

        if CHHUD.HeadModel.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) then
            local headBone = CHHUD.HeadModel.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
            local headpos = CHHUD.HeadModel.Entity:GetBonePosition(headBone)
            if ply:Team() == TEAM_SEEKING then
              CHHUD.HeadModel.Entity:ManipulateBoneScale(headBone, Vector(0, 0, 0))
            else
              CHHUD.HeadModel.Entity:ManipulateBoneScale(headBone, Vector(1, 1, 1))
            end
            if headpos then
                CHHUD.HeadModel:SetLookAt( headpos )
                CHHUD.HeadModel:SetCamPos( headpos - Vector( -15, 0, 0 ) )
            end
        end
    end

    if LocalPlayer():Alive() and (LocalPlayer():IsSeeking() or IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().DrawGWCrossHair) then
        CHHUD:Crosshair()
    end

    --Ammo
    if ply:Alive() and #ply:GetWeapons() > 0 and IsValid( ply:GetActiveWeapon() ) then

        local clipLeft = ply:GetActiveWeapon():Clip1()
        local clipExtra = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
        local secondaryAmmo = ply:GetAmmoCount(ply:GetActiveWeapon():GetSecondaryAmmoType())

        if ply:IsSeeking() then

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

        if ply:IsHiding() and ply:GetActiveWeapon():Clip2() > 0 then
            CHHUD:DrawPanel( ScrW() - 148, ScrH() - 40, 128, 20, {background = clrs.darkgreybg})
            CHHUD:DrawAbilityIcon(ply:GetActiveWeapon():GetClass(), ScrW() - 148, ScrH() - 168)
            CHHUD:DrawText( ScrW() - ( 84 + CHHUD:TextSize( ply:GetActiveWeapon().Name, "robot_small" ) / 2 ), ScrH() - 38, ply:GetActiveWeapon().Name, "robot_small", clrs.white )
        end

    end

    --TargetFinder
    if ply:Alive() and ply:IsSeeking() and GetConVar("gw_target_finder_enabled"):GetBool() then
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
        CHHUD:DrawCircle( ScrW() / 2, ScrH() - 75, maxRadius, 32, clrs.darkgreybg )
        CHHUD:DrawCircle( ScrW() / 2, ScrH() - 75, circleRadius, 32, teamColor )

        local distanceText = "No Target"
        if distance != -1 then
            if distance == 0 then
                distanceText = "Nearby"
            else
                distanceText = math.ceil(distance)
            end
        end
        CHHUD:DrawText( ScrW() / 2 - (CHHUD:TextSize( distanceText, "robot_small" ) / 2), ScrH() - 83, distanceText, "robot_small", clrs.white )
    end

    -- TOUCHES
    if ply:Alive() and ply:IsHiding() and GetConVar("gw_touches_enabled"):GetBool() then

        for i = 1, GetConVar("gw_touches_required"):GetInt() do
            CHHUD:DrawPanel( 110 + i * 20, ScrH() - 50, 10, 30, {background = clrs.darkgreybg})
        end

        for i = 1, ply:GetSeekerTouches() do
            CHHUD:DrawPanel( 110 + i * 20, ScrH() - 50, 10, 30, {background = teamColor})
        end


    end

    --draw weapon hud if spectating
    if LocalPlayer() != ply and IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon().DrawHUD then
        ply:GetActiveWeapon():DrawHUD()
    end

end
hook.Add( "HUDPaint", "CHuntHUD", CHuntHUD)

function GM:HUDDrawTargetID()

    local tr = util.GetPlayerTrace( LocalPlayer() )
    local trace = util.TraceLine( tr )
    if ( !trace.Hit ) then return end
    if ( !trace.HitNonWorld ) then return end

    local text
    local font = "robot_medium"

    if LocalPlayer():Alive() and ( trace.Entity:IsPlayer() and ( trace.Entity:Team() == LocalPlayer():Team() or LocalPlayer():IsHiding() or trace.Entity:GetDisguised() ) ) then
        text = trace.Entity:Nick()
    elseif trace.Entity:GetClass() == "gw_easter_egg" and trace.Entity:GetPos():Distance(LocalPlayer():GetPos()) < 100 then
        text = "Press " .. string.upper(input.LookupBinding( "use")) .. " for a suprise!"
    end

    if !text then return end

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
    if trace.Entity:IsPlayer() and trace.Entity:GetDisguised() then teamColor = self:GetTeamColor(LocalPlayer()) end

    x = x - w / 2
    y = y + 30

    -- The fonts internal drop shadow looks lousy with AA on
    draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( text, font, x, y, teamColor)

    y = y + h + 5

    text = trace.Entity:Health() .. "%"
    font = "robot_small"

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

        if ( !istable( v ) ) then

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
            if ( delta > 1 - v.fadein ) then
                alpha = math.Clamp( ( 1.0 - delta ) * ( 255 / v.fadein ), 0, 255 )
            elseif ( delta < v.fadeout ) then
                alpha = math.Clamp( delta * ( 255 / v.fadeout ), 0, 255 )
            end

            v.x = x + self.PickupHistoryWide - (self.PickupHistoryWide * ( alpha / 255 ) )

            local pickupText

            if ply:IsHiding() and IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon():GetClass() != "weapon_gw_smgdummy" then
                pickupText = gwlang:translate("hud_ability_pickup")
            else
                pickupText = v.name
            end

            local pickupTextSize = CHHUD:TextSize(pickupText, "robot_normal")

            CHHUD:DrawPanel( v.x + v.height + 8 - pickupTextSize / 2 - 5, v.y - ( v.height / 2 ) - 80, pickupTextSize + 10, 35, {background = clrs.darkgreybg})
            CHHUD:DrawPanel( v.x + v.height + 8 - pickupTextSize / 2 - 5, v.y - ( v.height / 2 ) - 50, pickupTextSize + 10, 5, {background = teamColor})
            CHHUD:DrawText( v.x + v.height + 8 - (pickupTextSize / 2), v.y - ( v.height / 2 ) - 75, pickupText, "robot_normal", clrs.white )

            y = y + ( v.height + 26 )
            tall = tall + v.height + 18
            wide = math.Max( wide, v.width + v.height + 24 )

            if ( alpha == 0 ) then self.PickupHistory[ k ] = nil end

        end

    end

    self.PickupHistoryTop = ( self.PickupHistoryTop * 5 + ( ScrH() * 0.75 - tall ) / 2 ) / 6
    self.PickupHistoryWide = ( self.PickupHistoryWide * 5 + wide ) / 6

end
