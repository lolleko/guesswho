function GM:HandlePlayerDucking( ply, velocity )

    if ( not ply:Crouching() ) then return false end

    if ply:Team() == GW_TEAM_SEEKING then

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

function GM:GrabEarAnimation( ply )

    ply.ChatGestureWeight = ply.ChatGestureWeight or 0

    -- Don't show this when we're playing a taunt!
    if ( ply:IsPlayingTaunt() ) then return end

    if ply:GWIsHiding() then return end

    if ( ply:IsTyping() ) then
        ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 1, FrameTime() * 5.0 )
    else
        ply.ChatGestureWeight = math.Approach( ply.ChatGestureWeight, 0, FrameTime() * 5.0 )
    end

    if ( ply.ChatGestureWeight > 0 ) then

        ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
        ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.ChatGestureWeight )

    end

end
