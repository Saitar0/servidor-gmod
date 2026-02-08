if SERVER then return end

zbl = zbl or {}
zbl.f = zbl.f or {}

local DSP_Active = false

function zbl.f.Draw_ScreenEffects(p_data)
	if p_data.colormodify then
		local tab = {
			["$pp_colour_addr"] = p_data.colormodify["pp_colour_addr"],
			["$pp_colour_addg"] = p_data.colormodify["pp_colour_addg"],
			["$pp_colour_addb"] = p_data.colormodify["pp_colour_addb"],
			["$pp_colour_brightness"] = p_data.colormodify["pp_colour_brightness"],
			["$pp_colour_contrast"] = p_data.colormodify["pp_colour_contrast"],
			["$pp_colour_colour"] = p_data.colormodify["pp_colour_colour"],
			["$pp_colour_mulr"] = p_data.colormodify["pp_colour_mulr"],
			["$pp_colour_mulg"] = p_data.colormodify["pp_colour_mulg"],
			["$pp_colour_mulb"] = p_data.colormodify["pp_colour_mulb"]
		}

		DrawColorModify(tab)
	end

	if p_data.b_blur then
		DrawToyTown(10 / 100 * p_data.b_blur, 5 * p_data.b_blur)
	end


	if GetConVar("zbl_cl_epilepsy"):GetInt() == 0  then

		if p_data.m_blur then
			DrawMotionBlur(0.2, 0.4 * p_data.m_blur, 0.1 * p_data.m_blur)
		end

		if p_data.mat then
			DrawMaterialOverlay(p_data.mat, 0)
		end

		if p_data.warp_mat then
			DrawMaterialOverlay(p_data.warp_mat, 0)
		end
	end

	if p_data.audio_filter and DSP_Active == false then
		LocalPlayer():SetDSP(p_data.audio_filter,true)
		DSP_Active = true
	end

	if p_data.bloom then
		DrawBloom(0, 1, 1, 1, 15, 0.1, p_data.bloom[1], p_data.bloom[2], p_data.bloom[3])
	end
end

local cough_strength = 0
net.Receive("zbl_scfx_cough", function(len)
	cough_strength = 1
end)

local vomit_strength = 0
net.Receive("zbl_scfx_vomit", function(len)
	vomit_strength = 1
end)

zbl_VaccineID_Test = nil
zbl_VaccineStage_Test = nil

hook.Add("RenderScreenspaceEffects", "zbl_Sickness_RenderScreenspaceEffects", function()

	local vaccineID = LocalPlayer():GetNWInt("zbl_Vaccine", -1)

	if zbl_VaccineID_Test then
		vaccineID = zbl_VaccineID_Test
	end

	if vaccineID ~= -1 then

		local vaccineStage = LocalPlayer():GetNWInt("zbl_VaccineStage", -1)
		if zbl_VaccineStage_Test then
			vaccineStage = zbl_VaccineStage_Test
		end

		local vaccineData = zbl.config.Vaccines[vaccineID]

		if vaccineData and vaccineData.mutation_stages[vaccineStage] and vaccineData.mutation_stages[vaccineStage].perception then

			local percetionData = zbl.config.PerceptionEffects[vaccineData.mutation_stages[vaccineStage].perception]

			if percetionData then

				zbl.f.Draw_ScreenEffects(percetionData)
			end
		end
	else
		if DSP_Active == true then
			LocalPlayer():SetDSP(0,true)
			DSP_Active = false
		end
	end

	if cough_strength > 0 then

		cough_strength = math.Clamp(cough_strength - 1 * FrameTime(), 0, 1)

		DrawToyTown(5 * cough_strength, (600 / 1) * cough_strength)
		local tab = {
			["$pp_colour_addr"] = 0.15 * cough_strength,
			["$pp_colour_addg"] = 0,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = math.Clamp(cough_strength, 0.9, 1),
			["$pp_colour_mulr"] = cough_strength,
			["$pp_colour_mulg"] = 0,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
	end

	if vomit_strength > 0 then
		vomit_strength = math.Clamp(vomit_strength - 1 * FrameTime(), 0, 1)
		DrawSharpen(1.25 * vomit_strength, 1)
		DrawToyTown(5 * vomit_strength, (600 / 1) * vomit_strength)
		local tab = {
			["$pp_colour_addr"] = 0,
			["$pp_colour_addg"] = 0.25 * vomit_strength,
			["$pp_colour_addb"] = 0,
			["$pp_colour_brightness"] = 0,
			["$pp_colour_contrast"] = 1,
			["$pp_colour_colour"] = 1 - vomit_strength,
			["$pp_colour_mulr"] = 0,
			["$pp_colour_mulg"] = vomit_strength * 0.5,
			["$pp_colour_mulb"] = 0
		}

		DrawColorModify(tab)
	end
end)
