sAdmin.addCommand({
    name = "ban",
    category = "Management",
    inputs = {{"player", "player_name"}, {"time"}, {"text", "reason"}},
    func = function(ply, args, silent)
        if !args[1] then return end
        local targets = sAdmin.getTargets("ban", ply, args[1], 1)
        local time = sAdmin.getTime(args[2])
        local reason = args[3] or slib.getLang("sadmin", sAdmin.config["language"], "no_reason_provided")

        for k,v in ipairs(targets) do
            sAdmin.banPly(v, time, reason, ply)
        end

        sAdmin.msg(silent and ply or nil, "ban_response", ply, targets, time, reason)
    end
})

sAdmin.addCommand({
    name = "banid",
    category = "Management",
    inputs = {{"text", "sid64/sid"}, {"time"}, {"text", "reason"}},
    func = function(ply, args, silent)
        local sid64, sid = sAdmin.convertSID64(args[1])
        if !sid64 then return end

        local time = sAdmin.getTime(args[2])
        local reason = args[3] or slib.getLang("sadmin", sAdmin.config["language"], "no_reason_provided")

        if IsValid(slib.sid64ToPly[sid64]) then
            sAdmin.banPly(slib.sid64ToPly[sid64], time, reason, ply)
        else
            sAdmin.addBan(sid64, time, reason, ply)
        end

        sAdmin.msg(silent and ply or nil, "banid_response", ply, args[1], time, reason)
    end
})

sAdmin.addCommand({
    name = "unban",
    category = "Management",
    inputs = {{"text", "sid64/sid"}},
    func = function(ply, args, silent)
        local sid64 = sAdmin.convertSID64(args[1])
        if !sid64 then return end

        sAdmin.unban(sid64)

        sAdmin.msg(silent and ply or nil, "unban_response", ply, args[1])
    end
})

sAdmin.addCommand({
    name = "kick",
    category = "Management",
    inputs = {{"player", "player_name"}, {"text", "reason"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("kick", ply, args[1], 1)
        local reason = args[2] or slib.getLang("sadmin", sAdmin.config["language"], "no_reason_provided")

        for k,v in ipairs(targets) do
            v:Kick(sAdmin.config["prefix"]..reason)
        end

        sAdmin.msg(silent and ply or nil, "kick_response", ply, targets, reason)
    end
})

sAdmin.addCommand({
    name = "setrank",
    category = "Management",
    inputs = {{"player", "player_name"}, {"dropdown", "rank", sAdmin.GetRanks}, {"time"}},
    func = function(ply, args, silent)
        local targets, rank, time = sAdmin.getTargets("setrank", ply, args[1], 1), args[2], sAdmin.getTime(args, 3)

        if !rank or !time then sAdmin.msg(ply, "invalid_arguments") return end
        if !sAdmin.usergroups[rank] then sAdmin.msg(ply, "invalid_usergroup") return end

        if IsValid(ply) and !sAdmin.config["super_users"][ply:SteamID64()] then
            local rank_immunity = sAdmin.usergroups[rank] and sAdmin.usergroups[rank].permissions and sAdmin.usergroups[rank].permissions.immunity and tonumber(sAdmin.usergroups[rank].permissions.immunity) or 0
            if rank_immunity > (tonumber(sAdmin.hasPermission(ply, "immunity")) or 0) then sAdmin.msg(ply, "too_high_rank") return end
        end

        for k,v in ipairs(targets) do
            sAdmin.setRank(v, rank, time)
        end

        sAdmin.msg(silent and ply or nil, "setrank_response", ply, targets[1]:Nick(), rank, time)
    end
})

sAdmin.addCommand({
    name = "setrankid",
    category = "Management",
    inputs = {{"text", "sid64/sid"}, {"dropdown", "rank", sAdmin.GetRanks}, {"time"}},
    func = function(ply, args, silent)
        local sid64 = sAdmin.convertSID64(args[1])
        if !sid64 then return end
        local rank, time = args[2], sAdmin.getTime(args, 3)

        if !rank or !time then sAdmin.msg(ply, "invalid_arguments") return end
        if !sAdmin.usergroups[rank] then sAdmin.msg(ply, "invalid_usergroup") return end
        
        if IsValid(ply) and !sAdmin.config["super_users"][ply:SteamID64()] then
            local rank_immunity = sAdmin.usergroups[rank] and sAdmin.usergroups[rank].permissions and sAdmin.usergroups[rank].permissions.immunity and tonumber(sAdmin.usergroups[rank].permissions.immunity) or 0
            if rank_immunity > (tonumber(sAdmin.hasPermission(ply, "immunity")) or 0) then sAdmin.msg(ply, "too_high_rank") return end
        end

        if IsValid(slib.sid64ToPly[sid64]) then
            sAdmin.setRank(slib.sid64ToPly[sid64], rank, time)
        else
            sAdmin.updatePlayerRank(sid64, rank, time)

            sAdmin.queueNetworking(nil, function(ply)
                sAdmin.networkData(ply, {"offlinePlayers", "refresh"}, true)
            end)
        end

        sAdmin.msg(silent and ply or nil, "setrankid_response", ply, args[1], rank, time)
    end
})

sAdmin.addCommand({
    name = "removeuser",
    category = "Management",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("removeuser", ply, args[1], 1)

        for k,v in ipairs(targets) do
            sAdmin.setRank(v, "user")
        end

        sAdmin.msg(silent and ply or nil, "removeuser_response", ply, targets[1]:Nick())
    end
})