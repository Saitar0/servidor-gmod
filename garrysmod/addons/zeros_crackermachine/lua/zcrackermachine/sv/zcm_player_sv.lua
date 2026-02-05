if (not SERVER) then return end
zcm = zcm or {}
zcm.f = zcm.f or {}
-- How often are clients allowed to send net messages to the server
ZCM_NW_TIMEOUT = 0.25

hook.Add("GravGunOnDropped", "zcm_EntityAligment", function(ply, ent)
	if IsValid(ent) and ent:GetClass() == "zcm_firecracker" then
		local ang = ply:GetAngles()
		ang:RotateAroundAxis(ply:GetUp(), 180)
		ent:SetAngles(Angle(0, ang.y, 0))
	end
end)

local zcm_DeleteEnts = {"zcm_crackermachine", "zcm_box", "zcm_blackpowder", "zcm_firecracker", "zcm_paperroll"}

hook.Add("OnPlayerChangedTeam", "zcm_OnPlayerChangedTeam", function(pl, before, after)
	for k, v in pairs(ents.GetAll()) do
		if IsValid(v) and table.HasValue(zcm_DeleteEnts, v:GetClass()) and zcm.f.GetOwnerID(v) == pl:SteamID() then
			v:Remove()
		end
	end
end)

hook.Add("PlayerDeath", "zcm_PlayerDeath", function(victim, inflictor, attacker)
	if IsValid(victim) then
		local fCount = victim:GetNWInt("zcm_firework", 0)
		if fCount and fCount > 0 and zcm.config.Player.ResetFirework_OnDeath then
			victim:SetNWInt("zcm_firework", 0)
		end
	end
end)
