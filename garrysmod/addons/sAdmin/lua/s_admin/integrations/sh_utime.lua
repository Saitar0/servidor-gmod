local meta = FindMetaTable("Player")

function meta:GetUTime()
	return sAdmin.getTotalPlaytime(self)
end

function meta:GetUTimeStart()
    local sid64 = self:SteamID64()
    local session = sAdmin.playerData and sAdmin.playerData[sid64] and sAdmin.playerData[sid64].synctime or 0
	return session
end

function meta:GetUTimeSessionTime()
	return sAdmin.getSessionPlaytime(self)
end

function meta:GetUTimeTotalTime()
	return sAdmin.getTotalPlaytime(self)
end