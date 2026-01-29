sAdmin = sAdmin or {}
sAdmin.bans = sAdmin.bans or {}
sAdmin.usergroups = sAdmin.usergroups or {}
sAdmin.playerData = sAdmin.playerData or {}
sAdmin.offlinePlayers = sAdmin.offlinePlayers or {}
sAdmin.offlinePlySID64ToIndex = sAdmin.offlinePlySID64ToIndex or {}
sAdmin.warnsData = sAdmin.warnsData or {
    warnsThisWeek = 0,
    warnsChart = {},
    totalWarns = 0,
    punishmentsThisWeek = 0,
    totalPunishments = 0
}

sAdmin.stats = sAdmin.stats or {totalPlaytime = 0, totalPlayers = 0, staff_playtimeLeaderboard = {}}

local query, db
local escape_str = function(str) return SQLStr(str, true) end

local create_queries = {
    [1] = [[CREATE TABLE IF NOT EXISTS sadmin_player(
        id INTEGER PRIMARY KEY %s,
        name VARCHAR(32),
        sid64 CHAR(17),
        rank_name VARCHAR(32),
        rank_expire INTEGER,
        playtime INTEGER DEFAULT 0,
        online INTEGER DEFAULT 0,
        staff INTEGER DEFAULT 0,
        total_warns INTEGER DEFAULT 0
    )]],
    [2] = [[CREATE TABLE IF NOT EXISTS sadmin_ranks(
        id INTEGER PRIMARY KEY %s,
        rank_name VARCHAR(32)
    )]],
    [3] = [[CREATE TABLE IF NOT EXISTS sadmin_permissions(
        id INTEGER PRIMARY KEY %s,
        rank_name VARCHAR(32),
        permission VARCHAR(32),
        value INTEGER
    )]],
    [4] = [[CREATE TABLE IF NOT EXISTS sadmin_bans(
        id INTEGER PRIMARY KEY %s,
        sid64 CHAR(17),
        admin_sid64 CHAR(17),
        expiration BIGINT,
        reason VARCHAR(100)
    )]],
    [5] = [[CREATE TABLE IF NOT EXISTS sadmin_warns(
        id INTEGER PRIMARY KEY %s,
        sid64 CHAR(17),
        admin_sid64 CHAR(17),
        date_given INTEGER,
        active INTEGER DEFAULT 0,
        reason VARCHAR(100)
    )]],
    [6] = [[CREATE TABLE IF NOT EXISTS sadmin_punishments(
        id INTEGER PRIMARY KEY %s,
        sid64 CHAR(17),
        name VARCHAR(32),
        date_given INTEGER,
        action INTEGER,
        active_warns INTEGER DEFAULT 0
    )]],
    [7] = [[CREATE TABLE IF NOT EXISTS sadmin_paramlimitations(
        id INTEGER PRIMARY KEY %s,
        rank_name VARCHAR(32),
        name VARCHAR(32),
        param_id INTEGER,
        min_limit INTEGER DEFAULT 0,
        max_limit INTEGER DEFAULT 0
    )]]
}

local migrations = {
    {[[ALTER TABLE sadmin_player
        ADD total_warns INTEGER DEFAULT 0
    ]], 1660036640},
    {[[ALTER TABLE sadmin_player
        RENAME COLUMN rank TO rank_name;
        ALTER TABLE sadmin_ranks
        RENAME COLUMN rank TO rank_name;
        ALTER TABLE sadmin_permissions
        RENAME COLUMN rank TO rank_name;
        ALTER TABLE sadmin_paramlimitations
        RENAME COLUMN rank TO rank_name
    ]], 1660036640, "sql_local"},
    {[[ALTER TABLE sadmin_player
        CHANGE COLUMN rank rank_name VARCHAR(32);
        ALTER TABLE sadmin_ranks
        CHANGE COLUMN rank rank_name VARCHAR(32);
        ALTER TABLE sadmin_permissions
        CHANGE COLUMN rank rank_name VARCHAR(32);
        ALTER TABLE sadmin_paramlimitations
        CHANGE COLUMN rank rank_name VARCHAR(32)
    ]], 1660036640, "mysql"},
    {[[ALTER TABLE sadmin_bans CHANGE COLUMN expiration expiration BIGINT]], 1660036640, "mysql"},
    {[[INSERT INTO sadmin_ranks(rank_name) VALUES('user');
    INSERT INTO sadmin_ranks(rank_name) VALUES('admin');
    INSERT INTO sadmin_ranks(rank_name) VALUES('superadmin');
    INSERT INTO sadmin_permissions(rank_name, permission, value) VALUES('user', 'immunity', 100);
    INSERT INTO sadmin_permissions(rank_name, permission, value) VALUES('admin', 'immunity', 200);
    INSERT INTO sadmin_permissions(rank_name, permission, value) VALUES('superadmin', 'immunity', 300)]], 1660036650},
}

local function runMigrations()
    file.CreateDir("sadmin")
    
    local migrationData = file.Read("sadmin/migration.txt", "DATA")
    migrationData = migrationData and util.JSONToTable(migrationData) or {
        sql_local = 0,
        mysql = 0
    }

    local lastMigration = tonumber(migrationData[sAdmin.config["storage_type"]] or 0) or 0

    for k,v in ipairs(migrations) do
        local queryString = v[1]
        local time = v[2]
        local realm = v[3]

        if (realm and realm != sAdmin.config["storage_type"]) or lastMigration > time then continue end

        query(queryString)
    end

    migrationData[sAdmin.config["storage_type"]] = os.time()

    file.Write("sadmin/migration.txt", util.TableToJSON(migrationData))
end

local function makeTables()
    for k, v in ipairs(create_queries) do
        query(string.format(v, sAdmin.config["storage_type"] == "sql_local" and "AUTOINCREMENT" or "AUTO_INCREMENT"))
    end

    runMigrations()
end

hook.Add("sA:SQLConnected", "sA:SetOnlineToOffline", function()
    query("UPDATE sadmin_player SET online = 0 WHERE online = 1")
end)

if sAdmin.config["storage_type"] == "mysql" then
    require("mysqloo")

    query = function() end

    local dbinfo = sAdmin.config["mysql_info"]

    db = mysqloo.connect(dbinfo.host, dbinfo.username, dbinfo.password, dbinfo.database, dbinfo.port)

    function db:onConnected()
        print(sAdmin.config["prefix"]..slib.getLang("sadmin", sAdmin.config["language"], "mysql_successfull"))

        query = function(str, func)
            local q = db:query(str)
            q.onSuccess = function(_, data)
                if func then
                    func(data)
                end
            end

            q.onError = function(_, err) end

            q:start()
        end

        escape_str = function(str) return db:escape(str) end

        sAdmin.query = query
        sAdmin.escape_str = escape_str

        makeTables()

        hook.Run("sA:SQLConnected")
    end

    function db:onConnectionFailed(err)
        print(sAdmin.config["prefix"]..slib.getLang("sadmin", sAdmin.config["language"], "mysql_failed"))
        print( "Error:", err )
    end

    db:connect()
else
    local oldFunc = sql.Query
    query = function(str, func)
        local result = oldFunc(str)

        if func then
            func(result)
        end
    end

    sAdmin.query = query
    sAdmin.escape_str = escape_str

    makeTables()
end

sAdmin.syncPlayerData = function(ply)
    if ply:IsBot() then return end
    local sid64 = ply:SteamID64()

    local nick = escape_str(ply:Nick())
    
    query("SELECT sid64, rank_name, rank_expire, playtime FROM sadmin_player WHERE sid64 = '"..sid64.."'", function(result)
        sAdmin.playerData[sid64] = sAdmin.playerData[sid64] or {}
        
        local inserted = false

        if result and result[1] then
            local data = result[1]
        
            sAdmin.playerData[sid64] = data
            sAdmin.playerData[sid64].id = nil

            local expiry = tonumber(data.rank_expire)
            local timeLeft = math.max(expiry - os.time(), 0)

            sAdmin.setRank(ply, data.rank_name, timeLeft, true)

            sAdmin.playerData[sid64].playtime = data.playtime
        else
            query("INSERT INTO sadmin_player(name, sid64, rank_name, rank_expire, playtime, online, staff) VALUES('"..nick.."', '"..sid64.."', 'user', 0, 0, 1, 0)")
            inserted = true

            sAdmin.setRank(ply, "user", 0, true)
        end

        if !inserted then
            query("UPDATE sadmin_player SET name = '"..nick.."', online = 1 WHERE sid64 = '"..sid64.."'")
        end

        sAdmin.playerData[sid64].synctime, sAdmin.playerData[sid64].playtime = CurTime(), sAdmin.playerData[sid64].playtime or 0

        hook.Run("sA:OnSyncedPlayer", ply)

        sAdmin.syncStats()
    end)
end

sAdmin.updatePlayerSessionEnd = function(ply, left)
    local sid64 = ply:SteamID64()
    if !sAdmin.playerData[sid64] or !sAdmin.synced[ply] then return end
    local playtime = sAdmin.playerData[sid64].synctime and sAdmin.playerData[sid64].playtime + (CurTime() - sAdmin.playerData[sid64].synctime) or sAdmin.playerData[sid64].playtime

    if !isnumber(playtime) then return end

    query(string.format("UPDATE sadmin_player SET playtime = %s, online = %s WHERE sid64 = '%s'", playtime, left and 0 or 1, sid64))
end

sAdmin.updatePlayerRank = function(ply, rank, rank_expire)
    rank_expire = rank_expire or 0
    local sid64 = isentity(ply) and ply:SteamID64() or escape_str(ply)
    if !sid64 or !isnumber(rank_expire) then return end
    rank, rank_expire = escape_str(rank), (rank_expire > 0 and rank_expire + os.time() or rank_expire)

    local is_staff = (sAdmin.usergroups[rank] and sAdmin.usergroups[rank].permissions and sAdmin.usergroups[rank].permissions["is_staff"]) and 1 or 0

    query("SELECT * FROM sadmin_player WHERE sid64 = '"..sid64.."'", function(result)
        if result and result[1] then
            query("UPDATE sadmin_player SET rank_name = '"..(rank or escape_str(result[1].rank_name)).."', rank_expire = '"..rank_expire.."', staff = '"..is_staff.."' WHERE sid64 = '"..sid64.."'")
        else
            query("INSERT INTO sadmin_player(sid64, rank_name, rank_expire, playtime, online, staff) VALUES('"..sid64.."', '"..rank.."', '"..rank_expire.."', 0, 0, '"..is_staff.."')")
        end

        if isentity(ply) and IsValid(ply) then
            sAdmin.playerData[sid64].rank = rank
            sAdmin.playerData[sid64].rank_expire = rank_expire

            sAdmin.queueNetworking(nil, function(ply)
                sAdmin.networkData(ply, {"playerData", sid64}, sAdmin.playerData[sid64])
            end)
        end
    end)
end

sAdmin.syncRanks = function()
    query("SELECT * FROM sadmin_ranks", function(result)
        if !result then return end
        for k,v in ipairs(result) do
            sAdmin.usergroups[v.rank_name] = {}
        end
    end)

    query("SELECT * FROM sadmin_permissions", function(result)
        if !result then return end
        for k,v in ipairs(result) do
            if !sAdmin.usergroups[v.rank_name] then continue end
            local default_type = sAdmin.getPermissiondata(v.permission) or {type = 0}
            default_type = default_type and default_type.type
            sAdmin.usergroups[v.rank_name].permissions = sAdmin.usergroups[v.rank_name].permissions or {}
            sAdmin.usergroups[v.rank_name].permissions[v.permission] = !default_type and true or v.value
        end

        hook.Run("sA:OnSyncedRank")
    end)
end

local syncedStats = function(queried)
    if queried >= 3 then
        sAdmin.queueNetworking(nil, function(ply)
            sAdmin.networkData(ply, {"stats"}, sAdmin.stats)
        end)
    end
end

sAdmin.syncStats = function()
    local queried = 0
    sAdmin.stats.staff_playtimeLeaderboard = {}
    query("SELECT COUNT(name), SUM(playtime) FROM sadmin_player", function(result)
        if result and result[1] then
            sAdmin.stats.totalPlayers = result[1]["COUNT(name)"] or 0
            sAdmin.stats.totalPlaytime = result[1]["SUM(playtime)"] or 0
        end

        queried = queried + 1
        syncedStats(queried)
    end)

    query("SELECT name, sid64, playtime FROM sadmin_player WHERE staff = 1 ORDER BY playtime DESC LIMIT 30", function(result)
        if result and result[1] then
            sAdmin.stats.staff_playtimeLeaderboard = result
        end

        queried = queried + 1
        syncedStats(queried)
    end)

    queried = queried + 1
    syncedStats(queried)
end

sAdmin.updateRank = function(rank, delete, callback)
    local escaped = escape_str(rank)

    if delete then
        query([[DELETE FROM sadmin_ranks WHERE rank_name =']]..escaped..[['; DELETE from sadmin_permissions WHERE rank_name = ']]..escaped..[[']])
    return end

    query([[INSERT INTO sadmin_ranks(rank_name) VALUES(']]..escaped..[[')]])
end

sAdmin.updatePermission = function(rank, perm, delete, val)
    if !sAdmin.usergroups[rank] then return end
    sAdmin.usergroups[rank].permissions = sAdmin.usergroups[rank].permissions or {}
    sAdmin.usergroups[rank].permissions[perm] = val
    
    local escaped_rank, escaped_perm = escape_str(rank), escape_str(perm)

    if perm == "is_staff" then
        local is_staff = tonumber((val and val ~= "") and 1 or 0)

        query("SELECT sid64 FROM sadmin_player WHERE rank_name = '"..escaped_rank.."'", function(result)
            if !result then return end
            for k,v in ipairs(result) do
                query("UPDATE sadmin_player SET staff = "..is_staff.." WHERE sid64 = '"..escape_str(v.sid64).."'", function() if k >= #result then sAdmin.syncStats() end end)
            end
        end)
    end

    if delete or !val or val == "" then
        query([[DELETE FROM sadmin_permissions WHERE rank_name =']]..escaped_rank..[[' and permission = ']]..escaped_perm..[[']])
    return end

    val = escape_str(tostring(isbool(val) and 1 or val))
    
    query(string.format("SELECT * FROM sadmin_permissions WHERE rank_name = '%s' AND permission = '%s'", escaped_rank, escaped_perm), function(res)
        if res and res[1] then
            query("UPDATE sadmin_permissions SET value = '"..val.."' WHERE rank_name = '"..escaped_rank.."' AND permission = '"..escaped_perm.."'")
        else
            query([[INSERT INTO sadmin_permissions(rank_name, permission, value) VALUES(']]..escaped_rank..[[', ']]..escaped_perm..[[', ']]..val..[[')]])
        end
    end)
end

sAdmin.syncBans = function()
    query("SELECT * FROM sadmin_bans", function(result)
        if !result then return end
        for k,v in ipairs(result) do
            local expiration = tonumber(v.expiration)
            local expire = expiration or 0
            if expire > 0 then expire = expire - os.time() end

            if expire ~= 0 then
                timer.Create(v.sid64.."_unban", expire, 1, function()
                    sAdmin.removeBan(v.sid64)
                end)
            end

            sAdmin.bans[v.sid64] = {sid64 = v.sid64, expiration = expiration, reason = v.reason, admin_sid64 = v.admin_sid64}
        end
    end)
end

sAdmin.addBan = function(sid64, expire, reason, admin)
    local admin_sid64 = (isentity(admin) and IsValid(admin)) and admin:SteamID64() or admin
    if !isnumber(expire) then return end

    reason = reason or sAdmin.bans[sid64].reason or ""
    expire = expire and expire or sAdmin.bans[sid64].expiration or 0
    admin_sid64 = admin_sid64 or sAdmin.bans[sid64].admin_sid64 or ""

    local ban_finish = expire > 0 and expire + os.time() or expire

    sid64, reason, admin_sid64 = escape_str(sid64), escape_str(reason), escape_str(admin_sid64)

    if sAdmin.bans[sid64] then
        query(string.format("UPDATE sadmin_bans SET expiration = %s, reason = '%s', admin_sid64 = '%s' WHERE sid64 = '%s'", ban_finish, reason, admin_sid64, sid64))
    else
        query([[INSERT INTO sadmin_bans(sid64, expiration, reason, admin_sid64) VALUES(']]..sid64..[[',]]..ban_finish..[[, ']]..reason..[[', ']]..admin_sid64..[[')]])
    end

    if expire ~= 0 then
        timer.Create(sid64.."_unban", expire, 1, function()
            sAdmin.removeBan(sid64)
        end)
    end

    sAdmin.bans[sid64] = {sid64 = sid64, expiration = ban_finish, reason = reason, admin_sid64 = admin_sid64}
    
    sAdmin.queueNetworking(nil, function(ply)
        sAdmin.networkData(ply, {"bans", sid64}, sAdmin.bans[sid64])
    end)
end

sAdmin.removeBan = function(sid64)
    sid64 = escape_str(sid64)
    query([[DELETE FROM sadmin_bans WHERE sid64 = ']]..sid64..[[']])
    sAdmin.bans[sid64] = nil
    sAdmin.queueNetworking(nil, function(ply)
        sAdmin.networkData(ply, {"bans", sid64}, nil)
    end)
end

local online_player_cd, offline_player_cd, punishment_cd, warns_cd = {}, {}, {}, {}

sAdmin.requestOfflinePlayer = function(ply, page, search, warn)
    local cd_type = warn and warns_cd or offline_player_cd
    if cd_type[ply] and cd_type[ply] > CurTime() then sAdmin.msg(ply, "request_rate_limit") return end
    cd_type[ply] = CurTime() + .1

    search = search ~= "" and escape_str(search) or nil
    local perpage = 20
    local start = perpage * ((tonumber(page) or 1) - 1)

    local search_str = search and  " AND (sid64 LIKE '%"..search.."%' OR name LIKE '%"..search.."%' OR rank_name LIKE '%"..search.."%')" or ""

    query("SELECT COUNT(name) FROM sadmin_player WHERE online = 0"..search_str, function(pageresult)
        local pageCount = 1
        if pageresult and pageresult[1] and pageresult[1]["COUNT(name)"] then
            pageCount = math.ceil((pageresult[1]["COUNT(name)"] or 0) / perpage)
        end

        query("SELECT sid64, name, rank_name, playtime, total_warns FROM sadmin_player WHERE online = 0"..search_str.." LIMIT "..start..", "..(perpage), function(result)
            result = result or {}
            
            result.total_pages, result.cur_page = pageCount, page

            sAdmin.networkData(ply, {(warn and "offlineWarns" or "offlinePlayers")}, result or {})
        end)
    end)
end

sAdmin.requestOnlinePlayer = function(ply, page, search)
    if online_player_cd[ply] and online_player_cd[ply] > CurTime() then sAdmin.msg(ply, "request_rate_limit") return end
    online_player_cd[ply] = CurTime() + .1

    search = search ~= "" and escape_str(search) or nil
    local perpage = 20
    local start = perpage * ((tonumber(page) or 1) - 1)

    local search_str = search and  " AND (sid64 LIKE '%"..search.."%' OR name LIKE '%"..search.."%' OR rank_name LIKE '%"..search.."%')" or ""

    query("SELECT COUNT(name) FROM sadmin_player WHERE online = 1"..search_str, function(pageresult)
        local pageCount = 1
        if pageresult and pageresult[1] and pageresult[1]["COUNT(name)"] then
            pageCount = math.ceil((pageresult[1]["COUNT(name)"] or 0) / perpage)
        end

        query("SELECT sid64, total_warns, rank_name FROM sadmin_player WHERE online = 1"..search_str.." LIMIT "..start..", "..(perpage), function(result)
            result = result or {}
            
            result.total_pages, result.cur_page = pageCount, page

            sAdmin.networkData(ply, {"onlineWarns"}, result or {})
        end)
    end)
end

sAdmin.requestPunishmentLogs = function(ply, page, search)
    if punishment_cd[ply] and punishment_cd[ply] > CurTime() then sAdmin.msg(ply, "request_rate_limit") return end
    punishment_cd[ply] = CurTime() + .1

    search = search ~= "" and escape_str(search) or nil
    local perpage = 20
    local start = perpage * ((tonumber(page) or 1) - 1)

    local search_str = search and " WHERE (sid64 LIKE '%"..search.."%' OR name LIKE '%"..search.."%')" or ""

    query("SELECT COUNT(id) FROM sadmin_punishments"..search_str, function(pageresult)
        local pageCount = 1
        if pageresult and pageresult[1] and pageresult[1]["COUNT(id)"] then
            pageCount = math.ceil((pageresult[1]["COUNT(id)"] or 0) / perpage)
        end

        query("SELECT * FROM sadmin_punishments"..search_str.." ORDER BY date_given DESC LIMIT "..start..", "..(perpage), function(result)
            result = result or {}
        
            result.total_pages, result.cur_page = pageCount, page

            sAdmin.networkData(ply, {"punishmentLogs"}, result or {})
        end)
    end)
end

local request_warn_cd = {}

sAdmin.requestWarnsPlayer = function(ply, sid64)
    if request_warn_cd[ply] and request_warn_cd[ply] > CurTime() then sAdmin.msg(ply, "request_rate_limit") return end
    request_warn_cd[ply] = CurTime() + .1

    query("SELECT * FROM sadmin_warns WHERE sid64 = '"..escape_str(sid64).."'", function(result)
        result = result or {}
        result.sid64 = sid64

        local active_time = sAdmin.getTime(sAdmin.config["warns"]["active_time"])
        local changed = false

        for k,v in ipairs(result) do
            if !v.date_given then continue end

            local isActive = os.time() - v.date_given < active_time

            if !isActive then
                result.active = "0"
                changed = true
            end
        end
        
        if changed then
            sAdmin.updateActiveWarns(sid64)
        end

        query("SELECT name FROM sadmin_player WHERE sid64 = '"..escape_str(sid64).."'", function(name)
            if !name or !name[1] then return end
            result.name = name[1].name or ""

            sAdmin.networkData(ply, {"playerWarns"}, result or {})
        end)
    end)
end

local function querypunishment(sid64, name, action, active_warns)
    name = escape_str(name)

    query(string.format("INSERT INTO sadmin_punishments(sid64, name, date_given, action, active_warns) VALUES('%s', '%s', %s, %s, %s)", sid64, name, os.time(), action, active_warns), function()
        sAdmin.queueNetworking(nil, function(ply)
            sAdmin.networkData(ply, {"warnsData", "logs"}, sAdmin.warnsData.warnsChart)
        end)

        sAdmin.syncWarnStats("punishments")
    end)
end

sAdmin.addPunishmentLog = function(ply, active_warns, action, callback)
    if !isnumber(action) or !isnumber(active_warns) then return end
    local sid64, name = IsValid(ply) and ply:SteamID64() or escape_str(ply), IsValid(ply) and ply:Nick()

    if !nick then
        query("SELECT * FROM sadmin_player WHERE sid64 = '"..sid64.."'", function(result)
            if result and result[1] then
                name = result[1].name
            end

            querypunishment(sid64, name, action, active_warns)
        end)
    return end

    querypunishment(sid64, name, action, active_warns)
end

sAdmin.saveParameterLimitations = function(rank, name, data)
    sAdmin.ParameterLimitations[name] = sAdmin.ParameterLimitations[name] or {}
    sAdmin.ParameterLimitations[name][rank] = sAdmin.ParameterLimitations[name][rank] or {}

    sAdmin.ParameterLimitations[name][rank] = data
    
    query(string.format("DELETE FROM sadmin_paramlimitations WHERE rank_name='%s' AND name='%s'", escape_str(rank), escape_str(name)), function()
        for k,v in pairs(data) do
            if !isnumber(k) or !istable(v) then continue end
            v.min, v.max = v.min or 0, v.max or 0

            if !isnumber(v.min) or !isnumber(v.max) then continue end

            query(string.format("INSERT INTO sadmin_paramlimitations(rank_name, name, param_id, min_limit, max_limit) VALUES('%s', '%s', %s, %s, %s)", escape_str(rank), escape_str(name), k, v.min, v.max))
        end
    end)
end 

sAdmin.syncParameterLimitations = function()
    query("SELECT * FROM sadmin_paramlimitations", function(result)
        if !result or !result[1] then return end

        sAdmin.ParameterLimitations = {}

        for k,v in ipairs(result) do
            sAdmin.ParameterLimitations[v.name] = sAdmin.ParameterLimitations[v.name] or {}
            sAdmin.ParameterLimitations[v.name][v.rank_name] = sAdmin.ParameterLimitations[v.name][v.rank_name] or {}

            sAdmin.ParameterLimitations[v.name][v.rank_name][v.param_id] = {min = v.min_limit or 0, max = v.max_limit or 0}
        end
    end)
end 

sAdmin.addWarn = function(ply, admin, reason, callback)
    local sid64, admin_sid64 = IsValid(ply) and ply:SteamID64() or escape_str(ply), IsValid(admin) and admin:SteamID64() or escape_str(admin)

    query(string.format("INSERT INTO sadmin_warns(sid64, admin_sid64, date_given, active, reason) VALUES('%s', '%s', %s, 1, '%s')", sid64, admin_sid64, os.time(), escape_str(reason)), function() sAdmin.syncWarnStats() if callback then sAdmin.getActiveWarns(ply, callback) end end)
    query("UPDATE sadmin_player SET total_warns = total_warns + 1 WHERE sid64 = '"..sid64.."'", function() sAdmin.syncWarnStats("warns") end)
end

sAdmin.deleteWarn = function(id, callback)
    if !isnumber(tonumber(id)) then return end

    query("SELECT * FROM sadmin_warns WHERE id = "..id, function(result)
        local sid64 = result and result[1] and result[1].sid64
        result = tobool(result)

        callback(result)

        if result then
            query("DELETE FROM sadmin_warns WHERE id = "..id)
            query("UPDATE sadmin_player SET total_warns = total_warns - 1 WHERE sid64 = '"..sid64.."'")

            sAdmin.syncWarnStats("warns")
        end
    end)
end

sAdmin.setWarnInactive = function(id, callback)
    if !isnumber(tonumber(id)) then return end

    query("SELECT * FROM sadmin_warns WHERE id = "..id, function(result)
        result = tobool(result)

        if callback then callback(result) end

        if result then
            query("UPDATE sadmin_warns SET active = 0 WHERE id = "..id, function() sAdmin.syncWarnStats() end)
        end
    end)
end

sAdmin.updateActiveWarns = function(ply, callback)
    local sid64 = IsValid(ply) and ply:SteamID64() or escape_str(ply)

    query(string.format("SELECT * FROM sadmin_warns WHERE sid64 = '%s' AND active = 1", sid64), function(result)
        if result then
            local active_time = sAdmin.getTime(sAdmin.config["warns"]["active_time"])

            for k,v in ipairs(result) do
                local isActive = os.time() - v.date_given < active_time

                if !isActive then
                    query("UPDATE sadmin_warns SET active = 0 WHERE id = "..v.id)
                end
            end

            if callback then
                callback()
            end
        end
    end)
end

sAdmin.getActiveWarns = function(ply, callback)
    local sid64 = IsValid(ply) and ply:SteamID64() or escape_str(ply)
    
    query(string.format("SELECT * FROM sadmin_warns WHERE sid64 = '%s' AND active = 1", sid64), function(result)
        if result then
            local total = 0
            local active_time = sAdmin.getTime(sAdmin.config["warns"]["active_time"])
            for k,v in ipairs(result) do
                local isActive = os.time() - v.date_given < active_time

                if isActive then
                    total = total + 1
                else
                    query("UPDATE sadmin_warns SET active = 0 WHERE id = "..(v.id))
                end
            end

            if callback then
                callback(total)
            end
        end
    end)
end

local days = {
    ["Monday"] = 0,
    ["Tuesday"] = 1,
    ["Wednesday"] = 2,
    ["Thursday"] = 3,
    ["Friday"] = 4,
    ["Saturday"] = 5,
    ["Sunday"] = 6
}

function getDayStart(day_wanted)
    local time = os.time()
    local day = os.date("%A", time)
    local splitted_time = string.Explode(":", os.date("%H:%M:%S", time))

    local h, m, s = splitted_time[1], splitted_time[2], splitted_time[3]

    time = time - (h * 3600) - (m * 60) - s

    time = time - (days[day] - days[day_wanted]) * 86400

    return time
end

sAdmin.syncWarnStats = function(specific)
    local monday_unix = getDayStart("Monday")

    if !specific or specific == "warns" then
        query("SELECT * FROM sadmin_warns WHERE date_given >= "..monday_unix, function(result)
            if result then
                sAdmin.warnsData.warnsThisWeek = #result

                local days = {
                    [1] = {
                        compare = getDayStart("Monday"),
                        amount = 0
                    },
                    [2] = {
                        compare = getDayStart("Tuesday"),
                        amount = 0
                    },
                    [3] = {
                        compare = getDayStart("Wednesday"),
                        amount = 0
                    },
                    [4] = {
                        compare = getDayStart("Thursday"),
                        amount = 0
                    },
                    [5] = {
                        compare = getDayStart("Friday"),
                        amount = 0
                    },
                    [6] = {
                        compare = getDayStart("Saturday"),
                        amount = 0
                    },
                    [7] = {
                        compare = getDayStart("Sunday"),
                        amount = 0
                    }
                }

                for k,v in ipairs(result) do
                    for i = 7, 1, -1 do
                        if tonumber(v.date_given) >= days[i].compare then
                            days[i].amount = days[i].amount + 1
                        break end
                    end
                end

                for k,v in ipairs(days) do -- Clean the table up for networking!
                    days[k].compare = nil
                end

                sAdmin.warnsData.warnsChart = days

                sAdmin.queueNetworking(nil, function(ply)
                    sAdmin.networkData(ply, {"warnsData", "warnsThisWeek"}, sAdmin.warnsData.warnsThisWeek)
                end)

                sAdmin.queueNetworking(nil, function(ply)
                    sAdmin.networkData(ply, {"warnsData", "warnsChart"}, sAdmin.warnsData.warnsChart)
                end)
            end
        end)

        query("SELECT COUNT(id) FROM sadmin_warns", function(result)
            if result and result[1] and result[1]["COUNT(id)"] then
                sAdmin.warnsData.totalWarns = result[1]["COUNT(id)"]

                sAdmin.queueNetworking(nil, function(ply)
                    sAdmin.networkData(ply, {"warnsData", "totalWarns"}, sAdmin.warnsData.totalWarns)
                end)
            end
        end)
    end

    if !specific or specific == "punishments" then
        query("SELECT COUNT(id) FROM sadmin_punishments WHERE date_given >= "..monday_unix, function(result)
            if result and result[1] and result[1]["COUNT(id)"] then
                sAdmin.warnsData.punishmentsThisWeek = result[1]["COUNT(id)"] or 0
            end

            sAdmin.queueNetworking(nil, function(ply)
                sAdmin.networkData(ply, {"warnsData", "punishmentsThisWeek"}, sAdmin.warnsData.punishmentsThisWeek or 0)
            end)
        end)


        query("SELECT COUNT(id) FROM sadmin_punishments", function(result)
            if result and result[1] and result[1]["COUNT(id)"] then
                sAdmin.warnsData.totalPunishments = result[1]["COUNT(id)"] or 0

                sAdmin.queueNetworking(nil, function(ply)
                    sAdmin.networkData(ply, {"warnsData", "totalPunishments"}, sAdmin.warnsData.totalPunishments)
                end)
            end
        end)
    end
end

if sAdmin.config["storage_type"] == "sql_local" then
    hook.Run("sA:SQLConnected")
end