AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Ragdoll"

function SWEP:Ability()
    local ply = self.Owner
    timer.Create( "Ability.Effect.Ragdoll" .. ply:SteamID(), 8, 1, function()
        if IsValid(self) then
            self:OnRemove()
        end
    end)

    if SERVER then

        local hunters = team.GetPlayers(GW_TEAM_SEEKING)
        local hunter = hunters[math.random(#hunters)]

        if (hunter) then
            net.Start( "PlayerKilledByPlayer" )

            net.WriteEntity( ply )
            net.WriteString( hunter:GetActiveWeapon():GetClass() )
            net.WriteEntity( hunter )

            net.Broadcast()
        end

        if ply:InVehicle() then
            ply:ExitVehicle()
        end

        local ragdoll = ents.Create( "prop_ragdoll" )
        ragdoll:SetAngles( ply:GetAngles() )
        ragdoll:SetModel( ply:GetModel() )
        ragdoll:SetPos( ply:GetPos() )
        ragdoll:SetOwner(ply)
        ragdoll:Spawn()
        ragdoll:Activate()
        ply:SetParent( ragdoll ) -- So their player ent will match up (position-wise) with where their ragdoll is.
        -- Set velocity for each peice of the ragdoll

        local velocity = ply:GetVelocity()
        local j = 1
        while true do -- Break inside
            local phys_obj = ragdoll:GetPhysicsObjectNum( j )
            if phys_obj then
                phys_obj:SetVelocity( velocity )
                j = j + 1
            else
                break
            end
        end

        ply:Spectate( OBS_MODE_CHASE )
        ply:SpectateEntity( ragdoll )

        ply.gwRagdoll = ragdoll
    end
end

function SWEP:OnRemove()
    if SERVER then
        if not IsValid( self.Owner ) then return end
        local ply = self.Owner
        timer.Remove( "Ability.Effect.Ragdoll" .. ply:SteamID() )
        ply:SetParent()
        ply:UnSpectate()

        local ragdoll = ply.gwRagdoll
        ply.gwRagdoll = nil -- Gotta do this before spawn or our hook catches it

        if not IsValid(ragdoll) or not ragdoll:IsValid() then -- Something must have removed it, just spawn
            return
        else

            if ply:Alive() then
                ply:Spawn()
            end

            local pos = ragdoll:GetPos()
            pos.z = pos.z + 10 -- So they don't end up in the ground

            ply:SetModel(ragdoll:GetModel())
            ply:SetPos( pos )
            ply:SetVelocity( ragdoll:GetVelocity() )
            local yaw = ragdoll:GetAngles().yaw
            ply:SetAngles( Angle( 0, yaw, 0 ) )
            ragdoll:Remove()

        end
    end
end
