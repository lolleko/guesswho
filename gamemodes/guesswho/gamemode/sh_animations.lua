function GM:HandlePlayerDucking( ply, velocity )

    if ( !ply:Crouching() ) then return false end

    if ply:Team() == TEAM_SEEKING then

        if ( velocity:Length2D() > 0.5 ) then
            ply.CalcIdeal = ACT_MP_CROUCHWALK
        else
            ply.CalcIdeal = ACT_MP_CROUCH_IDLE
        end

    else

        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, ply:LookupSequence("sit_zen"),0.9, true) -- true = autokill
        ply:AnimSetGestureWeight(GESTURE_SLOT_CUSTOM, 1)

    end

    return true

end