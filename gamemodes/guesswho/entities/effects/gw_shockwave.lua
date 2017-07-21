AddCSLuaFile()

EFFECT.Mat = Material( "models/props_combine/portalball001_sheet" )
--EFFECT.Mat = Material( "models/effects/comball_tape" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Entity = data:GetEntity()
	self.Radius = 10
	self.FinalRadius = data:GetRadius()
    self.Center = self.Entity:OBBCenter()
    self:SetPos( self.Entity:GetPos() )

    self.EndTime = CurTime() + 0.5

end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()

    self:SetPos( self.Entity:GetPos() )
    self.Center = self.Entity:OBBCenter()
    if self.Radius < self.FinalRadius then self.Radius = self.Radius + 40 end

	return ( CurTime() < self.EndTime )

end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

    render.SetMaterial( self.Mat )

    local pos = self:GetPos() + self.Center

    render.DrawSphere( pos, self.Radius, 20, 20, Color( 255, 255, 255, 255) )

end
