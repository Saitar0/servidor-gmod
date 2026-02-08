if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

////////////////////////////////////////////
//////////// Virus HotSpot  /////////////
////////////////////////////////////////////

// The Hotspot system creates virus hotspots from predefined positions by the admins.
// A Virus Hotspot gets populated by virus nodes overtime if not removed

// Here we store all the predefind positions for a outbreak to occur
zbl.VHS_Positions = zbl.VHS_Positions or {}

// This keeps count on all the virus nodes created by the outbreak
zbl.VHS_VirusNodes = zbl.VHS_VirusNodes or {}


// This will later store our outbreak core
//zbl.VHS_CoreNode = nil

timer.Simple(5,function()
    zbl.f.VHS_SetupTimer()
end)


function zbl.f.VHS_AddPos(pos,ang,ply)
    zbl.f.Debug("zbl.f.VHS_AddPos")

    table.insert(zbl.VHS_Positions, {
        pos = pos,
        ang = ang
    })

    zbl.f.Notify(ply, "Added Virus HotSpot positions", 0)

    timer.Simple(0,function()
        zbl.f.VHS_ShowAll(ply)
    end)
end

// Removes any spawn pos which is near this pos
function zbl.f.VHS_RemovePos(pos,ply)

    local removed_pos = 0
    local old_pos = zbl.VHS_Positions
    zbl.VHS_Positions = {}

    for k, v in pairs(old_pos) do
        if v and v.pos:Distance(pos) > 50 then
            table.insert(zbl.VHS_Positions,v)
        else
            removed_pos = removed_pos + 1
        end
    end

    if removed_pos > 0 then
        timer.Simple(0,function()
            zbl.f.Notify(ply, "Removed Virus HotSpot positions: " .. removed_pos, 0)
            zbl.f.VHS_ShowAll(ply)
        end)
    end
end

util.AddNetworkString("zbl_hotspot_showall")
function zbl.f.VHS_ShowAll(ply)

    local new_tbl = {}

    for k,v in pairs(zbl.VHS_Positions) do
        table.insert(new_tbl,v.pos)
    end

    local dataString = util.TableToJSON(new_tbl)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_hotspot_showall")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end

util.AddNetworkString("zbl_hotspot_hideall")
function zbl.f.VHS_HideAll(ply)
    net.Start("zbl_hotspot_hideall")
    net.Send(ply)
end


function zbl.f.VHS_SetupTimer()
    zbl.f.Debug("zbl.f.VHS_SetupTimer")

    local timerid = "zbl_vhs_timer"
    zbl.f.Timer_Remove(timerid)

    zbl.f.Timer_Create(timerid,zbl.config.VirusHotspots.growth_interval,0,function()
        zbl.f.VHS_SpreadLogic()
    end)
end

function zbl.f.VHS_SavePositions(ply)
    zbl.f.Debug("zbl.f.VHS_SavePositions")

    if not file.Exists("zbl", "DATA") then
        file.CreateDir("zbl")
    end
    if table.Count(zbl.VHS_Positions) > 0 then
        file.Write("zbl/" .. string.lower(game.GetMap()) .. "_hotspots" .. ".txt", util.TableToJSON(zbl.VHS_Positions))

        zbl.f.Notify(ply, "Virus HotSpots have been saved for the map " .. game.GetMap() .. "!", 0)
    end
end

function zbl.f.VHS_LoadPositions()
    zbl.f.Debug("zbl.f.VHS_LoadPositions")

    local path = "zbl/" .. string.lower(game.GetMap()) .. "_hotspots" .. ".txt"
    if file.Exists(path, "DATA") then
        local data = file.Read(path, "DATA")

        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            zbl.VHS_Positions = data

            print("[Zeros GenLab] Finished loading Virus Hotspots")
        end
    else
        print("[Zeros GenLab] No map data found for Virus Hotspots. Please place some and type !zbl_save in chat to create the data.")
    end
end

function zbl.f.VHS_RemovePositions(ply)
    zbl.f.Debug("zbl.f.VHS_RemovePositions")

    zbl.VHS_Positions = {}

    local path = "zbl/" .. string.lower(game.GetMap()) .. "_hotspots" .. ".txt"
    if file.Exists(path, "DATA") then
        file.Delete(path)
        zbl.f.Notify(ply, "Virus HotSpots have been removed for the map " .. game.GetMap() .. "!", 0)
    end
end

hook.Add("InitPostEntity", "zbl_VHS_LoadPositions_InitPostEntity", zbl.f.VHS_LoadPositions)


// Mainlogic
function zbl.f.VHS_SpreadLogic()

    // If there is no active researcher on the server then stop growing
    if zbl.config.VirusHotspots.GrowOnJobOnly == true and zbl.f.ActiveResearcher() == false then
        //zbl.f.Debug("VHS: No Research online")

        // Get Random node and increase its health
        local node = zbl.VHS_VirusNodes[math.random(#zbl.VHS_VirusNodes)]
        if not IsValid(node) then return end
        zbl.f.Debug("No Researcher on the server, killing random node")

        zbl.f.VN_ExplodeNode(node,true)
        return
    end

    if not IsValid(zbl.VHS_CoreNode) then

        if #zbl.VHS_Positions <= 0 then return end

        // Get Random pos from zbl.VHS_Positions
        local pos_data = zbl.VHS_Positions[math.random(#zbl.VHS_Positions)]

        // Generate a random virus id according to the spawn chance
        local virus_id
        local pool = {}
        for k, v in pairs(zbl.config.VirusHotspots.virus_chance) do
            for i = 1, v do
                table.insert(pool, k)
            end
        end
        pool = zbl.f.table_randomize(pool)
        virus_id = pool[math.random(#pool)]
        //zbl.f.Debug(pool)
        zbl.f.Debug("Winner ID: " .. virus_id)

        zbl.f.VHS_CreateNode(pos_data.pos,pos_data.ang,true,virus_id)
    else
        local vn_count = table.Count(zbl.VHS_VirusNodes)

        if vn_count > zbl.config.VirusHotspots.node_limit then

            // Get Random node and increase its health
            local node = zbl.VHS_VirusNodes[math.random(#zbl.VHS_VirusNodes)]
            if not IsValid(node) then return end

            if zbl.f.RandomChance(99) then
                // Increase Health
                zbl.f.VN_Heal(node,zbl.config.VirusHotspots.node_health_increment)
            else
                // Kill this node to infect close ents
                zbl.f.VN_ExplodeNode(node,true)
            end

            return
        end

        local node
        if vn_count > 3 then
            // Get the node which have the least numbers of neighbors in a radius of 200
            node = zbl.f.VHS_GetLeastNeighbor()
        else
            // Get first position from core node
            node = zbl.VHS_CoreNode
        end

        if not IsValid(node) then return end

        // Does this node have enough health to spread?
        if node:GetVHealth() < zbl.config.VirusHotspots.node_health_spread then

            // Increase Health
            zbl.f.VN_Heal(node,zbl.config.VirusHotspots.node_health_increment)
            return
        end

        // This keeps count on how often we used this node for finding a new spread position
        // If it got used more then 4 times in the last 5 intervals without any valid position then we kill it
        if node.LastRepeatCheck then

            if (node.LastRepeatCheck + (zbl.config.VirusHotspots.growth_interval * 10)) < CurTime() then

                node.RepeatCount = 0
                node.LastRepeatCheck  = CurTime()
            else
                // If it tried the last 3 intervals allways the same node then we kill the node since the position doesent allow to spread
                if node.RepeatCount >= 9 and node ~= zbl.VHS_CoreNode then
                    zbl.f.VN_ExplodeNode(node,true)
                    return
                end
            end
        else
            node.LastRepeatCheck  = CurTime()
        end

        node.RepeatCount = (node.RepeatCount or 0) + 1

        // Get Position data
        local tr = zbl.f.VHS_GetNodePos(node)
        if tr == false then
            //zbl.f.Debug("Could not find valid spawn pos")

            // Increase Health
            zbl.f.VN_Heal(node,zbl.config.VirusHotspots.node_health_increment)
            return
        end

        // If we found a position then we reset the counter
        node.RepeatCount = 0
        node.LastRepeatCheck  = CurTime()

        local node_pos =  tr.HitPos
        local node_ang = tr.HitNormal:Angle()
        node_ang:RotateAroundAxis(node_ang:Right(),-90)

        // Create new slave node
        zbl.f.VHS_CreateNode(node_pos,node_ang,false,zbl.VHS_CoreNode.Virus_ID)
    end
end

// Returns the virus node which has the least neighbors
function zbl.f.VHS_GetLeastNeighbor()
    local n_count = 999999999
    local least_neighbor = nil


    local dist = 300 + (100 * zbl.config.VirusNodes.max_scale)

    for k,v in pairs(zbl.VHS_VirusNodes) do
        if IsValid(v) then

            local _count = 0
            for s,w in pairs(zbl.VHS_VirusNodes) do
                if IsValid(w) and zbl.f.InDistance(v:GetPos(), w:GetPos(), dist) then
                    _count = _count + 1
                end
            end

            if _count < n_count then
                n_count = _count
                least_neighbor = v
            end
        end
    end

    return least_neighbor
end

// Returns a random node position traced from the provided node
function zbl.f.VHS_GetNodePos(node)
    if not IsValid(node) then return end
    local lenght = 200 + (60 * zbl.config.VirusNodes.max_scale)
    local tr = zbl.f.VN_PerformSpawnTrace(node:GetPos() + node:GetUp() * 50,node:GetAngles(),lenght)

    return tr
end

// Creates a slave virus node
function zbl.f.VHS_CreateNode(pos,ang,iscore,virus_id)

    local node = zbl.f.VN_CreateNode(pos, ang, virus_id, 1)

    if iscore then
        zbl.VHS_CoreNode = node
    else
        table.insert(zbl.VHS_VirusNodes,node)
    end
end

function zbl.f.VHS_RemoveNode(ent)
    zbl.f.Debug("zbl.f.VHS_RemoveNode")

    table.RemoveByValue(zbl.VHS_VirusNodes,ent)
end
////////////////////////////////////////////
////////////////////////////////////////////
