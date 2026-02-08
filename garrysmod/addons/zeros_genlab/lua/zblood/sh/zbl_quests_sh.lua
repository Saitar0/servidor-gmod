zbl = zbl or {}
zbl.f = zbl.f or {}

zbl.config = zbl.config or {}
zbl.config.NPC = zbl.config.NPC or {}
zbl.config.NPC.quests = zbl.config.NPC.quests or {}

// For easier quest creation
function zbl.f.Quest_CreateConfig(quest)
	return table.insert(zbl.config.NPC.quests, quest)
end

zbl.Quests = {}

function zbl.f.Quest_Create(quest)
	return table.insert(zbl.Quests, quest)
end

// The player needs to bring unique player samples to the npc
ZBL_SUPPLY_UNIQUE_PLAYER_SAMPLES = zbl.f.Quest_Create({
	icon = zbl.default_materials["zbl_dna_icon"],
	color = zbl.default_colors["virus_red"],
	// Gets called when the job got accepted
	OnStart = function(ply, quest_data) end,

	// Gets called when the player clicks on the finish button
	OnProgressCheck = function(ply, quest_data)

		// Lets check if the player has everything to complete the quest
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.f.Injector_HasFlask(swep, quest_data.count, true, "player", nil, 1)
	end,

	// Called when the player finishes the quest
	OnCompleted = function(ply, quest_data)

		// Removes the unique samples from the players gun
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.f.Injector_RemoveFlask(swep, quest_data.count, true, "player", nil, 1)
	end
})

// The player needs to bring virus samples to the npc
ZBL_SUPPLY_VIRUS_SAMPLES = zbl.f.Quest_Create({
	icon = zbl.default_materials["zbl_icon_virusdna"],
	color = zbl.default_colors["sample_blue"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.f.Injector_HasFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.f.Injector_RemoveFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end
})

// The player needs to bring specified samples
ZBL_SUPPLY_SAMPLES = zbl.f.Quest_Create({
	icon = zbl.default_materials["zbl_dna_icon"],
	color = zbl.default_colors["sample_blue"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.f.Injector_HasFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.f.Injector_RemoveFlask(swep, quest_data.count, false, quest_data.sample_class, quest_data.virus_id, 1)
	end
})

// The player needs to bring virus flasks
ZBL_SUPPLY_VACCINE = zbl.f.Quest_Create({
	icon = zbl.default_materials["zbl_icon_vaccine"],
	color = zbl.default_colors["virus_red"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.f.Injector_HasFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 2)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.f.Injector_RemoveFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 2)
	end
})

// The player needs to bring cure flasks
ZBL_SUPPLY_CURE = zbl.f.Quest_Create({
	icon = zbl.default_materials["zbl_cure_icon"],
	color = zbl.default_colors["cure_green"],
	OnStart = function(ply, quest_data) end,
	OnProgressCheck = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return false end

		return zbl.f.Injector_HasFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 3)
	end,
	OnCompleted = function(ply, quest_data)
		local swep = ply:GetWeapon("zbl_gun")
		if not IsValid(swep) then return end
		zbl.f.Injector_RemoveFlask(swep, quest_data.count, false, nil, quest_data.virus_id, 3)
	end
})
