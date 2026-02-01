AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
------------------------------//
util.AddNetworkString("zfs_baseanim_AnimEvent")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self:UseClientSideAnimation()
end

function ENT:CreateAnim_Table(anim, speed)
	self:ServerAnim(anim, speed)
	net.Start("zfs_AnimEvent")
	local animInfo = {}
	animInfo.anim = anim
	animInfo.speed = speed
	animInfo.parent = self
	net.WriteTable(animInfo)
	net.Broadcast()
end

function ENT:ServerAnim(anim, speed)
	local sequence = self:LookupSequence(anim)
	self:SetCycle(0)
	self:ResetSequence(sequence)
	self:SetPlaybackRate(speed)
	self:SetCycle(0)
end

function ENT:AnimSequence(anim1, anim2, speed)
	self:CreateAnim_Table(anim1, speed)

	timer.Simple(self:SequenceDuration(self:GetSequence()), function()
		if (not IsValid(self)) then return end
		self:CreateAnim_Table(anim2, speed)
	end)
end
