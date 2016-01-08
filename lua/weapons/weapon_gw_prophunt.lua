SWEP.Base = "weapon_gwbase"
SWEP.Name = "Prophunt"

function SWEP:Ability()
    timer.Create( "Ability.Effect." .. self.Owner:SteamID(), 7, 1, function() self:OnRemove() end )

    if CLIENT then return end

	local health = 10
	local volume = 1
    local ply = self.Owner

    local models = {
        "models/props_c17/signpole001.mdl",
        "models/props_junk/garbage_coffeemug001a.mdl",
        "models/props_lab/huladoll.mdl",
        "models/props_junk/plasticbucket001a.mdl",
        "models/props_c17/doll01.mdl",
        "models/props_trainstation/trainstation_post001.mdl",
        "models/props_trainstation/trashcan_indoor001b.mdl",
        "models/props_lab/cactus.mdl",
        "models/props_c17/oildrum001.mdl",
        "models/props_junk/wood_crate001a.mdl"
    }

    local model = models[math.random( 1, #models ) ]

    local tempEnt = ents.Create( "gw_ability_prophunt" )
    tempEnt:SetModel( model )
    tempEnt:Spawn()
    tempEnt:SetOwner( ply )
    tempEnt:SetMoveType( MOVETYPE_NONE )
	tempEnt:SetSolid( SOLID_NONE )
    tempEnt:SetPos( ply:GetPos() + Vector( 0, 0, 70 ) )
    tempEnt:DropToFloor()

    local xy = math.Round(math.Max(tempEnt:OBBMaxs().x - tempEnt:OBBMins().x, tempEnt:OBBMaxs().y - tempEnt:OBBMins().y) / 2)
    local z = math.Round(tempEnt:OBBMaxs().z - tempEnt:OBBMins().z)

    local phys = tempEnt:GetPhysicsObject()

    if IsValid( phys ) then
        volume = phys:GetVolume()
        health = math.Clamp(math.Round(volume / 230), 1, 200)
    end

    SafeRemoveEntityDelayed( tempEnt, 7)

    local spd

    if health < 50 then
        spd = 400
    elseif health < 100 then
        spd = 300
    elseif health < 150 then
        spd = 250
    else
        spd = 200
    end

    ply:SetRenderMode(RENDERMODE_NONE)
    ply:SetModel( tempEnt:GetModel() )

    ply:SetHull(Vector(-xy, -xy, 0), Vector(xy, xy, z))
    ply:SetHullDuck(Vector(-xy, -xy, 0), Vector(xy, xy, z))

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

function SWEP:OnRemove()

    if !IsValid( self.Owner ) then return end
    local ply = self.Owner
    timer.Remove( "Ability.Effect." .. ply:SteamID() )
    ply:ResetHull()
    ply:SetRunSpeed( 200 )
    ply:SetWalkSpeed( 100 )
    if SERVER then player_manager.RunClass( ply, "SetModel" ) end
    ply:SetRenderMode(RENDERMODE_NORMAL)
    ply:DrawShadow(true)

end
