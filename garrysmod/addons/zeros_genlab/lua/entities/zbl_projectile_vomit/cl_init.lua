include("shared.lua")

function ENT:Initialize()
	zbl.f.ParticleEffectAttach("zbl_vomit_trail", self, 0)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
end

function ENT:OnRemove()
	self:StopParticles()
	zbl.f.ParticleEffect("zbl_vomit_explosion", self:GetPos(), self:GetAngles(), Entity(1))
	sound.Play(zbl.Sounds["VomitExplosion"], self:GetPos(), 75, 100, 1)
end
