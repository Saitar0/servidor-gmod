sAdmin = sAdmin or {}

sAdmin.getTargets = function(cmd, ply, str, max, silent, forced_immunity)
    local cmd_data = sAdmin.commands[cmd]
    local ignoreImmunity = forced_immunity == true or sAdmin.config["ignore_immunity_cmds"][cmd]
    local rank = IsValid(ply) and ply:GetUserGroup()
    local limit_data = rank and sAdmin.ParameterLimitations[cmd] and sAdmin.ParameterLimitations[cmd][rank]
    local min_immunity

    if limit_data and cmd_data and cmd_data.inputs and istable(cmd_data.inputs) then
        for k, v in ipairs(cmd_data.inputs) do
            local limit = limit_data[k] or limit_data[tostring(k)]

            if v[1] == "player" and istable(limit) then

                if tonumber(limit.max) or 0 > 0 then
                    forced_immunity = limit.max
                end

                if tonumber(limit.min) or 0 > 0 then
                    min_immunity = limit.min
                end
            end
        end
    end

    local everyone = false

    if str == "*" then
        everyone = true
    end

    local targets = {}

    if str then
        if IsValid(ply) then
            if str == "@" then
                local along_ray = ents.FindAlongRay(ply:EyePos(), ply:GetAimVector() * 10000000)
                local found_plys = {}

                for k,v in ipairs(along_ray) do
                    if v != ply and v:IsPlayer() then
                        table.insert(found_plys, v)
                    end
                end
                
                local nearest_dist, nearest_ply = math.huge
                for k,v in ipairs(found_plys) do
                    local dist = v:GetPos():DistToSqr(ply:GetPos())

                    if dist < nearest_dist then
                        nearest_dist, nearest_ply = dist, v
                    end
                end


                if nearest_ply and IsValid(nearest_ply) and (sAdmin.canTarget(ply, nearest_ply, ignoreImmunity, min_immunity, forced_immunity)) then return {nearest_ply} end
            end

            if str == "^" then return {ply} end
        end

        for k,v in ipairs(player.GetAll()) do
            if (IsValid(ply) and !sAdmin.canTarget(ply, v, ignoreImmunity, min_immunity, forced_immunity)) then continue end
            if everyone or string.find(string.lower(v:Nick()), string.PatternSafe(string.lower(str))) or str == v:SteamID() or str == v:SteamID64() then
                table.insert(targets, v)
            end
        end
    else
        if ply then
            table.insert(targets, ply)
        end
    end

    if max and #targets > max then
        if !silent then
            sAdmin.msg(ply, "too_many_targets")
        end

        return {}
    end

    if table.IsEmpty(targets) then
        sAdmin.msg(ply, "no_targets")
    end

    return targets
end