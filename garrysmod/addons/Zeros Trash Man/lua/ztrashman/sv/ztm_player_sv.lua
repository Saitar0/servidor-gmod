if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

if ztm_PlayerList == nil then
    ztm_PlayerList = {}
end

function ztm.f.Add_Player(ply)
    table.insert(ztm_PlayerList, ply)
end

hook.Add("PlayerInitialSpawn", "ztm_PlayerInitialSpawn", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then
            ztm.f.Add_Player(ply)
        end
    end)
end)


local ztm_DeleteEnts = {
    ["ztm_trashbag"] = true,
}

function ztm.f.Cleanup_PlayerEnts(pl)
    for k, v in pairs(ztm.EntList) do
        if IsValid(v) and ztm_DeleteEnts[v:GetClass()] and ztm.f.GetOwnerID(v) == pl:SteamID() then
            v:Remove()
        end
    end
end

hook.Add("PlayerDisconnected", "ztm_player_disconnect", function(ply)
    ztm.f.Cleanup_PlayerEnts(ply)
end)


hook.Add("OnPlayerChangedTeam", "ztm_OnPlayerChangedTeam", function(pl, before, after)
    if before == TEAM_ZTM_TRASHMAN then
        ztm.f.Cleanup_PlayerEnts(pl)
        ztm.f.Debug("Player changed Job, entities removed!")
    end


    if after == TEAM_ZTM_TRASHMAN then
        pl:SetNWFloat( "ztm_trash", 0 )
    end
end)



// Dirty Players
concommand.Add( "ztm_debug_addbots_to_playerlist", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then

        for k, v in pairs(player.GetBots() ) do

            if IsValid(v) and v:Alive() then
                ztm.f.Add_Player(v)
            end
        end
    end
end )


function ztm.f.PlayerTrash_Timer()
    ztm.f.PlayerTrash_SetRandomPlayerDirty()
end

function ztm.f.PlayerTrash_SetRandomPlayerDirty()


    local valid_plys = {}
    for k, v in pairs(ztm_PlayerList) do

        if IsValid(v) and v:IsPlayer() and v:Alive() and v:Team() ~= TEAM_ZTM_TRASHMAN and v:GetNWFloat( "ztm_trash", 0 ) <= 0 then
            if table.Count(ztm.config.PlayerTrash.jobs) > 0 then
                if ztm.config.PlayerTrash.jobs[ ztm.f.GetPlayerJob(v) ] then
                    table.insert(valid_plys,v)
                end
            else
                table.insert(valid_plys,v)
            end
        end
    end

    if valid_plys and table.Count(valid_plys) > 0 then
        local rnd_ply = valid_plys[ math.random( #valid_plys ) ]
        ztm.f.Player_MakeDirty(rnd_ply)
    end
end

function ztm.f.Check_PlayerTrash_TimerExist()
    if ztm.config.PlayerTrash.Enabled == false then return end

    if timer.Exists("ztm_PlayerTrash_timer") then
        timer.Remove("ztm_PlayerTrash_timer")
    end

    timer.Create("ztm_PlayerTrash_timer", ztm.config.PlayerTrash.Interval, 0, ztm.f.PlayerTrash_Timer)
end

hook.Add("InitPostEntity", "ztm_PlayerTrash_timer_OnMapLoad", ztm.f.Check_PlayerTrash_TimerExist)


function ztm.f.Player_MakeDirty(ply)
    if not IsValid(ply) then return end

    local amount = math.random(ztm.config.PlayerTrash.trash_min,ztm.config.PlayerTrash.trash_max)
    ply:SetNWFloat( "ztm_trash", math.Clamp(ply:GetNWFloat( "ztm_trash", 0 ) + amount,0,ztm.config.PlayerTrash.Limit  ))
    ztm.f.Debug("Set " .. ply:Nick() .. " dirty with " .. amount .. ztm.config.UoW .. " of trash!")
end
