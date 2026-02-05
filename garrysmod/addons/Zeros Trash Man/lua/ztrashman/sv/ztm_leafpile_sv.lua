if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

ztm.leafpiles = ztm.leafpiles or {}

function ztm.f.Leafpile_Add(leafpile)

    table.insert(ztm.leafpiles,leafpile)

    ztm.f.Debug("Leafpile added!")
end


// Save function
concommand.Add( "ztm_save_leafpile", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Leafpile entities have been saved for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Leafpile_Save()
    end
end )

concommand.Add( "ztm_remove_leafpile", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Leafpile entities have been removed for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Leafpile_Remove()
    end
end )

function ztm.f.Leafpile_Save()
    local data = {}

    for u, j in pairs(ztm.leafpiles) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    if not file.Exists("ztm", "DATA") then
        file.CreateDir("ztm")
    end
    if table.Count(data) > 0 then
        file.Write("ztm/" .. string.lower(game.GetMap()) .. "_leafpiles" .. ".txt", util.TableToJSON(data))
    end
end

function ztm.f.Leafpile_Load()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_leafpiles" .. ".txt", "DATA") then
        local data = file.Read("ztm/" .. string.lower(game.GetMap()) .. "_leafpiles" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("ztm_leafpile")
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()

                ent:SetNoDraw(true)
                ent:PhysicsInit( SOLID_NONE  )


            end

            print("[Zeros WeedFarm] Finished loading Leafpile Entities.")
        end
    else
        print("[Zeros WeedFarm] No map data found for Leafpile entities. Please place some and do !saveztm to create the data.")
    end
end

function ztm.f.Leafpile_Remove()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_leafpiles" .. ".txt", "DATA") then
        file.Delete("ztm/" .. string.lower(game.GetMap()) .. "_leafpiles" .. ".txt")
    end

    for k, v in pairs(ztm.leafpiles) do
        if IsValid(v) then
            v:Remove()
        end
    end
end


// Setup function
hook.Add("InitPostEntity", "ztm_InitPostEntity_LeafPile_Setup", function()
    timer.Simple(1, function()
        ztm.f.LeafPile_Setup()
    end)
end)

function ztm.f.LeafPile_Setup()

    if timer.Exists("ztm_leafpile_refresher") then
        timer.Remove("ztm_leafpile_refresher")
    end

    timer.Create("ztm_leafpile_refresher", ztm.config.LeafPile.refresh_interval, 0, ztm.f.Leafpile_RefreshCheck)
end

function ztm.f.Leafpile_Initialize(leafpile)
    ztm.f.EntList_Add(leafpile)
    ztm.f.Leafpile_Add(leafpile)
    leafpile.spawned_trash = {}
    leafpile.LastUsed = -9999
end

// Spawn function
function ztm.f.Leafpile_GetActiveCount()
    local count = 0
    for k, v in pairs(ztm.leafpiles) do
        if IsValid(v) and v:GetNoDraw() == false then
            count = count + 1
        end
    end

    return count
end

function ztm.f.Leafpile_RefreshCheck()

    if ztm.f.Leafpile_GetActiveCount() >= ztm.config.LeafPile.refresh_count then
        //ztm.f.Debug("Leafpile limit reached!")
        return
    end

    local ent = ztm.f.Leafpile_FindFreeEnt()

    if IsValid(ent) then
        ztm.f.Leafpile_Refresh(ent)
    end
end

function ztm.f.Leafpile_HasUnUsedTrash(leafpile)
    local hastrash = false
    for k, v in pairs(leafpile.spawned_trash) do
        if IsValid(v) then
            hastrash = true
            break
        end
    end
    return hastrash
end

function ztm.f.Leafpile_FindFreeEnt()
    ztm.leafpiles = ztm.f.table_randomize( ztm.leafpiles )

    local ent
    for k, v in pairs(ztm.leafpiles) do
        if IsValid(v) and v:GetNoDraw() == true and (v.LastUsed + ztm.config.LeafPile.refresh_cooldown) < CurTime() and ztm.f.Leafpile_HasUnUsedTrash(v) == false then
            ent = v
            break
        end
    end

    return ent
end





// Action function
function ztm.f.Leafpile_Explode(leafpile,ply)

    ztm.f.LeafpileEffect(leafpile)

    // Spawn Trash
    if ztm.f.RandomChance(ztm.config.LeafPile.trash_chance) then
        local trash_count = math.random(1, ztm.config.LeafPile.trash_count)
        local trash_amount = math.random(ztm.config.LeafPile.trash_min, ztm.config.LeafPile.trash_max)
        leafpile.spawned_trash = {}
        for i = 1, trash_count do
            local pos = leafpile:GetPos() + leafpile:GetRight() * math.Rand(-55, 55) + leafpile:GetForward() * math.Rand(-55, 55)
            local ent = ztm.f.Trash_Create(pos, leafpile:GetAngles(), trash_amount / trash_count)
            local rad = ent:BoundingRadius()
            ent:SetPos(pos + Vector(0, 0, rad * 0.8))
            table.insert(leafpile.spawned_trash,ent)
        end
    end

    // Custom Hook
    hook.Run("ztm_OnLeafpileBlast", ply, leafpile)

    leafpile:SetNoDraw(true)
    leafpile:PhysicsInit( SOLID_NONE  )
    leafpile.LastUsed = CurTime()
end

concommand.Add("ztm_debug_leafpile_refresh", function(ply, cmd, args)
    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        for k, v in pairs(ztm.EntList) do
            if IsValid(v) and v:GetClass() == "ztm_leafpile" then
                ztm.f.Leafpile_Refresh(v)
            end
        end
    end
end)

function ztm.f.Leafpile_Refresh(leafpile)
    leafpile:SetNoDraw(false)

    leafpile:PhysicsInit(SOLID_VPHYSICS)
    leafpile:SetSolid(SOLID_VPHYSICS)
    leafpile:SetMoveType(MOVETYPE_VPHYSICS)
    leafpile:SetUseType(SIMPLE_USE)
    leafpile:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    local phys = leafpile:GetPhysicsObject()

    if (phys:IsValid()) then
        phys:Wake()
        phys:EnableMotion(false)
    end
end
