/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

include("shared.lua")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:Initialize()
	zmlab2.Filter.Initialize(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zmlab2.Filter.Draw(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:OnRemove()
    zmlab2.Filter.OnRemove(self)
end

