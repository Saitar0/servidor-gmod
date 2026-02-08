zbl = zbl or {}
zbl.f = zbl.f or {}



// Here we define diffrent effect groups which later make it pretty optimized to create Sound/Particle effects over the network
// The key will be used as the NetworkString
zbl.NetEffectGroups = {

	["infect_cough"] = {
		action = function(pos)

			zbl.f.ParticleEffect("zbl_cough_infect", pos, Angle(0,0,0), Entity(1))
		end,
	},

	["infect_diaria"] = {
		_type = "entity",

		action = function(ply)
			local pos = ply:GetPos()

			zbl.f.ParticleEffect("zbl_diaria_explosion", pos, Angle(0,0,0), ply)

			ply:EmitSound("zbl_fart")
			if GetConVar("zbl_cl_decals"):GetInt() == 1  then
				local radius = 50
				for i = 1, 15 do
					local decal_pos = pos + Vector(1,0,0) * math.random(-radius, radius) + Vector(0,1,0) * math.random(-radius, radius)
					util.Decal("YellowBlood", decal_pos + Vector(0,0,5), decal_pos - Vector(0,0,50))
				end
			end
		end,
	},

	["explode_head"] = {
		action = function(pos)

			zbl.f.ParticleEffect("zbl_explode_head", pos, Angle(0,0,0), Entity(1))

			if GetConVar("zbl_cl_decals"):GetInt() == 1  then
				local radius = 100
				for i = 1, 15 do
					local decal_pos = pos + Vector(1,0,0) * math.random(-radius, radius) + Vector(0,1,0) * math.random(-radius, radius)
					util.Decal("Blood", decal_pos + Vector(0,0,15), decal_pos - Vector(0,0,200))
				end
			end

			sound.Play(zbl.Sounds["VomitExplosion"], pos, 75, 100, 1)
		end,
	},


	["player_disinfect"] = {
		_type = "entity",

		action = function(ply)

			local entityClass = GetViewEntity():GetClass()

			if entityClass == "gmod_cameraprop" or (entityClass == "player" and GetConVar( "simple_thirdperson_enabled" ) and GetConVar( "simple_thirdperson_enabled" ):GetBool()) then

				local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
				local _pos,_ang = ply:GetBonePosition(bone)
				_ang:RotateAroundAxis(_ang:Right(),-90)

				zbl.f.ParticleEffect("zbl_disinfect", _pos + (_ang:Forward() * 5) + (_ang:Right() * 2) ,_ang , ply)
			else
				local ang = ply:EyeAngles()
				ang:RotateAroundAxis(ang:Right(),-90)
				zbl.f.ParticleEffect("zbl_disinfect", ply:EyePos() + ang:Up() * 5,ang , ply)
			end
		end,
	},
	["node_explode"] = {
		action = function(pos)

			zbl.f.ParticleEffect("zbl_infect_nodeexplode", pos, Angle(0,0,0), Entity(1))
			sound.Play(zbl.Sounds["spore_explo"], pos, 75, 100, 1)
		end,
	},
	["jar_break_sample"] = {
		action = function(pos)

			if zbl.f.RandomChance(50) then
				sound.Play(zbl.Sounds["JarBreak01"], pos, 75, 100, 1)
			else
				sound.Play(zbl.Sounds["JarBreak02"], pos, 75, 100, 1)
			end
			zbl.f.ParticleEffect("zbl_jar_explode_blue", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["jar_break_virus"] = {
		action = function(pos)

			if zbl.f.RandomChance(50) then
				sound.Play(zbl.Sounds["JarBreak01"], pos, 75, 100, 1)
			else
				sound.Play(zbl.Sounds["JarBreak02"], pos, 75, 100, 1)
			end
			zbl.f.ParticleEffect("zbl_infect_nodeexplode", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["jar_break_cure"] = {
		action = function(pos)

			if zbl.f.RandomChance(50) then
				sound.Play(zbl.Sounds["JarBreak01"], pos, 75, 100, 1)
			else
				sound.Play(zbl.Sounds["JarBreak02"], pos, 75, 100, 1)
			end
			zbl.f.ParticleEffect("zbl_jar_explode_green", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["jar_break_abillity"] = {
		action = function(pos)

			if zbl.f.RandomChance(50) then
				sound.Play(zbl.Sounds["JarBreak01"], pos, 75, 100, 1)
			else
				sound.Play(zbl.Sounds["JarBreak02"], pos, 75, 100, 1)
			end
			zbl.f.ParticleEffect("zbl_jar_explode_yellow", pos, Angle(0,0,0), Entity(1))
		end,
	},
	["jar_break_blood"] = {
		action = function(pos)

			if zbl.f.RandomChance(50) then
				sound.Play(zbl.Sounds["JarBreak01"], pos, 75, 100, 1)
			else
				sound.Play(zbl.Sounds["JarBreak02"], pos, 75, 100, 1)
			end
			zbl.f.ParticleEffect("zbl_jar_explode_blood", pos, Angle(0,0,0), Entity(1))
		end,
	},

	["scan_fx"] = {
		_type = "entity",
		action = function(ent)
			if LocalPlayer() == ent then return end
			zbl.f.ParticleEffect("zbl_scan_small", ent:GetPos(), Angle(0,0,0), ent)
		end,
	},

	["corpse_head"] = {
		action = function(pos)

			zbl.f.ParticleEffect("zbl_explode_head", pos, Angle(0,0,0), Entity(1))
			zbl.f.ParticleEffect("zbl_infect_nodeexplode", pos, Angle(0,0,0), Entity(1))

			if GetConVar("zbl_cl_decals"):GetInt() == 1  then
				local radius = 100
				for i = 1, 15 do
					local decal_pos = pos + Vector(1,0,0) * math.random(-radius, radius) + Vector(0,1,0) * math.random(-radius, radius)
					util.Decal("Blood", decal_pos + Vector(0,0,15), decal_pos - Vector(0,0,200))
				end
			end

			sound.Play(zbl.Sounds["VomitExplosion"], pos, 75, 100, 1)
			sound.Play(zbl.Sounds["spore_explo"], pos, 75, 100, 1)
		end,
	},
}

function zbl.f.PlayAnimation(ent,anim, speed)
	local sequence = ent:LookupSequence(anim)
	ent:SetCycle(0)
	ent:ResetSequence(sequence)
	ent:SetPlaybackRate(speed)
	ent:SetCycle(0)
end

if SERVER then

	// Creates a network string for all the effect groups
	for k, v in pairs(zbl.NetEffectGroups) do
		util.AddNetworkString("zbl_fx_" .. k)
	end

	// Sends a Net Effect Msg to all clients
	function zbl.f.CreateNetEffect(id,data)

		// Data can be a entity or position

		local EffectGroup = zbl.NetEffectGroups[id]

		// Some events should be called on server to
		if EffectGroup._server then
			EffectGroup.action(data)
		end

		net.Start("zbl_fx_" .. id)
		if EffectGroup._type == "entity" then
			net.WriteEntity(data)
		else
			net.WriteVector(data)
		end
		net.Broadcast()
	end
end

if CLIENT then

	for k, v in pairs(zbl.NetEffectGroups) do
		net.Receive("zbl_fx_" .. k, function(len)
			//zbl.f.Debug("zbl_fx_" .. k .. " Len: " .. len)

			if v._type == "entity" then
				local ent = net.ReadEntity()

				if IsValid(ent) then

					zbl.NetEffectGroups[k].action(ent)
				end
			else
				local pos = net.ReadVector()
				if pos then
					zbl.NetEffectGroups[k].action(pos)
				end
			end
		end)
	end

	function zbl.f.ParticleEffect(effect, pos, ang, ent)
		if GetConVar("zbl_cl_particleeffects"):GetInt() == 1 then
			ParticleEffect(effect, pos, ang, ent)
		end
	end

	function zbl.f.ParticleEffectAttach(effect, ent, attachid)
		if GetConVar("zbl_cl_particleeffects"):GetInt() == 1 then
			ParticleEffectAttach(effect, PATTACH_POINT_FOLLOW, ent, attachid)
		end
	end
end
