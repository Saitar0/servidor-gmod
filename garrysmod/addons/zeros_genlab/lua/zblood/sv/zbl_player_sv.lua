if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}


////////////////////////////////////////////
//////////////// NW Timeout ////////////////
////////////////////////////////////////////
// How often are clients allowed to send net messages to the server
zbl_NW_TIMEOUT = 0.1

function zbl.f.Player_Timeout(ply)
    local Timeout = false

    if ply.zbl_NWTimeout and ply.zbl_NWTimeout > CurTime() then
        zbl.f.Debug("Player_Timeout!")

        Timeout = true
    end

    ply.zbl_NWTimeout = CurTime() + zbl_NW_TIMEOUT

    return Timeout
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////// Player Initialize ////////////
////////////////////////////////////////////
if zbl_PlayerList == nil then
    zbl_PlayerList = {}
end

function zbl.f.Player_Add(ply)
    zbl_PlayerList[zbl.f.Player_GetID(ply)] = ply
end

function zbl.f.Player_Remove(steamid)
    zbl_PlayerList[steamid] = nil
end

util.AddNetworkString("zbl_Player_Initialize")
net.Receive("zbl_Player_Initialize", function(len, ply)

    if not IsValid(ply) then return end

    if ply.zbl_HasInitialized then
        return
    else
        ply.zbl_HasInitialized = true
    end

    zbl.f.Debug("zbl_Player_Initialize Netlen: " .. len)

    zbl.f.Player_Add(ply)

    ply:SetNWInt( "zbl_Vaccine", -1 )
    ply:SetNWInt( "zbl_VaccineStage", -1 )
end)
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////////// Appearance ////////////////
////////////////////////////////////////////
// Changes the Visual Appearance of the Player
function zbl.f.Player_ChangeAppearance(ply, vacData, vacStage)
    zbl.f.Debug("zbl.f.Player_ChangeAppearance")

    local mutation_stage = vacData.mutation_stages[vacStage]
    if mutation_stage == nil then return end

    if mutation_stage.appearance then
        local appearanceData = zbl.config.AppearanceEffects[mutation_stage.appearance]
        if appearanceData then
            // Apply Wound material
            if appearanceData.MaterialOverlay then
                ply:SetMaterial( appearanceData.MaterialOverlay, true )
            end

            // Apply Wound Color
            if appearanceData.ColorOverlay then
                ply:SetColor( appearanceData.ColorOverlay, true )
            end

            if appearanceData.PlayerModel then
                ply.zbl_OldPlayerModel = ply:GetModel()
                ply:SetModel( appearanceData.PlayerModel )
            end
        end
    end
end

// Resets the Visual Appearance of the Player
function zbl.f.Player_ResetAppearance(ply)
    ply:SetMaterial( "", true )

    ply:SetColor(Color(255,255,255,255))


    if ply.zbl_OldPlayerModel then
        ply:SetModel(ply.zbl_OldPlayerModel)
        ply.zbl_OldPlayerModel = nil
    end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////// Player Status Changed /////////
////////////////////////////////////////////
local zbl_DeleteEnts = {
    ["zbl_flask"] = true,
    ["zbl_lab"] = true,
    ["zbl_scanner"] = true,
}

function zbl.f.Player_CleanUpEnts(steamID)
    for k, v in pairs(zbl.EntList) do
        if IsValid(v) and zbl_DeleteEnts[v:GetClass()] and zbl.f.GetOwnerID(v) == steamID then
            SafeRemoveEntity(v)
        end
    end
end

function zbl.f.Player_Disconnect(steamid)

    // Remove any Vaccine/Symptome timer that exists from this player
    local timerid_vac = "zbl_vaccinetimer_" .. steamid
    zbl.f.Timer_Remove(timerid_vac)

    local vaccine_id, vaccine_stage = zbl.f.Player_GetActiveVaccine(steamid)
    if vaccine_id and vaccine_stage then

        local vaccineData = zbl.config.Vaccines[vaccine_id]

        if vaccineData == nil then return end

        local mutation_stage = vaccineData.mutation_stages[vaccine_stage]

        if mutation_stage == nil then return end


        if mutation_stage.symptomes and table.Count(mutation_stage.symptomes) > 0 then
            for k, v in pairs(mutation_stage.symptomes) do
                if zbl.Symptomes[k] then
                    local sympt_timerid = "zbl_" .. k .. "_" .. steamid
                    zbl.f.Timer_Remove(sympt_timerid)
                end
            end
        end


        // Removes the activevaccine id from the list
        zbl.f.Player_RemoveActiveVaccine(steamid)
    end

    // Remove the occopation timer if it exists
    local timerid_ov = "zbl_vaccine_occopation_timer_" .. steamid
    zbl.f.Timer_Remove(timerid_ov)

    // Removes player from occopation list if he is on it
    zbl.f.OV_RemovePlayer(steamid)

    // Remove the player from the list
    zbl.f.Player_Remove(steamid)

    // Saves the player DNA Points if he got any
    zbl.f.Lab_Data_PlayerDisconnect(steamid)

    // Remove the player entities
    zbl.f.Player_CleanUpEnts(steamid)

    // Stop any quest timer that might exist
    zbl.f.Quest_Stop(steamid,nil)
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "zbl_player_disconnect", function(data)
    local steamid

    if data.bot == 1 then
        steamid = data.userid
    else
        steamid = data.networkid
    end

    zbl.f.Player_Disconnect(steamid)
end)

hook.Add("PlayerDeath", "zbl_PlayerDeath", function(victim, inflictor, attacker)

    if zbl.f.Player_HasVaccine(victim) then
        zbl.f.Debug("zbl.f.Player_Death")

        local vac_id = victim:GetNWInt("zbl_Vaccine", -1)
        local vac_data = zbl.config.Vaccines[vac_id]
        local vac_stage = victim:GetNWInt("zbl_VaccineStage",-1)

        // Create corpse
        if zbl.config.Corpse.enabled then
            local rag = victim:GetRagdollEntity()
            if IsValid(rag) then
                rag:Remove()
            end
            zbl.f.Corpse_Spawn(victim,vac_id,vac_stage)
        end

        if vac_data.cure and vac_data.cure.ondeath then
            timer.Simple(1,function()
                if IsValid(victim) then
                    zbl.f.Player_ForceCure(victim)
                end
            end)
        end
    end

    // If the player had a gasmask then he lost it now
    zbl.f.GasMask_Equipt(victim, false)

    zbl.f.NPC_ForceCloseMenu(victim)
end)

hook.Add("OnPlayerChangedTeam", "zbl_OnPlayerChangedTeam", function(ply, before, after)
    if zbl.config.Jobs[before] == true then
        // Stop any quest timer that might exist
        zbl.f.Quest_Stop(zbl.f.Player_GetID(ply),ply)

        zbl.f.Lab_Data_PlayerChangedJob(zbl.f.Player_GetID(ply))

        zbl.f.Player_CleanUpEnts(zbl.f.Player_GetID(ply))
    end

    // If the player is infected then lets call the Appearance update again, if the mutation stage changes his appearance then we need to update it
    // Because changing job also changes the player model
    timer.Simple(0,function()

        if IsValid(ply) then

            local vaccine_id = zbl.f.Player_GetVaccine(ply)

            if vaccine_id ~= -1 then
                local vacData = zbl.config.Vaccines[vaccine_id]
                zbl.f.Player_ChangeAppearance(ply, vacData, ply:GetNWInt("zbl_VaccineStage", 1))
            end

            // If the player had a gasmask before job change and how his chance is higher or equals 100 then this means he has some other protection now and we remove his mask
            if zbl.f.Player_GetProtectionChance(ply, nil, nil) >= 100 and ply:GetNWInt("zbl_RespiratorUses",0) > 0 then
                zbl.f.GasMask_Equipt(ply, false)
            end
        end
    end)
end)


// Used by the Player to tell him his Candy Score / Points
hook.Add("PlayerSay", "zbl_PlayerSay", function(ply, text)
    if string.sub(string.lower(text), 1, 9) == "!zbl_save" and zbl.f.IsAdmin(ply) then

        // Save the NPCs current Position
        zbl.f.Notify(ply, "Genetic NPC has been saved for the map " .. game.GetMap() .. "!", 0)
        zbl.f.NPC_Save()

        // Save VirusHotSpots
        zbl.f.VHS_SavePositions(ply)

        // Save Anit Infection Zones
        zbl.f.AIZ_SavePositions(ply)

    elseif string.sub(string.lower(text), 1, 9) == "!dropmask" then
        if ply:GetNWInt("zbl_RespiratorUses",0) > 0 then
            zbl.f.GasMask_Equipt(ply, false)
        end
    end
end)
////////////////////////////////////////////
////////////////////////////////////////////
