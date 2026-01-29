sAdmin = sAdmin or {}
local lastRequest, requestedPeople = {}, {}

local function cooldownHandeler(identifier, identifier2, time)
    lastRequest[identifier] = lastRequest[identifier] or {}

    if lastRequest[identifier][identifier2] and lastRequest[identifier][identifier2] - CurTime() < time then return false end

    lastRequest[identifier][identifier2] = CurTime() + time

    return true
end

local function requestData(ply)
    local sid64 = ply:SteamID64()
    
    if !sid64 then return end

    if SERVER or !cooldownHandeler("playtime", sid64, 1) then return end

    requestedPeople[sid64] = true

    net.Start("sA:Networking")
    net.WriteUInt(6, 3)
    net.WriteEntity(ply)
    net.SendToServer()
end

sAdmin.getTotalPlaytime = function(ply)
    if !IsValid(ply) or !ply:IsPlayer() or ply:IsBot() then return 0 end
    local sid64 = ply:SteamID64()
    local playtime = sAdmin.playerData and sAdmin.playerData[sid64] and sAdmin.playerData[sid64].playtime or 0

    return math.max(0, math.Round(playtime + sAdmin.getSessionPlaytime(ply)))
end

sAdmin.getSessionPlaytime = function(ply)
    if !IsValid(ply) or !ply:IsPlayer() or ply:IsBot() then return 0 end
    local sid64 = ply:SteamID64()
    local session = sAdmin.playerData and sAdmin.playerData[sid64] and sAdmin.playerData[sid64].synctime or 0

    if session == 0 then
        requestData(ply)
    end

    return math.max(0, math.Round(CurTime() - session))
end