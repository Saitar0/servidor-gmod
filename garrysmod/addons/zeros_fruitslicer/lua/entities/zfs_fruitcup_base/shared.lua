ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.PrintName = "FruitCup"
ENT.Author = "ClemensProduction aka Zerochain"
ENT.Information = "info"
ENT.Category = "Zeros FruitSlicer"
ENT.Model = "models/zerochain/fruitslicerjob/fs_fruitcup.mdl"
ENT.DisableDuplicator = false

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "ReadydoSell")
	self:NetworkVar("Float", 0, "Price")
end
