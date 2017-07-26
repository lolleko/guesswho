local plymeta = FindMetaTable( "Player" )
if ( !plymeta ) then return end

AccessorFunc( plymeta, "iOldTeam", "PreviousTeam", FORCE_NUMBER )

function plymeta:SetSpeed( spd )
	self:SetWalkSpeed(spd)
	self:SetRunSpeed(spd)
end

function plymeta:IsSeeking()
	return ( self:Team() == TEAM_SEEKING )
end

function plymeta:IsHiding()
	return ( self:Team() == TEAM_HIDING )
end

function plymeta:SetStunned(state)
	self:SetNWBool("gw_stunned", state)
end

function plymeta:GetStunned(stae)
	return self:GetNWBool("gw_stunned", false)
end

function plymeta:IsStunned()
	return self:GetStunned()
end

-- TOUCHES
function plymeta:GetSeekerTouches()
	return self:GetNWInt("seeker_touches", 0)
end

function plymeta:SetSeekerTouches(val)
	self:SetNWInt("seeker_touches", val)
end

function plymeta:GetLastSeekerTouch()
	return self:GetNWFloat("last_seeker_touch", 0)
end

function plymeta:SetLastSeekerTouch(val)
	self:SetNWFloat("last_seeker_touch", val)
end


function plymeta:AddSeekerTouch()
	if self:GetLastSeekerTouch() + 2 < CurTime() then
		self:SetSeekerTouches(self:GetSeekerTouches() + 1)
		self:SetLastSeekerTouch(CurTime())
		if SERVER then
			self:PlaySoundForPlayer("buttons/blip1.wav")
		end

		if self:GetSeekerTouches() >= GetConVar("gw_touches_required"):GetInt() then
			self:ResetSeekerTouches()
		end
	end
end

function plymeta:ResetSeekerTouches()
	self:SetSeekerTouches(0)

	if SERVER then
		self:GiveRandomAbility()
	end
end

function plymeta:SetDeflect(state)
	self.deflect = state
end

function plymeta:GetDeflect()
	return self.deflect or false
end

function plymeta:SetDisguised(state)
	self.disguise = state
end

function plymeta:GetDisguised()
	return self.disguise or false
end
