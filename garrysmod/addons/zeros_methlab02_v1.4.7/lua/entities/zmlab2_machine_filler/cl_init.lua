/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zmlab2.Filler.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zmlab2.Filler.Draw(self)
end

function ENT:Think()
    zmlab2.Filler.Think(self)
end

function ENT:OnRemove()
    zmlab2.Filler.OnRemove(self)
end

