include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.Ignited = false
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Think()
	if zcm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		local ign = self:GetIgnited()

		if self.Ignited ~= ign then
			self.Ignited = ign
			if self.Ignited then

				ParticleEffectAttach("zcm_fuse", PATTACH_POINT_FOLLOW, self, 1)

				EmitSound("zcm/zcm_fuse.wav", self:GetPos(), self:EntIndex(), CHAN_STATIC, GetConVar("zcm_cl_sfx_volume"):GetFloat() or 1, SNDLVL_75dB, 0, 100)

				timer.Simple(1.9,function()
					if IsValid(self) then
						zcm.f.CrackerPackExplode(self)
					end
				end)
			end
		end
	else
		self.Ignited = false
		self:StopParticles()
	end
end

function ENT:OnRemove()
	self:StopParticles()
end
