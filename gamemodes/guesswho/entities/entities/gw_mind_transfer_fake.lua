AddCSLuaFile()

ENT.Base = "base_nextbot"

function ENT:Initialize()
    self:SetHealth(20)
    self:SetModel( "models/player/eli.mdl" )

    self.GetPlayerColor = function()
        return self:GetNWVector("gw_playercolor", Vector(1, 1, 1))
    end

    if SERVER then
        self.boundsSize = 16
        self.boundsHeight = 70
        self:SetCollisionBounds(
            Vector(-self.boundsSize, -self.boundsSize, 0),
            Vector(self.boundsSize, self.boundsSize, self.boundsHeight)
        )
    end

end

function ENT:RunBehaviour()

    while ( true ) do
        coroutine.wait(0.1)
    end

end

function ENT:SetPlayer(ply)
    self.player = ply
    self:SetNWVector("gw_playercolor", ply:GetPlayerColor())
end

function ENT:OnKilled(dmgInfo)
    hook.Call("OnNPCKilled", GAMEMODE, self, dmgInfo:GetAttacker(), dmgInfo:GetInflictor())
    self:BecomeRagdoll(dmgInfo)
    -- self.player:Kill()
end

function ENT:BodyUpdate()
    self.CalcIdeal = ACT_HL2MP_IDLE

    self:StartActivity(self.CalcIdeal)

    self:FrameAdvance()
end
