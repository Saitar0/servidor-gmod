AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 180)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel("models/zerochain/props_bloodlab/zbl_hazmat_npc.mdl")

	self:SetSolid(SOLID_BBOX)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetHullType(HULL_HUMAN)
	self:SetUseType(SIMPLE_USE)
	self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	self:CapabilitiesAdd(CAP_TURN_HEAD)

	zbl.f.NPC_Add(self)

	self:SetSkin(1)
end

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) and zbl.f.InDistance(ply:GetPos(), self:GetPos(), 100) then
		self.lastUsed = CurTime() + 1
		zbl.f.NPC_OnUse(self, ply)
	end
end

function ENT:OnRemove()
	zbl.f.NPC_Remove(self)
end
