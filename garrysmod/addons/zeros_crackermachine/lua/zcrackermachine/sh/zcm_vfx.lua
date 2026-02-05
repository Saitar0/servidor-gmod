zcm = zcm or {}
zcm.f = zcm.f or {}

if SERVER then
	--Effects
	util.AddNetworkString("zcm_FX")

	function zcm.f.CreateEffectTable(effect, sound, parent, angle, position, attach)
		net.Start("zcm_FX")
		local effectInfo = {}
		effectInfo.effect = effect
		effectInfo.pos = position
		effectInfo.ang = angle
		effectInfo.parent = parent
		effectInfo.attach = attach
		effectInfo.sound = sound
		net.WriteTable(effectInfo)
		net.SendPVS(position)
	end
end

if CLIENT then
	-- Effects
	net.Receive("zcm_FX", function(len)
		local effectInfo = net.ReadTable()

		if effectInfo then
			if (effectInfo.sound) then

				local soundData = zcm.f.CatchSound(effectInfo.sound)
				EmitSound(soundData.sound, effectInfo.pos, LocalPlayer():EntIndex(), CHAN_STATIC, soundData.volume, soundData.lvl, 0, soundData.pitch)
			end

			if (effectInfo.effect) then
				if effectInfo.attach and IsValid(effectInfo.parent) then
					ParticleEffectAttach(effectInfo.effect, PATTACH_POINT_FOLLOW, effectInfo.parent, effectInfo.attach)
				else
					ParticleEffect(effectInfo.effect, effectInfo.pos, effectInfo.ang, NULL)
				end
			end
		end
	end)
end
