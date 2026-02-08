if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

////////////////////////////////////////////
///////// Player Vaccinate / Cure //////////
////////////////////////////////////////////

// This list keeps track on which player is infected by which virus and at what stage
if zbl_ActiveVaccines == nil then
    zbl_ActiveVaccines = {}
end

function zbl.f.Player_SetActiveVaccine(steamID,vaccine_id,vaccine_stage)
    zbl_ActiveVaccines[steamID] = {id = vaccine_id,stage = vaccine_stage}
end

function zbl.f.Player_RemoveActiveVaccine(steamID)
    zbl_ActiveVaccines[steamID] = nil
end

function zbl.f.Player_GetActiveVaccine(steamID)
    local data = zbl_ActiveVaccines[steamID]
    if data then
        return data.id,data.stage
    end
end




// Returns the Protection Chance
function zbl.f.Player_GetProtectionChance(ply, vaccineID, vaccinestage)
    return zbl.config.ProtectionCheck(ply, vaccineID, vaccinestage)
end

// Tests the player Protection and removes a gasmask use if he has any
function zbl.f.Player_ProtectionTest(ply, vaccineID, vaccinestage)
    local chance = zbl.f.Player_GetProtectionChance(ply, vaccineID, vaccinestage)
    local immun =  zbl.f.RandomChance(chance)

    if ply:GetNWInt("zbl_RespiratorUses",0) > 0 then
        // Removes a use from the respirator
        zbl.f.GasMask_Use(ply)
    end

    zbl.f.Debug("Protection chance: " .. chance .. " %")

    zbl.f.Debug("zbl.f.Player_ProtectionTest: " .. zbl.f.Player_GetName(ply) .. " IsImmun: " .. tostring(immun))
    return chance , immun
end

// Same as Player_Vaccinate but its called only by viruses to diffrenciate it better
function zbl.f.Player_Infect(ply,vaccineID,vaccinestage)

    // We dont allow player to get infected near the Anti Infection zones
    if zbl.f.AIZ_NearZone(ply:GetPos()) then
        zbl.f.Debug("AIZ: Infection prevented")
        zbl.f.Notify(ply, "Protected Zone: Infection prevented!", 2)
        return
    end

    // Check if the player is immun/protected against the virus
    local chance , immun = zbl.f.Player_ProtectionTest(ply, vaccineID, vaccinestage)
    if immun then
        zbl.f.Debug("Infection Failed")
        zbl.f.Debug(zbl.f.Player_GetName(ply) .. " is well protected against any virus.")
        return
    end

    // If the player got cured from this virus then lets check if he is still immun against it
    if ply.zbl_Immuinty and ply.zbl_Immuinty[vaccineID] and CurTime() < ply.zbl_Immuinty[vaccineID] then
        zbl.f.Debug("Infection Failed")
        zbl.f.Debug(zbl.f.Player_GetName(ply) .. " is still immun against this virus!")
        return
    end

    zbl.f.Player_StartVaccine(ply,vaccineID,vaccinestage)
end

// Applys a Vaccine/Virus to a Player
// This gets only called by a player
function zbl.f.Player_Vaccinate(ply,vaccineID,vaccinestage,inflictor)
    zbl.f.Debug("zbl.f.Player_Vaccinate")

    // We dont allow player to get infected near the Anti Infection zones
    if zbl.f.AIZ_NearZone(ply:GetPos()) then
        zbl.f.Debug("AIZ: Infection prevented")
        zbl.f.Notify(ply, "Protected Zone: Infection prevented!", 2)
        return
    end

    // Custom Hook
    hook.Run("zbl_OnPlayerInject" ,ent, vaccineID,inflictor)

    zbl.f.Player_StartVaccine(ply,vaccineID,vaccinestage)
end

// Starts the specified vaccine
function zbl.f.Player_StartVaccine(ply,vaccineID,vaccinestage)

    // If the vaccine id is a virus then we stop any active abillity and infect the player
    if zbl.f.Player_VaccineOverride(ply) == true then
        zbl.f.Player_ForceCure(ply)
    end

    // Cant infect the player if he is allready infected
    if zbl.f.Player_HasVaccine(ply) then
        zbl.f.Debug(zbl.f.Player_GetName(ply) .. " is allready infected " .. zbl.config.Vaccines[ply:GetNWInt("zbl_Vaccine", -1)].name)

        return
    end

    local vaccineData = zbl.config.Vaccines[vaccineID]
    if vaccineData == nil then return end

    // Custom Hook
    hook.Run("zbl_OnPlayerInfect" ,ply, vaccineID)


    // Is this a virus
    if vaccineData.isvirus then

        zbl.f.Debug(zbl.f.Player_GetName(ply) .. " got infected with " .. vaccineData.name)

        // Has it occopation period?
        if vaccineData.occopation == nil then

            zbl.f.Player_ApplyVaccineStage(ply,vaccineID,vaccinestage)
            return
        end

        // This tells that the players virus is still in its occopation stage
        ply:SetNWInt( "zbl_VaccineStage", 0 )

        ply:SetNWInt( "zbl_Vaccine", vaccineID )

        // Start occopation Timer
        local timerid = "zbl_vaccine_occopation_timer_" .. zbl.f.Player_GetID(ply)
        zbl.f.Timer_Remove(timerid)

        // Add player to occopation list
        zbl.f.OV_AddPlayer(ply)

        zbl.f.Timer_Create(timerid,vaccineData.occopation.time,1,function()
            zbl.f.Timer_Remove(timerid)

            // Remove Player from Occopation list
            zbl.f.OV_RemovePlayer(zbl.f.Player_GetID(ply))

            zbl.f.Player_ApplyVaccineStage(ply,vaccineID,vaccinestage)
        end)
        zbl.f.Debug(zbl.f.Player_GetName(ply) .. " Occopation Timer started with " .. vaccineData.occopation.time .. " seconds!")
    else

        zbl.f.Debug(zbl.f.Player_GetName(ply) .. " got vaccined with " .. vaccineData.name)

        // Notify the player that his ability has started
        zbl.f.Notify(ply, string.Replace(zbl.language.General["AbilityStart"],"$AbilityName",vaccineData.name), 4)


        zbl.f.Player_ApplyVaccineStage(ply,vaccineID,vaccinestage)
    end
end


// Cures all the players in proximity if the vaccine id matches
function zbl.f.Player_CureProximity(vac_id, pos, dist)
    if vac_id == -1 then return end
    zbl.f.Debug("zbl.f.Player_CureProximity")

    for k, v in pairs(zbl_PlayerList) do

        if IsValid(v) and v:Alive() and zbl.f.InDistance(pos, v:GetPos(), dist) then

            local vaccindID = zbl.f.Player_GetVaccine(v)

            // Check if player is even infected
            if vaccindID ~= -1 and vaccindID == vac_id then
                zbl.f.Player_MakeImmun(v, vac_id, zbl.config.Vaccines[vac_id].cure.immunity_time)
                zbl.f.Player_Cure(v)
            end
        end
    end
end

function zbl.f.Player_ApplyVaccineStage(ply,vaccineID,vaccinestage)
    zbl.f.Debug("zbl.f.Player_ApplyVaccineStage")

    local vaccineData = zbl.config.Vaccines[vaccineID]
    if vaccineData == nil then return end

    // Stores which steamid got vaccined by which vaccine
    zbl.f.Player_SetActiveVaccine(zbl.f.Player_GetID(ply),vaccineID,vaccinestage)

    // Changes the Visual Appearance of the Player
    zbl.f.Player_ChangeAppearance(ply, vaccineData, vaccinestage or 1)

    // Start Symptomes
    zbl.f.Symptome_OnStart(ply,vaccineID,vaccinestage)

    // Start Vaccine Timer
    local timerid = "zbl_vaccinetimer_" .. zbl.f.Player_GetID(ply)
    zbl.f.Timer_Remove(timerid)
    zbl.f.Timer_Create(timerid,vaccineData.duration,1,function()

        zbl.f.Timer_Remove(timerid)

        zbl.f.Symptome_OnEnd(ply)

        local nextStage = ply:GetNWInt("zbl_VaccineStage", 1) + 1

        // Here we gonna check if the vaccine has more stages and if so then we check if it can mutate
        if vaccineData.mutation_chance > 1 and table.Count(vaccineData.mutation_stages) > 1 and vaccineData.mutation_stages[nextStage] and zbl.f.RandomChance(vaccineData.mutation_chance) then

            zbl.f.Debug("Vaccine: " .. vaccineData.name .. " just mutated to stage " .. nextStage .. "!")

            // Lets mutate the vaccine to the next stage
            zbl.f.Player_ApplyVaccineStage(ply,ply:GetNWInt("zbl_Vaccine", -1),nextStage)
        else
            if vaccineData.isvirus == false then
                zbl.f.Notify(ply, string.Replace(zbl.language.General["AbilityStop"],"$AbilityName",vaccineData.name), 4)
            end
            zbl.f.Player_ForceCure(ply)
        end
    end)

    ply:SetNWInt( "zbl_VaccineStage", vaccinestage or 1 )

    ply:SetNWInt( "zbl_Vaccine", vaccineID )
end

// Makes the player immun against this virus id for a certain amount of time
function zbl.f.Player_MakeImmun(ply,virus_id,time)
    if ply.zbl_Immuinty == nil then
        ply.zbl_Immuinty = {}
    end

    ply.zbl_Immuinty[virus_id] = CurTime() + time
end

// Called when the player gets cured/vaccine removed
function zbl.f.Player_Cure(ply)
    zbl.f.Debug("zbl.f.Player_Cure")
    if not IsValid(ply) then return end

    local vac_id = ply:GetNWInt("zbl_Vaccine",-1)

    // Custom Hook
    hook.Run("zbl_OnPlayerCured" ,ply, vac_id)

    zbl.f.Symptome_OnEnd(ply)

    local timerid_vac = "zbl_vaccinetimer_" .. zbl.f.Player_GetID(ply)
    zbl.f.Timer_Remove(timerid_vac)

    local timerid_ov = "zbl_vaccine_occopation_timer_" .. zbl.f.Player_GetID(ply)
    zbl.f.Timer_Remove(timerid_ov)

    // Removes the activevaccine id from the list
    zbl.f.Player_RemoveActiveVaccine(zbl.f.Player_GetID(ply))

    // Resets the Visual Appearance of the Player
    zbl.f.Player_ResetAppearance(ply)

    // Remove Player from Occopation list
    zbl.f.OV_RemovePlayer(zbl.f.Player_GetID(ply))

    local vaccineData = zbl.config.Vaccines[vac_id]
    if vaccineData == nil then return end


    ply:SetNWInt( "zbl_VaccineStage", -1 )

    ply:SetNWInt( "zbl_Vaccine", -1 )

    zbl.f.Debug(zbl.f.Player_GetName(ply) .. " got cured from " .. vaccineData.name)
end

// This gets called by the script when the player dies or the vaccine run out of mutation stages
function zbl.f.Player_ForceCure(ply)
    zbl.f.Debug("zbl.f.Player_ForceCure")
    if not IsValid(ply) then return end

    local vac_id = ply:GetNWInt("zbl_Vaccine",-1)

    // Lets make the player immun against any virus for the next 10 seconds
    zbl.f.Player_MakeImmun(ply,vac_id,10)

    zbl.f.Player_Cure(ply)
end


// Checks if the player has any vaccine currently in his system
function zbl.f.Player_HasVaccine(ply)
    return ply:GetNWInt("zbl_Vaccine", -1) ~= -1
end

// This only returns true if the player is infected by a virus
function zbl.f.Player_IsInfected(ply)
    local id = ply:GetNWInt("zbl_Vaccine", -1)

    if id ~= -1 and zbl.config.Vaccines[id] and zbl.config.Vaccines[id].isvirus then
        return true
    else
        return false
    end
end

// Returns the currently active vaccine
function zbl.f.Player_GetVaccine(ply)
    return ply:GetNWInt("zbl_Vaccine", -1)
end

// Tells us if the players current infection can be overriden by another vaccine
// Return true to allow the current vaccine to be overriden
function zbl.f.Player_VaccineOverride(ply)
    local active_vac_id = zbl.f.Player_GetVaccine(ply)

    if active_vac_id > 0 and zbl.config.Vaccines[active_vac_id] then
        if zbl.config.Vaccines[active_vac_id].isvirus == false then
            return true
        else
            return false
        end
    else
        return nil
    end
end
////////////////////////////////////////////
////////////////////////////////////////////
