if SERVER then
	CreateConVar( "gw_propfreeze_enabled", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )

	local Delay = 5 -- between 5-10 is recommended

	function DoPropFreeze(ply)
		timer.Simple( Delay, function()
			for k, v in pairs( ents.FindByClass( "prop_*" ) ) do 
				local phys = v:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
			end
		end)
		print("[INFO] Props are frozen now!")
	end

	if GetConVar("gw_propfreeze_enabled"):GetBool() then
		hook.Add( "InitPostEntity", "PropFreezeOnInit", DoPropFreeze )
		hook.Add( "PostCleanupMap", "PropFreezeOnCleanUP", DoPropFreeze )
	end
end