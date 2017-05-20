SWEP.Base = "weapon_gwbase"
SWEP.Name = "Decoy"
SWEP.AbilitySound = "vo/canals/matt_goodluck.wav"

function SWEP:Ability()

    if CLIENT then return end

    local locations = {
        Vector( 48, 0, 2 ),
        Vector( -48, 0, 2 ),
        Vector( 0, 48, 2 ),
        Vector( 0, -48, 2 ),
        Vector( 48, 48, 2 ),
        Vector( 48, -48, 2 ),
        Vector( -48, 48, 2 ),
        Vector( -48, -48, 2),
        Vector( 96, 0, 2 ),
        Vector( -96, 0, 2 ),
        Vector( 0, 96, 2 ),
        Vector( 0, -96, 2 )
    }

    local decoyCount = 0

    local walkers = {}

    for _,v in pairs( locations ) do
        if decoyCount == math.random( 1, 6 ) then break end

        local location = self.Owner:GetPos() + v

        local tr = util.TraceHull( {
            start = location,
            endpos = location,
            maxs = Vector( 16, 16, 70 ),
            mins = Vector( -16, -16, 0 ),
        } )

        --debugoverlay.Box( location, Vector( -16, -16, 0 ), Vector( 16, 16, 70 ), 5, Color( 255, 0, 0 ) )

        if !tr.Hit then
            local walker = ents.Create("npc_walker")
            if !IsValid( walker ) then break end
            walker:SetPos( location )
            walker:Spawn()
            walker:Activate()
            table.insert( walkers, walker )
            SafeRemoveEntityDelayed( walker, 12 )
            decoyCount = decoyCount + 1
        end

    end

    if #walkers >= 2 then
        local swap = walkers[ math.random(1, #walkers) ]
        local spos = swap:GetPos() + Vector( 0, 0, 2 )
        swap:SetPos( self.Owner:GetPos() + Vector( 0, 0, 2 ) )
        self.Owner:SetPos( spos )
        self.Owner:SetModel( GAMEMODE.Models[ math.random( 1, #GAMEMODE.Models ) ] )
    else
        self.Owner:SetHealth( 100 )
    end

end
