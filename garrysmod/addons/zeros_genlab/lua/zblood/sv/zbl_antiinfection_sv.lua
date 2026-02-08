if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

// Anti Infection zones define areas in which player cant get infected and where objects cant be contamined

// Here we store all the predefind positions for the Anti Infection Zone
zbl.AIZ_Positions = zbl.AIZ_Positions or {}

concommand.Add("zbl_debug_AIZ_SavePos", function(ply, cmd, args)
    if IsValid(ply) and zbl.f.IsAdmin(ply) then
        zbl.f.AIZ_SavePositions(ply)
    end
end)

concommand.Add("zbl_debug_AIZ_RemovePos", function(ply, cmd, args)
    if IsValid(ply) and zbl.f.IsAdmin(ply) then
        zbl.f.AIZ_RemovePositions(ply)
    end
end)

function zbl.f.AIZ_AddPos(pos, radius, ply)
    zbl.f.Debug("zbl.f.AIZ_AddPos")

    table.insert(zbl.AIZ_Positions, {
        pos = pos,
        radius = radius
    })

    zbl.f.Notify(ply, "Added Anti Infection Zone", 0)

    timer.Simple(0, function()
        zbl.f.AIZ_ShowAll(ply)
    end)
end

// Removes any spawn pos which is near this pos
function zbl.f.AIZ_RemovePos(pos,ply,dist)

    local removed_pos = 0
    local old_pos = zbl.AIZ_Positions
    zbl.AIZ_Positions = {}

    for k, v in pairs(old_pos) do
        if v and v.pos:Distance(pos) > dist then
            table.insert(zbl.AIZ_Positions,v)
        else
            removed_pos = removed_pos + 1
        end
    end

    if removed_pos > 0 then
        timer.Simple(0,function()
            zbl.f.Notify(ply, "Removed Anti Infection Zones: " .. removed_pos, 0)
            zbl.f.AIZ_ShowAll(ply)
        end)
    end
end

util.AddNetworkString("zbl_aiz_showall")
function zbl.f.AIZ_ShowAll(ply)

    local dataString = util.TableToJSON(zbl.AIZ_Positions)
    local dataCompressed = util.Compress(dataString)

    net.Start("zbl_aiz_showall")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end

util.AddNetworkString("zbl_aiz_hideall")
function zbl.f.AIZ_HideAll(ply)
    net.Start("zbl_aiz_hideall")
    net.Send(ply)
end


// Tells us if the provided pos is near a Anit Infection Zone
function zbl.f.AIZ_NearZone(pos)
    local NearZone = false
    for k,v in pairs(zbl.AIZ_Positions) do
        if v and zbl.f.InDistance(v.pos, pos, v.radius) then
            NearZone = true
            break
        end
    end
    return NearZone
end



function zbl.f.AIZ_SavePositions(ply)
    zbl.f.Debug("zbl.f.AIZ_SavePositions")

    if not file.Exists("zbl", "DATA") then
        file.CreateDir("zbl")
    end
    if table.Count(zbl.AIZ_Positions) > 0 then
        file.Write("zbl/" .. string.lower(game.GetMap()) .. "_anti_infection_zones" .. ".txt", util.TableToJSON(zbl.AIZ_Positions))

        zbl.f.Notify(ply, "Anti Infection Zones have been saved for the map " .. game.GetMap() .. "!", 0)
    end
end

function zbl.f.AIZ_LoadPositions()
    zbl.f.Debug("zbl.f.AIZ_LoadPositions")

    local path = "zbl/" .. string.lower(game.GetMap()) .. "_anti_infection_zones" .. ".txt"
    if file.Exists(path, "DATA") then
        local data = file.Read(path, "DATA")

        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            zbl.AIZ_Positions = data

            print("[Zeros GenLab] Finished loading Anti Infection Zones")
        end
    else
        print("[Zeros GenLab] No map data found for Anti Infection Zone. Please place some and type !zbl_save in chat to create the data.")
    end
end

function zbl.f.AIZ_RemovePositions(ply)
    zbl.f.Debug("zbl.f.AIZ_RemovePositions")

    zbl.AIZ_Positions = {}

    local path = "zbl/" .. string.lower(game.GetMap()) .. "_anti_infection_zones" .. ".txt"
    if file.Exists(path, "DATA") then
        file.Delete(path)
        zbl.f.Notify(ply, "Anti Infection Zone have been removed for the map " .. game.GetMap() .. "!", 0)
    end
end

hook.Add("InitPostEntity", "zbl_AIZ_LoadPositions_InitPostEntity", zbl.f.AIZ_LoadPositions)
