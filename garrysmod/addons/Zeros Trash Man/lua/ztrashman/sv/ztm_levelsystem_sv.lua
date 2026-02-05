if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

ztm.data = ztm.data or {}

function ztm.data.DataChanged(ply)
    //ztm.f.Debug("ztm.data.DataChanged")

    if not ply.ztm_DataChanged then
        ply.ztm_DataChanged = true
    end
end

function ztm.data.PlayerDisconnect(ply)
    ztm.f.Debug("ztm.data.PlayerDisconnect")

    if (ply.ztm_DataChanged) then
        ztm.data.Save(ply)
    end
end

hook.Add("PlayerDisconnected", "ztm.data.playerdisconnect_id", ztm.data.PlayerDisconnect)

function ztm.data.Init(ply)

    if ply.ztm_data then return end
    ztm.f.Debug("ztm.data.Init: " .. ply:Nick())

    if not file.Exists("ztm", "DATA") then
        file.CreateDir("ztm")
    end

    if not file.Exists("ztm/data/", "DATA") then
        file.CreateDir("ztm/data/")
    end

    local plyID = ply:SteamID64()

    if file.Exists("ztm/data/" .. plyID .. ".txt", "DATA") then
        local data = file.Read("ztm/data/" .. plyID .. ".txt", "DATA")
        data = util.JSONToTable(data)
        ply.ztm_data = data
        ztm.f.Debug("Level Data fully loaded!")

    else
        ply.ztm_data = {
            xp = 0,
            lvl = 1
        }
        ztm.f.Debug("Level Data created!")
    end

    ztm.data.DataChanged(ply)
end

concommand.Add( "ztm_lvlsys_reset", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then

        ply.ztm_data = {
            xp = 0,
            lvl = 1
        }
        ztm.data.Save(ply)
        ztm.data.UpdateSWEP(ply)
    end
end )

concommand.Add( "ztm_lvlsys_max", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then

        ply.ztm_data = {
            xp = 0,
            lvl = table.Count(ztm.config.TrashSWEP.level)
        }
        ztm.data.Save(ply)
        ztm.data.UpdateSWEP(ply)
    end
end )

function ztm.data.AddXP(ply, xp)
    //ztm.f.Debug("ztm.data.AddXP")

    ply.ztm_data = {
        xp = (ply.ztm_data.xp or 0) + xp,
        lvl = ply.ztm_data.lvl
    }

    ztm.data.LevelUP_Check(ply)
end

function ztm.data.LevelUP_Check(ply)
    //ztm.f.Debug("ztm.data.LevelUP_Check")

    // Checks if there is a level after the current one
    if ztm.config.TrashSWEP.level[ply.ztm_data.lvl + 1] then

        local nextXP = ztm.config.TrashSWEP.level[ply.ztm_data.lvl].next_xp

        // Checks if we can level up
        if ply.ztm_data.xp >= nextXP then
            ply.ztm_data = {
                xp = 0,
                lvl = ply.ztm_data.lvl + 1
            }

            ztm.data.Save(ply)
        end
    end

    ztm.data.DataChanged(ply)

    ztm.data.UpdateSWEP(ply)
end

function ztm.data.UpdateSWEP(ply)
    //ztm.f.Debug("ztm.data.UpdateSWEP")

    local swep = ply:GetWeapon( "ztm_trashcollector" )
    if swep and IsValid(swep) then

        swep:SetPlayerLevel(ply.ztm_data.lvl)
        swep:SetPlayerXP(ply.ztm_data.xp)
    end
end

function ztm.data.Save(ply)
    ztm.f.Debug("ztm.data.Save")

    local plyID = ply:SteamID64()
    file.Write("ztm/data/" .. tostring(plyID) .. ".txt", util.TableToJSON(ply.ztm_data))
end


function ztm.data.Save_All()
    for k, v in pairs(ztm_PlayerList) do

        if (v.ztm_DataChanged) then
            ztm.data.Save(v)
        end
    end
end

function ztm.data.Check_DataSaver_TimerExist()

    if timer.Exists("ztm_DataSaver_timer") then
        timer.Remove("ztm_DataSaver_timer")
    end

    timer.Create("ztm_DataSaver_timer", ztm.config.TrashSWEP.data_save_interval, 0, ztm.data.Save_All)
end

hook.Add("InitPostEntity", "ztm_DataSaver_timer_OnMapLoad", ztm.data.Check_DataSaver_TimerExist)
