if SERVER then
    local function voiceTaunt(ply, cmd, args)
        if SERVER then
            if !GetConVar( "gw_taunt_voice_enabled" ):GetBool() then ply:ChatPrint("Voice taunts are not enabled on this server.") return end
            if !GetConVar( "gw_taunt_voice_seeker_enabled" ):GetBool() and ply:Team() == TEAM_SEEKING then ply:ChatPrint("Voice taunts connot be used by seekers on this server.") return end
            if !ply.voicetauntcd then ply.voicetauntcd = CurTime() end
            if !ply:Alive() then ply:ChatPrint("You can't do that while dead.") return end
            if ply.voicetauntcd > CurTime() then
                ply:ChatPrint("Wait " .. math.Round(ply.voicetauntcd - CurTime(), 1) .. " seconds before using that again.")
                return
            end
            if args[1] == nil then return end
            local sounds = file.Find( "sound/gwtaunts/*", "GAME" )
            local sound = args[1] .. ".mp3"
            if !table.HasValue(sounds, sound) then ply:ChatPrint("Not a valid Guess Who taunt.") return end
            ply:EmitSound( Sound( "gwtaunts/" .. sound ))
            ply.voicetauntcd = CurTime() + GetConVar( "gw_taunt_voice_cooldown" ):GetInt()
        end
    end

    concommand.Add("gw_voicetaunt", voiceTaunt)

    function GM:PlayerShouldTaunt( ply, act )
        if !GetConVar( "gw_taunt_body_enabled" ):GetBool() then ply:ChatPrint("Body taunts are not enabled on this server.") return false end
        return true
    end

end

if CLIENT then
    net.Receive( "gwTauntExecuted", function( len )
        local ply = net.ReadEntity()
        ply:AddVCDSequenceToGestureSlot(GESTURE_SLOT_CUSTOM, net.ReadInt(32), 0, true)
        ply:AnimSetGestureWeight(GESTURE_SLOT_CUSTOM, 1)
    end )
end