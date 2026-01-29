local lastPos = {}

local function tpTo(caller, ply, dest_ply)
    local pos
    local og_pos = dest_ply:GetPos()
    local isNoclipped = ply:GetMoveType() == MOVETYPE_NOCLIP

	for i=0,360,3 do
		local rad = math.rad(i)
		local dir = Vector(math.cos(rad), math.sin(rad), 0)
		
        local newpos = og_pos + dir * 80
        local detected = false

        for k,v in ipairs(ents.FindInSphere(newpos, 5)) do
            local classname = v:GetClass()
            if !v:IsWeapon() and !isNoclipped then continue end
            detected = true
        end

        if util.IsInWorld(newpos) and !detected or isNoclipped then
            pos = newpos
            break
        end
	end

    if !pos then
        if caller then
            sAdmin.msg(caller, "no_valid_pos")
        end
    return end
    
    lastPos[ply] = ply:GetPos()

    if ply:InVehicle() then
        ply:ExitVehicle()
    end

    ply:SetPos(pos)
end

sAdmin.addCommand({
    name = "goto",
    category = "Teleport",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("goto", ply, args[1], 1)
        local frozenplys = {}

        for k,v in ipairs(targets) do
            if v == ply then
                sAdmin.msg(ply, "cant_target_self")
                table.remove(targets, k)
            continue end
            
            tpTo(ply, ply, v)
        end

        sAdmin.msg(silent and ply or nil, "goto_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "bring",
    category = "Teleport",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("bring", ply, args[1], 1)
        local unavailableplys, toRemove = {}, {}

        for k,v in ipairs(targets) do
            if v == ply then
                sAdmin.msg(ply, "cant_target_self")
                table.insert(toRemove, k)
            continue end

            if v.physFrozen or v:IsFrozen() or sAdmin.jailData[v:SteamID64()] then
                table.insert(unavailableplys, v)
                table.insert(toRemove, k)
            continue end
            
            tpTo(ply, v, ply)
        end

        for k,v in ipairs(toRemove) do
            targets[v] = nil
        end

        local clearTbl = {}

        for k,v in SortedPairs(targets) do
            table.insert(clearTbl, v)
        end

        targets = clearTbl

        sAdmin.msg(silent and ply or nil, "bring_response", ply, targets)
        sAdmin.msg(silent and ply or nil, "unavailable_plys", unavailableplys)
    end
})

sAdmin.addCommand({
    name = "tp",
    category = "Teleport",
    inputs = {{"player", "player_name"}, {"player", "player_name"}},
    func = function(ply, args, silent)
        local target_ply = sAdmin.getTargets("tp", ply, args[1], 1, true)
        local dest_ply = sAdmin.getTargets("tp", ply, args[2], 1, true)

        if target_ply[1] == dest_ply[1] then
            sAdmin.msg(ply, "invalid_arguments")
        return end

        if target_ply[1] and dest_ply[1] then
            tpTo(ply, target_ply[1], dest_ply[1])
        else
            sAdmin.msg(ply, "invalid_arguments")
        return end

        sAdmin.msg(silent and ply or nil, "tp_response", ply, target_ply[1], dest_ply[1])
    end
})

sAdmin.addCommand({
    name = "return",
    category = "Teleport",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("return", ply, args[1], nil, true)
        
        for k,v in ipairs(targets) do
            local pos = lastPos[v]
            if !pos then
                sAdmin.msg(ply, "no_valid_return_pos")
            return end
            
            v:SetPos(pos)
        end
        
        sAdmin.msg(silent and ply or nil, "return_response", ply, targets)
    end
})