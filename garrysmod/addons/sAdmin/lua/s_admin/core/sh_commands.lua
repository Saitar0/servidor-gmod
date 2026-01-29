sAdmin = sAdmin or {}
sAdmin.commands = sAdmin.commands or {}
sAdmin.permissions = sAdmin.permissions or {}
sAdmin.abbreviations = sAdmin.abbreviations or {}

local index = 0
sAdmin.addCommand = function(data)
    if sAdmin.config["disabled_modules"][data.category] then return end

    index = index + 1
    sAdmin.commands[data.name] = {
        category = data.category,
        func = data.func,
        inputs = data.inputs,
        index = index
    }

    if data.abbreviation then
        for k,v in ipairs(data.abbreviation) do
            sAdmin.abbreviations[v] = data.name
        end
    end

    sAdmin.registerPermission(data.name, data.category)
end

sAdmin.runCommand = function(ply, name, args, silent)
    if !name then return end
    
    name = string.lower(name)
    local data = sAdmin.commands[name]
    if !data then return end
    
    local canRun = hook.Run("sA:RunCommand", ply, name, args)
    if canRun == false then return end

    if IsValid(ply) and !sAdmin.hasPermission(ply, name) then
        sAdmin.msg(ply, "no_permission", name)
    return end

    if canRun == nil then data.func(ply, args, silent == true) end
    
    local argsStr = ""

    local argCount = #args
    for k,v in ipairs(args) do
        argsStr = argsStr..v..(k >= argCount and "" or ", ")
    end
    
    if argsStr == "" then argsStr = slib.getLang("sadmin", sAdmin.config["language"], "n/a") end

    hook.Run("sA:RanCommand", ply, name, args, argsStr)
    if sAdmin.config["console_prints"]["attempt_call"] then
        MsgC(sAdmin.config["chat_prefix"][1], sAdmin.config["chat_prefix"][2], sAdmin.config["colors"]["green_ply"], IsValid(ply) and ply:Nick() or slib.getLang("sadmin", sAdmin.config["language"], "console"), color_white, " "..slib.getLang("sadmin", sAdmin.config["language"], "ran_command").." ", sAdmin.config["colors"]["orange_ply"], name, color_white, " "..slib.getLang("sadmin", sAdmin.config["language"], "with_args").." [", sAdmin.config["colors"]["orange_ply"],argsStr, color_white, "]\n")
    end
end

local function autoComplete(ply, cmd)
    local alternatives = {}

    local base = "sa "
    cmd = string.gsub(cmd, " ", "", 1)

    local args = string.Split(cmd, " ")
    local command = args[1]
    if sAdmin.commands[command] then
        if args[2] then
            if sAdmin.commands[command].inputs[1][1] == "player" then
                for k, v in ipairs(player.GetAll()) do
                    local nick = v:Nick()

                    if !string.find(string.lower(nick), string.lower(args[2])) then continue end
                    table.insert(alternatives, base..command..' "'..nick..'"')
                end
            end
        else
            table.insert(alternatives, base..command)
        end
    else
        for name,v in pairs(sAdmin.commands) do
            if command and !string.find(string.lower(name), string.lower(command)) then continue end

            table.insert(alternatives, base..name)
        end
    end

    local cmd_data = sAdmin.commands[string.lower(command)]
    if cmd_data and !args[2] then
        local params = ""

        if cmd_data.inputs then
            for k, type in ipairs(cmd_data.inputs) do
                params = params.." ["..slib.getLang("sadmin", sAdmin.config["language"], type[2] or type[1]).."]"
            end
        end
    end

    return alternatives
end

local function hasEndQuote(iteration, tbl)
    local full_str = ""

    for i = iteration + 1, #tbl do
        local str = tbl[i]

        full_str = full_str..str

        if tbl[i] == '"' then return true, string.sub(full_str, 1, #full_str - 1), i + 2 end
    end

    return false, "", 0
end

local function getArgs(arg_str)
    local args = {}
    local exploded = string.ToTable(arg_str)

    local cur_str = ""
    local nextIterate = 0

    for k,v in ipairs(exploded) do
        if nextIterate > k then continue end

        if v == '"' then
            local isQuote, addStr, continueIterate = hasEndQuote(k, exploded)
            nextIterate = continueIterate

            if isQuote then
                table.insert(args, addStr)
            end
        else
            if v != " " then
                cur_str = cur_str..v 
            end
        end

        if v == " " or k == #exploded then table.insert(args, cur_str) cur_str = "" continue end
    end

    return args
end

if SERVER then
    local cmd_func = function(ply, cmd, args, silent)
        local name = args[1]

        table.remove(args, 1)

        local param_limited, max_limit, is_min_limited = false
        local cmd_data = sAdmin.commands[name]
        local rank = IsValid(ply) and ply:GetUserGroup()

        if rank and sAdmin.ParameterLimitations[name] and sAdmin.ParameterLimitations[name][rank] and istable(sAdmin.ParameterLimitations[name][rank]) then
            for k, v in ipairs(cmd_data.inputs) do
                local limit = sAdmin.ParameterLimitations[name][rank][k] or sAdmin.ParameterLimitations[name][rank][tostring(k)]

                if !istable(limit) or !isnumber(limit.min) or !isnumber(limit.max) then continue end

                local limit_type = cmd_data.inputs and cmd_data.inputs[k]

                if !limit_type then continue end

                if limit_type[1] == "player" then continue end

                local val = (tonumber(args[k]) or 0)

                if limit_type[1] == "time" then
                    val = sAdmin.getTime(args, k)
                    
                    if (val == 0 or !val) then
                        param_limited = true
                        max_limit = sAdmin.formatTime(val)
                    break end
                end

                if (limit.min > 0 and val < limit.min) or (limit.max > 0 and val > limit.max) then
                    param_limited = true
                    max_limit = limit_type[1] == "time" and (val < limit.min and sAdmin.formatTime(limit.min) or sAdmin.formatTime(limit.max)) or (val < limit.min and limit.min or limit.max)

                    is_min_limited = val < limit.min
                break end
            end
        end

        if param_limited then sAdmin.msg(ply, is_min_limited == nil and "limited_parameter_limits" or (is_min_limited and "limited_parameter_limits_min" or "limited_parameter_limits_max"), max_limit) return end

        sAdmin.runCommand(ply, name, args, silent)
    end

    local command = function(ply, cmd, _, arg_str)
        local args = getArgs(arg_str)

        cmd_func(ply, cmd, args)
    end

    concommand.Add("sa_cmd", command)
    concommand.Add("sa", command)

    local silent_command = function(ply, cmd, _, arg_str)
        if !sAdmin.hasPermission(ply, "silent") then
            sAdmin.msg(ply, "no_permission", slib.getLang("sadmin", sAdmin.config["language"], "silent"))
        return end

        local args = getArgs(arg_str)
        cmd_func(ply, cmd, args, true)
    end

    concommand.Add("sa_cmd_silent", silent_command)
    concommand.Add("sa_silent", silent_command)
else
    concommand.Add("sa", function(ply, _, _, arg_str) ply:ConCommand("sa_cmd "..arg_str) end, autoComplete)
    concommand.Add("sa_silent", function(ply, _, _, arg_str) ply:ConCommand("sa_cmd_silent "..arg_str) end, autoComplete)
end