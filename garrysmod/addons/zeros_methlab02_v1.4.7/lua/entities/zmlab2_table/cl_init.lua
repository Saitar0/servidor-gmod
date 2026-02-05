/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643

function ENT:Initialize()
	zmlab2.Table.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643

function ENT:DrawTranslucent()
	self:Draw()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:Draw()
	self:DrawModel()
	zmlab2.Table.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:Think()
	zmlab2.Table.Think(self)
	self:SetNextClientThink(CurTime())

	return true
end

function ENT:OnRemove()
	zmlab2.Table.OnRemove(self)
end

