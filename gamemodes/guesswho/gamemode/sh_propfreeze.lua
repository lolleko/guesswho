-- Needs few language functions to understand it better

if SERVER then
	local Enabled = GM.PropFreezeEnabled
	local IsTimed = GM.PropFreezeIsTimed
	local Delay = GM.PropFreezeDelay

	function DoPropFreeze(ply)
		for k, v in pairs( ents.FindByClass( "prop_*" ) ) do 
			local phys = v:GetPhysicsObject()
			if IsTimed == true and IsValid(phys) then
				timer.Simple( Delay, function() if (IsValid(phys)) then phys:EnableMotion(false) end end )
			elseif IsTimed == false and IsValid(phys) then
				phys:EnableMotion(false)
			end
		end

		local typemsg = "Freeze type set to"
		if IsTimed == true then
			print("[INTO] "..typemsg.." 'Timed'")
		elseif IsTimed == false then
			print("[INFO] "..typemsg.." 'Instant'")
		end

		print("[INFO] Props are frozen now!")
	end

	if Enabled == true then
		hook.Add( "InitPostEntity", "PropFreezeOnInit", DoPropFreeze )
		hook.Add( "PostCleanupMap", "PropFreezeOnCleanUP", DoPropFreeze )
	end

end