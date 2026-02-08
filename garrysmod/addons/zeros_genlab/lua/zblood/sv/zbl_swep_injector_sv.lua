if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

function zbl.f.Injector_GetTarget(swep)
	local tr = swep.Owner:GetEyeTrace()
	local ent = tr.Entity

	if tr.Hit == false then return end
	if not IsValid(ent) then return end

	if not ent:IsPlayer() then return end

	if zbl.f.InDistance(swep.Owner:GetPos(), ent:GetPos(), 100) == false then return end

	return ent
end

function zbl.f.Injector_Initialize(swep)
	zbl.f.Debug("zbl.f.Injector_Initialize")
	swep:SetHoldType(swep.HoldType)
	swep:SetBusy(false)
	swep.FlaskSetup = false


	zbl.f.Injector_SetupFlasks(swep)
end

function zbl.f.Injector_SetupFlasks(swep)
	if swep.FlaskSetup == true then return end

	timer.Simple(0,function()
		if IsValid(swep.Owner) then
			swep.Flasks = {}
			local capacity = zbl.config.InjectorGun.flask_capacity[zbl.f.GetPlayerRank(swep.Owner)]

			if capacity == nil then
				capacity = zbl.config.InjectorGun.flask_capacity["default"]
			end

			for i = 1, capacity do
				swep.Flasks[i] = {
					GenType = 0,
					GenValue = 0,
					GenName = "",
					GenPoints = 0,
					GenClass = ""
				}
			end

			swep.FlaskSetup = true
			zbl.f.Injector_UpdateFlaskSequence(swep)
		end
	end)
end

function zbl.f.Injector_UpdateFlaskSequence(swep)
	// Creates a string sequence which tells us
		// How many flasks
		// What flasks holst which gen type
		// and if the gen type is vaccine but its a ability then we add 100
	local sequence = ""
	for k,v in pairs(swep.Flasks) do

		if v.GenType == 2 then

			if v.GenValue and zbl.config.Vaccines[v.GenValue] and zbl.config.Vaccines[v.GenValue].isvirus then
				sequence = sequence .. v.GenType
			else
				sequence = sequence .. tostring(100 + v.GenType)
			end
		else
			sequence = sequence .. v.GenType
		end

		if k < #swep.Flasks then
			sequence = sequence .. "_"
		end
	end
	swep:SetFlaskSequence(sequence)
end

function zbl.f.Injector_Primary(swep)
	zbl.f.Debug("zbl.f.Injector_Primary")

	if zbl.f.Injector_HasLiquid(swep) == false then
		zbl.f.Notify(swep.Owner, zbl.language.Gun["GunEmpty"], 1)
		return
	end

	if swep:GetBusy() then
		return false
	end

	local _type = swep:GetGenType()
	local _val = swep:GetGenValue()
	if _type < 2 then
		zbl.f.Notify(swep.Owner, zbl.language.Gun["NoVaccine"], 1)
		return false
	end

	// Performs a Target Trace
	local ent = zbl.f.Injector_GetTarget(swep)
	if not IsValid(ent) then return end

	if _type == 3 then

		// Check if player is even infected
		if zbl.f.Player_HasVaccine(ent) then

			local vaccindID = zbl.f.Player_GetVaccine(ent)

			// Remove Active Vaccine if the gun has the correct anti vaccine
			if vaccindID == _val then

				swep.Owner:EmitSound("zbl_vo_inject")
				timer.Simple(0.5, function()
					if IsValid(ent) then
						zbl.f.Player_PlaySound_Ouch(ent)
					end
					if IsValid(swep) and IsValid(swep.Owner) then
						swep.Owner:EmitSound("zbl_gun_inject")
					end
				end)

				// Makes the player immun against the virus for a certain amount of time
				zbl.f.Player_MakeImmun(ent,vaccindID,zbl.config.Vaccines[vaccindID].cure.immunity_time)

				// Cures the player
				zbl.f.Player_Cure(ent)

				// Custom Hook
				hook.Run("zbl_OnPlayerCurePlayer" ,ent, vaccindID,swep.Owner)

				// Emptys the flask
				zbl.f.Injector_EmptyLiquid(swep,swep:GetSelectedFlask())

				swep:SetBusy(true)
				zbl.f.Injector_PlayShootAnim(swep)
			else

				zbl.f.Notify(swep.Owner, zbl.language.Gun["WrongCure"], 1)
				return
			end
		else
			zbl.f.Notify(swep.Owner, zbl.language.Gun["PlayerNotInfected"], 1)
		end
	elseif _type == 2 then

		// Check if the target is currently infected and if its a virus we stop
	    if zbl.f.Player_VaccineOverride(ent) == false then
	       zbl.f.Notify(swep.Owner, zbl.language.Gun["PlayerAlreadyInfected"], 1)
		   return
	    end

		swep.Owner:EmitSound("zbl_vo_inject")

		timer.Simple(0.5, function()
			if IsValid(ent) and IsValid(swep) and IsValid(swep.Owner) and _val then

				zbl.f.Player_PlaySound_Ouch(ent)

				zbl.f.Player_Vaccinate(ent,_val,1,swep.Owner)



				swep.Owner:EmitSound("zbl_gun_inject")
			end
		end)

		zbl.f.Injector_EmptyLiquid(swep,swep:GetSelectedFlask())

		swep:SetBusy(true)
		zbl.f.Injector_PlayShootAnim(swep)
	end

	swep:SetNextPrimaryFire(CurTime() + swep.Primary.Delay)
end

function zbl.f.Injector_Secondary(swep)
	if swep:GetBusy() then
		return false
	end

	zbl.f.Debug("zbl.f.Injector_Secondary")

	// If we still have a empty flask in the gun then we use it
	local empty_flask = zbl.f.Injector_GetEmptyFlask(swep)
	if empty_flask == nil then
		zbl.f.Notify(swep.Owner, zbl.language.Gun["GunIsFull"], 1)
		return
	end

	local tr = swep.Owner:GetEyeTrace()

	local ent = tr.Entity

	if tr.Hit and IsValid(ent) and zbl.f.InDistance(swep.Owner:GetPos(), ent:GetPos(), 100) then

		if ent:GetClass() == "zbl_flask" and ent:GetGenType() ~= 0 then

			zbl.f.Injector_AddLiquid(swep,empty_flask,ent:GetGenType(),ent:GetGenValue(),ent:GetGenName(),ent:GetGenPoints(),ent:GetGenClass())

			swep.Owner:EmitSound("zbl_gun_fill")

			SafeRemoveEntity(ent)

			zbl.f.Injector_PlayShootAnim(swep)
		else
			local sample_class = ent:GetClass()

			local sample_type = zbl.config.SampleTypes[sample_class]

			// Can this entity be collected/harvested?
			if sample_type == nil then return end

			local sample_name = sample_type.name(ent)
			local sample_value = sample_type.identifier(ent)
			local sample_points = sample_type.points_modify(swep.Owner,ent,sample_type.dna_points)

			swep.Owner:EmitSound("zbl_gun_fill")

			sample_type.OnCollect(swep.Owner,ent)

			zbl.f.Injector_AddLiquid(swep,empty_flask,1,sample_value,sample_name,sample_points,sample_class)

			// Custom Hook
			hook.Run("zbl_OnPlayerGetSample" ,ent,swep.Owner,sample_name,sample_value,sample_points)


			zbl.f.Injector_PlayShootAnim(swep)
		end
	end

	swep:SetNextSecondaryFire(CurTime() + swep.Secondary.Delay)
end

function zbl.f.Injector_Equip(swep)
	zbl.f.Debug("zbl.f.Injector_Equip")
	zbl.f.Injector_PlayDrawAnim(swep)
	zbl.f.Injector_SetupFlasks(swep)
end

function zbl.f.Injector_Deploy(swep)
	zbl.f.Debug("zbl.f.Injector_Deploy")

	zbl.f.Timer_Remove("zbl_gun_drawanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_gun_shootanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_gun_reloadanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_gun_selfinjectanim_" .. swep:EntIndex() .. "_timer")



	zbl.f.Injector_PlayDrawAnim(swep)
	zbl.f.Injector_SetupFlasks(swep)
end

function zbl.f.Injector_Holster(swep)
	zbl.f.Debug("zbl.f.Injector_Holster")

	zbl.f.Timer_Remove("zbl_gun_drawanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_gun_shootanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_gun_reloadanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_gun_selfinjectanim_" .. swep:EntIndex() .. "_timer")

	swep:SendWeaponAnim(ACT_VM_HOLSTER)

	swep:SetBusy(false)
end

function zbl.f.Injector_Reload(swep)

	if swep:GetBusy() then
		return false
	end

	zbl.f.Debug("zbl.f.Injector_Reload")


	swep:SetBusy(true)

	swep.Owner:EmitSound("zbl_gun_fill")

	swep:SendWeaponAnim(ACT_VM_RELOAD)
	swep.Owner:SetAnimation(PLAYER_ATTACK1)

	zbl.f.Injector_SwitchFlask(swep)


	local timerID = "zbl_gun_reloadanim_" .. swep:EntIndex() .. "_timer"
	zbl.f.Timer_Remove(timerID)

	zbl.f.Timer_Create(timerID,0.15,1,function()
		zbl.f.Timer_Remove(timerID)

		if IsValid(swep) and IsValid(swep.Owner) and IsValid(swep.Owner:GetActiveWeapon()) and swep.Owner:GetActiveWeapon():GetClass() == "zbl_gun"  then

			zbl.f.Injector_PlayIdleAnim(swep)
		end
	end)
end

// Inject the currently selected vaccin in to yourself
function zbl.f.Injector_SelfInject(swep)
	zbl.f.Debug("zbl.f.Injector_SelfInject")

	if zbl.f.Injector_HasLiquid(swep) == false then
		zbl.f.Notify(swep.Owner, zbl.language.Gun["Empty"], 1)
		return
	end

	if swep:GetBusy() then
		return false
	end

	local _type = swep:GetGenType()
	local _val = swep:GetGenValue()
	if _type < 2 then
		zbl.f.Notify(swep.Owner, zbl.language.Gun["NoVaccine"], 1)
		return false
	end

	// Performs a Target Trace
	local ent = swep.Owner
	if not IsValid(ent) then return end

	if _type == 3 then

		// Check if player is even infected
		if zbl.f.Player_HasVaccine(ent) then

			local vaccindID = zbl.f.Player_GetVaccine(ent)

			// Remove Active Vaccine if the gun has the correct anti vaccine
			if vaccindID == _val then

				swep.Owner:EmitSound("zbl_vo_inject")
				timer.Simple(0.5, function()
					if IsValid(ent) then
						zbl.f.Player_PlaySound_Ouch(ent)

						// Makes the player immun against the virus for a certain amount of time
						zbl.f.Player_MakeImmun(ent,vaccindID,zbl.config.Vaccines[vaccindID].cure.immunity_time)

						// Cures the player
						zbl.f.Player_Cure(ent)
					end
					if IsValid(swep) and IsValid(swep.Owner) then
						swep.Owner:EmitSound("zbl_gun_inject")
					end
				end)

				// Emptys the flask
				zbl.f.Injector_EmptyLiquid(swep,swep:GetSelectedFlask())

				swep:SetBusy(true)
				zbl.f.Injector_PlaySelfInjectAnim(swep)
			else

				zbl.f.Notify(swep.Owner, zbl.language.Gun["WrongCure"], 1)
				return
			end
		else
			zbl.f.Notify(swep.Owner, zbl.language.Gun["PlayerNotInfected"], 1)
		end
	elseif _type == 2 then

		// Check if the target is currently infected and if its a virus we stop
	    if zbl.f.Player_VaccineOverride(ent) == false then
	       zbl.f.Notify(swep.Owner, zbl.language.Gun["PlayerAlreadyInfected"], 1)
		   return
	    end

		swep.Owner:EmitSound("zbl_vo_inject")

		timer.Simple(0.5, function()
			if IsValid(ent) and IsValid(swep) then
				zbl.f.Player_PlaySound_Ouch(ent)
				zbl.f.Player_Vaccinate(ent,_val,1,swep.Owner)
			end
			if IsValid(swep) and IsValid(swep.Owner) then
				swep.Owner:EmitSound("zbl_gun_inject")
			end
		end)

		zbl.f.Injector_EmptyLiquid(swep,swep:GetSelectedFlask())

		swep:SetBusy(true)
		zbl.f.Injector_PlaySelfInjectAnim(swep)
	end

	swep:SetNextPrimaryFire(CurTime() + 1.6)
end



function zbl.f.Injector_PlayShootAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SetBusy(true)

	swep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	swep.Owner:SetAnimation(PLAYER_ATTACK1)

	local timerID = "zbl_gun_shootanim_" .. swep:EntIndex() .. "_timer"
	zbl.f.Timer_Remove(timerID)

	zbl.f.Timer_Create(timerID,0.9,1,function()
		zbl.f.Timer_Remove(timerID)

		if IsValid(swep) and IsValid(swep.Owner) and IsValid(swep.Owner:GetActiveWeapon()) and swep.Owner:GetActiveWeapon():GetClass() == "zbl_gun"  then

			zbl.f.Injector_PlayIdleAnim(swep)
		end
	end)
end

function zbl.f.Injector_PlayDrawAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SetBusy(true)

	swep.Owner:SetAnimation(PLAYER_IDLE)
	swep:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zbl_gun_drawanim_" .. swep:EntIndex() .. "_timer"
	zbl.f.Timer_Remove(timerID)

	zbl.f.Timer_Create(timerID,0.9,1,function()
		zbl.f.Timer_Remove(timerID)

		if IsValid(swep) and IsValid(swep.Owner) and IsValid(swep.Owner:GetActiveWeapon()) and swep.Owner:GetActiveWeapon():GetClass() == "zbl_gun"  then

			zbl.f.Injector_PlayIdleAnim(swep)
		end
	end)
end

function zbl.f.Injector_PlayIdleAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SendWeaponAnim(ACT_VM_IDLE)
	swep.Owner:SetAnimation(PLAYER_IDLE)
	swep:SetBusy(false)
end

function zbl.f.Injector_PlaySelfInjectAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SetBusy(true)

	swep:SendWeaponAnim(ACT_VM_THROW)
	swep.Owner:SetAnimation(PLAYER_ATTACK1)

	local timerID = "zbl_gun_selfinjectanim_" .. swep:EntIndex() .. "_timer"
	zbl.f.Timer_Remove(timerID)

	zbl.f.Timer_Create(timerID,1.6,1,function()
		zbl.f.Timer_Remove(timerID)

		if IsValid(swep) and IsValid(swep.Owner) and IsValid(swep.Owner:GetActiveWeapon()) and swep.Owner:GetActiveWeapon():GetClass() == "zbl_gun"  then

			zbl.f.Injector_PlayIdleAnim(swep)
		end
	end)
end



function zbl.f.Injector_SwitchFlask(swep)
	zbl.f.Debug("zbl.f.Injector_SwitchFlask")

	// Switch to next flask
	local nextFlask = swep:GetSelectedFlask() + 1
	if nextFlask > #swep.Flasks then
		nextFlask = 1
	end
	swep:SetSelectedFlask(nextFlask)

	local _data = swep.Flasks[nextFlask]

	swep:SetGenType(_data.GenType)
	swep:SetGenValue(_data.GenValue)
	swep:SetGenName(_data.GenName)
	swep:SetGenPoints(_data.GenPoints)
	swep:SetGenClass(_data.GenClass)
end

// Returns the first free flask it finds in the gun
function zbl.f.Injector_GetEmptyFlask(swep)
	local emptyflask_id
	for i,v in ipairs(swep.Flasks) do
		if v.GenType == 0 then
			emptyflask_id = i
			break
		end
	end
	return emptyflask_id
end

// Tells us if the current selected flask has any liquid in it
function zbl.f.Injector_HasLiquid(swep)
	return swep.Flasks[swep:GetSelectedFlask()].GenType > 0
end

function zbl.f.Injector_AddLiquid(swep,flask_id,gen_type,gen_value,gen_name,gen_points,gen_class)
	swep:SetSelectedFlask(flask_id)
	//local select_flask = swep:GetSelectedFlask()
	local select_flask = flask_id

	swep:SetGenType(gen_type)
	swep.Flasks[select_flask].GenType = gen_type

	swep:SetGenValue(gen_value)
	swep.Flasks[select_flask].GenValue = gen_value

	swep:SetGenName(gen_name)
	swep.Flasks[select_flask].GenName = gen_name

	swep:SetGenPoints(gen_points)
	swep.Flasks[select_flask].GenPoints = gen_points

	swep:SetGenClass(gen_class)
	swep.Flasks[select_flask].GenClass = gen_class

	zbl.f.Injector_UpdateFlaskSequence(swep)
end

function zbl.f.Injector_EmptyLiquid(swep,flask_id)
	swep:SetGenType(0)
	swep:SetGenValue(0)
	swep:SetGenName("")
	swep:SetGenPoints(0)
	swep:SetGenClass("")

	swep.Flasks[flask_id] = {
		GenType = 0,
		GenValue = 1,
		GenName = "",
		GenPoints = 0,
		GenClass = ""
	}

	zbl.f.Injector_UpdateFlaskSequence(swep)
end

function zbl.f.Injector_ExtractLiquid(swep)
	local tr = swep.Owner:GetEyeTrace()

	if tr.Hit and tr.HitPos and zbl.f.InDistance(swep.Owner:GetPos(), tr.HitPos, 300) then

		if IsValid(tr.Entity) and tr.Entity:GetClass() == "zbl_lab" and swep:GetGenType() == 1 then


			if tr.Entity:GetSampleCount() >= 12 then

				return
			end

			local sample_data = {
				id = swep:GetGenValue(),
				type = swep:GetGenType(),
				name = swep:GetGenName(),
				points = swep:GetGenPoints(),
				class = swep:GetGenClass()
			}

			zbl.f.Lab_AddSampleData(tr.Entity,sample_data)

			zbl.f.Injector_EmptyLiquid(swep,swep:GetSelectedFlask())
			swep.Owner:EmitSound("zbl_gun_extract")
		else

			if zbl.f.Flask_DropLimitReached(swep.Owner) then
				return
			end

			local flask = zbl.f.Flask_Spawn(swep.Owner,tr.HitPos + Vector(0, 0, 15), swep:GetGenType(), swep:GetGenValue(), swep:GetGenName(),swep:GetGenPoints(),swep:GetGenClass())
			zbl.f.Flask_Add(swep.Owner,flask)

			zbl.f.Injector_EmptyLiquid(swep,swep:GetSelectedFlask())
			swep.Owner:EmitSound("zbl_gun_extract")
		end
	end
end

// Returns true if we have the specified amount of (unique) samples with the specified class
function zbl.f.Injector_HasFlask(swep,count,unique,genclass, genvalue,gentype)
	zbl.f.Debug("zbl.f.Injector_HasUniqueSamples")

	/*
		swep - The swep from the player
		count - How many samples should we have
		unique - Should we only search for unique samples (no duplicates allowed)
		genclass - What class should the sample have
		genvalue - If specified then we also check if the flasks genvalue matches with this
		gentype - Check if the flasks genvalue matches with this
	*/

	local current = 0
	local used_id = {}
	for k, v in pairs(swep.Flasks) do
		// Is this flask a sample with the correct class?
		if v.GenType == gentype and (genclass == nil or v.GenClass == genclass) and (genvalue == nil or v.GenValue == genvalue) then

			// Are we searching for only unique samples?
			if unique then

				// Is this sample unique?
				if table.HasValue(used_id, v.GenValue) == false then
					table.insert(used_id, v.GenValue)
					current = current + 1
				end
			else
				current = current + 1
			end
		end
	end

	if current >= count then
		return true
	else
		return false
	end
end

// Removes the amount of samples which match the class
function zbl.f.Injector_RemoveFlask(swep,count,unique,genclass,genvalue,gentype)
	zbl.f.Debug("zbl.f.Injector_RemoveUniqueSamples")

	local current = 0
	local used_id = {}
	local seleced_flask = swep:GetSelectedFlask()
	for k,v in pairs(swep.Flasks) do

		// Did we allready hit our target count?
		if current >= count then
			break
		end

		// Is this flask a sample with the correct class?
		if v.GenType == gentype and (genclass == nil or v.GenClass == genclass) and (genvalue == nil or v.GenValue == genvalue) then

			// Are we searching for only unique samples?
			if unique then

				if table.HasValue(used_id, v.GenValue) == false then

					table.insert(used_id, v.GenValue)
					current = current + 1

					if k == seleced_flask then
						swep:SetGenType(0)
						swep:SetGenValue(0)
						swep:SetGenName("")
						swep:SetGenPoints(0)
						swep:SetGenClass("")
					end

					swep.Flasks[k] = {
						GenType = 0,
						GenValue = 0,
						GenName = "",
						GenPoints = 0,
						GenClass = ""
					}

				end
			else
				current = current + 1

				if k == seleced_flask then
					swep:SetGenType(0)
					swep:SetGenValue(0)
					swep:SetGenName("")
					swep:SetGenPoints(0)
					swep:SetGenClass("")
				end

				swep.Flasks[k] = {
					GenType = 0,
					GenValue = 0,
					GenName = "",
					GenPoints = 0,
					GenClass = ""
				}
			end
		end
	end

	zbl.f.Injector_UpdateFlaskSequence(swep)
end

// Scans the area arround the player
util.AddNetworkString("zbl_scan_pulse")
function zbl.f.Injector_Scan(swep)
	local interval = zbl.config.InjectorGun.Scan.interval[zbl.f.GetPlayerRank(swep.Owner)]

	if interval == nil then
		interval = zbl.config.InjectorGun.Scan.interval["default"]
	end

	if swep.LastScan ~= nil and (swep.LastScan + interval) > CurTime() then return end

	zbl.f.CreateNetEffect("scan_fx",swep.Owner)

	// Create scan pulse
	net.Start("zbl_scan_pulse")
	net.WriteVector(swep.Owner:GetPos())
	net.Send(swep.Owner)

	swep.Owner:EmitSound("zbl_scan_action")
	swep.LastScan = CurTime()
end

hook.Add("PlayerButtonDown", "zbl_PlayerButtonDown_Injector", function(ply, key)
	if IsValid(ply) then

		local swep = ply:GetActiveWeapon()

		if IsValid(swep) and swep:GetClass() == "zbl_gun" then

			if key == zbl.config.InjectorGun.Keys.EmptyFlask and zbl.f.Injector_HasLiquid(swep) then
				zbl.f.Injector_EmptyLiquid(swep,swep:GetSelectedFlask())

			elseif key == zbl.config.InjectorGun.Keys.SwitchFlask then
				zbl.f.Injector_Reload(swep)

			elseif key == zbl.config.InjectorGun.Keys.ExtractFlask and zbl.f.Injector_HasLiquid(swep) then
				zbl.f.Injector_ExtractLiquid(swep)

			elseif key == zbl.config.InjectorGun.Keys.SelfInject then
				zbl.f.Injector_SelfInject(swep)

			elseif key == zbl.config.InjectorGun.Keys.ScanArea then
				zbl.f.Injector_Scan(swep)

			end
		end
	end
end)
