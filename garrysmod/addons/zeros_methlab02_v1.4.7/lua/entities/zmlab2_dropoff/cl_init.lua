/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

include("shared.lua")

function ENT:Initialize()
	zmlab2.Dropoff.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	zmlab2.Dropoff.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:OnRemove()
	zmlab2.Dropoff.OnRemove(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:Think()
	zmlab2.Dropoff.Think(self)
	self:SetNextClientThink(CurTime())
	return true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

