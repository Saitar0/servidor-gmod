AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
end

local function GravGun_FillFruits(ply, ent)
	if (IsValid(ent) and string.sub(ent:GetClass(), 0, 12) == "zfs_fruitbox") then
		for k, v in pairs(ents.FindInSphere(ent:GetPos(), 50)) do
			if (v:GetClass() == "zfs_shop" and zfs.f.IsOwner(ply, v)) then
				v:FillStorage(ent.FruitType, ent.FruitAmount, true)
				ent:Remove()
				break
			end
		end
	end
end

hook.Add("GravGunOnDropped", "zfs_FillShop", GravGun_FillFruits)
