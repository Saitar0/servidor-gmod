include("shared.lua")

function ENT:Initialize()
	zbl.f.EntList_Add(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
end
