local function warnPly(target, ply, reason)
    sAdmin.addWarn(target, ply, reason, function(amount)
        for k,v in SortedPairs(sAdmin.config["warns"]["punishments"], true) do
            if (tonumber(amount) or 0) >= k then
                if v.type == "kick" then
                    sAdmin.addPunishmentLog(target, amount, 1)

                    if IsValid(target) then
                        target:Kick(slib.getLang("sadmin", sAdmin.config["language"], "exceed_warn_limit", k))
                    end
                elseif v.type == "ban" then
                    sAdmin.addPunishmentLog(target, amount, 2)
                    RunConsoleCommand("sa", "banid", IsValid(target) and target:SteamID64() or target, v.time or 0, slib.getLang("sadmin", sAdmin.config["language"], "exceed_warn_limit", k))
                end
            break end
        end

        sAdmin.queueNetworking(nil, function(ply)
            sAdmin.networkData(ply, {"offlineWarns", "refresh"}, true)
            sAdmin.networkData(ply, {"onlineWarns", "refresh"}, true)
        end)
    end)
end

sAdmin.addCommand({
    name = "warn",
    category = "Warns",
    inputs = {{"player", "player_name"}, {"text", "reason"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("warn", ply, args[1], 1)
        local reason = args[2] or slib.getLang("sadmin", sAdmin.config["language"], "no_reason_provided")

        for k,target in ipairs(targets) do
            warnPly(target, ply, reason)
        end

        sAdmin.msg(silent and ply or nil, "warn_response", ply, targets, reason)
    end
})

sAdmin.addCommand({
    name = "warns",
    category = "Warns",
    inputs = {},
    func = function(ply, args, silent)
        sAdmin.requestWarnsPlayer(ply, ply:SteamID64())
    end
})

sAdmin.addCommand({
    name = "warnid",
    category = "Warns",
    inputs = {{"text", "sid64/sid"}, {"text", "reason"}},
    func = function(ply, args, silent)
        local sid64, sid = sAdmin.convertSID64(args[1])
        if !sid64 then return end

        local reason = args[2] or slib.getLang("sadmin", sAdmin.config["language"], "no_reason_provided")
        local target = slib.sid64ToPly[sid64]
        warnPly(IsValid(target) and target or sid64, ply, reason)

        sAdmin.msg(silent and ply or nil, "warn_response", ply, IsValid(target) and {target} or args[1], reason)
    end
})


sAdmin.addCommand({
    name = "warn_remove",
    category = "Warns",
    inputs = {{"text", "id"}},
    func = function(ply, args, silent)
        local id = args[1]

        if !id then sAdmin.msg(ply, "invalid_arguments") return end

        sAdmin.deleteWarn(id, function(result)
            if result then
                sAdmin.msg(silent and ply or nil, "warn_remove_response", ply, id)
            else
                sAdmin.msg(ply, "invalid_id")
            end

            sAdmin.queueNetworking(nil, function(ply)
                sAdmin.networkData(ply, {"offlineWarns", "refresh"}, true)
                sAdmin.networkData(ply, {"onlineWarns", "refresh"}, true)
            end)
        end)
    end
})

sAdmin.addCommand({
    name = "warn_setinactive",
    category = "Warns",
    inputs = {{"text", "id"}},
    func = function(ply, args, silent)
        local id = args[1]

        if !id then sAdmin.msg(ply, "invalid_arguments") return end

        sAdmin.setWarnInactive(id, function(result)
            if result then
                sAdmin.msg(silent and ply or nil, "warn_setinactive_response", ply, id)
            else
                sAdmin.msg(ply, "invalid_id")
            end

            sAdmin.queueNetworking(nil, function(ply)
                sAdmin.networkData(ply, {"offlineWarns", "refresh"}, true)
                sAdmin.networkData(ply, {"onlineWarns", "refresh"}, true)
            end)
        end)
    end
})