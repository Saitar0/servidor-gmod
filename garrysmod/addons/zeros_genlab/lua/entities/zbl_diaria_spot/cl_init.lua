include("shared.lua")

function ENT:Initialize()
	zbl.f.ParticleEffectAttach("zbl_diaria_spot", self, 0)
	self:DrawShadow(false)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	//self:DrawModel()
end

function ENT:OnRemove()
	self:StopParticles()
end
