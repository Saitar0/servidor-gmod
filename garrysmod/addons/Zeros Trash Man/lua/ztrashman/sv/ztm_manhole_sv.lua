if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

ztm.manholes = ztm.manholes or {}


function ztm.f.Manhole_Initialize(Manhole)
    ztm.f.EntList_Add(Manhole)

    Manhole.IsBusy = false
    Manhole.Cooldown = 0

    table.insert(ztm.manholes,Manhole)
end

function ztm.f.Manhole_USE(Manhole,ply)
    if Manhole.IsBusy then return end

    ztm.f.Manhole_Switch(Manhole)
end

function ztm.f.Manhole_Switch(Manhole)

    Manhole:SetIsClosed( not Manhole:GetIsClosed())

    if Manhole:GetIsClosed() then
        ztm.f.Manhole_Close(Manhole)
    else
        ztm.f.Manhole_Open(Manhole)
    end
end

function ztm.f.Manhole_Open(Manhole)
    Manhole:SetIsClosed( false )
    Manhole.IsBusy = true
    ztm.f.Debug("Open manhole")

    timer.Simple(1.1,function()
        if IsValid(Manhole) then
            Manhole.IsBusy = false
        end
    end)

    // If no player is in distance then we close the manhole after 10 seconds
    ztm.f.Manhole_StartAutoClose(Manhole)

    if Manhole.Cooldown < CurTime() then

        if ztm.f.RandomChance(ztm.config.Manhole.chance) == false then
            ztm.f.Debug("No trash today!")
        else
            ztm.f.Debug("Rebuild Trash")
            Manhole:SetTrash(math.random(ztm.config.Manhole.min_amount,ztm.config.Manhole.max_amount))
        end

    else
        ztm.f.Debug("Cooldown: " .. math.Round(Manhole.Cooldown - CurTime()))
    end
    Manhole.Cooldown = ztm.config.Manhole.cooldown + CurTime()
end

function ztm.f.Manhole_Close(Manhole)
    Manhole:SetIsClosed( true )
    Manhole.IsBusy = true
    ztm.f.Debug("Close manhole")

    timer.Simple(1.1,function()
        if IsValid(Manhole) then
            Manhole.IsBusy = false
        end
    end)
end

function ztm.f.Manhole_StartAutoClose(Manhole)
    local timerID = "ztm_manhole_autocloser_" .. Manhole:EntIndex() .. "_timer"
    ztm.f.Timer_Remove(timerID)

    ztm.f.Timer_Create(timerID, 5, 1, function()
        ztm.f.Timer_Remove(timerID)

        if IsValid(Manhole) then
            if ztm.f.Manhole_PlayerInDistance(Manhole) then
                ztm.f.Debug("Player is in distance, Restart auto close timer!")
                ztm.f.Manhole_StartAutoClose(Manhole)
            else
                ztm.f.Manhole_Close(Manhole)
            end
        end
    end)
end

function ztm.f.Manhole_PlayerInDistance(Manhole)
    local _PlayerInDistance = false

    // Check if a player is in distance
    for k, v in pairs(ztm_PlayerList) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and ztm.f.InDistance(Manhole:GetPos(), v:GetPos(), 200) then
            _PlayerInDistance = true
            break
        end
    end
    return _PlayerInDistance
end




// Save function
concommand.Add( "ztm_save_manhole", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Manhole entities have been saved for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Manhole_Save()
    end
end )

concommand.Add( "ztm_remove_manhole", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Manhole entities have been removed for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Manhole_Remove()
    end
end )

function ztm.f.Manhole_Save()
    local data = {}

    for u, j in pairs(ztm.manholes) do
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
        file.Write("ztm/" .. string.lower(game.GetMap()) .. "_manholes" .. ".txt", util.TableToJSON(data))
    end
end

function ztm.f.Manhole_Load()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_manholes" .. ".txt", "DATA") then
        local data = file.Read("ztm/" .. string.lower(game.GetMap()) .. "_manholes" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("ztm_manhole")
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

            print("[Zeros WeedFarm] Finished loading Manhole Entities.")
        end
    else
        print("[Zeros WeedFarm] No map data found for Manhole entities. Please place some and do !saveztm to create the data.")
    end
end

function ztm.f.Manhole_Remove()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_manholes" .. ".txt", "DATA") then
        file.Delete("ztm/" .. string.lower(game.GetMap()) .. "_manholes" .. ".txt")
    end

    for k, v in pairs(ztm.manholes) do
        if IsValid(v) then
            v:Remove()
        end
    end
end
