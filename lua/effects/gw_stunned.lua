EFFECT.Mat = Material( "icon16/star.png", "unlitgeneric" )
--EFFECT.Mat = Material( "models/effects/comball_tape" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.Entity = data:GetEntity()
    self.EndTime = CurTime() + data:GetMagnitude()
    self:SetPos( self.Entity:GetBonePosition( self.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) ) )


end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()

    self:SetPos( self.Entity:GetBonePosition( self.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) ) )

	return ( CurTime() < self.EndTime )

end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	local pos = self:GetPos()

	cam.Start3D()
		render.SetMaterial( self.Mat )

		render.DrawSprite( pos + Vector( 6, 0, 8 ), 4, 4, Color( 255, 255, 255, 255) )
		render.DrawSprite( pos + Vector( -6, 0, 8 ), 4, 4, Color( 255, 255, 255, 255) )
		render.DrawSprite( pos + Vector( 0, 6, 8 ), 4, 4, Color( 255, 255, 255, 255) )
		render.DrawSprite( pos + Vector( 0, -6, 8 ), 4, 4, Color( 255, 255, 255, 255) )
	cam.End3D()
end
