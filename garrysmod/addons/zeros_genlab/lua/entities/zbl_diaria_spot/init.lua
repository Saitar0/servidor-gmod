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
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetTrigger(true)
	self:SetCustomCollisionCheck(true)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	self.PhysgunDisabled = true

	SafeRemoveEntityDelayed(self,15)
end

function ENT:StartTouch(other)
	if IsValid(other) and other:IsPlayer() and other:Alive() and self.VaccineID and self.VaccineStage then

		// Infect player
		zbl.f.Player_Infect(other,self.VaccineID,self.VaccineStage)
	end
end
