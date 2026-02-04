ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_OPAQUE
--ENT.RenderGroup				=  RENDERGROUP_TRANSLUCENT
ENT.PrintName = "Shop"
ENT.Author = "ClemensProduction aka Zerochain"
ENT.Information = "info"
ENT.Category = "Zeros FruitSlicer"

if (zfs.config.Theme == 1) then
	ENT.Model = "models/zerochain/fruitslicerjob/fs_shop.mdl"
elseif (zfs.config.Theme == 2) then
	ENT.Model = "models/zerochain/fruitslicerjob/fs_shop_india.mdl"
end

ENT.DisableDuplicator = false

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "CurrentState")
	self:NetworkVar("Int", 0, "TSelectedItem")
	self:NetworkVar("Int", 1, "TSelectedTopping")
	self:NetworkVar("Float", 0, "PPrice")
	self:NetworkVar("Bool", 0, "IsBusy")
	self:NetworkVar("Bool", 1, "PublicEntity")
end
