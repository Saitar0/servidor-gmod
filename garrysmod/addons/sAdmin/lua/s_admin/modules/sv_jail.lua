sAdmin = sAdmin or {}

sAdmin.jailData = sAdmin.jailData or {}

local jailSpawnPos = {
    pos = Vector(1.4, -2, 50),
    ang = Angle(0, -90, 0)
}

sAdmin.unjailPly = function(ply)
    local sid64 = isentity(ply) and IsValid(ply) and ply:SteamID64() or ply
    if !sid64 then return end

    timer.Remove("sAdmin_jail_"..sid64)

    if !sAdmin.jailData[sid64] then return end
    local jail_cell = sAdmin.jailData[sid64].ent

    if IsValid(jail_cell) then
        jail_cell:Remove()
    end

    sAdmin.jailData[sid64] = nil
end

sAdmin.jailPly = function(ply, time, ignoretime)
    if !IsValid(ply) then return end
    ply:SetMoveType(MOVETYPE_WALK)
    local sid64 = ply:SteamID64()
    
    time = tonumber(time)

    local toMake = !sAdmin.jailData[sid64] or !IsValid(sAdmin.jailData[sid64])

    if toMake then
        local jail_cell = ents.Create("prop_physics")
        if !IsValid(jail_cell) then return end
        jail_cell:SetModel("models/sterling/gmodel_penitentiary.mdl")
        jail_cell:Spawn()

        jail_cell:SetPos(ply:LocalToWorld(jailSpawnPos.pos))
        jail_cell:SetAngles(ply:LocalToWorldAngles(jailSpawnPos.ang))
        jail_cell.sAdmin_JailCell = true

        local phys = jail_cell:GetPhysicsObject()

        if IsValid(phys) then
            phys:EnableMotion(false)
        end

        local plyPos = ply:GetPos()
        
        sAdmin.jailData[sid64] = {ent = jail_cell, pos = plyPos}

        plyPos.z = plyPos.z + 3

        ply:SetPos(plyPos)
    end

    if !time or !isnumber(time) or time <= 0 or ignoretime then
        if timer.Exists("sAdmin_jail_"..sid64) then
            timer.Remove("sAdmin_jail_"..sid64)
        end
    return end
    
    timer.Create("sAdmin_jail_"..sid64, time, 1, function()
        sAdmin.unjailPly(sid64)
    end)
end

hook.Add("PlayerSpawn", "sA:JailReposition", function(ply)
    local sid64 = ply:SteamID64()

    if sAdmin.jailData[sid64] then
        timer.Simple(0, function()
            if !IsValid(ply) or !sAdmin.jailData[sid64].pos then return end
            ply:SetPos(sAdmin.jailData[sid64].pos)
        end)
    end
end)

hook.Add("PlayerSpawnProp", "sA:BlockJail", function(ply)
    local sid64 = ply:SteamID64()

    if sAdmin.jailData[sid64] then return false end
end)

hook.Add("PlayerDisconnected", "sA:JailHandleDisconnect", function(ply)
    local sid64 = ply:SteamID64()

    if sAdmin.jailData[sid64] then
        if sAdmin.jailData[sid64].ent and IsValid(sAdmin.jailData[sid64].ent) then
            sAdmin.jailData[sid64].ent:Remove()
        end

        sAdmin.jailData[sid64].ent = nil
    end
end)

hook.Add("PlayerInitialSpawn", "sA:JailHandleReconnect", function(ply)
    local sid64 = ply:SteamID64()

    if sAdmin.jailData[sid64] and sAdmin.jailData[sid64].pos then
        ply:SetPos(sAdmin.jailData[sid64].pos)
        sAdmin.jailPly(ply, 0, true)
    end
end)

hook.Add("PlayerShouldTakeDamage", "sA:PreventDamageInJail", function(ply, attacker)
    if !IsValid(attacker) or !attacker:IsPlayer() then return end
    
	if sAdmin.jailData[attacker:SteamID64()] then return false end
end)

hook.Add("PhysgunPickup", "sA:PreventPickupJail", function(ply, ent)
    if ent.sAdmin_JailCell then return false end
end)