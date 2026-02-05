if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

ztm.recycler = ztm.recycler or {}

function ztm.f.Recycler_Initialize(Recycler)
    ztm.f.EntList_Add(Recycler)

    Recycler.IsBusy = false
    Recycler.LastPlayer = nil

    table.insert(ztm.recycler,Recycler)
end

function ztm.f.Recycler_Touch(Recycler, other)
    if Recycler.IsBusy then return end
    if Recycler:GetTrash() >= ztm.config.Recycler.capacity then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "ztm_trashbag" and other:GetClass() ~= "ztm_trash" then return end
    if ztm.f.CollisionCooldown(other) then return end
    if other:GetTrash() <= 0 then return end

    ztm.f.Recycler_AddTrash(Recycler, other)
end

function ztm.f.Recycler_AddTrash(Recycler, trash)
    Recycler.IsBusy = true
    Recycler:SetTrash(Recycler:GetTrash() + trash:GetTrash())

    SafeRemoveEntity(trash)

    timer.Simple(1,function()
        if IsValid(Recycler) then
            Recycler.IsBusy = false
        end
    end)
end

function ztm.f.Recycler_USE(Recycler,ply)
    if Recycler.IsBusy then return end

    if table.Count(ztm.config.Recycler.job_restriction) > 0 and not ztm.config.Recycler.job_restriction[ztm.f.GetPlayerJob(ply)] then
        ztm.f.Notify(ply, ztm.language.General["WrongJob"], 1)
        return
    end

    if table.Count(ztm.config.Recycler.rank_restriction) > 0 and not ztm.config.Recycler.rank_restriction[ztm.f.GetPlayerRank(ply)] then
        ztm.f.Notify(ply, ztm.language.General["WrongRank"], 1)
        return
    end

    if Recycler:OnSwitchButton_Left(ply) then

        Recycler:SetSelectedType(Recycler:GetSelectedType() - 1)
        if Recycler:GetSelectedType() <= 0 then
            Recycler:SetSelectedType(table.Count(ztm.config.Recycler.recycle_types))
        end
        Recycler:EmitSound("ztm_ui_click")

    elseif Recycler:OnSwitchButton_Right(ply) then

        Recycler:SetSelectedType(Recycler:GetSelectedType() + 1)
        if Recycler:GetSelectedType() > table.Count(ztm.config.Recycler.recycle_types) then
            Recycler:SetSelectedType(1)
        end
        Recycler:EmitSound("ztm_ui_click")

    elseif Recycler:OnStartButton(ply) then

        // Check if we have enough trash for this material
        local _recycle_type = ztm.config.Recycler.recycle_types[Recycler:GetSelectedType()]

        if Recycler:GetTrash() >= _recycle_type.trash_per_block then
            Recycler:EmitSound("ztm_ui_click")
            Recycler:SetTrash(Recycler:GetTrash() - _recycle_type.trash_per_block)

            Recycler.LastPlayer = ply

            ztm.f.Recycler_StartRecycling(Recycler)
        end


    end
end

function ztm.f.Recycler_StartRecycling(Recycler)
    ztm.f.Debug("Start Recycle")
    local _recycle_type = ztm.config.Recycler.recycle_types[Recycler:GetSelectedType()]


    // Tells the client script to play the close animation
    Recycler:SetRecycleStage(1)

    Recycler:SetStartTime(CurTime())
    Recycler.IsBusy = true

    // Tells the client script to play the recycle animation
    timer.Simple(1,function()
        if IsValid(Recycler) then
            Recycler:SetRecycleStage(2)
            ztm.f.Debug("Play Recycle animation")
        end
    end)

    local timerID = "ztm_Recycler_recycling_" .. Recycler:EntIndex() .. "_timer"
    ztm.f.Timer_Remove(timerID)

    ztm.f.Timer_Create(timerID, _recycle_type.recycle_time, 1, function()
        ztm.f.Timer_Remove(timerID)

        if IsValid(Recycler) then
            ztm.f.Recycler_FinishRecycling(Recycler)
        end
    end)
end

function ztm.f.Recycler_FinishRecycling(Recycler)
    ztm.f.Debug("Output Recycle Block")

    Recycler:SetRecycleStage(3)

    timer.Simple(1.6,function()
        if IsValid(Recycler) then

            local _recycle_type = ztm.config.Recycler.recycle_types[Recycler:GetSelectedType()]

            local ent = ents.Create("ztm_recycled_block")
            ent:SetPos(Recycler:GetPos() + Recycler:GetUp() * 35 + Recycler:GetRight() * 100)
            ent:SetAngles(Recycler:GetAngles())
            ent:Spawn()
            ent:Activate()
            ent:SetRecycleType(Recycler:GetSelectedType())
            ent:SetMaterial( _recycle_type.mat, true )

            // Custom Hook
            hook.Run("ztm_OnTrashBlockCreation" , Recycler.LastPlayer, Recycler, ent)


            ztm.f.Recycler_Reset(Recycler)
        end
    end)
end
function ztm.f.Recycler_Reset(Recycler)
    ztm.f.Debug("Reset Recycler")
    Recycler.IsBusy = false
    Recycler.LastPlayer = nil
    Recycler:SetRecycleStage(0)
    Recycler:SetStartTime(-1)
end



// Save function
concommand.Add( "ztm_save_recycler", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Recycler entities have been saved for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Recycler_Save()
    end
end )

concommand.Add( "ztm_remove_recycler", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Recycler entities have been removed for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Recycler_Remove()
    end
end )

function ztm.f.Recycler_Save()
    local data = {}

    for u, j in pairs(ztm.recycler) do
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
        file.Write("ztm/" .. string.lower(game.GetMap()) .. "_recyclers" .. ".txt", util.TableToJSON(data))
    end
end

function ztm.f.Recycler_Load()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_recyclers" .. ".txt", "DATA") then
        local data = file.Read("ztm/" .. string.lower(game.GetMap()) .. "_recyclers" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("ztm_recycler")
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

            print("[Zeros WeedFarm] Finished loading Recycler Entities.")
        end
    else
        print("[Zeros WeedFarm] No map data found for Recycler entities. Please place some and do !saveztm to create the data.")
    end
end

function ztm.f.Recycler_Remove()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_recyclers" .. ".txt", "DATA") then
        file.Delete("ztm/" .. string.lower(game.GetMap()) .. "_recyclers" .. ".txt")
    end

    for k, v in pairs(ztm.recycler) do
        if IsValid(v) then
            v:Remove()
        end
    end
end
