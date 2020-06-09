CreateClientConVar("gw_hud_showhead", "1", true, false)
CreateClientConVar("gw_language", "auto", true, false)

language.Add(GW_WALKER_CLASS, "Walker")
language.Add("gw_ability_wall", "Graviton Surge")
language.Add("gw_mind_control_fake", "Mind Control Remnant")

surface.CreateFont("robot_medium", {
    font = "Roboto",
    size = 32,
    weight = 400,
    antialias = true,
    shadow = false
})

surface.CreateFont("robot_large", {
    font = "Roboto",
    size = 48,
    weight = 400,
    antialias = true,
    shadow = false
})

surface.CreateFont("robot_normal", {
    font = "Roboto",
    size = 24,
    weight = 400,
    antialias = true,
    shadow = false
})
surface.CreateFont("robot_small", {
    font = "Roboto",
    size = 16,
    weight = 400,
    antialias = true,
    shadow = false
})
surface.CreateFont("robot_smaller", {
    font = "Roboto",
    size = 12,
    weight = 400,
    antialias = true,
    shadow = false
})

clrs = {
    red = Color(158, 49, 74),
    blue = Color(53, 152, 219),
    green = Color(45, 204, 113),
    purple = Color(108, 113, 196),
    yellow = Color(241, 196, 16),
    lightgrey = Color(240, 240, 240),
    grey = Color(42, 42, 42),
    darkgrey = Color(26, 26, 26),
    black = Color(0, 0, 0),
    darkgreybg = Color(26, 26, 26, 245),
    greybg = Color(42, 42, 42, 200),
    redbg = Color(158, 49, 74, 50),
    white = Color(255, 255, 255)
}

-- includes
include("shared.lua")
include("cl_lang.lua")
include("cl_hud.lua")
include("cl_pickteam.lua")
include("cl_scoreboard.lua")
include("cl_settings.lua")
include("cl_acts.lua")
include("cl_round.lua")

-- Thirdpersoon + blinding
function GM:CalcView(ply, pos, angles, fov)

    local Vehicle = ply:GetVehicle()
    local Weapon = ply:GetActiveWeapon()

    local view = {}
    view.origin = origin
    view.angles = angles
    view.fov = fov
    view.znear = znear
    view.zfar = zfar
    view.drawviewer = false

    if (IsValid(Vehicle)) then
        return hook.Run("CalcVehicleView", Vehicle, ply, view)
    end

    if (drive.CalcView(ply, view)) then return view end

    player_manager.RunClass(ply, "CalcView", view)

    if (IsValid(Weapon)) then

        local func = Weapon.CalcView
        if (func) then
            view.origin, view.angles, view.fov =
                func(Weapon, ply, origin * 1, angles * 1, fov)
        end

    end

    if ply:IsHiding() or
        ((ply:IsStunned() or ply:IsPlayingTaunt()) and GWRound:IsCurrentState(GW_ROUND_HIDE)) then

        local dist = 100

        local tr = {}
        tr.start = pos
        tr.endpos = pos - (angles:Forward() * dist)
        tr.filter = LocalPlayer()
        local trace = util.TraceLine(tr)
        if trace.HitPos:Distance(pos) < dist - 10 then
            dist = trace.HitPos:Distance(pos) - 10;
        end

        view.origin = pos - (angles:Forward() * dist)
        view.drawviewer = true

    elseif ply:IsSeeking() and GWRound:IsCurrentState(GW_ROUND_HIDE) then -- blind seekers
        view.origin = Vector(20000, 0, 0)
        view.angles = Angle(0, 0, 0)
    end

    return view

end

local function RecievePlayerHull()

    local xy = net.ReadFloat()
    local z = net.ReadFloat()

    LocalPlayer():SetHull(Vector(-xy, -xy, 0), Vector(xy, xy, z))
    LocalPlayer():SetHullDuck(Vector(-xy, -xy, 0), Vector(xy, xy, z))

end
net.Receive("gwPlayerHull", RecievePlayerHull)
