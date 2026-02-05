/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zmlab2.Tent.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zmlab2.Tent.Draw(self)
end

function ENT:Think()
	self:SetNextClientThink(CurTime())
	zmlab2.Tent.OnThink(self)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643

function ENT:OnRemove()
	zmlab2.Tent.OnRemove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

