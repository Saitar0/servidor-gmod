if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}
ztm.trash = ztm.trash or {}
ztm.trash_spawns = ztm.trash_spawns or {}

//CLEANUP
function ztm.f.Trash_Cleanup()

    for k, v in pairs(ztm.trash) do
        if IsValid(v) then

            // Recalculate idle time
            if v.lastpos == v:GetPos() then
                v.idle_time = v.idle_time + 1
            else
                v.idle_time = 0
            end

            // Delete entity if to long idle
            if v.idle_time > ztm.config.Trash.cleanup_time then
                SafeRemoveEntity( v )
            else
                v.lastpos = v:GetPos()
            end
        end
    end
end

function ztm.f.Check_TrashCleanup_TimerExist()

    if timer.Exists("ztm_TrashCleanup_timer") then
        timer.Remove("ztm_TrashCleanup_timer")
    end

    timer.Create("ztm_TrashCleanup_timer", 1, 0, ztm.f.Trash_Cleanup)
end

hook.Add("InitPostEntity", "ztm_TrashCleanup_timer_OnMapLoad", ztm.f.Check_TrashCleanup_TimerExist)




//SPAWN
function ztm.f.Trash_AddSpawnPos(pos,ply)
    table.insert(ztm.trash_spawns,pos)
    timer.Simple(0,function()
        ztm.f.Notify(ply, "Trash position added!", 0)
        ztm.f.Trash_ShowAll(ply)
    end)
end

function ztm.f.Trash_RemoveSpawnPos(pos,ply)

    local removed_pos = 0
    local old_pos = ztm.trash_spawns
    ztm.trash_spawns = {}

    for k, v in pairs(old_pos) do
        if v:Distance(pos) > 25 then
            table.insert(ztm.trash_spawns,v)
        else
            removed_pos = removed_pos + 1
        end
    end

    if removed_pos > 0 then
        timer.Simple(0,function()
            ztm.f.Notify(ply, "Removed Trash positions: " .. removed_pos, 0)
            ztm.f.Trash_ShowAll(ply)
        end)
    end
end

util.AddNetworkString("ztm_trash_showall")
function ztm.f.Trash_ShowAll(ply)
    local dataString = util.TableToJSON(ztm.trash_spawns)
    local dataCompressed = util.Compress(dataString)

    net.Start("ztm_trash_showall")
    net.WriteUInt(#dataCompressed, 16)
    net.WriteData(dataCompressed, #dataCompressed)
    net.Send(ply)
end

util.AddNetworkString("ztm_trash_hideall")
function ztm.f.Trash_HideAll(ply)
    net.Start("ztm_trash_hideall")
    net.Send(ply)
end



function ztm.f.Check_TrashSpawn_Call()
    ztm.f.Trash_Spawn()
end

function ztm.f.Check_TrashSpawn_TimerExist()
    if ztm.config.Trash.spawn.enabled == false then return end
    if timer.Exists("ztm_TrashSpawn_timer") then
        timer.Remove("ztm_TrashSpawn_timer")
    end

    timer.Create("ztm_TrashSpawn_timer", ztm.config.Trash.spawn.time, 0, ztm.f.Check_TrashSpawn_Call)
end

hook.Add("InitPostEntity", "ztm_TrashSpawn_timer_OnMapLoad", ztm.f.Check_TrashSpawn_TimerExist)


// Returns the current valid count of trash entities spawned from the custom spawns
function ztm.f.Trash_GetValidCount()
    local count = 0
    for k, v in pairs(ztm.trash) do
        if IsValid(v) and v.IsFromCustomSpawn ~= nil and v.IsFromCustomSpawn == true then
            count = count + 1
        end
    end

    return count
end

// Spawns trash at a random point
function ztm.f.Trash_Spawn()
    if ztm.trash_spawns == nil or table.Count(ztm.trash_spawns) <= 0 then
        //ztm.f.Debug("No Spawn Positions set!")
        return
    end

    if ztm.f.Trash_GetValidCount() >= ztm.config.Trash.spawn.count then
        //ztm.f.Debug("Trash limit reached!")
        return
    end

    local rndPos = ztm.trash_spawns[ math.random( #ztm.trash_spawns ) ]

    local trash_InDistance = false
    for k, v in pairs(ztm.trash) do
        if IsValid(v) and ztm.f.InDistance(v:GetPos(), rndPos, 50) then

            trash_InDistance = true
            break
        end
    end


    if trash_InDistance == false then
        spawn_trys = 0

        local ent = ztm.f.Trash_Create(rndPos, Angle(0,0,0), math.random(ztm.config.Trash.spawn.trash_min,ztm.config.Trash.spawn.trash_max))
        local rad = ent:BoundingRadius()
        ent:SetPos(rndPos + Vector(0, 0, rad * 0.8))
        ent.IsFromCustomSpawn = true
    end
end

function ztm.f.Trash_Create(pos, ang, amount)
    local ent = ents.Create("ztm_trash")
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:SetTrash(amount)
    ent:Spawn()
    ent:Activate()

    ent.lastpos = pos
    ent.idle_time = 0

    return ent
end












// Save function
concommand.Add( "ztm_save_trash", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Trash spawns have been saved for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Trash_Save()
    end
end )

concommand.Add( "ztm_remove_trash", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Trash spawns have been removed for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Trash_Remove()
        ztm.f.Trash_HideAll(ply)
    end
end )

function ztm.f.Trash_Save()
    local data = {}

    for u, j in pairs(ztm.trash_spawns) do
        if j then
            table.insert(data, j)
        end
    end

    if not file.Exists("ztm", "DATA") then
        file.CreateDir("ztm")
    end
    if table.Count(data) > 0 then
        file.Write("ztm/" .. string.lower(game.GetMap()) .. "_trashspawns" .. ".txt", util.TableToJSON(data))
    end
end

function ztm.f.Trash_Load()
    if ztm.config.Trash.spawn.enabled == false then return end

    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_trashspawns" .. ".txt", "DATA") then
        local data = file.Read("ztm/" .. string.lower(game.GetMap()) .. "_trashspawns" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            ztm.trash_spawns = data

            print("[Zeros WeedFarm] Finished loading Trash Spawns.")
        end
    else

        print("[Zeros WeedFarm] No map data found for Trash Spawns. Create some using Chat Commands: !ztm_trash_add  !ztm_trash_remove  !ztm_trash_showall")
    end
end

function ztm.f.Trash_Remove()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_trashspawns" .. ".txt", "DATA") then
        file.Delete("ztm/" .. string.lower(game.GetMap()) .. "_trashspawns" .. ".txt")
    end

    ztm.trash_spawns = {}
end
