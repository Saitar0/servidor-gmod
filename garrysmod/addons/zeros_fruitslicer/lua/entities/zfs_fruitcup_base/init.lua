AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("zfs_ItemBuy_net")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Right(), -90)
	ent:SetAngles(angle)
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
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	-- Since we create a complete new entity when finishing a fruit cup this got Obsolete
	self:SetReadydoSell(false)
	-- This is not in use atm sry
	self:SetPrice(-1)
	-- This makes sure we cant Interact with it if its in use by some other player
	self.IsInUseByOtherPlayer = false
	-- This makes sure it cant get sold for 1 Second
	self.SaleDelay = true

	timer.Simple(1, function()
		if (IsValid(self)) then
			self.SaleDelay = false
		end
	end)

	-- The Importent Information about the Cup
	self.ToppingID = nil
	self.ProductID = nil
end

function ENT:Use(activator, caller)
	if (not self:GetReadydoSell() or self.SaleDelay) then return end

	if (self.IsInUseByOtherPlayer) then
		zfs.f.Notify(activator, zfs.language.Shop.Item_InUse, 1)

		return
	end

	if (self.ProductID) then
		self.IsInUseByOtherPlayer = true
		net.Start("zfs_ItemBuy_net")
		local infotable = {}
		infotable.ProductID = self.ProductID
		infotable.ToppingID = self.ToppingID
		infotable.Price = self:GetPrice()
		infotable.ItemEntIndex = self:EntIndex()
		net.WriteTable(infotable)
		net.Send(activator)
	else
		if (zfs.config.Debug) then
			print("ProductID is nil?")
		end
	end
end
