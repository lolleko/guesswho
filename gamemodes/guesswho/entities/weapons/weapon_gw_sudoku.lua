AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Sudoku"
SWEP.AbilitySound = {"vo/npc/male01/runforyourlife01.wav", "vo/canals/female01/gunboat_farewell.wav", "vo/canals/male01/stn6_incoming.wav"}
SWEP.AbilityModelScaleTimes = 10
SWEP.AbilityDuration = math.log(SWEP.AbilityModelScaleTimes)
SWEP.AbilityDescription = "Creates an explosion after $AbilityDuration seconds that damages nearby seekers."

function SWEP:Ability()
    if CLIENT then return end

    for t = self.AbilityModelScaleTimes, 1, -1 do
        self:AbilityTimerIfValidOwnerAndAlive(math.log(t), 1, true, function()
            self:GetOwner():SetColor(ColorRand())
            self:GetOwner():SetPlayerColor(Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1)))
            if SERVER then self:GetOwner():SetModel(GAMEMODE.GWConfig.HidingModels[math.random(1, #GAMEMODE.GWConfig.HidingModels)]) end
            self:GetOwner():SetModelScale(self:GetOwner():GetModelScale() + self:GetOwner():GetModelScale() / 10, 0.2)
        end)
    end

    self:AbilityTimerIfValidOwnerAndAlive(self.AbilityDuration, 1, true, function()
        self:GetOwner():Kill()
        local explode = ents.Create("env_explosion")
        explode:SetPos(self:GetOwner():GetPos())
        explode:SetOwner(self:GetOwner())
        explode:Spawn()
        explode:SetKeyValue("iMagnitude", "112")
        explode:Fire( "Explode", 0, 0 )
        explode:EmitSound( "BaseExplosionEffect.Sound", 100, 100 )
    end)
end

function SWEP:AbilityCleanup()
    if IsValid(self:GetOwner()) then
        self:GetOwner():SetModelScale(1, 0.1)
        self:GetOwner():SetColor(Color( 255, 255, 255, 255))
    end
end
