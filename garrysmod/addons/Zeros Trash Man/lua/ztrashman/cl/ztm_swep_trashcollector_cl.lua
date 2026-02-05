if SERVER then return end

hook.Add( "PostDrawViewModel", "PostDrawViewModel_trashcollector", function(viewmodel,player,weapon )

	if IsValid(weapon) and weapon:GetClass() == "ztm_trashcollector" and IsValid(viewmodel) then

		local attach = viewmodel:GetAttachment(1)

		if attach then

			local Ang = attach.Ang
			local Pos = attach.Pos

			Ang:RotateAroundAxis(Ang:Forward(),-90)

			local _playerlevel = weapon:GetPlayerLevel()
			local _playerxp =  weapon:GetPlayerXP()
			local _playerlvldata = ztm.config.TrashSWEP.level[_playerlevel]
			local _trash = weapon:GetTrash() or 0
			cam.Start3D2D(Pos, Ang, 0.02)

				surface.SetDrawColor(ztm.default_colors["blue04"])
				surface.SetMaterial(ztm.default_materials["ztm_trashgun_interface"])
				surface.DrawTexturedRect(-200 ,-205 ,400 , 400)


				draw.DrawText(ztm.language.General["Level"] .. ":", ztm.f.GetFontFromTextSize(ztm.language.General["Level"],8,"ztm_gun_font01","ztm_gun_font01_small"), -150, -100, ztm.default_colors["white01"], TEXT_ALIGN_LEFT)
				draw.DrawText(ztm.language.General["Trash"] .. ":", ztm.f.GetFontFromTextSize(ztm.language.General["Level"],8,"ztm_gun_font01","ztm_gun_font01_small"), -150, -50, ztm.default_colors["white01"], TEXT_ALIGN_LEFT)

				draw.RoundedBox( 5, 0,-100,150,40, ztm.default_colors["black01"] )
				if _playerlevel >= table.Count(ztm.config.TrashSWEP.level) then
					draw.RoundedBox( 5, 0,-100,150,40, ztm.default_colors["blue02"] )
					draw.DrawText(ztm.language.General["Max"], "ztm_gun_font01", 75, -100, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				else

					local l_size = (150 / _playerlvldata.next_xp) * _playerxp
					l_size = math.Clamp(l_size,0,150)
					draw.RoundedBox( 5, 0,-100,l_size,40,ztm.default_colors["blue02"] )

					draw.DrawText(_playerlevel, "ztm_gun_font01", 75, -100, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				end

				draw.RoundedBox( 5, 0,-50,150,40, ztm.default_colors["black01"] )
				local t_size = (150 / _playerlvldata.inv_cap) * _trash
				t_size = math.Clamp(t_size,0,150)
				draw.RoundedBox( 5, 0,-50,t_size,40, ztm.default_colors["blue02"] )
				draw.DrawText(_trash .. ztm.config.UoW, "ztm_gun_font02", 75, -45, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)


				local p_interval = _playerlvldata.primaty_interval
				local p_time = (weapon:GetLast_Primary() + p_interval) - CurTime()
				p_time = math.Clamp(p_time,0,99)
				local p_size = (150 / p_interval) * p_time
				p_size = math.Clamp(p_size,0,150)
				draw.RoundedBox( 5, 0,0,150,40, ztm.default_colors["black01"] )
				draw.RoundedBox(5, 0, 0, p_size, 40, ztm.f.LerpColor((1 / p_interval) * p_time, ztm.default_colors["blue02"], ztm.default_colors["red01"]))
				draw.DrawText("LMB", "ztm_gun_font02", 75, 5, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				draw.DrawText(ztm.language.General["Blast"] .. ":", ztm.f.GetFontFromTextSize(ztm.language.General["Blast"],9,"ztm_gun_font01","ztm_gun_font01_small"), -150, 0, ztm.default_colors["white01"], TEXT_ALIGN_LEFT)


				local s_interval = _playerlvldata.secondary_interval
				local s_time = (weapon:GetLast_Secondary() + s_interval) - CurTime()
				s_time = math.Clamp(s_time,0,99)
				local s_size = (150 / s_interval) * s_time
				s_size = math.Clamp(s_size,0,150)
				draw.RoundedBox( 5, 0,50,150,40, ztm.default_colors["black01"] )
				draw.RoundedBox( 5, 0,50,s_size,40, ztm.f.LerpColor((1 / s_interval) * s_time, ztm.default_colors["blue02"], ztm.default_colors["red01"]) )

				draw.DrawText("RMB", "ztm_gun_font02", 75, 55, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				draw.DrawText(ztm.language.General["Suck"] .. ":",  ztm.f.GetFontFromTextSize(ztm.language.General["Suck"],8,"ztm_gun_font01","ztm_gun_font01_small"), -150, 50, ztm.default_colors["white01"], TEXT_ALIGN_LEFT)


				surface.SetDrawColor(ztm.default_colors["white02"])
				surface.SetMaterial(ztm.default_materials["ztm_trashgun_interface"])
				surface.DrawTexturedRect(-200 ,-205 ,400 , 400)



			cam.End3D2D()

		end
	end
end )


local ztm_LastEffect = 1

hook.Add("Think", "Think_trashcollector_collect", function()
	if CurTime() > ztm_LastEffect then
		for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), 300)) do
			if IsValid(v) and v:IsPlayer() and v:Alive() and LocalPlayer() ~= v and IsValid(v:GetActiveWeapon()) and v:GetActiveWeapon():GetClass() == "ztm_trashcollector" then

				local swep = v:GetActiveWeapon()

				local cur_trash = swep:GetTrash()

				if (swep.LastTrash or 0) < cur_trash then
					swep.TrashIncrease = true
				else
					swep.TrashIncrease = false
				end

				swep.LastTrash = cur_trash


				ztm.f.LoopedSound(swep, "ztm_trashsuck_loop", swep:GetIsCollectingTrash() and swep.TrashIncrease == true)
				ztm.f.LoopedSound(swep, "ztm_airsuck_loop", swep:GetIsCollectingTrash() and swep.TrashIncrease == false)

				if swep:GetIsCollectingTrash() then

					if swep.TrashIncrease then


						ztm.f.ParticleEffectAttach("ztm_airsuck_trash", PATTACH_POINT_FOLLOW, swep, 1)


					else
						ztm.f.ParticleEffectAttach("ztm_airsuck", PATTACH_POINT_FOLLOW, swep, 1)


					end
				end

			end
		end

		ztm_LastEffect = CurTime() + 1
	end
end)
