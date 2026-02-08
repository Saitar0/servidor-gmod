AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 15
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zbl.f.SetOwner(ent, ply)

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:UseClientSideAnimation()
	self:SetCustomCollisionCheck(true)
	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(100)
		phys:Wake()
		phys:EnableMotion(true)
	end

	zbl.f.Flask_Initialize(self)
end

function ENT:PhysicsCollide(data, phys)
	zbl.f.Flask_OnPhysicsCollide(self, data)
end

function ENT:OnTakeDamage(dmginfo)
	if (not self.m_bApplyingDamage) then
		self.m_bApplyingDamage = true
		self:TakeDamageInfo(dmginfo)
		zbl.f.Flask_OnDamage(self, dmginfo)
		self.m_bApplyingDamage = false
	end
end

function ENT:OnRemove()
	zbl.f.Flask_OnRemove(self)
end
