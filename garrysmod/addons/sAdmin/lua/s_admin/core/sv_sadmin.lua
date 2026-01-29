resource.AddWorkshop("2432188292")

util.AddNetworkString("sA:Networking")

sAdmin = sAdmin or {}
sAdmin.usergroups = sAdmin.usergroups or {}
sAdmin.playerData = sAdmin.playerData or {}
sAdmin.offlinePlayers = sAdmin.offlinePlayers or {}
sAdmin.synced = sAdmin.synced or {}

local transformTable = function(tbl)
    local result = {}

    for k,v in ipairs(tbl) do
        if !IsValid(v) or !v:IsPlayer() then continue end
        result[k] = {index = v:EntIndex(), nick = v.Nick and v:Nick()}
    end

    return result
end

sAdmin.silentMsg = function(ply, variable, ...)
    local result = {}
    local args = {...}

    for k,v in ipairs(args) do
        if v == nil or v == "" or (istable(v) and table.IsEmpty(v)) then return end
        local data = v
        
        if istable(v) and isentity(v[1]) and IsValid(v[1]) and v[1]:IsPlayer() then
            data = transformTable(data)
            data.hasPlayer = true
        end
        
        if isentity(v) then
            data = {[1] = {index = IsValid(v) and v:EntIndex() or 0, nick = v.Nick and v:Nick()}, hasPlayer = true}
        end

        table.insert(result, data)
    end

    net.Start("sA:Networking")
    net.WriteUInt(0,3)
    net.WriteString(variable)
    net.WriteString(util.TableToJSON(result))

    if ply then
        net.Send(ply)
    else
        net.Send(sAdmin.FindByPerm("chat_notification"))
    end

    return result
end

sAdmin.msg = function(ply, variable, ...)
    local result = sAdmin.silentMsg(ply, variable, ...)
    
    if sAdmin.config["console_prints"]["fine_print"] and (variable[1] ~= "s" and variable[2] ~= "!") then
        local packed = sAdmin.niceDisplayText(variable, result)
        table.insert(packed, "\n")

        if #packed <= 3 then return end

        MsgC(sAdmin.config["chat_prefix"][1], sAdmin.config["chat_prefix"][2], unpack(packed))
    end
end

local netQueue, menuOpen = {}, {}

sAdmin.queueNetworking = function(ply, func)
    if ply then
        netQueue[ply] = netQueue[ply] or {}
        table.insert(netQueue[ply], func)
        if menuOpen[ply] then
            func(ply)
        end
    else
        for k, v in ipairs(player.GetAll()) do
            sAdmin.queueNetworking(v, func)
        end
    end
end

sAdmin.handleQueue = function(ply)
    if !netQueue[ply] then return end
    for k,v in ipairs(netQueue[ply]) do
        v(ply)
    end

    netQueue[ply] = nil
end

sAdmin.setRank = function(ply, rank, expire, noupdate)
    rank = rank or "user"

    local sid64, oldRank = ply:SteamID64(), ply:GetUserGroup()

    ply:SetUserGroup(rank)

    if expire ~= 0 and isnumber(expire) then
        timer.Create(sid64.."rank_expire", math.max(expire, 0), 1, function()
            sAdmin.setRank(ply, nil, 0)
        end)
    else
        timer.Remove(sid64.."rank_expire")
    end    

    sAdmin.networkData(nil, {"playerData", sid64, "rank"}, rank)

    if !noupdate then
        hook.Run("CAMI.PlayerUsergroupChanged", ply, oldRank, rank, "sAdmin")
        
        sAdmin.updatePlayerRank(ply, rank, expire)
    end
end

sAdmin.banPly = function(ply, time, reason, admin)
    admin = IsValid(admin) and admin:SteamID64() or "0"
    local timeLeft = time == 0 and slib.getLang("sadmin", sAdmin.config["language"], "eternity") or sAdmin.formatTime(time)

    local sid64 = ply:SteamID64()
    sAdmin.addBan(sid64, time, reason, admin)
    ply:Kick("\n"..string.format(sAdmin.config["ban_message"], admin == "0" and slib.getLang("sadmin", sAdmin.config["language"], "console") or admin, reason, timeLeft))
end

sAdmin.unban = function(sid64)
    sAdmin.removeBan(sid64)
    sAdmin.bans[sid64] = nil
end

sAdmin.isBanned = function(sid64)
    return sAdmin.bans[sid64]
end

sAdmin.networkData = function(ply, args, pre_data, compress, json_fix)
    if !ply then
        for k,v in ipairs(player.GetAll()) do
            sAdmin.networkData(v, args, pre_data, compress, json_fix)
        end
    return end

    local data = {}
    data.args = args
    data.data, data.data_type = istable(pre_data) and table.Copy(pre_data) or pre_data, slib.getStatement(pre_data)

    if istable(data.data) and json_fix then for k,v in pairs(data.data) do data.data[k] = nil data.data[k.."_"] = v end end 

    net.Start("sA:Networking")
    net.WriteUInt(1,3)
    net.WriteBool(compressed)

    local json = util.TableToJSON(data)

    if compressed then
        local compressed_data = util.Compress(json)
        local len = #compressed_data

        net.WriteUInt(len, 32)
        net.WriteData(compressed_data, len)
    else
        net.WriteString(json)
    end

    net.Send(ply)
end

local hasNetworked = {}
local intToType2 = {[0] = "playerData", [1] = "stats", [2] = "bans", [3] = "warnsData"}

net.Receive("sA:Networking", function(len, ply)
    local managePerms = sAdmin.hasPermission(ply, "manage_perms") or sAdmin.config["super_users"][ply:SteamID64()]

    local action = net.ReadUInt(3)
    if action == 0 then
        if !managePerms then return end
        
        local group = net.ReadString()
        local perm = net.ReadString()

        if !group or !perm then return end

        local permData = sAdmin.getPermissiondata(perm)
        if !permData and !sAdmin.limits[perm] or !sAdmin.usergroups[group] then return end
        local type = sAdmin.limits[perm] and "int" or slib.getStatement(permData and permData.type or true)
        local val

        if type ~= "int" then
            val = net.ReadBool()
        else
            val = net.ReadInt(13)
        end

        sAdmin.updatePermission(group, perm, !tobool(val) and type != "int", val or nil)

        sAdmin.queueNetworking(nil, function(ply)
            sAdmin.networkData(ply, {"usergroups", group, "permissions", perm}, sAdmin.usergroups[group] and sAdmin.usergroups[group].permissions and sAdmin.usergroups[group].permissions[perm] or nil)
        end)
    elseif action == 1 then
        if !managePerms then return end
        local rank = net.ReadString()
        local create = net.ReadBool()
        
        if !rank or sAdmin.usergroups[rank] and create then return end

        local perms, copied_perms = {}

        if create then
            local copy_from_rank = net.ReadString()

            if sAdmin.usergroups[copy_from_rank] and sAdmin.usergroups[copy_from_rank].permissions then
                perms, copied_perms = sAdmin.usergroups[copy_from_rank].permissions, copy_from_rank
            end
        end

        sAdmin.usergroups[rank] = create and (sAdmin.usergroups[rank] or {permissions = perms}) or nil
        sAdmin.updateRank(rank, !create)

        for k, v in pairs(perms) do
            sAdmin.updatePermission(rank, k, !tobool(v), v or nil)
        end
        
        if copied_perms then
            for cmd, v in pairs(sAdmin.ParameterLimitations) do
                for cur_rank, v in pairs(v) do
                    if cur_rank == copied_perms then
                        sAdmin.saveParameterLimitations(rank, cmd, v)
                    end
                end
            end
        end

        if create then
            sAdmin.registerCAMIGroup(rank)
        elseif CAMI and CAMI.UnregisterUsergroup then
            CAMI.UnregisterUsergroup(rank)
        end

        sAdmin.networkData(nil, {"usergroups", rank}, create and (copied_perms and sAdmin.usergroups[rank] or {}) or nil)
    elseif action == 2 then
        local menuPerms = sAdmin.hasPermission(ply, "menu")
        if !menuPerms and !menuOpen[ply] then return end
        local open = net.ReadBool()
        if open and !menuPerms then return end

        menuOpen[ply] = open or nil
        if open then sAdmin.handleQueue(ply) end
    elseif action == 3 then
        if !sAdmin.hasPermission(ply, "menu") then return end
        local type = net.ReadUInt(2)
        if !intToType2[type] then return end
        hasNetworked[intToType2[type]] = hasNetworked[intToType2[type]] or {}
        if hasNetworked[intToType2[type]][ply] then return end
        hasNetworked[intToType2[type]][ply] = true
        sAdmin.networkData(ply, {intToType2[type]}, sAdmin[intToType2[type]], true, intToType2[type] == "bans")
    elseif action == 4 then
        if !sAdmin.hasPermission(ply, "menu") then return end
        local sid64 = net.ReadString()
        local action = net.ReadBool()
        if !sAdmin.bans[sid64] then return end

        if !action then if sAdmin.hasPermission(ply, "unban") then sAdmin.removeBan(sid64) end return end

        if !sAdmin.hasPermission(ply, "ban") and !sAdmin.hasPermission(ply, "banid") then return end

        local expire = net.ReadUInt(32)
        local reason = net.ReadString()

        local rank = ply:GetUserGroup()
        local limit = sAdmin.ParameterLimitations["ban"][rank] and sAdmin.ParameterLimitations["ban"][rank][2]
        local new_time = limit and math.Clamp(expire, limit.min, limit.max) or expire

        hook.Run("sA:EdittedBan", ply, sid64, new_time, reason)

        sAdmin.addBan(sid64, new_time, reason, ply)
    elseif action == 5 then
        local type = net.ReadUInt(3)
        local page = net.ReadUInt(15)
        local search = net.ReadString()

        if type == 0 then
            sAdmin.requestOfflinePlayer(ply, page, search)
        elseif type == 1 then
            sAdmin.requestPunishmentLogs(ply, page, search)
        elseif type == 2 then
            sAdmin.requestOfflinePlayer(ply, page, search, true)
        elseif type == 3 then
            sAdmin.requestOnlinePlayer(ply, page, search)
        elseif type == 4 then
            sAdmin.requestWarnsPlayer(ply, search)
        end
    elseif action == 6 then
        local target = net.ReadEntity()
        if !IsValid(target) or !target:IsPlayer() and !target:IsBot() or !sAdmin.synced[target] then return end
        hasNetworked[ply] = hasNetworked[ply] or {}
        if hasNetworked[ply][target] then return end

        local sid64 = target:SteamID64()

        if !sid64 or !sAdmin["playerData"][sid64] or !sAdmin["playerData"][sid64].playtime or !sAdmin["playerData"][sid64].synctime then return end
        
        hasNetworked[ply][target] = true
        sAdmin.networkData(ply, {"playerData", sid64, "playtime"}, sAdmin["playerData"][sid64].playtime)
        sAdmin.networkData(ply, {"playerData", sid64, "synctime"}, sAdmin["playerData"][sid64].synctime)
    end
end)

hook.Add("slib.FullLoaded", "sA:LoadPlayer", function(ply)
    sAdmin.networkData(ply, {"usergroups"}, sAdmin.usergroups)
    sAdmin.networkData(ply, {"cloakedPeople"}, sAdmin.cloakedPeople)
    sAdmin.networkData(ply, {"gagged"}, sAdmin.gagged)
    sAdmin.networkData(ply, {"muted"}, sAdmin.muted)

    sAdmin.syncPlayerData(ply)
end)

hook.Add("PlayerInitialSpawn", "sA:SyncPlayer", function(ply)
    sAdmin.syncPlayerData(ply)
end)

hook.Add("sA:OnSyncedPlayer", "sA:HandleNetworking", function(ply)
    local sid64 = ply:SteamID64()
    sAdmin.synced[ply] = true
end)

hook.Add("sA:OnSyncedPlayer", "sA:ItemStoreSupport", function(ply) -- Itemstore Support
    if itemstore and isfunction(ply.SetupInventory) then
        ply:SetupInventory()

        local inv = ply.Inventory
        
        if !inv then return end

        inv:Sync()

        net.Start("ItemStoreSyncInventory")
        net.WriteUInt(inv:GetID(), 32)
        net.Send(ply)
    end
end)

hook.Add("sA:OnSyncedRank", "sA:RegisterCAMIRanks", function(ply)
    if CAMI and CAMI.RegisterUsergroup then
        for k,v in pairs(sAdmin.usergroups) do
            sAdmin.registerCAMIGroup(k)
        end
    end
end)

hook.Add("sA:SQLConnected", "sA:HandleSQL", function()
    sAdmin.syncRanks()
    sAdmin.syncBans()
    sAdmin.syncStats()
    sAdmin.syncWarnStats()
    sAdmin.syncParameterLimitations()
end)

hook.Add("PlayerDisconnected", "sA:PlaytimeHandeler", function(ply)
    if ply:IsBot() then return end
    local sid64 = ply:SteamID64()
    sAdmin.playerData[sid64] = sAdmin.playerData[sid64] or {}
    sAdmin.playerData[sid64].playtime = sAdmin.playerData[sid64].playtime or 0

    if sAdmin.cloakedPeople[sid64] then sAdmin.networkData(nil, {"cloakedPeople", sid64}, nil) sAdmin.cloakedPeople[sid64] = nil end
    if sAdmin.gagged[sid64] then sAdmin.networkData(nil, {"gagged", sid64}, nil) sAdmin.gagged[sid64] = nil end
    if sAdmin.muted[sid64] then sAdmin.networkData(nil, {"muted", sid64}, nil) sAdmin.muted[sid64] = nil end

    sAdmin.updatePlayerSessionEnd(ply, true)

    sAdmin.playerData[sid64] = nil
end)

local isConsole = {
    ["0"] = true,
    ["[NULL Entity]"] = true
}

hook.Add("CheckPassword", "sA:BanHandeler", function(sid64, ip)
    if sAdmin.bans[sid64] and (tonumber(sAdmin.bans[sid64].expiration) == 0 or tonumber(sAdmin.bans[sid64].expiration) > os.time()) then
        local unbanTime = tonumber(sAdmin.bans[sid64].expiration) or 0
        local timeLeft = unbanTime == 0 and slib.getLang("sadmin", sAdmin.config["language"], "eternity") or sAdmin.formatTime(unbanTime - os.time())

        return false, string.format(sAdmin.config["ban_message"], isConsole[sAdmin.bans[sid64].admin_sid64] and slib.getLang("sadmin", sAdmin.config["language"], "console") or sAdmin.bans[sid64].admin_sid64, sAdmin.bans[sid64].reason, timeLeft)
    end
end)

hook.Add("PlayerNoClip", "sA:HandleNoclip", function(ply, desiredNoClipState)
    local sid64 = ply:SteamID64()
    if sAdmin.jailData[sid64] then return false end
	if !sAdmin.hasPermission(ply, "noclip") then sAdmin.msg(ply, "no_permission", "noclip") return false end

    if hook.Run("sA:CanNoclip", ply) == false then return false end

    if sAdmin.config["auto_cloak_on_noclip"] then
        local isNoclipped = ply:GetMoveType() == MOVETYPE_NOCLIP

        sAdmin.cloakHandle(ply, !isNoclipped and true)
    end
    
    return true
end)

hook.Add("PlayerSay", "sA:CommandHandler", function(ply, text)
    local prefix = text[1]

    if sAdmin.config["silent_chat_command_prefix"][prefix] or sAdmin.config["chat_command_prefix"][prefix] or sAdmin.abbreviations[prefix] then
        local silent = !!sAdmin.config["silent_chat_command_prefix"][prefix]
        local args = string.Explode(" ", text)
        args[1] = string.sub(args[1], 2, #args[1])

        local command = string.lower(args[1])

        local darkRPCommands = DarkRP and DarkRP.getChatCommands and DarkRP.getChatCommands()

        if darkRPCommands and darkRPCommands[command] then return false end

        if sAdmin.abbreviations[prefix] then
            command = sAdmin.abbreviations[prefix]

            if args[1] == "" then
                args[1] = sAdmin.abbreviations[prefix]
            else
                table.insert(args, 1, sAdmin.abbreviations[prefix])
            end
        end

        local data = sAdmin.commands[command]

        if data then
            local fullstr = ""

            for k,v in ipairs(args) do
                fullstr = fullstr.." "..v    
            end

            if silent then
                ply:ConCommand("sa_silent"..fullstr)
            else
                ply:ConCommand("sa"..fullstr)
            end

            return ""
        end
    end
    
    if sAdmin.hasPermission(ply, "menu") and sAdmin.config["chat_command"][text:lower()] then
        net.Start("sA:Networking")
        net.WriteUInt(2,3)
        net.Send(ply)

        return ""
    end
end)

timer.Create("sAdmin:SyncPlaytime", 300, 0, function()
    for k, v in ipairs(player.GetAll()) do
        if !IsValid(v) then continue end
        sAdmin.updatePlayerSessionEnd(v)
    end
end)