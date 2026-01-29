sAdmin = sAdmin or {}
sAdmin.limits = sAdmin.limits or {}
sAdmin.timeUnderstandings = sAdmin.timeUnderstandings or {}

local understandings = {
    ["y"] = 31556926,
    ["mo"] = 2629743.83,
    ["w"] = 604800,
    ["d"] = 86400,
    ["h"] = 3600,
    ["m"] = 60,
    ["s"] = 1
}

sAdmin.formatTime = function(num, na)
    num = tonumber(num)
    if !isnumber(num) or (num == 0 and na) then return "N/A" end

    if num == 0 then return slib.getLang("sadmin", sAdmin.config["language"], "eternity") end

    local y = math.floor(num / understandings["y"])
    num = num - (y * understandings["y"])
    local mo = math.floor(num / understandings["mo"])
    num = num - (mo * understandings["mo"])
    local w = math.floor(num / understandings["w"])
    num = num - (w * understandings["w"])
    local d = math.floor(num / understandings["d"])
    num = num - (d * understandings["d"])
    local h = math.floor(num / understandings["h"])
    num = num - (h * understandings["h"])
	local m = math.floor(( num / 60 ) % 60)
    num = num - (m * understandings["m"])
    local s = num

    local str, varargs = "", {}
    if y > 0 then
        str = str.." %i"..slib.getLang("sadmin", sAdmin.config["language"], "time_y")
        table.insert(varargs, y)
    end

    if mo > 0 then
        str = str.." %i"..slib.getLang("sadmin", sAdmin.config["language"], "time_mo")
        table.insert(varargs, mo)
    end

    if w > 0 then
        str = str.." %i"..slib.getLang("sadmin", sAdmin.config["language"], "time_w")
        table.insert(varargs, w)
    end

    if d > 0 then
        str = str.." %i"..slib.getLang("sadmin", sAdmin.config["language"], "time_d")
        table.insert(varargs, d)
    end

    if h > 0 then
        str = str.." %i"..slib.getLang("sadmin", sAdmin.config["language"], "time_h")
        table.insert(varargs, h)
    end

    if m > 0 then
        str = str.." %i"..slib.getLang("sadmin", sAdmin.config["language"], "time_m")
        table.insert(varargs, m)
    end

    if s > 0 then
        str = str.." %i"..slib.getLang("sadmin", sAdmin.config["language"], "time_s")
        table.insert(varargs, s)
    end

    str = string.sub(str, 2, #str)

	return string.format(str, unpack(varargs))
end

sAdmin.isTime = function(str)
    return understandings[str[#str - 1]..str[#str]] or understandings[str[#str]] or false
end

sAdmin.addTimeUnderstandings = function(lang, y, mo, w, d, h, m, s)
    sAdmin.timeUnderstandings[lang] = {
        [y] = "y",
        [mo] = "mo",
        [w] = "w",
        [d] = "d",
        [h] = "h",
        [m] = "m",
        [s] = "s"
    }

    slib.setLang("sadmin", lang, "time_y", y)
    slib.setLang("sadmin", lang, "time_mo", mo)
    slib.setLang("sadmin", lang, "time_w", w)
    slib.setLang("sadmin", lang, "time_d", d)
    slib.setLang("sadmin", lang, "time_h", h)
    slib.setLang("sadmin", lang, "time_m", m)
    slib.setLang("sadmin", lang, "time_s", s)

    hook.Run("sA:ConfigReloaded")
end

sAdmin.getTime = function(args, start)
    if !args then return 0 end
    if isnumber(args) then return args end
    if isstring(args) then
        args = string.Explode(" ", args)
        start = 1
    end

    local fullnum = 0
    for i = start,#args do
        if !sAdmin.timeUnderstandings[sAdmin.config["language"]] then break end
        local str = args[i]

        local isNumber = tonumber(str)

        if isNumber then
            fullnum = fullnum + isNumber
        continue end
        
        local strTbl = string.ToTable(str)
        if table.IsEmpty(strTbl) then continue end
        local multiplier, size
        local doubles = #strTbl > 2 and strTbl[#strTbl - 1]..strTbl[#strTbl] or ""

        if understandings[sAdmin.timeUnderstandings[sAdmin.config["language"]][doubles]] then
            multiplier = understandings[sAdmin.timeUnderstandings[sAdmin.config["language"]][doubles]]
            size = 2
        else
            multiplier = understandings[sAdmin.timeUnderstandings[sAdmin.config["language"]][strTbl[#strTbl]]]
            size = 1
        end
        
        if multiplier then
            local num = tonumber(string.sub(str, 1, #str - size))
            if !num then continue end

            fullnum = fullnum + (num * multiplier)
        end
    end

    return fullnum
end

sAdmin.registerCAMIGroup = function(usergroup)
    if !CAMI or !CAMI.RegisterUsergroup then return end
    local data = sAdmin.usergroups[usergroup]
    if !data then return end
    local inherit = "user"
    local immunity = data.permissions and tonumber(data.permissions["immunity"]) or 0
    local admin_Immunity = sAdmin.usergroups["admin"] and sAdmin.usergroups["admin"].permissions and sAdmin.usergroups["admin"].permissions.immunity and tonumber(sAdmin.usergroups["admin"].permissions.immunity) or 0
    local superadmin_Immunity = sAdmin.usergroups["superadmin"] and sAdmin.usergroups["superadmin"].permissions and sAdmin.usergroups["superadmin"].permissions.immunity and tonumber(sAdmin.usergroups["superadmin"].permissions.immunity) or 0

    if immunity >= superadmin_Immunity then
        inherit = "superadmin"
    elseif immunity >= admin_Immunity then
        inherit = "admin"
    end

    CAMI.RegisterUsergroup({Name = usergroup, Inherits = inherit}, "sAdmin")
end

local stringExplode = function(str)
    local curStr, result, tbl, skip = "", {}, string.ToTable(str), {}

    for k,v in ipairs(tbl) do
        if skip[k] then continue end
        if v == "%" and (tbl[k + 1] == "s" or tbl[k + 1] == "t") then
            if curStr ~= "" then
                
                table.insert(result, curStr)
                curStr = ""
            end

            table.insert(result, tbl[k + 1] == "s" and "" or "%t")
            skip[k + 1] = true
        continue end

        curStr = curStr..v

        if #tbl <= k then
            table.insert(result, curStr)
        end
    end

    return result
end

local calledYou = false

local convertPlayers = function(tbl)
    local result = {}

    if istable(tbl) then
        for k,v in ipairs(tbl) do
            if k >= 3 then
                table.insert(result, color_white)
                table.insert(result, slib.getLang("sadmin", sAdmin.config["language"], "and_others", #tbl - k + 1))
            break end

            local ply = Entity(v.index)
            local isYou = ply == (CLIENT and LocalPlayer() or false)
            local teamColor = IsValid(ply) and team.GetColor(ply:Team())
            local nick = isYou and (!calledYou and slib.getLang("sadmin", sAdmin.config["language"], "you") or slib.getLang("sadmin", sAdmin.config["language"], "yourself")) or ply:IsPlayer() and ply:Nick() or v.nick or slib.getLang("sadmin", sAdmin.config["language"], "console")

            if isYou then calledYou = true end
            
            if k > 1 then
                table.insert(result, color_white)
                table.insert(result, #tbl <= k and " & " or ", ")
            end

            table.insert(result, isYou and (teamColor or sAdmin.config["colors"]["orange_ply"]) or (teamColor or sAdmin.config["colors"]["red_ply"]))
            table.insert(result, nick)
        end
    else
        result = tbl
    end

    return result
end

sAdmin.niceDisplayText = function(var, info)
    calledYou = false
    local result = {}

    for k,v in ipairs(info) do
        if istable(v) and v.hasPlayer then
            info[k] = convertPlayers(v)
        continue end

        info[k] = tostring(v)
    end

    local preSeperator = slib.getLang("sadmin", sAdmin.config["language"], var)
    local final = {}

    local seperated = stringExplode(preSeperator)

    local infoIterator = 1

    for k,v in ipairs(seperated) do
        if (v == "" or v == "%t") and info[infoIterator] then
            local isTime = v == "%t"
            table.insert(final, sAdmin.config["colors"]["green_ply"])
            if istable(info[infoIterator]) then
                for k,v in ipairs(info[infoIterator]) do
                    table.insert(final, isTime and string.lower(sAdmin.formatTime(v)) or v)
                end
            else
                table.insert(final, isTime and string.lower(sAdmin.formatTime(info[infoIterator])) or info[infoIterator])
            end
            
            infoIterator = infoIterator + 1
        else
            table.insert(final, color_white)
            table.insert(final, v)
        end
    end

    return final
end

sAdmin.convertSID64 = function(sid64)
    local sid
    
    if #sid64 == 17 then
        sid = util.SteamIDFrom64(sid64)
    else
        sid64 = util.SteamIDTo64(sid64)
    end

    return sid64, sid
end

sAdmin.canTarget = function(ply, target, ignore_immunity, min_immunity, max_immunity)
    local ply_immunity, target_immunity, min_immunity, max_immunity = tonumber(sAdmin.hasPermission(ply, "immunity")) or 0, tonumber(sAdmin.hasPermission(target, "immunity")) or 0, tonumber(min_immunity) or 0, tonumber(max_immunity) or 0
    min_immunity, max_immunity = min_immunity <= 0 and nil, max_immunity <= 0 and nil

    return sAdmin.config["super_users"][ply:SteamID64()] or ignore_immunity or (ply_immunity >= target_immunity and (!min_immunity or target_immunity >= min_immunity) and (!max_immunity or target_immunity <= max_immunity))
end

if SERVER then
    sAdmin.Gamemodes, sAdmin.Maps = {}, {}

    local maps = file.Find("maps/*.bsp", "GAME")

    for k,v in ipairs(maps) do
        table.insert(sAdmin.Maps, string.sub(v, 1, #v - 4))
    end

    for k,v in ipairs(engine.GetGamemodes()) do
        table.insert(sAdmin.Gamemodes, v.name)
    end

    hook.Add("slib.FullLoaded", "sA:NetworkGamemodes", function(ply)
        sAdmin.networkData(ply, {"Gamemodes"}, sAdmin.Gamemodes)
        sAdmin.networkData(ply, {"Maps"}, sAdmin.Maps)
        sAdmin.networkData(ply, {"limits"}, sAdmin.limits)
    end)

    hook.Add("PostGamemodeLoaded", "sA:AddLimits", function()
        for k, v in ipairs(cleanup.GetTable(), true) do
            if GetConVar("sbox_max"..v) then
                table.insert(sAdmin.limits, v)
                sAdmin.limits[v] = true
            end
        end
    
        local meta = FindMetaTable("Player")
    
        if !meta.sAdmin_OldCheckLimit then
            meta.sAdmin_OldCheckLimit = meta.CheckLimit
        end
        
        function meta:CheckLimit(type)
            if !sAdmin.limits[type] then return self:sAdmin_OldCheckLimit(type) end
            local rank = self:GetUserGroup()
            local limit = tonumber(sAdmin.usergroups[rank] and sAdmin.usergroups[rank].permissions and sAdmin.usergroups[rank].permissions[type] or GetConVar("sbox_max"..type):GetInt()) or -1
            local result = limit == -1 or self:GetCount(type) < limit
            
            if !result then
                sAdmin.msg(self, "reached_limit", type)
            end
        
            return result
        end
    end)
end

sAdmin.GetGamemodes = function()
    return sAdmin.Gamemodes
end

sAdmin.GetMaps = function()
    return sAdmin.Maps
end

sAdmin.GetRanks = function()
    local usergroups = {}
    
    for k,v in pairs(sAdmin.usergroups) do
        table.insert(usergroups, k)    
    end

    return usergroups
end

local function addAdvertTimers()
    if SERVER or !sAdmin.config["adverts"] then return end
    for k,v in ipairs(sAdmin.config["adverts"]) do
        timer.Simple(v.offset or 0, function()
            timer.Create("sAdmin_advert:"..k, sAdmin.getTime(v.time), 0, function()
                local fullTbl = {}

                for k,v in ipairs(v.msg) do
                    table.insert(fullTbl, isfunction(v) and tostring(v()) or v)
                end

                chat.AddText(unpack(fullTbl))
            end)
        end)
    end
end

addAdvertTimers()

hook.Add("sA:ConfigReloaded", "sA:ReloadAdverts", addAdvertTimers)