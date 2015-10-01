function GM:HandlePlayerDucking( ply, velocity )

    if ( !ply:Crouching() ) then return false end

    ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence("sit_zen"),0.9, true) -- true = autokill
    ply:AnimSetGestureWeight(GESTURE_SLOT_CUSTOM, 1)

    return true

end