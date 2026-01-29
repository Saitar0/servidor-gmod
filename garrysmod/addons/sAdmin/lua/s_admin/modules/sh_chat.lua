sAdmin = sAdmin or {}
sAdmin.muted = sAdmin.muted or {}
sAdmin.gagged = sAdmin.gagged or {}

local function commsMute(ply, type, time, ignore)
    local sid64 = ply:SteamID64()
    sAdmin[type][sid64] = time or true

    if !isnumber(time) then return end

    if time > 0 then
        timer.Create("sAdmin_"..type.."_"..sid64, time, 1, function()
            sAdmin[type][sid64] = nil
            sAdmin.networkData(nil, {type, sid64}, nil)

            if !IsValid(ply) then return end
            ply:RemovePData("sA:"..type)
        end)
    else
        timer.Remove("sAdmin_"..type.."_"..sid64)
    end

    sAdmin.networkData(nil, {type, sid64}, true)

    if ignore then return end
    ply:SetPData("sA:"..type, time + os.time())
end

local function commsUnmute(ply, type)
    local sid64 = isnumber(ply) and ply or (IsValid(ply) and ply:SteamID64())
    sAdmin[type][sid64] = nil
    timer.Remove("sAdmin_"..type.."_"..sid64)

    sAdmin.networkData(nil, {type, sid64}, nil)

    ply:RemovePData("sA:"..type)
end

sAdmin.addCommand({
    name = "pm",
    category = "Chat",
    inputs = {{"player", "player_name"}, {"text", "msg"}},
    func = function(ply, args)
        local targets = sAdmin.getTargets("pm", ply, args[1], 1, true)
        local msg = ""

        for i=2,#args do
            msg = msg.." "..args[i]
        end

        if !msg or msg:Trim() == "" then return end
        for k,v in ipairs(targets) do
            sAdmin.msg(ply, "pm_response", v, msg)
            sAdmin.msg(v, "pm_response_receive", ply, msg)
        end
    end
})

sAdmin.addCommand({
    name = "asay",
    category = "Chat",
    abbreviation = {"@"},
    inputs = {{"text", "msg"}},
    func = function(ply, args)
        local msg = ""
        for i=1,#args do
            msg = msg.." "..args[i]
        end

        if !msg or msg:Trim() == "" then return end
        for k,v in ipairs(player.GetAll()) do
            if !sAdmin.hasPermission(v, "is_staff") or ply == v then continue end
            sAdmin.msg(v, "asay_response_receive", ply, msg)
        end

        sAdmin.msg(ply, "asay_response", ply, msg)
    end
})

sAdmin.addCommand({
    name = "mute",
    category = "Chat",
    inputs = {{"player", "player_name"}, {"time"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("mute", ply, args[1])
        local time = sAdmin.getTime(args, 2)
        for k,v in ipairs(targets) do
            commsMute(v, "muted", time)
        end

        sAdmin.msg(silent and ply or nil, "mute_response", ply, targets, time)
    end
})

sAdmin.addCommand({
    name = "unmute",
    category = "Chat",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("unmute", ply, args[1])
        for k,v in ipairs(targets) do
            commsUnmute(v, "muted")
        end

        sAdmin.msg(silent and ply or nil, "unmute_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "gag",
    category = "Chat",
    inputs = {{"player", "player_name"}, {"time"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("gag", ply, args[1])
        local time = sAdmin.getTime(args, 2)
        for k,v in ipairs(targets) do
            commsMute(v, "gagged", time)
            v:ConCommand("-voicerecord")
        end

        sAdmin.msg(silent and ply or nil, "gag_response", ply, targets, time)
    end
})

sAdmin.addCommand({
    name = "ungag",
    category = "Chat",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("ungag", ply, args[1])
        for k,v in ipairs(targets) do
            commsUnmute(v, "gagged")
        end

        sAdmin.msg(silent and ply or nil, "ungag_response", ply, targets)
    end
})

hook.Add("PlayerSay", "sA:HandleMute", function(ply)
    local sid64 = ply:SteamID64()
    if sAdmin.muted[sid64] then sAdmin.msg(ply, "s!muted_for", sAdmin.formatTime(timer.TimeLeft("sAdmin_muted_"..sid64) or 0)) return "" end
end)

hook.Add("PlayerCanHearPlayersVoice", "sA:HandleGag", function(listener, talker)
    local sid64 = talker:SteamID64()
    if sAdmin.gagged[sid64] then
		return false
	end
end )

hook.Add("PlayerInitialSpawn", "sA:RegisterCommsState", function(ply)
    local muted = ply:GetPData("sA:muted")
    local gagged = ply:GetPData("sA:gagged")

    if muted then
        commsMute(ply, "muted", muted - os.time(), true)
    end

    if gagged then
        commsMute(ply, "gagged", gagged - os.time(), true)
    end
end)

hook.Add("PlayerDisconnected", "sA:RemoveTimersComms", function(ply)
    local sid64 = ply:SteamID64()
    timer.Remove("sAdmin_muted_"..sid64)
    timer.Remove("sAdmin_gagged_"..sid64)
end)