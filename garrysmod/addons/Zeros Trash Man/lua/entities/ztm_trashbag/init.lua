AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

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

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	ztm.f.Trashbag_Initialize(self)
end

function ENT:StartTouch(other)
	ztm.f.Trashbag_Touch(self, other)
end



function ENT:OnTakeDamage( dmginfo )
	-- Make sure we're not already applying damage a second time
	-- This prevents infinite loops
	if ( not self.ztm_bApplyingDamage ) then
		self.ztm_bApplyingDamage = true
		ztm.f.Entity_OnTakeDamage(self,dmginfo)
		self.ztm_bApplyingDamage = false
	end
end
