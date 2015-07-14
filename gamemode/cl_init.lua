include( "shared.lua" )
include( "cl_hud.lua" )
include( "cl_pickteam.lua")
include( "cl_scoreboard.lua")

function GM:CalcView(ply, pos, angles, fov)
	
	local Vehicle	= ply:GetVehicle()
	local Weapon	= ply:GetActiveWeapon()

	local view = {}
	view.origin		= origin
	view.angles		= angles
	view.fov		= fov
	view.znear		= znear
	view.zfar		= zfar
	view.drawviewer	= false

	--
	-- Let the vehicle override the view and allows the vehicle view to be hooked
	--
	if ( IsValid( Vehicle ) ) then return hook.Run( "CalcVehicleView", Vehicle, ply, view ) end

	--
	-- Let drive possibly alter the view
	--
	if ( drive.CalcView( ply, view ) ) then return view end

	--
	-- Give the player manager a turn at altering the view
	--
	player_manager.RunClass( ply, "CalcView", view )

	-- Give the active weapon a go at changing the viewmodel position
	if ( IsValid( Weapon ) ) then

		local func = Weapon.CalcView
		if ( func ) then
			view.origin, view.angles, view.fov = func( Weapon, ply, origin * 1, angles * 1, fov ) -- Note: *1 to copy the object so the child function can't edit it.
		end

	end

	if ply:Team() == TEAM_HIDING then

		local dist = 100

		local trace = {}
		trace.start = pos
		trace.endpos = pos - ( angles:Forward() * dist )
		trace.filter = LocalPlayer()
		local trace = util.TraceLine( trace )
		if trace.HitPos:Distance( pos ) < dist - 10 then
			dist = trace.HitPos:Distance( pos ) - 10;
		end

		view.origin = pos - ( angles:Forward() * dist )
		view.drawviewer = true

	elseif ply:Team() == TEAM_SEEKING and !GAMEMODE:InRound() then -- blind seekers
		view.origin = Vector(20000, 0, 0)
		view.angles = Angle(0, 0, 0)
	end

	return view
	
end

net.Receive("CleanUp", function(ken)
	game.CleanUpMap()
end)