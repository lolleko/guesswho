SWEP.Base = "weapon_gwbase"
SWEP.Name = "Sudoku"
SWEP.AbilitySound = {"vo/npc/male01/runforyourlife01.wav", "vo/canals/female01/gunboat_farewell.wav", "vo/canals/male01/stn6_incoming.wav"}

function SWEP:Ability()

    local ply = self.Owner
    local last = 1
    --[[1 + 1 = 2
    1+0.95 = 1.95
    0.95 + 0.9 = 1.85
    0.9 + 0.85 = 1.75
    0.85 + 0.77 = 1.57
    0.77 + 0.69 = 1.46
    0.69 + 0.60 = 1.29
    0.6 + 0.47 = 1.07
    0.47 + 0.3 = 0.77
    0.3 + 0 = 0.3--]]
    for t = 10, 1, -1 do
        timer.Simple( math.log( t ), function()
            if !IsValid( ply ) or !ply:Alive() then return end
            ply:SetColor( ColorRand() )
            ply:SetPlayerColor( Vector( math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1) ) )
            if SERVER then ply:SetModel( GAMEMODE.Models[ math.random( 1, #GAMEMODE.Models ) ] ) end
            ply:SetModelScale( ply:GetModelScale() + ply:GetModelScale() / 10, 0.1 )
        end )
        last = math.log( t )
    end

    timer.Simple( 2, function()
        if !IsValid( ply ) or !ply:Alive() then return end
        if SERVER then
            ply:Kill()
            local explode = ents.Create( "env_explosion" )
        	explode:SetPos( ply:GetPos() )
        	explode:SetOwner( ply:GetPos() )
        	explode:Spawn()
        	explode:SetKeyValue( "iMagnitude", "115" )
        	explode:Fire( "Explode", 0, 0 )
        	explode:EmitSound( "BaseExplosionEffect.Sound", 100, 100 )
        end
    end)

    timer.Simple( 2.1, function()
        ply:SetModelScale( 1, 0.1 )
        ply:SetColor( Color( 255, 255, 255, 255 ) )
    end)

end
