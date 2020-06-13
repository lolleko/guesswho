AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Prophunt"

SWEP.AbilitySound = "physics/metal/metal_barrel_impact_hard1.wav"
SWEP.AbilityDuration = 7
SWEP.AbilityDescription = "A classic. Lasts $AbilityDuration seconds."

function SWEP:Ability()
    self:AbilityTimerIfValidSWEP(self.AbilityDuration, 1, true, function() self:AbilityCleanup() end)

    if CLIENT then return end

    local health = 10
    local volume = 1
    local ply = self.Owner

    local models = {
        {model = "models/props_c17/signpole001.mdl", offset = Vector(0, 0 , 0)},
        {model = "models/props_junk/garbage_coffeemug001a.mdl", offset = Vector(0, 0, 3)},
        {model = "models/props_lab/huladoll.mdl", offset = Vector(0, 0, 0)},
        {model = "models/props_junk/plasticbucket001a.mdl", offset = Vector(0, 0, 7)},
        {model = "models/props_c17/doll01.mdl", offset = Vector(0, 0 , 8)},
        {model = "models/props_trainstation/trainstation_post001.mdl", offset = Vector(0, 0, 0)},
        {model = "models/props_trainstation/trashcan_indoor001b.mdl", offset = Vector(0, 0, 17)},
        {model = "models/props_lab/cactus.mdl", offset = Vector(0, 0, 5)},
        {model = "models/props_c17/oildrum001.mdl", offset = Vector(0, 0, 0)},
    }

    local model = models[math.random(1, #models)]

    local tempEnt = ents.Create("gw_ability_prophunt")
    tempEnt:SetModel(model.model)
    tempEnt:Spawn()
    tempEnt:SetOwner(ply)
    tempEnt:SetMoveType(MOVETYPE_NONE)
    tempEnt:PhysicsInit(SOLID_VPHYSICS)
    tempEnt:SetPos(ply:GetPos())

    tempEnt:SetPropOffset(model.offset)

    local xy = math.Round(math.Max(tempEnt:OBBMaxs().x - tempEnt:OBBMins().x, tempEnt:OBBMaxs().y - tempEnt:OBBMins().y) / 2)
    local z = math.Round(tempEnt:OBBMaxs().z - tempEnt:OBBMins().z)

    local phys = tempEnt:GetPhysicsObject()

    if IsValid( phys ) then
        volume = phys:GetVolume()
        print("volume", volume)
        health = math.Clamp(math.Round(volume / 190), 1, 200)
    end
    tempEnt:PhysicsInit(SOLID_NONE)

    SafeRemoveEntityDelayed( tempEnt, 7)

    local spd

    if health < 50 then
        spd = 450
    elseif health < 100 then
        spd = 400
    elseif health < 150 then
        spd = 300
    else
        spd = 250
    end

    ply:SetRenderMode(RENDERMODE_NONE)
    ply:SetModel( tempEnt:GetModel() )

    ply:SetHull(Vector(-xy, - xy, 0), Vector(xy, xy, z))
    ply:SetHullDuck(Vector(-xy, - xy, 0), Vector(xy, xy, z))

    net.Start( "gwPlayerHull" )
    net.WriteFloat( xy )
    net.WriteFloat( z )
    net.Send( ply )

    ply:SetNoDraw(false)
    ply:DrawShadow(false)
    ply:SetHealth( health )

    ply:SetRunSpeed( spd )
    ply:SetWalkSpeed( spd )
end

function SWEP:AbilityCleanup()
    if not IsValid( self.Owner ) then return end
    local ply = self.Owner
    timer.Remove( "Ability.Effect.Prophunt" .. ply:SteamID() )
    ply:ResetHull()
    ply:SetRunSpeed( GetConVar("gw_hiding_run_speed"):GetFloat() )
    ply:SetWalkSpeed( GetConVar("gw_hiding_walk_speed"):GetFloat() )
    if SERVER then player_manager.RunClass( ply, "SetModel" ) end
    ply:SetRenderMode(RENDERMODE_NORMAL)
    ply:DrawShadow(true)
end
