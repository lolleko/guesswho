if SERVER then
    local function voiceTaunt( ply, cmd, args )
        if SERVER then
            if not GetConVar( "gw_taunt_voice_enabled" ):GetBool() then ply:ChatPrint("Voice taunts are not enabled on this server.") return end
            if not GetConVar( "gw_taunt_voice_seeker_enabled" ):GetBool() and ply:IsSeeking() then ply:ChatPrint("Voice taunts connot be used by seekers on this server.") return end
            if not ply.voicetauntcd then ply.voicetauntcd = CurTime() end
            if not ply:Alive() then ply:ChatPrint("You can't taunt while dead.") return end
            if ply.voicetauntcd > CurTime() then
                ply:ChatPrint("Wait " .. math.Round(ply.voicetauntcd - CurTime(), 1) .. " seconds before you can taunt again.")
                return
            end
            if args[1] == nil then return end
            local sounds = file.Find( "sound/gwtaunts/*", "GAME" )
            local sound = args[1] .. ".mp3"
            if not table.HasValue( sounds, sound ) then ply:ChatPrint("Not a valid Guess Who taunt." ) return end
            ply:EmitSound( Sound( "gwtaunts/" .. sound ) )
            ply:ChatPrint( "Playing taunt: " .. args[1] )
            ply.voicetauntcd = CurTime() + GetConVar( "gw_taunt_voice_cooldown" ):GetInt()
        end
    end

    concommand.Add("gw_voicetaunt", voiceTaunt)

    function GM:PlayerShouldTaunt( ply, act )
        if not GetConVar( "gw_taunt_body_enabled" ):GetBool() then ply:ChatPrint("Body taunts are not enabled on this server." ) return false end
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
