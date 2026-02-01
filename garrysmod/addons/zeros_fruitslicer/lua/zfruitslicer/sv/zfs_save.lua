if (not SERVER) then return end
zfs = zfs or {}
zfs.f = zfs.f or {}

function zfs.f.PublicEnts_Save(ply)
    if not file.Exists("zfs", "DATA") then
        file.CreateDir("zfs")
    end

    local data = {}

    for u, j in pairs(ents.FindByClass("zfs_shop")) do
        if zfs.f.IsOwner(ply, j) then
            table.insert(data, {
                class = j:GetClass(),
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    file.Write("zfs/" .. game.GetMap() .. "_FruitSlicers" .. ".txt", util.TableToJSON(data))
    zfs.f.Notify(ply, "The FruitSlicer Entities have been saved for the map " .. game.GetMap() .. "!", 0)
end

function zfs.f.PublicEnts_Load()
    local path = "zfs/" .. game.GetMap() .. "_FruitSlicers" .. ".txt"

    if file.Exists(path, "DATA") then
        local data = file.Read(path, "DATA")
        data = util.JSONToTable(data)

        for k, v in pairs(data) do
            local ent = ents.Create(v.class)
            ent:SetPos(v.pos)
            ent:SetAngles(v.ang)
            ent:Spawn()

            ent:SetPublicEntity(true)

            local phys = ent:GetPhysicsObject()
            if (phys:IsValid()) then
                phys:Wake()
                phys:EnableMotion(false)
            end

            timer.Simple(1.3, function()
                if (ent:IsValid()) then
                    ent:action_Enable()
                end
            end)
        end

        print("[Zeros FruitSlicer] Finished loading FruitSlicer entities.")
    else
        print("[Zeros FruitSlicer] No map data found for FruitSlicer entities.")
    end
end

hook.Add("InitPostEntity", "zfs_PublicEnts_OnMapLoad", zfs.f.PublicEnts_Load)
hook.Add("PostCleanupMap", "zfs_PublicEnts_PostCleanUp", zfs.f.PublicEnts_Load)

concommand.Add("zfs_saveents", function(ply, cmd, args)
    if zfs.f.IsAdmin(ply) then
        zfs.f.PublicEnts_Save(ply)
    else
        zfs.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
    end
end)

hook.Add("PlayerSay", "zfs_HandleConCanCommands", function(ply, text)
    if string.sub(string.lower(text), 1, 10) == "!savezfs" then
        if zfs.f.IsAdmin(ply) then
            zfs.f.PublicEnts_Save(ply)
        else
            zfs.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
        end
    end
end)
