AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("zfs_sweetener_AnimEvent")
util.AddNetworkString("zfs_sweetener_FX")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:UseClientSideAnimation()
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	self.IsFilling = false
end

function ENT:Use(activator, caller)
	if not zfs.f.IsOwner(activator, self:GetParent()) then
		zfs.f.Notify(activator, zfs.language.Shop.NotOwner, 1)

		return
	end

	if (self:GetParent():GetCurrentState() ~= "WAIT_FOR_SWEETENER") then return end
	self:GetParent():action_AddSweetener(self.SweetenerType)
	self:SweetFill()
end

function ENT:SweetFill()
	self:CreateAnim_Table("fill", 1)

	if (self.SweetenerType == "Coffe") then
		self:CreateEffect_Table("zfs_sweetener_coffee", nil, self)
	elseif (self.SweetenerType == "Milk") then
		self:CreateEffect_Table("zfs_sweetener_milk", nil, self)
	elseif (self.SweetenerType == "Chocolate") then
		self:CreateEffect_Table("zfs_sweetener_chocolate", nil, self)
	end

	timer.Simple(4, function()
		if (IsValid(self)) then
			self:SetNoDraw(true)
			self:SetPos(self:GetParent():GetAttachment(self:GetParent():LookupAttachment("fruitlift")).Pos)
			self:CreateAnim_Table("idle", 1)
			self:GetParent():ChangeState("WAIT_FOR_MIXERBUTTON")
		end
	end)
end

--Animation
function ENT:CreateAnim_Table(anim, speed)
	self:ServerAnim(anim, speed)
	net.Start("zfs_sweetener_AnimEvent")
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

-- Effects
function ENT:CreateEffect_Table(effect, sound, parent)
	net.Start("zfs_sweetener_FX")
	local effectInfo = {}
	effectInfo.effect = effect
	effectInfo.sound = sound
	effectInfo.parent = parent
	net.WriteTable(effectInfo)
	net.SendPVS(self:GetPos())
end
