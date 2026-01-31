AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(zcm.config.NPC.Model)
	self:SetSolid(SOLID_BBOX)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetHullType(HULL_HUMAN)
	self:SetUseType(SIMPLE_USE)

	self:SetMaxYawSpeed(90)

	if zcm.config.NPC.Capabilities then
		self:CapabilitiesAdd(CAP_ANIMATEDFACE)
		self:CapabilitiesAdd(CAP_TURN_HEAD)
	end

	self:RefreshBuyRate()
	zcm.f.Add_BuyerNPC(self)
end

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) and zcm.f.InDistance(ply:GetPos(), self:GetPos(), 100) then
		self.lastUsed = CurTime() + 0.25
		zcm.f.Sell_CrackerPack(ply, self ,nil)
	end
end

function ENT:RefreshBuyRate()
	local newBuyRate = math.random(zcm.config.NPC.MinBuyRate, zcm.config.NPC.MaxBuyRate)
	self:SetPriceModifier(newBuyRate)

	zcm.f.debug("NPC: " .. self:EntIndex() .. " New BuyRate: " .. newBuyRate)
end
