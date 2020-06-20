AddCSLuaFile()

SWEP.Base = "weapon_gwbase"
SWEP.Name = "Mind Transfer"

SWEP.AbilityRange = 1600
SWEP.AbilityDescription = "Tranforms your mind to the targeted NPC leaving only an empty shell of your prior self behind.\n\nThe maximum transfer range is $AbilityRange units."

function SWEP:Ability()
    local ply = self.Owner
    local target = self:GetMindTransferTarget()
    if IsValid(target) then
        if SERVER then
            local effect = EffectData()
            effect:SetStart(ply:EyePos())
            effect:SetOrigin(ply:EyePos())
            effect:SetNormal(ply:GetAngles():Up())
            util.Effect("ManhackSparks", effect, true, true)

            local oldModel = ply:GetModel()
            local oldPos = ply:GetPos()
            local oldAngles = ply:GetAngles()
            local oldColor = target:GetPlayerColor()
            ply:SetModel(target:GetModel())
            ply:SetPos(target:GetPos())
            ply:SetAngles(target:GetAngles())
            target:Remove()
            local fake = ents.Create( "gw_mind_transfer_fake" )
            fake:Spawn()
            fake:Activate()
            fake:SetPos(oldPos)
            fake:SetAngles(Angle(0, oldAngles.yaw, 0))
            fake:SetPlayer(ply)
            ply:SetPlayerColor(oldColor)
            timer.Simple(0.01, function()
                fake:SetModel(oldModel)
                fake:SetCollisionBounds( Vector(-8, - 8, 0), Vector(8, 8, 36) )
            end)
        end
    else
        return GW_ABILTY_CAST_ERROR_INVALID_TARGET
    end
end

function SWEP:GetMindTransferTarget()
    local tr = util.TraceHull( {
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + (self.Owner:GetAimVector() * self.AbilityRange),
        filter = self.Owner,
        mins = Vector(-8, -8, -8),
        maxs = Vector(8, 8, 8),
        mask = MASK_SHOT_HULL
    } )
    local hitEnt = tr.Entity
    if IsValid(hitEnt) and hitEnt:GetClass() == GW_WALKER_CLASS then
        return tr.Entity
    end
    return nil
end

function SWEP:DrawHUD()
    if self:GetIsAbilityUsed() then self.DrawGWCrossHair = false return end
    local target = self:GetMindTransferTarget()
    if IsValid(target) then
        halo.Add( {target}, Color(255, 0, 0), 3, 3, 5, true, true)
    end
end
