if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

// Called when the quest starts
function zbl.f.Quest_OnStart(ply,quest_id)
	zbl.f.Debug('zbl.f.Quest_OnStart')
	local swep = ply:GetWeapon('zbl_gun')
	if not IsValid(swep) then return end

	local quest_config = zbl.config.NPC.quests[quest_id]
	if quest_config == nil then return end

	local quest_data = zbl.Quests[quest_config.q_type]
	if quest_data == nil then return end

	// If the player doesent have enough space in his gun then we dont allow him to take this quest
	if #swep.Flasks < quest_config.count then
		return
	end



	ply.zbl_Quest.accepted = true
	ply.zbl_Quest.start_time = CurTime()


	// Run any code that might be needed
	quest_data.OnStart(ply,quest_config)

	local timerID = 'zbl_quest_timer_' .. zbl.f.Player_GetID(ply)
	zbl.f.Timer_Remove(timerID)

	zbl.f.Timer_Create(timerID,quest_config.time,1,function()
		zbl.f.Timer_Remove(timerID)

		if IsValid(ply) then
			zbl.f.Quest_OnFailed(ply)
		end
	end)
end

//Called to stop the quest instantly
function zbl.f.Quest_Stop(steamid,ply)
	zbl.f.Debug('zbl.f.Quest_Stop')

	local timerID = 'zbl_quest_timer_' .. steamid
	zbl.f.Timer_Remove(timerID)

	if IsValid(ply) then
		ply.zbl_Quest = {
			id = -1,
			request_time = CurTime(),
			start_time = -1,
			accepted = false,
			npc = nil
		}
	end
end


util.AddNetworkString('zbl_OnQuestFailed')
util.AddNetworkString('zbl_OnQuestCompleted')
// Called when the quest timer runs out
function zbl.f.Quest_OnFailed(ply)
	zbl.f.Debug('zbl.f.Quest_OnFailed')

	zbl.f.Notify(ply, zbl.language.NPC['Quest_FailedNotify'], 1)

	// If the client has the interface open while this happens then we update it
	net.Start('zbl_OnQuestFailed')
	net.Send(ply)

	ply.zbl_Quest = {
		id = -1,
		request_time = CurTime(),
		start_time = -1,
		accepted = false,
		npc = nil
	}
end

// Checks if we reached our goal for the quest
function zbl.f.Quest_CheckProgress(ply)
	local result = false
	if ply.zbl_Quest and ply.zbl_Quest.id ~= -1 and ply.zbl_Quest.accepted then
		local quest_config = zbl.config.NPC.quests[ply.zbl_Quest.id]

		result = zbl.Quests[quest_config.q_type].OnProgressCheck(ply,quest_config)
	end

	if result == true then
		zbl.f.Debug('zbl.f.Quest_CheckProgress: Quest Completed!')
	else
		zbl.f.Debug('zbl.f.Quest_CheckProgress: Quest not done yet')
	end

	return result
end

// Called when the player completed the quest
function zbl.f.Quest_OnCompleted(ply)
	zbl.f.Debug('zbl.f.Quest_OnCompleted')

	local quest_config = zbl.config.NPC.quests[ply.zbl_Quest.id]
	zbl.Quests[quest_config.q_type].OnCompleted(ply, quest_config)

	// Give player the money
	if quest_config.money_reward then
		zbl.f.GiveMoney(ply, quest_config.money_reward)
		ply:EmitSound('zbl_cash')
		zbl.f.Notify(ply, string.Replace(zbl.language.General['ReceivedMoney'],'$Money',zbl.f.CurrencyPos(quest_config.money_reward, zbl.config.Currency)), 4)
	end

	// Give the Player DNA Points
	if quest_config.dna_reward then
		zbl.f.Lab_Data_AddPoints(ply, quest_config.dna_reward)
		zbl.f.Notify(ply, string.Replace(zbl.language.General['ReceivedDNAPoints'], '$Points', quest_config.dna_reward), 4)
	end

	zbl.f.Quest_Stop(zbl.f.Player_GetID(ply), ply)

	local swep = ply:GetWeapon('zbl_gun')
	if not IsValid(swep) then return end

	local reduced_tbl = {}
	for k,v in pairs(swep.Flasks) do
		local name = v.GenName
		reduced_tbl[k] = {
			gt = v.GenType,
			gv = v.GenValue,
			gn = name,
		}
	end

	timer.Simple(0,function()
		if IsValid(ply) and reduced_tbl then

			// If the client has the interface open while this happens then we update it
			local dataString = util.TableToJSON(reduced_tbl)
			local dataCompressed = util.Compress(dataString)
			net.Start('zbl_OnQuestCompleted')
			net.WriteUInt(#dataCompressed, 16)
			net.WriteData(dataCompressed, #dataCompressed)
			net.Send(ply)
		end
	end)
end
