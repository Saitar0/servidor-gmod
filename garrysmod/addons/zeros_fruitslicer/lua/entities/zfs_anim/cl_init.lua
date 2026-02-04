include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Think()
	self:SetNextClientThink(CurTime())

	return true
end

function ENT:ClientAnim(anim, speed)
	local sequence = self:LookupSequence(anim)
	self:SetCycle(0)
	self:ResetSequence(sequence)
	self:SetPlaybackRate(speed)
	self:SetCycle(0)
end

net.Receive("zfs_baseanim_AnimEvent", function(len, ply)
	local animInfo = net.ReadTable()

	if (animInfo and IsValid(animInfo.parent) and animInfo.anim) then
		animInfo.parent:ClientAnim(animInfo.anim, animInfo.speed)
	end
end)
