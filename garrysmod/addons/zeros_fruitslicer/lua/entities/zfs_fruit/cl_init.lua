include("shared.lua")

net.Receive("zfs_fruit_FX", function(len, ply)
	local effectInfo = net.ReadTable()

	if (effectInfo and IsValid(effectInfo.parent)) then
		if (effectInfo.sound) then
			effectInfo.parent:EmitSound(effectInfo.sound)
		end

		if (effectInfo.effect) then
				local ang = effectInfo.ang or Angle(0, 0, 0)
				ParticleEffect(effectInfo.effect, effectInfo.pos, ang, effectInfo.parent)
		end
	end
end)

function ENT:Draw()
	self:DrawModel()
end

function ENT:DrawTranslucent()
	self:Draw()
end
