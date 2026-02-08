if SERVER then return end

zbl = zbl or {}
zbl.f = zbl.f or {}

zbl.RunningHooks = zbl.RunningHooks or {}

function zbl.f.CreateHook(name,func)

	zbl.f.RemoveHook(name)

	hook.Add("Think", name, func)
	table.insert(zbl.RunningHooks,name)
end

function zbl.f.RemoveHook(name)
	hook.Remove("Think", name)
	table.RemoveByValue(zbl.RunningHooks,name)
end

// Used to scale the specified players head
net.Receive("zbl_scalebone", function(len)
	local ply = net.ReadEntity(ply)
	local scale = net.ReadInt(16) / 10
	local boneid = net.ReadInt(16)
	local speed = net.ReadInt(16)
	if IsValid(ply) and scale then
		local name = "zbl_scalebone_" .. boneid .. "_" .. ply:EntIndex()

		zbl.f.CreateHook(name, function()
			if IsValid(ply) and scale then
				local cur_scale = ply.zbl_bonescale or 1

				if cur_scale == scale then
					zbl.f.RemoveHook(name)
					return
				end

				if cur_scale < scale then
					cur_scale = math.Clamp(cur_scale + (speed * FrameTime()), cur_scale, scale)
				else
					cur_scale = math.Clamp(cur_scale - (speed * FrameTime()), scale, cur_scale)
				end

				ply.zbl_bonescale = cur_scale

				// Scales the players head to the new scale
				if boneid then
					ply:ManipulateBoneScale(boneid, Vector(cur_scale, cur_scale, cur_scale))
				end
			else
				zbl.f.RemoveHook(name)
			end
		end)
	end
end)


local LastMoveDistortion = -1
local MoveStrength = 0
local MoveSwitch = false
hook.Add("StartCommand","zbl_movement_StartCommand", function(ply,ucmd)
	if !ply:Alive() then return end

	local vac_id = ply:GetNWInt("zbl_Vaccine", -1)
	if vac_id ~= -1 then

		local vaccineData = zbl.config.Vaccines[vac_id]
		if vaccineData then
			local vaccineStage = ply:GetNWInt("zbl_VaccineStage", -1)
			local mutation_stage = vaccineData.mutation_stages[vaccineStage]

			if mutation_stage and mutation_stage.effects then

				local mv_fw = ucmd:GetForwardMove()
				local mv_sd = ucmd:GetSideMove()

				if mutation_stage.effects["movement_distortion"] then
					if LastMoveDistortion < CurTime() then

						local strength = mutation_stage.effects["movement_distortion"]

						MoveStrength = math.Rand(-strength,strength)
						MoveSwitch = !MoveSwitch
						LastMoveDistortion = CurTime() + math.Rand(5 / strength, 3)
					else

						if MoveSwitch then
							mv_fw = mv_fw + (10000 * MoveStrength)
							mv_sd = mv_sd + (10000 * MoveStrength)
						end
					end
				end

				if mutation_stage.effects["movement_invert"] then
					mv_fw = -mv_fw
					mv_sd = -mv_sd
				end

				ucmd:SetForwardMove(mv_fw)
				ucmd:SetSideMove(mv_sd)
			end
		end
	end
end)
