local category = "sadmin"

mLogs.addLogger(slib.getLang("sadmin", sAdmin.config["language"], "commands"), "sacommand", category)
mLogs.addHook("sA:RanCommand", category, function(ply, name, args, argstr)
	if !IsValid(ply) then return end

	mLogs.log("sacommand", category, {ply = (IsValid(ply) and mLogs.logger.getPlayerData(ply) or slib.getLang("sadmin", sAdmin.config["language"], "console")), cmd = name, args = argstr})
end)

mLogs.addLogger(slib.getLang("sadmin", sAdmin.config["language"], "ban_edits"), "sabanedit", category)
mLogs.addHook("sA:EdittedBan", category, function(ply, sid64, new_time, new_reason)
	if !IsValid(ply) then return end

	local target = slib.sid64ToPly[sid64]
	target = IsValid(target) and mLogs.logger.getPlayerData(target) or target

	mLogs.log("sabanedit", category, {ply = (IsValid(ply) and mLogs.logger.getPlayerData(ply) or slib.getLang("sadmin", sAdmin.config["language"], "console")), target = target, new_time = new_time, new_reason = new_reason})
end)