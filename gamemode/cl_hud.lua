CHHUD ={}

surface.CreateFont( "robot",
     {
                    font    = "Roboto", -- Not file name, font name
                    size    = 32,
                    weight  = 400,
                    antialias = true,
                    shadow = false
            })

surface.CreateFont( "robot_small",
     {
                    font    = "Roboto", -- Not file name, font name
                    size    = 16,
                    weight  = 400,
                    antialias = true,
                    shadow = false
            })
surface.CreateFont( "robot_medium",
     {
                    font    = "Roboto", -- Not file name, font name
                    size    = 24,
                    weight  = 400,
                    antialias = true,
                    shadow = false
            })

function HideHUD(name) -- Removing the default HUD
	for k, v in pairs({"CHudCrosshair"})do
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
 
	surface.SetFont( font );
	return surface.GetTextSize( text );
 
end

function CHHUD:DrawPanel( x, y, w, h, clrs, brdwidth)

    local b 
    
    if not brdwidth then b = 1 else b = brdwidth end

    if clrs.border then
        surface.SetDrawColor( color( clrs.border ) )

        for i=0, b - 1 do
            surface.DrawOutlinedRect( x + i - b, y + i - b , w + b * 2 - i * 2, h + b * 2 - i * 2 ) --What a mess (TIDY?)
        end

    end
 
    surface.SetDrawColor( color( clrs.background ) )
    surface.DrawRect( x, y, w, h )

end

function CHHUD:Crosshair()
    local x = ScrW() / 2
    local y = ScrH() / 2

    for w=1,5 do
        surface.DrawCircle( x, y, w, Color(255/w,255/w,255/w,10) )
    end
end

function CHuntHUD()
	local time = string.ToMinutesSeconds(GetGlobalFloat("EndTime", 0) - CurTime())
	CHHUD:DrawPanel( ScrW()/2- 85, 0, 170, 65, {background = Color(120,120,120,20)})
	CHHUD:DrawText( ScrW()/2 - (CHHUD:TextSize(time, "robot")/2), 5, time, "robot", Color(255,255,255) )
    CHHUD:DrawText( ScrW()/2 - (CHHUD:TextSize(GAMEMODE:GetRoundState(), "robot_small")/2), 40, GAMEMODE:GetRoundState() , "robot_small", Color(255,255,255) )

    if LocalPlayer():Team() == TEAM_SEEKING then CHHUD:Crosshair() end
end
hook.Add( "HUDPaint", "CHuntHUD", CHuntHUD)

function GM:HUDDrawTargetID()

    local tr = util.GetPlayerTrace( LocalPlayer() )
    local trace = util.TraceLine( tr )
    if ( !trace.Hit ) then return end
    if ( !trace.HitNonWorld ) then return end
    
    local text = "ERROR"
    local font = "robot_medium"
    
    if ( trace.Entity:IsPlayer() and trace.Entity:Team() == LocalPlayer():Team() ) then
        text = trace.Entity:Nick()
    else
        return
        --text = trace.Entity:GetClass()
    end
    
    surface.SetFont( font )
    local w, h = surface.GetTextSize( text )
    
    local MouseX, MouseY = gui.MousePos()
    
    if ( MouseX == 0 && MouseY == 0 ) then
    
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