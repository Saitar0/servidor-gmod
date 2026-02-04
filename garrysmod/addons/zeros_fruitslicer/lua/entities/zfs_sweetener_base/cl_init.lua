include("shared.lua")

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
end

--Animation
net.Receive("zfs_sweetener_AnimEvent", function(len, ply)
	local animInfo = net.ReadTable()

	if (animInfo and IsValid(animInfo.parent) and animInfo.anim) then
		animInfo.parent:ClientAnim(animInfo.anim, animInfo.speed)
	end
end)

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

--Effects
net.Receive("zfs_sweetener_FX", function(len, ply)
	local effectInfo = net.ReadTable()

	if (effectInfo) then
		if (effectInfo.parent == nil) then return end

		if (IsValid(effectInfo.parent)) then
			if (effectInfo.sound) then
				effectInfo.parent:EmitSound(effectInfo.sound)
			end

			if (effectInfo.effect) then
				ParticleEffectAttach(effectInfo.effect, PATTACH_POINT_FOLLOW, effectInfo.parent, 1)
			end
		end
	end
end)
