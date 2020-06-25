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
    local ply = self:GetOwner()

    local models = {
        {model = "models/props_c17/signpole001.mdl", offset = Vector(0, 0 , 0), health = 11},
        --{model = "models/props_junk/garbage_coffeemug001a.mdl", offset = Vector(0, 0, 3)},
        {model = "models/props_lab/huladoll.mdl", offset = Vector(0, 0, 0), health = 1},
        {model = "models/props_junk/plasticbucket001a.mdl", offset = Vector(0, 0, 7), health = 25},
        {model = "models/props_c17/doll01.mdl", offset = Vector(0, 0 , 8), health = 15},
        {model = "models/props_trainstation/trainstation_post001.mdl", offset = Vector(0, 0, 0), health = 30},
        {model = "models/props_trainstation/trashcan_indoor001b.mdl", offset = Vector(0, 0, 17), health = 100},
        {model = "models/props_lab/cactus.mdl", offset = Vector(0, 0, 5), health = 9},
        {model = "models/props_c17/oildrum001.mdl", offset = Vector(0, 0, 0), health = 190},
    }

    local model = models[math.random(1, #models)]

    local tempEnt = ents.Create("gw_ability_prophunt")
    tempEnt:SetModel(model.model)
    tempEnt:Spawn()
    tempEnt:SetOwner(ply)
    tempEnt:SetMoveType(MOVETYPE_NONE)
    tempEnt:PhysicsInit(SOLID_NONE)
    tempEnt:SetPos(ply:GetPos())

    tempEnt:SetPropOffset(model.offset)

    local xy = math.Round(math.Max(tempEnt:OBBMaxs().x - tempEnt:OBBMins().x, tempEnt:OBBMaxs().y - tempEnt:OBBMins().y) / 2)
    local z = math.Round(tempEnt:OBBMaxs().z - tempEnt:OBBMins().z)

    SafeRemoveEntityDelayed( tempEnt, 7)

    local spd

    if health <= 50 then
        spd = 450
    elseif health <= 100 then
        spd = 400
    elseif health <= 200 then
        spd = 325
    else
        spd = 275
    end

    ply:SetRenderMode(RENDERMODE_NONE)
    ply:SetModel( tempEnt:GetModel() )

    ply:GWSetHullNetworked(xy, z)

    ply:SetNoDraw(false)
    ply:DrawShadow(false)
    ply:SetHealth(model.health)

    ply:SetRunSpeed( spd )
    ply:SetWalkSpeed( spd )
end

function SWEP:AbilityCleanup()
    if not IsValid( self:GetOwner() ) then return end
    local ply = self:GetOwner()
    ply:ResetHull()
    ply:SetRunSpeed( GetConVar("gw_hiding_run_speed"):GetFloat() )
    ply:SetWalkSpeed( GetConVar("gw_hiding_walk_speed"):GetFloat() )
    if SERVER then player_manager.RunClass( ply, "SetModel" ) end
    ply:SetRenderMode(RENDERMODE_NORMAL)
    ply:DrawShadow(true)
end
