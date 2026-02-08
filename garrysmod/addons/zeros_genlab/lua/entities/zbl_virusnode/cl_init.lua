include("shared.lua")

function ENT:Initialize()
	self.m_scale = -1
	self:DrawShadow(false)
	self.HasEffect = false
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()
	zbl.f.UpdateEntityVisuals(self)

	if zbl.f.InDistance(self:GetPos(), LocalPlayer():GetPos(), 500) then
		if self.HasEffect == nil or self.HasEffect == false then
			zbl.f.ParticleEffectAttach("zbl_infect_sporecloud", self, 0)
			self.HasEffect = true
		end
	else
		if self.HasEffect == true then
			self:StopParticles()
			self.HasEffect = false
		end
	end

	if zbl.f.InDistance(self:GetPos(), LocalPlayer():GetPos(), 2000) then
		self:ScaleModel()
	else
		self.m_scale = -1
	end
end

function ENT:UpdateVisuals()
	self.m_scale = math.Clamp((zbl.config.VirusNodes.max_scale / zbl.config.VirusHotspots.node_health_max) * self:GetVHealth(), 0.5, zbl.config.VirusNodes.max_scale)
	self:SetModelScale(self.m_scale, 0)
end

local function ConvertToInt(float)
	return math.Round(float * 1000)
end

local function ConvertToFloat(int)
	return int / 1000
end

function ENT:ScaleModel()
	local current_Scale = math.Clamp(self.m_scale, 0.5, zbl.config.VirusNodes.max_scale)
	current_Scale = ConvertToInt(current_Scale)

	local goal = math.Clamp((zbl.config.VirusNodes.max_scale / zbl.config.VirusHotspots.node_health_max) * self:GetVHealth(), 0.5, zbl.config.VirusNodes.max_scale)
	goal = ConvertToInt(goal)
	//if current_Scale == goal then return end

	if current_Scale < goal then
		current_Scale = current_Scale + ConvertToInt(0.5 * FrameTime())
	elseif current_Scale > goal then
		current_Scale = current_Scale - ConvertToInt(0.5 * FrameTime())
	end

	current_Scale = math.Clamp(current_Scale, ConvertToInt(0.3), ConvertToInt(zbl.config.VirusNodes.max_scale))
	self.m_scale = ConvertToFloat(current_Scale)
	self:SetModelScale(self.m_scale, 0)
end

function ENT:OnRemove()
	self:StopParticles()
end
