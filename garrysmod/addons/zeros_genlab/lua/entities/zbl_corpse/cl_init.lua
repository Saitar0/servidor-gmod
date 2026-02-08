include("shared.lua")

function ENT:Initialize()
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()

	if zbl.config.Corpse.ExplodeOnDespawn then

		local time = (self:GetCreationTime() + zbl.config.Corpse.life_time) - CurTime()
		local scale = (1 / zbl.config.Corpse.life_time) * math.Clamp(zbl.config.Corpse.life_time - time, 0, zbl.config.Corpse.life_time)
		scale = scale + 1

		for i = 0, self:GetBoneCount() - 1 do
			self:ManipulateBoneScale(i, Vector(1, 1, 1) * scale)
		end

		local prc = (1 / zbl.config.Corpse.life_time) * time

		self:SetColor(zbl.f.LerpColor(prc, zbl.default_colors["black01"], zbl.default_colors["white01"]))

	end
end

function ENT:OnRemove()
	if zbl.config.Corpse.ExplodeOnDespawn and CurTime() >= ((self:GetCreationTime() + zbl.config.Corpse.life_time) - 1) then
		zbl.NetEffectGroups["corpse_head"].action(self:GetPos())
	end
end
