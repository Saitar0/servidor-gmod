/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zmlab2.Frezzer.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zmlab2.Frezzer.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643

function ENT:Think()
    zmlab2.Frezzer.Think(self)
	self:SetNextClientThink(CurTime())
	return true
end

function ENT:OnRemove()
    zmlab2.Frezzer.OnRemove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

