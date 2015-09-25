function GM:PlayerDeathThink( ply )

    local spectargets = team.GetPlayers( ply:Team() )

    if GAMEMODE:InRound() then
        if !ply.SpecID then
            ply:Spectate(OBS_MODE_CHASE)
            if spectargets != nil then
                for k,v in pairs(spectargets) do
                    if v:Alive() then ply.SpecID = k ply:SpectateEntity(v)  break end
                end
            end
            if !ply.SpecID then ply.SpecID = 1 end
        end
        if ply:KeyPressed( IN_ATTACK ) then
            ply.SpecID = ply.SpecID + 1
            if ply.SpecID > #spectargets then
                ply.SpecID = 1
            end
            while !spectargets[ply.SpecID]:Alive() do ply.SpecID = ply.SpecID + 1 if spectargets[ply.SpecID] == nil then break end end -- if player not alive find next alive
            if IsValid(spectargets[ply.SpecID]) then
                ply:SpectateEntity(spectargets[ply.SpecID])
            end
        elseif ply:KeyPressed( IN_ATTACK2 ) then
            ply.SpecID = ply.SpecID - 1
            if ply.SpecID < 1 then
                ply.SpecID = #spectargets
            end
            while !spectargets[ply.SpecID]:Alive() do ply.SpecID = ply.SpecID - 1 if spectargets[ply.SpecID] == nil then break end end -- if player not alive find next alive
            if IsValid(spectargets[ply.SpecID]) then
                ply:SpectateEntity(spectargets[ply.SpecID])
            end
        end
    end

    if ( ply.NextSpawnTime and ply.NextSpawnTime > CurTime() ) then return end

    --give hiders a 2nd chance if they died in prep
    if ply:Team() == TEAM_HIDING and GAMEMODE:GetRoundState() == PRE_ROUND then
        ply:Spawn()
    end

    if ply:Team() == TEAM_SEEKING or ply:Team() == TEAM_HIDING then return end

    if ( ply:IsBot() or ply:KeyPressed( IN_ATTACK ) or ply:KeyPressed( IN_ATTACK2 ) or ply:KeyPressed( IN_JUMP ) ) then

        ply:Spawn()

    end

end

function GM:PlayerDeath( ply, inflictor, attacker )

    -- Don't spawn for at least 2 seconds
    ply.NextSpawnTime = CurTime() + 2
    ply.DeathTime = CurTime()

    ---spectate first alive player in team
    ply:Spectate(OBS_MODE_CHASE)
    local spectargets = team.GetPlayers( ply:Team() )
    if spectargets != nil then
        for k,v in pairs(spectargets) do
            if v:Alive() then ply.SpecID = k ply:SpectateEntity(v)  break end
        end
    end

    if ( IsValid( attacker ) and attacker:GetClass() == "trigger_hurt" ) then attacker = ply end

    if ( IsValid( attacker ) and attacker:IsVehicle() and IsValid( attacker:GetDriver() ) ) then
        attacker = attacker:GetDriver()
    end

    if ( !IsValid( inflictor ) and IsValid( attacker ) ) then
        inflictor = attacker
    end

    -- Convert the inflictor to the weapon that they're holding if we can.
    -- This can be right or wrong with NPCs since combine can be holding a
    -- pistol but kill you by hitting you with their arm.
    if ( IsValid( inflictor ) and inflictor == attacker and ( inflictor:IsPlayer() or inflictor:IsNPC() ) ) then

        inflictor = inflictor:GetActiveWeapon()
        if ( !IsValid( inflictor ) ) then inflictor = attacker end

    end

    if ( attacker == ply ) then

        net.Start( "PlayerKilledSelf" )
            net.WriteEntity( ply )
        net.Broadcast()

        MsgAll( attacker:Nick() .. " suicided!\n" )

    return end

    if ( attacker:IsPlayer() ) then

        net.Start( "PlayerKilledByPlayer" )

            net.WriteEntity( ply )
            net.WriteString( inflictor:GetClass() )
            net.WriteEntity( attacker )

        net.Broadcast()

        MsgAll( attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass() .. "\n" )

    return end

    net.Start( "PlayerKilled" )

        net.WriteEntity( ply )
        net.WriteString( inflictor:GetClass() )
        net.WriteString( attacker:GetClass() )

    net.Broadcast()

    MsgAll( ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )

end

function GM:PlayerSpawn( pl )

    --
    -- If the player doesn't have a team in a TeamBased game
    -- then spawn him as a spectator
    --
    if ( GAMEMODE.TeamBased and ( pl:Team() == TEAM_SPECTATOR or pl:Team() == TEAM_UNASSIGNED ) ) then

        GAMEMODE:PlayerSpawnAsSpectator( pl )
        return

    end

    if pl:Team() == TEAM_SEEKING then
        player_manager.SetPlayerClass( pl, "player_seeker")
    elseif pl:Team() == TEAM_HIDING then
        player_manager.SetPlayerClass( pl, "player_hiding")
    end

    -- Stop observer mode
    pl:UnSpectate()

    pl:SetupHands()

    player_manager.OnPlayerSpawn( pl )
    player_manager.RunClass( pl, "Spawn" )

    -- Call item loadout function
    hook.Call( "PlayerLoadout", GAMEMODE, pl )

    -- Set player model
    hook.Call( "PlayerSetModel", GAMEMODE, pl )

end

function GM:OnPlayerChangedTeam( ply, oldteam, newteam )

    -- Here's an immediate respawn thing by default. If you want to
    -- re-create something more like CS or some shit you could probably
    -- change to a spectator or something while dead.
    if ( newteam == TEAM_SPECTATOR ) then

        -- If we changed to spectator mode, respawn where we are
        local Pos = ply:EyePos()
        ply:Spawn()
        ply:SetPos( Pos )

    elseif ( oldteam == TEAM_SPECTATOR ) then

        -- If we're changing from spectator, join the game
        --disabled ply:Spawn()

    else

        -- If we're straight up changing teams just hang
        -- around until we're ready to respawn onto the
        -- team that we chose

    end

    PrintMessage( HUD_PRINTTALK, Format( "%s joined '%s'", ply:Nick(), team.GetName( newteam ) ) )

end

function GM:IsSpawnpointSuitable( pl, spawnpointent, bMakeSuitable )

    local Pos = spawnpointent:GetPos()

    -- Note that we're searching the default hull size here for a player in the way of our spawning.
    -- This seems pretty rough, seeing as our player's hull could be different.. but it should do the job
    -- (HL2DM kills everything within a 128 unit radius)
    local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 64 ) )

    if ( pl:Team() == TEAM_SPECTATOR ) then return true end

    local Blockers = 0

    for k, v in pairs( Ents ) do
        if ( IsValid( v ) and (v != pl and v:GetClass() == "player" and v:Alive()) or v:GetClass() == "npc_walker" ) then

            Blockers = Blockers + 1

            if ( bMakeSuitable ) then
            end

        end
    end

    if ( bMakeSuitable ) then return true end
    if ( Blockers > 0 ) then return false end
    return true

end

function GM:PlayerCanJoinTeam( ply, teamid )

    local TimeBetweenSwitches = GAMEMODE.SecondsBetweenTeamSwitches or 10
    if ( ply.LastTeamSwitch and RealTime() - ply.LastTeamSwitch < TimeBetweenSwitches ) then
        ply.LastTeamSwitch = ply.LastTeamSwitch + 1
        ply:ChatPrint( Format( "Please wait %i more seconds before trying to change team again", ( TimeBetweenSwitches - ( RealTime() - ply.LastTeamSwitch ) ) + 1 ) )
        return false
    end

    -- Already on this team!
    if ( ply:Team() == teamid ) then
        ply:ChatPrint( "You're already on that team" )
        return false
    end

    if teamid == TEAM_SEEKING then
        if team.NumPlayers( TEAM_SEEKING ) > team.NumPlayers( TEAM_HIDING ) then
            return false
        end
    elseif teamid == TEAM_HIDING then
        if team.NumPlayers( TEAM_HIDING ) > team.NumPlayers( TEAM_SEEKING ) then
            return false
        end
    end

    return true

end

function GM:ShowHelp(ply)
    if IsValid(ply) then
        ply:ConCommand("gw_settings")
    end
end

function GM:PlayerCanSeePlayersChat( text, teamonly, listenply, speakply )

    if ( teamonly ) then
        if ( !IsValid( speakply ) or !IsValid( listenply ) ) then return false end
        if ( listenply:Team() != speakply:Team() ) then return false end
    end

    if ( !IsValid( speakply ) or !IsValid( listenply ) ) then return false end
    if !listenply:Alive() and sepakerply:Alive() then return false end

    return true

end