AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
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
	self:UseClientSideAnimation()

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	ztm.f.Buyermachine_Initialize(self)
end

function ENT:StartTouch(other)
	ztm.f.Buyermachine_Touch(self,other)
end

function ENT:AcceptInput( input, activator, caller, data )
	if string.lower( input ) == "use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		 ztm.f.Buyermachine_USE(self,activator)
	end
end

function ENT:Think()
	ztm.f.Buyermachine_Think(self)
	self:NextThink(CurTime() + 1)
	return true
end
