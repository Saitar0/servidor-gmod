include("shared.lua")

function ENT:Initialize()
	zbl.f.Lab_Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zbl.f.Lab_Draw(self)
end

function ENT:OnRemove()
	zbl.f.Lab_OnRemove(self)
end

function ENT:Think()
	zbl.f.Lab_Think(self)
	self:SetNextClientThink(CurTime())
	return true
end

function ENT:UpdateVisuals()
	zbl.f.Lab_UpdateVisuals(self)
end
