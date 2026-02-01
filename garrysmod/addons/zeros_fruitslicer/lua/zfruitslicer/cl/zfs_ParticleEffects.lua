if not CLIENT then return end

net.Receive("zfs_benefit_FX", function(len, ply)
	local effectInfo = net.ReadTable()

	if (effectInfo and IsValid(effectInfo.parent) and effectInfo.effect) then
		ParticleEffectAttach(effectInfo.effect, PATTACH_POINT_FOLLOW, effectInfo.parent, 0)

		timer.Simple(effectInfo.duration, function()
			if (IsValid(effectInfo.parent)) then
				effectInfo.parent:StopParticlesNamed(effectInfo.effect)
			end
		end)
	end
end)
