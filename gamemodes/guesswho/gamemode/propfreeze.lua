if SERVER then
	local Delay = 5 -- between 5-7 is recommended
	function DoPropFreeze(ply)
		timer.Simple( Delay, function()
			for k, v in pairs( ents.FindByClass( "prop_*" ) ) do
				local phys = v:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
			end
			print("[INFO] Props are frozen now!")
		end)
	end

	if GetConVar("gw_propfreeze_enabled"):GetBool() then
		hook.Add( "InitPostEntity", "PropFreezeOnInit", DoPropFreeze )
		hook.Add( "PostCleanupMap", "PropFreezeOnCleanUP", DoPropFreeze )
	end
end
