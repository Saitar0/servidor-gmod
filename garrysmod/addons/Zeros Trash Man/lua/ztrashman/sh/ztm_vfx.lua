ztm = ztm or {}
ztm.f = ztm.f or {}

if SERVER then

	//Effects
	util.AddNetworkString("ztm_FX")
	function ztm.f.CreateEffectTable(effect, sound, parent, angle, position, attach)
		local effectInfo = {}

		if sound and effect == nil then
			effectInfo.sound = sound
			effectInfo.parent = parent
		else

			effectInfo.effect = effect
			effectInfo.sound = sound
			effectInfo.pos = position
			effectInfo.ang = angle
			effectInfo.parent = parent
			effectInfo.attach = attach
		end

		net.Start("ztm_FX")
		net.WriteTable(effectInfo)
		net.SendPVS(parent:GetPos())
	end

	util.AddNetworkString("ztm_remove_FX")

	function ztm.f.RemoveEffectNamed(prop, effect)
		local effectInfo = {}
		effectInfo.effect = effect
		effectInfo.parent = prop
		net.Start("ztm_remove_FX")
		net.WriteTable(effectInfo)
		net.SendPVS(prop:GetPos())
	end

	function ztm.f.GenericEffect(effect,vPoint)
		local effectdata = EffectData()
		effectdata:SetStart(vPoint)
		effectdata:SetOrigin(vPoint)
		effectdata:SetScale(1)
		util.Effect(effect, effectdata)
	end



	util.AddNetworkString("ztm_trash_fx")
	// Special effect nw for trashcollector primary
	function ztm.f.TrashEffect(pos)
		net.Start("ztm_trash_fx")
		net.WriteVector(pos)
		net.Broadcast()
	end

	util.AddNetworkString("ztm_leafpile_fx")
	// Special effect nw for trashcollector primary
	function ztm.f.LeafpileEffect(leafpile)
		net.Start("ztm_leafpile_fx")
		net.WriteEntity(leafpile)
		net.Broadcast()
	end

	util.AddNetworkString("ztm_trashcollector_primary_fx")
	// Special effect nw for trashcollector primary
	function ztm.f.Effect_Exception(parent,exception)

		net.Start("ztm_trashcollector_primary_fx")
		//net.WriteTable(effectInfo)
		net.WriteEntity(exception)
		net.SendPVS(parent:GetPos())
	end
end

if CLIENT then


	net.Receive("ztm_trash_fx", function(len, ply)

		local pos = net.ReadVector()
		ztm.f.Debug("Trash FX Net Length: " .. len)

		if pos then
			local effects = {"ztm_trash_break01","ztm_trash_break02","ztm_trash_break03"}
			ztm.f.ParticleEffect(effects[ math.random( #effects ) ],pos, Angle(), Entity(1))

		end
	end)


	net.Receive("ztm_leafpile_fx", function(len, ply)

		local ent = net.ReadEntity()
		ztm.f.Debug("Leafpile FX Net Length: " .. len)

		if IsValid(ent) then

			ztm.f.ParticleEffect("ztm_leafpile_explode",ent:GetPos(), ent:GetAngles(), ent)
			ent:EmitSound("ztm_leafpile_explode01")
		end
	end)

	// Creates a random trash break effect
	function ztm.f.TrashEffect(ent, pos)
		ent:EmitSound("ztm_trash_break")
		local effects = {"ztm_trash_break01","ztm_trash_break02","ztm_trash_break03"}
		ztm.f.ParticleEffect(effects[ math.random( #effects ) ],pos, ent:GetAngles(), ent)
	end

	local function create_effect(effectInfo)
		if (effectInfo.effect and ztm.f.InDistance(LocalPlayer():GetPos(), effectInfo.parent:GetPos(), 500)) then

			if (effectInfo.attach) then

				ztm.f.ParticleEffectAttach(effectInfo.effect, PATTACH_POINT_FOLLOW, effectInfo.parent, effectInfo.attach)
			else

				ztm.f.ParticleEffect(effectInfo.effect, effectInfo.pos, effectInfo.ang, effectInfo.parent)
			end
		end
	end

	// Effects
	net.Receive("ztm_FX", function(len, ply)

		local effectInfo = net.ReadTable()
		ztm.f.Debug("FX Net Length: " .. len)

		if effectInfo and IsValid(effectInfo.parent) then

			if (effectInfo.sound) then
				ztm.f.EmitSoundENT(effectInfo.sound,effectInfo.parent)
			end

			if (effectInfo.effect and ztm.f.InDistance(LocalPlayer():GetPos(), effectInfo.parent:GetPos(), 500)) then

				if (effectInfo.attach) then

					ztm.f.ParticleEffectAttach(effectInfo.effect, PATTACH_POINT_FOLLOW, effectInfo.parent, effectInfo.attach)
				else

					ztm.f.ParticleEffect(effectInfo.effect, effectInfo.pos, effectInfo.ang, effectInfo.parent)
				end
			end
		end
	end)

	/*
	net.Receive("ztm_exception_fx", function(len, ply)

		local effectInfo = net.ReadTable()
		ztm.f.Debug("Except FX Net Length: " .. len)

		if effectInfo and IsValid(effectInfo.parent) then

			if (effectInfo.sound) then
				ztm.f.EmitSoundENT(effectInfo.sound,effectInfo.parent)
			end

			if LocalPlayer() == effectInfo.exception then
				local ve = GetViewEntity()

				if ve:GetClass() ~= "player" then
					create_effect(effectInfo)
				end
			else
				create_effect(effectInfo)
			end
		end
	end)
	*/

	net.Receive("ztm_trashcollector_primary_fx", function(len, ply)

		local exception = net.ReadEntity()
		ztm.f.Debug("Except FX Net Length: " .. len)

		if IsValid(exception) then


			//ztm.f.EmitSoundENT(effectInfo.sound,effectInfo.parent)

			local swep = exception:GetActiveWeapon()
			if not IsValid(swep) then return end
			if swep:GetClass() ~= "ztm_trashcollector" then return end

			local attach = swep:GetAttachment(1)
			if attach == nil then return end

			local effectInfo = {}
			effectInfo.effect = "ztm_air_burst"
			effectInfo.pos = attach.Pos
			effectInfo.ang = attach.Ang
			effectInfo.parent = swep
			effectInfo.attach = 1

			if LocalPlayer() == exception then
				local ve = GetViewEntity()

				if ve:GetClass() ~= "player" then
					create_effect(effectInfo)
				end
			else
				create_effect(effectInfo)
			end
		end
	end)

	function ztm.f.ParticleEffect(effect, pos, ang, ent)
		//if GetConVar("ztm_cl_vfx_particleeffects"):GetInt() == 1 then
			ParticleEffect(effect, pos, ang, ent)
		//end
	end

	function ztm.f.ParticleEffectAttach(effect, enum, ent, attachid)
		//if GetConVar("ztm_cl_vfx_particleeffects"):GetInt() == 1 then
			ParticleEffectAttach(effect, enum, ent, attachid)
		//end
	end

	net.Receive("ztm_remove_FX", function(len, ply)
		local effectInfo = net.ReadTable()

		if (effectInfo and IsValid(effectInfo.parent) and effectInfo.effect) then
			effectInfo.parent:StopParticlesNamed(effectInfo.effect)
		end
	end)
end
