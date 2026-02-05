include("shared.lua")

function ENT:Initialize()
	ztm.f.EntList_Add(self)
end

function ENT:Draw()
	self:DrawModel()
end
