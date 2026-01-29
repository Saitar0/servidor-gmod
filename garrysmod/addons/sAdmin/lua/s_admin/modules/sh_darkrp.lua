hook.Add("PostGamemodeLoaded", "sA:LoadDarkRP", function()
    if !DarkRP then return end
    
    sAdmin.addCommand({
        name = "arrest",
        category = "DarkRP",
        inputs = {{"player", "player_name"}, {"time"}},
        func = function(ply, args, silent)
            local targets = sAdmin.getTargets("arrest", ply, args[1])
            local time = sAdmin.getTime(args, 2)

            for k,v in ipairs(targets) do
                v:arrest(time)
            end

            sAdmin.msg(silent and ply or nil, "arrest_response", ply, targets, time)
        end
    })

    sAdmin.addCommand({
        name = "unarrest",
        category = "DarkRP",
        inputs = {{"player", "player_name"}},
        func = function(ply, args, silent)
            local targets = sAdmin.getTargets("unarrest",ply, args[1])

            for k,v in ipairs(targets) do
                v:unArrest()
            end

            sAdmin.msg(silent and ply or nil, "unarrest_response", ply, targets)
        end
    })

    sAdmin.addCommand({
        name = "setmoney",
        category = "DarkRP",
        inputs = {{"player", "player_name"}, {"numeric", "amount"}},
        func = function(ply, args, silent)
            local targets = sAdmin.getTargets("setmoney", ply, args[1], 1)
            local amount = tonumber(args[2]) or 0

            for k,v in ipairs(targets) do
                local oldMoney = v:getDarkRPVar("money")
                v:addMoney(-oldMoney + amount)
            end

            sAdmin.msg(silent and ply or nil, "setmoney_response", ply, targets, amount)
        end
    })

    sAdmin.addCommand({
        name = "setname",
        category = "DarkRP",
        inputs = {{"player", "player_name"}, {"text", "name"}},
        func = function(ply, args, silent)
            local targets = sAdmin.getTargets("setname", ply, args[1], 1)
            local name = args[2]

            for k,v in ipairs(targets) do
                v:setRPName(name)
            end

            sAdmin.msg(silent and ply or nil, "setname_response", ply, targets, name)
        end
    })

    sAdmin.addCommand({
        name = "addmoney",
        inputs = {{"player", "player_name"}, {"numeric", "amount"}},
        category = "DarkRP",
        func = function(ply, args, silent)
            local targets = sAdmin.getTargets("addmoney", ply, args[1])
            local amount = tonumber(args[2]) or 0

            for k,v in ipairs(targets) do
                v:addMoney(amount)
            end

            sAdmin.msg(silent and ply or nil, "addmoney_response", ply, amount, targets)
        end
    })

    sAdmin.addCommand({
        name = "selldoor",
        category = "DarkRP",
        func = function(ply, args, silent)
            local door = ply:GetEyeTrace().Entity

            if !door:isDoor() then return end
            local owner = door:getDoorOwner()
            door:keysUnOwn(owner)

            sAdmin.msg(silent and ply or nil, "selldoor_response", ply)
        end
    })

    sAdmin.addCommand({
        name = "sellall",
        category = "DarkRP",
        inputs = {{"player", "player_name"}},
        func = function(ply, args, silent)
            local targets = sAdmin.getTargets("sellall", ply, args[1], 1)

            for k,v in ipairs(targets) do
                v:keysUnOwnAll()
            end

            sAdmin.msg(silent and ply or nil, "sellall_response", ply, targets)
        end
    })

    sAdmin.addCommand({
        name = "setjailpos",
        category = "DarkRP",
        func = function(ply, args, silent)
            DarkRP.setJailPos(ply:GetPos())

            sAdmin.msg(silent and ply or nil, "setjailpos_response", ply)
        end
    })

    sAdmin.addCommand({
        name = "addjailpos",
        category = "DarkRP",
        func = function(ply, args, silent)
            DarkRP.addJailPos(ply:GetPos())

            sAdmin.msg(silent and ply or nil, "addjailpos_response", ply)
        end
    })

    sAdmin.addCommand({
        name = "setjob",
        category = "DarkRP",
        inputs = {{"player", "player_name"}, {"text", "job"}},
        func = function(ply, args, silent)
            local targets, job = sAdmin.getTargets("setjob", ply, args[1], 1), string.lower(args[2])
            local actualJob


            for k, target in ipairs(targets) do
                for index, v in ipairs(RPExtraTeams) do
                    if string.find(string.lower(v.name), job) or string.find(string.lower(v.command), job) then
                        actualJob = v.name
                        target:changeTeam(index, true, true)
                        break
                    end
                end
            end
            
            if actualJob then
                sAdmin.msg(silent and ply or nil, "setjob_response", ply, targets, actualJob)
            end
        end
    })

    sAdmin.jobBans = sAdmin.jobBans or {}

    local updateJobBanSave = function(sid64)
        file.CreateDir("sadmin/jobban")

        file.Write("sadmin/jobban/"..sid64..".json", util.TableToJSON(sAdmin.jobBans[sid64]))
    end

    local jobBan = function(ply, job, time)
        local sid64, finishTime = ply:SteamID64(), os.time() + time
        local timerIdentifier = "sA:JobBanning:"..sid64

        sAdmin.jobBans[sid64] = sAdmin.jobBans[sid64] or {}
        sAdmin.jobBans[sid64][job] = finishTime

        if ply:Team() == job then
            ply:changeTeam(1)
        end

        updateJobBanSave(sid64)
    end

    local jobUnban = function(ply, job)
        local sid64 = ply:SteamID64()

        if sAdmin.jobBans[sid64] then
            sAdmin.jobBans[sid64][job] = nil

            updateJobBanSave(sid64)
        end
    end

    hook.Add("playerCanChangeTeam", "sA:JobBanning", function(ply, team, force)
        local sid64 = ply:SteamID64()
        
        if sAdmin.jobBans[sid64] and sAdmin.jobBans[sid64][team] then
            local finishTime = sAdmin.jobBans[sid64][team]

            if finishTime - os.time() > 0 then
                sAdmin.silentMsg(ply, "jobbanned_response", RPExtraTeams[team].name,  math.max(finishTime - os.time(), 0))

                return false
            else
                jobUnban(ply, team)
            end
        end
    end)

    hook.Add("canStartVote", "sA:JobBanning", function(vote)
        if vote and vote.votetype == "job" and IsValid(vote.target) and (vote.info and vote.info.targetTeam) then
            local ply = vote.target
            local sid64 = ply:SteamID64()
            local team = vote.info and vote.info.targetTeam

            if team and sAdmin.jobBans[sid64] and sAdmin.jobBans[sid64][team] then 
                return false, true -- This will skip the vote and then get cancelled by the "playerCanChangeTeam" hook
            end
        end
    end)

    hook.Add("slib.FullLoaded", "sA:LoadJobBans", function(ply)
        local sid64 = ply:SteamID64()

        local jobBansSave = file.Read("sadmin/jobban/"..sid64..".json", "DATA")

        if !jobBansSave then return end

        sAdmin.jobBans[sid64] = util.JSONToTable(jobBansSave)
    end)

    sAdmin.addCommand({
        name = "jobban",
        category = "DarkRP",
        inputs = {{"player", "player_name"}, {"text", "job"}, {"time"}},
        func = function(ply, args, silent)
            if !args[1] then return end
            local targets = sAdmin.getTargets("jobban", ply, args[1], 1)
            local job = args[2]
            local time = sAdmin.getTime(args[3])
            local jobIndex

            for k, v in pairs(RPExtraTeams) do
                if string.find(string.lower(v.name), string.lower(job)) then 
                    jobIndex = k
                    job = v.name
                    
                    break
                end
            end

            if !jobIndex then
                sAdmin.silentMsg(ply, "couldnt_match_job", job)
            return end

            for k,v in ipairs(targets) do
                jobBan(v, jobIndex, time)
            end

            sAdmin.msg(silent and ply or nil, "jobban_response", ply, targets, job, time)
        end
    })

    sAdmin.addCommand({
        name = "jobunban",
        category = "DarkRP",
        inputs = {{"player", "player_name"}, {"text", "job"}},
        func = function(ply, args, silent)
            if !args[1] then return end
            local targets = sAdmin.getTargets("jobunban", ply, args[1], 1)
            local job = args[2]

            local jobIndex

            for k, v in pairs(RPExtraTeams) do
                if string.find(string.lower(v.name), string.lower(job)) then 
                    jobIndex = k
                    job = v.name
                    
                    break
                end
            end

            if !jobIndex then
                sAdmin.msg(ply, "couldnt_match_job", job)
            return end

            for k,v in ipairs(targets) do
                jobUnban(v, jobIndex)
            end

            sAdmin.msg(silent and ply or nil, "jobunban_response", ply, targets, job)
        end
    })

    sAdmin.addCommand({
        name = "shipment",
        category = "DarkRP",
        inputs = {{"text", "name"}, {"numeric", "amount"}},
        func = function(ply, args, silent)
            local classname, count = args[1], tonumber(args[2])

            local startPos = ply:EyePos() + ply:GetAimVector() * 85

            local ship_key, ship_count = DarkRP.getShipmentByName(classname)
            local actualName

            if !ship_key then
                classname = string.lower(classname)
                for k,v in ipairs(CustomShipments) do
                    if string.find(string.lower(v.entity), classname) or string.find(string.lower(v.name), classname) then
                        actualName = v.name
                        ship_key, ship_count = k, v.amount
                        break
                    end
                end
            end

            if !ship_key then return end

            count = count or ship_count

            if !isnumber(count) then count = ship_count end

            local crate = ents.Create("spawned_shipment")
            if !IsValid(crate) then return end
            crate:SetPos(startPos)
            crate:SetContents(ship_key, count)
            crate:Spawn()

            if actualName then
                sAdmin.msg(silent and ply or nil, "shipment_response", ply, actualName, count)
            end
        end
    })
end)