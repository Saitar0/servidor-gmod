local function followInheritance(result, tbl, current, name, next)
    if current[name] then return end
    current[name] = true
    current.index = current.index + 1
    local next = tbl[name].inherit_from

    result[name] = result[name] or {}
    result[name].permissions = result[name].permissions or {}

    if tbl[next or name].allow then
        for k, perm in ipairs(tbl[next or name].allow) do
            if !perm or perm == "" then continue end
            result[name].permissions[string.gsub(perm, "ulx ", "")] = ""
        end
    end

    if next then
        if current[next] then return end
        current[next] = true
    end

    followInheritance(result, tbl, current, name, next)
end

local function giveInheritancePower(tbl, from, result, name)
    if !name then return end

    if from[name] then
        for k,v in ipairs(from[name]) do
            result[#result + 1] = v
        end

        for k,v in ipairs(from[name]) do
            giveInheritancePower(tbl, from, result, v)
        end
    end
end

concommand.Add("sadmin_transfer", function(ply, cmd, args)
    if IsValid(ply) and !sAdmin.config["super_users"][ply:SteamID64()] then sAdmin.msg(ply, "requires_superuser") return end
    
    if args[1] == "ulx" then
        if !ULib or !ULib.parseKeyValues then if IsValid(ply) then sAdmin.msg(ply, "ulib_required") end return end
        local usergroups, bans, users = ULib.parseKeyValues(file.Read("ulib/groups.txt", "DATA") or ""), ULib.parseKeyValues(file.Read("ulib/bans.txt", "DATA") or ""), ULib.parseKeyValues(file.Read("ulib/users.txt", "DATA") or "") 
        local inheritance_from = {}

        for k,v in pairs(usergroups) do
            sAdmin.updateRank(k)
            if v.inherit_from then
                inheritance_from[v.inherit_from] = inheritance_from[v.inherit_from] or {}
                table.insert(inheritance_from[v.inherit_from], k)
            end

            sAdmin.usergroups[k] = sAdmin.usergroups[k] or {}
            sAdmin.usergroups[k].permissions = sAdmin.usergroups[k].permissions or {}
            for i, perm in ipairs(v.allow) do
                if !perm or perm == "" then continue end
                sAdmin.usergroups[k].permissions[string.gsub(perm, "ulx ", "")] = ""
            end

            followInheritance(sAdmin.usergroups, usergroups, {index = 1}, k)
        end

        for k,v in pairs(usergroups) do
            if !sAdmin.usergroups[k] or !istable(sAdmin.usergroups[k].permissions) then continue end
            for k,v in pairs(sAdmin.usergroups[k].permissions) do
                sAdmin.updatePermission(k, k, false, v)
            end
        end

        local inheritance = {"user"}
        giveInheritancePower(usergroups, inheritance_from, inheritance, "user")
        for k,v in ipairs(inheritance) do
            sAdmin.usergroups[v].permissions["immunity"] = k
        end

        for sid32,v in pairs(users) do
            local sid64 = util.SteamIDTo64(sid32)
            if sid64 then
                sid64 = sAdmin.escape_str(sid64)
            else continue end

            sAdmin.query("SELECT sid64 FROM sadmin_player WHERE sid64 = '"..sid64.."'", function(result)
                if result and result[1] then
                    sAdmin.updatePlayerRank(sid64, v.group)
                else
                    sAdmin.query("INSERT INTO sadmin_player(name, sid64, rank_name, rank_expire, playtime, online, staff) VALUES('"..sAdmin.escape_str(v.name).."', '"..sid64.."', '"..sAdmin.escape_str(v.group).."', 0, 0, 0, 0)")
                end
            end)
        end

        for k,v in pairs(bans) do
            local admin_sid32 = v.modified_admin or v.admin
            local adminsid_tbl = string.ToTable(admin_sid32)
            
            admin_sid32 = ""

            for i = #adminsid_tbl, 1, -1 do
                if adminsid_tbl[i] == ")" then continue end
                if adminsid_tbl[i] == "(" then break end
                admin_sid32 = adminsid_tbl[i]..admin_sid32
            end

            local bannedsid64 = util.SteamIDTo64(k)

            sAdmin.addBan(bannedsid64, (v.modified_time or v.time) - os.time(), v.reason, util.SteamIDTo64(admin_sid32))
        end

        if IsValid(ply) then sAdmin.msg(ply, "successful_transfer") end
    elseif args[1] == "sam" then
        sAdmin.query("SELECT * FROM sam_players", function(result)
            for k,v in ipairs(result) do
                local sid64 = util.SteamIDTo64(v.steamid)
                
                if sid64 then
                    sid64 = sAdmin.escape_str(sid64)
                else continue end

                local name, rank, rank_expire, playtime = sAdmin.escape_str(v.name), sAdmin.escape_str(v.rank), tonumber(v.expiry_date) or 0, tonumber(v.play_time) or 0
                local is_staff = (sAdmin.usergroups[rank] and sAdmin.usergroups[rank].permissions and sAdmin.usergroups[rank].permissions["is_staff"]) and 1 or 0
                
                if !isnumber(rank_expire) or !isnumber(playtime) then continue end

                sAdmin.query("SELECT sid64 FROM sadmin_player WHERE sid64 = '"..sid64.."'", function(result)
                    if result and result[1] then
                        sAdmin.query("UPDATE sadmin_player SET name = '"..name.."', rank_name = '"..rank.."', rank_expire = "..rank_expire..", playtime = "..playtime..", staff = "..is_staff.." WHERE sid64 = '"..sid64.."'")
                    else
                        sAdmin.query("INSERT INTO sadmin_player(name, sid64, rank_name, rank_expire, playtime, online, staff) VALUES('"..name.."', '"..sid64.."', '"..rank.."', "..rank_expire..", "..playtime..", 0, "..is_staff..")")
                    end
                end)
            end
        end)

        sAdmin.query("SELECT * FROM sam_ranks", function(result)
            if result and result[1] then
                for k,v in ipairs(result) do
                    local data = v
                    sAdmin.updateRank(data.name)

                    local perms = util.JSONToTable(data.data)
        
                    for k,v in pairs(perms.permissions) do
                        sAdmin.updatePermission(data.name, k, false, v)
                    end
                end
            end
        end)

        sAdmin.query("SELECT * FROM sam_bans", function(result)
            if result and result[1] then
                for k,v in ipairs(result) do
                    local sid64 = util.SteamIDTo64(v.steamid)
                    local adminsid64 = util.SteamIDTo64(v.admin)
                    local unban_date = tonumber(v.unban_date) or 0
                    local timeLeft = unban_date > 0 and unban_date - os.time() or 0
                    sAdmin.addBan(sid64, timeLeft, v.reason, adminsid64)
                end
            end

            if IsValid(ply) then sAdmin.msg(ply, "successful_transfer") end
        end)
    elseif args[1] == "xadmin2" then
        local xadmin_terms = {
            ["xadminallperms"] = "all_perms",
            ["physgunplayer"] = "phys_players"
        }
        sAdmin.query("SELECT * FROM xadmin_usergroups", function(result)
            local sid64, rank = sAdmin.escape_str(v.SteamID), sAdmin.escape_str(v.UserGroup)
            sAdmin.query("SELECT sid64 FROM sadmin_player WHERE sid64 = '"..sid64.."'", function(result)
                if result and result[1] then
                    sAdmin.updatePlayerRank(sid64, rank)
                else
                    local is_staff = (sAdmin.usergroups[rank] and sAdmin.usergroups[rank].permissions and sAdmin.usergroups[rank].permissions["is_staff"]) and 1 or 0
                    sAdmin.query("INSERT INTO sadmin_player(name, sid64, rank_name, rank_expire, playtime, online, staff) VALUES('N/A', '"..sid64.."', '"..rank.."', 0, 0, 0, "..is_staff..")")
                end
            end)
        end)

        sAdmin.query("SELECT * FROM xadmin_bansdata", function(result)
            if result and result[1] then
                for k,v in ipairs(result) do
                    local sid64 = util.SteamIDTo64(v.steamid)
                    local timeLeft = v.Length > 0 and (v.StartTime + v.Length) - os.time() or 0
                    sAdmin.addBan(v.SteamID, timeLeft, v.Reason, v.Admin)
                end
            end
        end)

        sAdmin.query("SELECT * FROM xadmin_groupsdata", function(result)
            if result and result[1] then
                for k,v in ipairs(result) do
                    sAdmin.updateRank(v.ID)

                    local perms = util.JSONToTable(v.Permissions)
                    
                    sAdmin.updatePermission(v.ID, "immunity", false, v.Power)
                    for k,v in pairs(perms) do
                        sAdmin.updatePermission(v.ID, xadmin_terms[v] or v, false, true)
                    end
                end
            end

            if IsValid(ply) then sAdmin.msg(ply, "successful_transfer") end
        end)
    elseif args[1] == "local_sadmin" then
        if IsValid(ply) then sAdmin.msg(ply, "trasferring_please_be_patient") end
        
        local players = sql.Query( "SELECT * FROM sadmin_player")

        for k,v in ipairs(players or {}) do
            sAdmin.query(string.format([[INSERT INTO sadmin_player(name, sid64, rank_name, rank_expire, playtime, online, staff, total_warns) VALUES('%s','%s','%s',%s,%s,%s,%s,%s)]], sAdmin.escape_str(v.name), v.sid64, sAdmin.escape_str(v.rank or v.rank_name), tonumber(v.rank_expire) or 0, tonumber(v.playtime) or 0, tonumber(v.online) or 0, tonumber(v.staff) or 0, tonumber(v.total_warns) or 0))
        end

        local ranks = sql.Query( "SELECT * FROM sadmin_ranks")
        
        for k,v in ipairs(ranks or {}) do
            sAdmin.query(string.format([[INSERT INTO sadmin_ranks(rank_name) VALUES('%s')]], sAdmin.escape_str(v.rank or v.rank_name)))
        end
        
        local perms = sql.Query( "SELECT * FROM sadmin_permissions")
        
        for k,v in ipairs(perms or {}) do
            sAdmin.query(string.format([[INSERT INTO sadmin_permissions(rank_name, permission, value) VALUES('%s', '%s', %s)]], sAdmin.escape_str(v.rank or v.rank_name), sAdmin.escape_str(v.permission), tonumber(v.value) or 0))
        end
        
        local bans = sql.Query( "SELECT * FROM sadmin_bans")
        
        for k,v in ipairs(bans or {}) do
            sAdmin.query(string.format([[INSERT INTO sadmin_bans(sid64, admin_sid64, expiration, reason) VALUES('%s', '%s', '%s', '%s')]],
            v.sid64, v.admin_sid64, tonumber(v.expiration) or 0, sAdmin.escape_str(v.reason)))
        end
    
        local warns = sql.Query( "SELECT * FROM sadmin_warns")
        
        for k,v in ipairs(warns or {}) do
            sAdmin.query(string.format([[INSERT INTO sadmin_warns(sid64, admin_sid64, date_given, active, reason) VALUES('%s', '%s', %s, %s, '%s')]],
            v.sid64, v.admin_sid64, tonumber(v.date_given) or 0, tonumber(v.active) or 0, sAdmin.escape_str(v.reason)))
        end
        
        local punishments = sql.Query( "SELECT * FROM sadmin_punishments")
        
        for k,v in ipairs(punishments or {}) do
            sAdmin.query(string.format([[INSERT INTO sadmin_punishments(sid64, name, date_given, action, active_warns) VALUES('%s', '%s', %s, %s, %s)]],
            v.sid64, sAdmin.escape_str(v.name), tonumber(v.date_given) or 0, tonumber(v.action) or 0, tonumber(v.active_warns) or 0))
        end
        
        local paramlimitations = sql.Query( "SELECT * FROM sadmin_paramlimitations")
        
        for k,v in ipairs(paramlimitations or {}) do
            sAdmin.query(string.format([[INSERT INTO sadmin_paramlimitations(rank_name, name, param_id, min_limit, max_limit) VALUES('%s', '%s', %s, %s, %s)]],
            sAdmin.escape_str(v.rank or v.rank_name), sAdmin.escape_str(v.name), tonumber(v.param_id) or 0, tonumber(v.min_limit) or 0, tonumber(v.max_limit) or 0))
        end

        if IsValid(ply) then sAdmin.msg(ply, "successful_transfer") end
    end
end)