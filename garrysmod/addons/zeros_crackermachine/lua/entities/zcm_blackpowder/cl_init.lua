include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end


function ENT:Initialize()
	self.Destroyed = false
end

local sound_Explode = {"weapons/explode3.wav", "weapons/explode4.wav", "weapons/explode5.wav"}

function ENT:Think()
	if zcm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then
		local destroyd = self:GetDestroyed()

		if self.Destroyed ~= destroyd then
			self.Destroyed = destroyd
			if self.Destroyed then
				EmitSound(sound_Explode[math.random(#sound_Explode)], self:GetPos(), self:EntIndex(), CHAN_STATIC, 1, SNDLVL_75dB, 0, 100)
				ParticleEffect("zcm_blackpowder_explode", self:GetPos(), self:GetAngles(), NULL)
			end
		end
	else
		self.Destroyed = false
		self:StopParticles()
	end
end

function ENT:OnRemove()
	self:StopParticles()
end
