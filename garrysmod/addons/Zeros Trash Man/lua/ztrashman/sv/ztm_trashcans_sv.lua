if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

ztm.trashcans = ztm.trashcans or {}

function ztm.f.Trashcan_AddEntity(ent)
    ent:SetNWInt( "ztm_trash", 0 )
    table.insert(ztm.trashcans,ent)
end

hook.Add("InitPostEntity", "ztm_InitPostEntity_CatchTrashcans", function()
    if ztm.config.TrashCans.Enabled then
        timer.Simple(1, function()
            ztm.f.Trashcan_CatchEntities()
        end)
    end
end)


function ztm.f.Trashcan_CatchEntities()
    ztm.trashcans = {}

    for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and ztm.config.TrashCans.models[v:GetModel()] and ztm.config.TrashCans.class[v:GetClass()] then
            //debugoverlay.Sphere(v:GetPos() + v:GetRight() * math.random(-5, 5) + v:GetForward() * math.random(-5, 5), 5, 15, ztm.default_colors["white01"], true)
            ztm.f.Trashcan_AddEntity(v)
        end
    end
end

concommand.Add("ztm_debug_CatchTrashcans", function(ply, cmd, args)
    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Trashcan_CatchEntities()
    end
end)

concommand.Add("ztm_debug_GetModel", function(ply, cmd, args)
    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        local tr = ply:GetEyeTrace()

        if tr.Hit and IsValid(tr.Entity) then
            local model = tr.Entity:GetModel()
            if model then
                print("[ DEBUG ] Model: " .. model)
            end
        end

    end
end)

function ztm.f.Trashcan_RefreshTrashcans()
    for k, v in pairs(ztm.trashcans) do
        if IsValid(v) then
            local max = ztm.config.TrashCans.models[v:GetModel()]

            v:SetNWInt( "ztm_trash", math.Clamp((v:GetNWInt("ztm_trash",0) or 0) + ztm.config.TrashCans.Refresh_Amount,0,max ))
        end
    end
end

function ztm.f.Check_TrashCanRefresher_TimerExist()
    if ztm.config.TrashCans.Enabled == false then return end

    if timer.Exists("ztm_trashcan_refresher") then
        timer.Remove("ztm_trashcan_refresher")
    end

    timer.Create("ztm_trashcan_refresher", ztm.config.TrashCans.Refresh_Interval, 0, ztm.f.Trashcan_RefreshTrashcans)
end

hook.Add("InitPostEntity", "ztm_trashcan_refresher_OnMapLoad", ztm.f.Check_TrashCanRefresher_TimerExist)
