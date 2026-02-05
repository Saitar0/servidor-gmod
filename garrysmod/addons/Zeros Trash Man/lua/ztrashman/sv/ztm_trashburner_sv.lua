if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

ztm.trashburner = ztm.trashburner or {}

function ztm.f.Trashburner_Initialize(TrashBurner)
    ztm.f.EntList_Add(TrashBurner)

    TrashBurner.IsBusy = false
    TrashBurner.LastPlayer = nil

    table.insert(ztm.trashburner,TrashBurner)
end

function ztm.f.Trashburner_Touch(TrashBurner, other)
    if TrashBurner.IsBusy then return end
    if TrashBurner:GetTrash() >= ztm.config.TrashBurner.burn_load then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "ztm_trashbag" and other:GetClass() ~= "ztm_trash" then return end
    if ztm.f.CollisionCooldown(other) then return end
    if other:GetTrash() <= 0 then return end
    if TrashBurner:GetIsClosed() then return end

    ztm.f.Trashburner_AddTrash(TrashBurner, other)
end

function ztm.f.Trashburner_AddTrash(TrashBurner, trash)
    TrashBurner.IsBusy = true
    TrashBurner:SetTrash(TrashBurner:GetTrash() + trash:GetTrash())
    SafeRemoveEntity(trash)

    timer.Simple(1,function()
        if IsValid(TrashBurner) then
            TrashBurner.IsBusy = false
        end
    end)
end

function ztm.f.Trashburner_USE(TrashBurner,ply)
    if TrashBurner.IsBusy then return end

    if TrashBurner:OnCloseButton(ply) then
        ztm.f.Trashburner_SwitchDoor(TrashBurner)
        TrashBurner:EmitSound("ztm_ui_click")
    end

    if TrashBurner:OnStartButton(ply) then
        ztm.f.Trashburner_StartBurning(TrashBurner,ply)
    end
end

function ztm.f.Trashburner_SwitchDoor(TrashBurner)
    TrashBurner.IsBusy = true
    TrashBurner:SetIsClosed( not TrashBurner:GetIsClosed() )

    local timerID = "ztm_trashburner_switchdoor_" .. TrashBurner:EntIndex() .. "_timer"
    ztm.f.Timer_Remove(timerID)

    ztm.f.Timer_Create(timerID, 1, 1, function()
        ztm.f.Timer_Remove(timerID)

        if IsValid(TrashBurner) then
            TrashBurner.IsBusy = false
        end
    end)
end

function ztm.f.Trashburner_StartBurning(TrashBurner,ply)
    if TrashBurner:GetIsClosed() == false then return end
    if TrashBurner:GetTrash() <= 0 then return end

    TrashBurner.LastPlayer = ply
    TrashBurner:EmitSound("ztm_ui_click")

    TrashBurner:SetIsBurning(true)
    TrashBurner:SetStartTime(CurTime())
    TrashBurner.IsBusy = true

    local timerID = "ztm_trashburner_burn_" .. TrashBurner:EntIndex() .. "_timer"
    ztm.f.Timer_Remove(timerID)

    local exp_time = math.Clamp(TrashBurner:GetTrash() * ztm.config.TrashBurner.burn_time,1,ztm.config.TrashBurner.burn_load * ztm.config.TrashBurner.burn_time)


    ztm.f.Timer_Create(timerID, exp_time, 1, function()
        ztm.f.Timer_Remove(timerID)

        if IsValid(TrashBurner) then
            ztm.f.Trashburner_FinishBurning(TrashBurner)
        end
    end)
end

function ztm.f.Trashburner_FinishBurning(TrashBurner)
    TrashBurner.IsBusy = false
    TrashBurner:SetIsBurning(false)
    TrashBurner:SetIsClosed(false)
    TrashBurner:SetStartTime(-1)

    local trash = TrashBurner:GetTrash()
    local money = trash * ztm.config.TrashBurner.money_per_kg

    // Custom Hook
    hook.Run("ztm_OnTrashBurned" ,TrashBurner.LastPlayer, TrashBurner, money, trash)


    // Spawn money
    local pos = TrashBurner:GetPos() +  TrashBurner:GetUp() * 35 + TrashBurner:GetForward() * -60
    ztm.config.MoneySpawn(pos,money)

    TrashBurner.LastPlayer = nil
    TrashBurner:SetTrash(0)
end




// Save function
concommand.Add( "ztm_save_trashburner", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Trashburner entities have been saved for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Trashburner_Save()
    end
end )

concommand.Add( "ztm_remove_trashburner", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Trashburner entities have been removed for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Trashburner_Remove()
    end
end )

function ztm.f.Trashburner_Save()
    local data = {}

    for u, j in pairs(ztm.trashburner) do
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
        file.Write("ztm/" .. string.lower(game.GetMap()) .. "_trashburners" .. ".txt", util.TableToJSON(data))
    end
end

function ztm.f.Trashburner_Load()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_trashburners" .. ".txt", "DATA") then
        local data = file.Read("ztm/" .. string.lower(game.GetMap()) .. "_trashburners" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("ztm_trashburner")
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()

                local phys = ent:GetPhysicsObject()

                if (phys:IsValid()) then
                    phys:Wake()
                    phys:EnableMotion(false)
                end

            end

            print("[Zeros WeedFarm] Finished loading Trashburner Entities.")
        end
    else
        print("[Zeros WeedFarm] No map data found for Trashburner entities. Please place some and do !saveztm to create the data.")
    end
end

function ztm.f.Trashburner_Remove()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_trashburners" .. ".txt", "DATA") then
        file.Delete("ztm/" .. string.lower(game.GetMap()) .. "_trashburners" .. ".txt")
    end

    for k, v in pairs(ztm.trashburner) do
        if IsValid(v) then
            v:Remove()
        end
    end
end
