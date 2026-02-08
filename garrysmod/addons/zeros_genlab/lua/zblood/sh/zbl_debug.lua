zbl = zbl or {}
zbl.f = zbl.f or {}


// Used for Debug
function zbl.f.Debug(mgs)
	if (zbl.config.Debug) then
		if istable(mgs) then
			print("[    DEBUG    ] Table Start >")
			PrintTable(mgs)
			print("[    DEBUG    ] Table End <")
		else
			print("[    DEBUG    ] " .. mgs)
		end
	end
end

function zbl.f.Debug_Sphere(pos,size,lifetime,color,ignorez)
	if zbl.config.Debug then
		debugoverlay.Sphere( pos, size, lifetime, color, ignorez )
	end
end

local names = {"Peter", "Franz", "Juliet", "Naomi", "Henry","William","Hector","Donald","Goofy","Mickey"}


if SERVER then


	/////////////// DEFAULT
	////////////////////////////////////////////
	concommand.Add("zbl_debug_EntList", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			PrintTable(zbl.EntList)
		end
	end)

	concommand.Add("zbl_debug_GetClass", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and IsValid(tr.Entity) then
				print(tr.Entity:GetClass())
			end
		end
	end)

	concommand.Add("zbl_debug_GetPlayermodel", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			print(ply:GetModel())
		end
	end)

	concommand.Add("zbl_debug_SetPlayermodel", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local path = args[1]
			ply:SetModel(tostring(path))
		end
	end)



	/*
	concommand.Add("zbl_debug_GetID", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and IsValid(tr.Entity) then
				print(tr.Entity:EntIndex())
			end
		end
	end)

	concommand.Add("zbl_debug_LockAllDoors", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local lock = tonumber(args[1]) == 1
			local command = "lock"

			if lock == false then
				command = "unlock"
			end

			local doors = {"func_door", "func_door_rotating", "prop_door_rotating"}
			local blacklist = {
				[792] = true
			}
			for s, w in pairs(doors) do
				for k, v in pairs(ents.FindByClass(w)) do
					if IsValid(v) and blacklist[v:EntIndex()] then
						v:Fire(command, "", 0)
					end
				end
			end
		end
	end)
	*/



	/////////////// PLAYER
	////////////////////////////////////////////
	concommand.Add("zbl_debug_PlayerList", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then

	        zbl_PlayerList = {}

	        for k,v in pairs(player.GetBots()) do
	            if IsValid(v) then
	                zbl.f.Player_Add(v)
	            end
	        end

	        for k,v in pairs(player.GetAll()) do
	            if IsValid(v) then
	                zbl.f.Player_Add(v)
	            end
	        end

	        PrintTable(zbl_PlayerList)
	    end
	end)

	concommand.Add("zbl_debug_player", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:Alive() then
	            print(tostring(tr.Entity))
	            print("VaccineID: " .. zbl.f.Player_GetVaccine(ply))
	            print("VaccineStage: " .. ply:GetNWInt("zbl_VaccineStage", 0))
	        end
	    end
	end)



	/////////////// Object Contamination
	////////////////////////////////////////////
	concommand.Add("zbl_debug_Ctmn_SetupTimer", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        zbl.f.Ctmn_SetupTimer()
	    end
	end)

	concommand.Add("zbl_debug_Ctmn_ObjectContaminate", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()
	        if tr.Hit and IsValid(tr.Entity) then
	            zbl.f.Ctmn_ObjectContaminate(tr.Entity,tonumber(args[1]))
	        end
	    end
	end)

	concommand.Add("zbl_debug_Ctmn_Auto_SetupTimer", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        zbl.f.Ctmn_Auto_SetupTimer()
	    end
	end)


	concommand.Add("zbl_debug_Ctmn_ClearObjects", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then

			for k, v in pairs(zbl.ContaminatedObjects) do
				if IsValid(v) then
					zbl.f.Ctmn_ObjectSanitise(v)
				else
					zbl.ContaminatedObjects[k] = nil
				end
			end
		end
	end)

	/////////////// FLASK
	////////////////////////////////////////////
	concommand.Add("zbl_debug_flask_blood_unique", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit then
	            zbl.f.Flask_Spawn(ply,tr.HitPos + Vector(0, 0, 15), 1, math.random(1,500), names[math.random(#names)],math.random(3,10),"player")
	        end
	    end
	end)

	concommand.Add("zbl_debug_flask_blood", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit then
				zbl.f.Flask_Spawn(ply,tr.HitPos + Vector(0, 0, 15), 1, 666, "Gorden",25,"player")
			end
		end
	end)

	concommand.Add("zbl_debug_flask_random", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and tr.HitNormal then
	            for i = 1, 10 do
	                local _type = math.random(1, 3)
	                local eang = ply:EyeAngles()
	                local _pos = tr.HitPos + Vector(0, 0, 15) + eang:Right() * (15 * i)

	                if _type == 1 then

	                    zbl.f.Flask_Spawn(ply, _pos, _type, math.random(1, 500), "Ricky Gaysultanova ", 25, "player")
	                elseif _type == 2 or _type == 3 then

	                    local vac_id = math.random(#zbl.config.Vaccines)
	                    local vac_data = zbl.config.Vaccines[vac_id]
	                    zbl.f.Flask_Spawn(ply, _pos, _type, vac_id, vac_data.name, 0, "")
	                end
	            end
	        end
	    end
	end)

	concommand.Add("zbl_debug_flask", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitNormal then
				local _type = math.Clamp(tonumber(args[1]), 2, 3)
				local vac_id = tonumber(args[2])
				local _pos = tr.HitPos + Vector(0, 0, 15)
				local vac_data = zbl.config.Vaccines[vac_id]
				zbl.f.Flask_Spawn(nil, _pos, _type, vac_id, vac_data.name, 0, "")
			end
		end
	end)


	/////////////// GASMASK
	////////////////////////////////////////////
	concommand.Add("zbl_debug_GasMask_switch", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	       if ply:GetNWInt("zbl_RespiratorUses",0) > 0 then
			   zbl.f.GasMask_Equipt(ply,false)
		   else
			   zbl.f.GasMask_Equipt(ply,true)
		   end
	    end
	end)
	concommand.Add("zbl_debug_GasMask_EquiptID", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then

			ply:SetNWInt("zbl_RespiratorUses",zbl.config.Respirator.Uses)

			local maskID = tonumber(args[1])

			net.Start("zbl_Gasmask_Equipt")
			net.WriteEntity(ply)
			net.WriteBool(true)
			net.WriteInt(maskID,6)
			net.Broadcast()
		end
	end)



	/////////////// VIRUS HOTSPOTS
	////////////////////////////////////////////
	concommand.Add("zbl_debug_VHS_SetupTimer", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        zbl.f.VHS_SetupTimer()
	    end
	end)

	// Adds a new position
	concommand.Add("zbl_debug_VHS_AddPos", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local pt = ply:GetEyeTrace()

	        if pt.Hit and pt.HitPos then
	            local _ang = pt.HitNormal:Angle()
	            _ang:RotateAroundAxis(_ang:Right(), -90)

				zbl.f.VHS_AddPos(pt.HitPos,_ang)

	            debugoverlay.Sphere( pt.HitPos, 3, 1, Color(255, 0, 0), true)
	            debugoverlay.Line( pt.HitPos, pt.HitPos + _ang:Up() * 100, 1, Color(255, 0, 0), true)
	        end
	    end
	end)

	// Shows all existing positions (Only works on developer 1)
	concommand.Add("zbl_debug_VHS_ShowPos", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        for k, v in pairs(zbl.VHS_Positions) do
	            if v then
	                debugoverlay.Sphere(v.pos, 3, 1, Color(255, 0, 0), true)
	                debugoverlay.Line(v.pos, v.pos + v.ang:Up() * 100, 1, Color(255, 0, 0), true)
	            end
	        end

	        PrintTable(zbl.VHS_Positions)
	    end
	end)

	// Clears all positions
	concommand.Add("zbl_debug_VHS_ClearPos", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        zbl.VHS_Positions = {}
	    end
	end)

	// Purges all the Virus Hotspots
	concommand.Add("zbl_debug_VHS_Purge", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then

	       // local timerid = "zbl_vhs_timer"
	        //zbl.f.Timer_Remove(timerid)

	        if IsValid(zbl.VHS_CoreNode) then
	            SafeRemoveEntity(zbl.VHS_CoreNode)
	        end
	        zbl.VHS_CoreNode = nil

	        //zbl.VHS_Positions = {}

	        //  Kill all nodes
	        for k,v in pairs(zbl.VHS_VirusNodes) do
	            if IsValid(v) then
	                SafeRemoveEntity(v)
	            end
	        end

	    end
	end)

	// Starts a Hotspot at the point you are looking
	concommand.Add("zbl_debug_VHS_StartHere", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then

		    zbl.f.VHS_SetupTimer()

		    zbl.VHS_Positions = {}

		    local pt = ply:GetEyeTrace()

		    if pt.Hit and pt.HitPos then
		        local _ang = pt.HitNormal:Angle()
		        _ang:RotateAroundAxis(_ang:Right(), -90)

		        table.insert(zbl.VHS_Positions, {
		            pos = pt.HitPos,
		            ang = _ang
		        })

		        debugoverlay.Sphere( pt.HitPos, 3, 1, Color(255, 0, 0), true)
		        debugoverlay.Line( pt.HitPos, pt.HitPos + _ang:Up() * 100, 1, Color(255, 0, 0), true)
		    end
		end
	end)

	// Gives all the virus nodes full health
	concommand.Add("zbl_debug_VHS_MaxHealth", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        for k, v in pairs(zbl.VHS_VirusNodes) do
	            if IsValid(v) then
	                zbl.f.VN_ChangeHealth(v, zbl.config.VirusHotspots.node_health_max)
	            end
	        end
	    end
	end)

	// Saves all the HotSpot position to a txt file
	concommand.Add("zbl_debug_VHS_SavePos", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then

	        zbl.f.VHS_SavePositions(ply)
	    end
	end)

	// Removes all the HotSpots positions for the current map
	concommand.Add("zbl_debug_VHS_RemovePos", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			zbl.f.VHS_RemovePositions(ply)

			if IsValid(zbl.VHS_CoreNode) then
				SafeRemoveEntity(zbl.VHS_CoreNode)
			end

			zbl.VHS_CoreNode = nil

			//  Kill all nodes
			for k, v in pairs(zbl.VHS_VirusNodes) do
				if IsValid(v) then
					SafeRemoveEntity(v)
				end
			end

			zbl.f.VHS_ShowAll(ply)
		end
	end)




	/////////////// NPC ENTITY
	////////////////////////////////////////////
	concommand.Add("zbl_debug_NPC_SetQuest", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbl_npc" then
				ply.zbl_Quest = {
					id = math.random(#zbl.config.NPC.quests),
					request_time = CurTime(),
					start_time = -1,
					accepted = false,
					npc = tr.Entity
				}
	        end
	    end
	end)



	/////////////// LAB ENTITY
	////////////////////////////////////////////
	concommand.Add("zbl_debug_lab", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zbl_lab" then
	            print(tr.Entity:GetActionState())
	        end
	    end
	end)



	/////////////// VIRUS OCCOPATING
	////////////////////////////////////////////
	concommand.Add("zbl_debug_OV_SetupTimer", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        zbl.f.OV_SetupTimer()
	    end
	end)



	/////////////// INJECTOR GUN
	////////////////////////////////////////////
	concommand.Add("zbl_debug_InjectorLoadout", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local swep = ply:GetWeapon("zbl_gun")

			if IsValid(swep) then
				for k, v in pairs(swep.Flasks) do
					local gn = math.random(0, 3)
					v.GenType = gn

					if gn == 2 or gn == 3 then
						local vac_id = math.random(#zbl.config.Vaccines)
						local vac_data = zbl.config.Vaccines[vac_id]
						v.GenValue = vac_id
						v.GenName = vac_data.name
						v.GenPoints = 0
					elseif gn == 1 then
						local name = names[math.random(#names)]
						v.GenValue = math.random(5, 999)
						v.GenName = name
						v.GenPoints = 25
						v.GenClass = "player"
					end
				end

				local _data = swep.Flasks[swep:GetSelectedFlask()]

				swep:SetGenType(_data.GenType)
				swep:SetGenValue(_data.GenValue)
				swep:SetGenName(_data.GenName)
				swep:SetGenPoints(_data.GenPoints)
				swep:SetGenClass(_data.GenClass)
			end
		end
	end)

	concommand.Add("zbl_debug_InjectorLoadout_PlayerSample", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local swep = ply:GetWeapon("zbl_gun")

			if IsValid(swep) then
				for k, v in pairs(swep.Flasks) do
					v.GenType = 1
					v.GenValue = math.random(5, 999)
					v.GenName = names[math.random(#names)]
					v.GenPoints = 25
					v.GenClass = "player"
				end

				local _data = swep.Flasks[swep:GetSelectedFlask()]

				swep:SetGenType(_data.GenType)
				swep:SetGenValue(_data.GenValue)
				swep:SetGenName(_data.GenName)
				swep:SetGenPoints(_data.GenPoints)
				swep:SetGenClass(_data.GenClass)
			end
		end
	end)



	/////////////// VACCINES
	////////////////////////////////////////////
	// Infected yourself with the provided virus id
	concommand.Add("zbl_debug_vaccinate_self", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local vaccineID = tonumber(args[1])
	        local vaccineStage = tonumber(args[2])

			local vacData = zbl.config.Vaccines[vaccineID]

	        if vaccineID and vacData and vacData.mutation_stages and vaccineStage <= #vacData.mutation_stages then
	            zbl.f.Player_ApplyVaccineStage(ply,vaccineID,vaccineStage or 1)
	        end
	    end
	end)

	// Infected target with the provided virus id
	concommand.Add("zbl_debug_vaccinate_target", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local tr = ply:GetEyeTrace()

	        if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:Alive() then
	            local vaccineID = args[1]
				//local vaccinestage = args[2]

	            if vaccineID then
	                zbl.f.Player_Vaccinate(tr.Entity,tonumber(vaccineID),1,ply)
	            end
	        end
	    end
	end)

	// Infected all with the provided virus id
	concommand.Add("zbl_debug_vaccinate_all", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local vaccineID = args[1]

	        if vaccineID then
	            for k,v in pairs(zbl_PlayerList) do
	                if IsValid(v) then
	                    zbl.f.Player_Vaccinate(v,tonumber(vaccineID),1,ply)
	                end
	            end
	        end
	    end
	end)

	concommand.Add("zbl_debug_ForceCure", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then

	        for k,v in pairs(zbl_PlayerList) do
	            if IsValid(v) and v:Alive() and zbl.f.Player_HasVaccine(v) then
	                zbl.f.Player_ForceCure(v)
	            end
	        end
	    end
	end)



	/////////////// VIRUsNODES
	////////////////////////////////////////////
	concommand.Add("zbl_debug_createnode", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local tr = ply:GetEyeTrace()

			if tr.Hit and tr.HitPos then
				local ang = tr.HitNormal:Angle()
				ang:RotateAroundAxis(ang:Right(), -90)
				local ent = zbl.f.VN_CreateNode(tr.HitPos, ang, math.Clamp(tonumber(args[1] or 1),1,table.Count(zbl.config.Vaccines)), 1)

				zbl.f.VN_ChangeHealth(ent,zbl.config.VirusHotspots.node_health_max)
			end
		end
	end)

	concommand.Add("zbl_debug_VN_TraceTest", function(ply, cmd, args)
	    if IsValid(ply) and zbl.f.IsAdmin(ply) then
	        local pt = ply:GetEyeTrace()

	        if pt.Hit then
	            local pos , ang

	            if IsValid(pt.Entity) then
	                pos = pt.Entity:GetPos() + pt.Entity:GetUp() * 50
	                ang = pt.Entity:GetAngles()
	            else
	                pos = pt.HitPos + pt.HitNormal:Angle():Forward() * 50
	                ang = Angle(0,0,0)
	            end

	            for i = 1, 100 do
	                zbl.f.VN_PerformSpawnTrace(pos,ang,1000)
	            end
	        end
	    end
	end)

	concommand.Add("zbl_debug_VN_removeall", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			//  Kill all nodes
			for k, v in pairs(ents.FindByClass("zbl_virusnode")) do
				if IsValid(v) then
					SafeRemoveEntity(v)
				end
			end
		end
	end)



	/////////////// CORPSES
	////////////////////////////////////////////

	concommand.Add("zbl_debug_corpse_create", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then

			zbl.f.Corpse_Spawn(ply,4,1)
		end
	end)


	concommand.Add("zbl_debug_corpse_removeall", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then

			//  Kill all nodes
			for k, v in pairs(ents.FindByClass("zbl_corpse")) do
				if IsValid(v) then
					SafeRemoveEntity(v)
				end
			end
		end
	end)
else

	/////////////// SYMPTOMES
	////////////////////////////////////////////
	concommand.Add("zbl_debug_runninghooks", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			PrintTable(zbl.RunningHooks)
		end
	end)

	/////////////// SCREENEFFECTS
	////////////////////////////////////////////
	concommand.Add("zbl_debug_screeneffect", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			if args[1] == nil then
				zbl_VaccineID_Test = nil
				zbl_VaccineStage_Test = nil
			else
				zbl_VaccineID_Test = tonumber(args[1])
				zbl_VaccineStage_Test = tonumber(args[2])
			end
		end
	end)
end



// Lang Refresh
if SERVER then
	util.AddNetworkString("zbl_langrefresh")
	concommand.Add("zbl_debug_LangRefresh", function(ply, cmd, args)
		if IsValid(ply) and zbl.f.IsAdmin(ply) then
			local lang = tostring(args[1])
			net.Start("zbl_langrefresh")
			net.WriteString(lang)
			net.Broadcast()
		end
	end)
else

	net.Receive("zbl_langrefresh", function(len)
		local lang = net.ReadString()
		zbl.config.SelectedLanguage = lang
		zbl.f.LoadAllFiles("zbl_languages/")
	end)
end
