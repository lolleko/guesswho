AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Decoy"

SWEP.AbilitySound = "vo/canals/matt_goodluck.wav"
SWEP.AbilityDecoyCountMin = 2
SWEP.AbilityDecoyCountMax = 9
SWEP.AbilityDuration = 14
SWEP.AbilityDescription = "Spawns between $AbilityDecoyCountMin and $AbilityDecoyCountMax decoys around you and swaps you with one of the spawned decoys.\n\nRequires enough room to spawn all decoys.\nThe decoys disappear afer $AbilityDuration seconds."

function SWEP:Ability()

    if CLIENT then return end

    local locations = {
        Vector(40, 0, 2),
        Vector(-40, 0, 2),
        Vector(0, 40, 2),
        Vector(0, -40, 2),
        Vector(40, 40, 2),
        Vector(40, -40, 2),
        Vector(-40, 40, 2),
        Vector(-40, -40, 2),
        Vector(80, 0, 2),
        Vector(-80, 0, 2),
        Vector(0, 80, 2),
        Vector(0, -80, 2),
        Vector(80, 80, 2),
        Vector(80, -80, 2),
        Vector(-80, 80, 2),
        Vector(-80, -80, 2),
    }

    -- shuffle locations table
    local rand = math.random
    local n = #locations

    while n > 2 do
        local k = rand(1, n) -- 1 <= k <= n
        locations[n], locations[k] = locations[k], locations[n]
        n = n - 1
    end

    local walkers = {}

    local decoyCount = math.random(self.AbilityDecoyCountMin, self.AbilityDecoyCountMax)

    local spawnedCount = 0

    for _,v in pairs(locations) do
        if decoyCount == spawnedCount then break end

        local location = self:GetOwner():GetPos() + v + Vector(0, 0, 8)

        local tr = util.TraceHull({
            start = location,
            endpos = location,
            maxs = Vector(16, 16, 70),
            mins = Vector(-16, -16, 0),
        })

        if not tr.Hit then
            local walker = ents.Create(GW_WALKER_CLASS)
            if not IsValid(walker) then break end
            walker:SetPos(location)
            walker:Spawn()
            walker:Activate()
            table.insert(walkers, walker)
            SafeRemoveEntityDelayed(walker, self.AbilityDuration)
            spawnedCount = spawnedCount + 1
        end

    end

    if #walkers >= 2 then
        local swap = walkers[math.random(1, #walkers)]
        local spos = swap:GetPos() + Vector(0, 0, 2)
        swap:SetPos(self:GetOwner():GetPos() + Vector(0, 0, 2))
        self:GetOwner():SetPos(spos)
        self:GetOwner():SetModel(GAMEMODE.GWConfig.HidingModels[math.random(1, #GAMEMODE.GWConfig.HidingModels)])
    else
        self:GetOwner():SetHealth(100)
    end

end
