if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

////////////////////////////////////////////
//////////// Virus Occopating  /////////////
////////////////////////////////////////////

// The occopating system runs through a list of players which got infected but havent developted any symtomes yet.
// While the virus is occopating inside the player it secretly infects other players close by.
// After a certain amount of time the player gets removed from the list and the virus breaks out.

zbl.Player_OV = zbl.Player_OV or {}

timer.Simple(5,function()
    zbl.f.OV_SetupTimer()
end)

function zbl.f.OV_SetupTimer()
    local timerid = "zbl_ov_timer"
    zbl.f.Timer_Remove(timerid)

    zbl.f.Timer_Create(timerid,10,0,function()
        if table.Count(zbl.Player_OV) > 0 then
            for k,v in pairs(zbl.Player_OV) do

                if IsValid(v) then

                    local vac_id = zbl.f.Player_GetVaccine(v)
                    if vac_id == -1 then continue end

                    local vac_data = zbl.config.Vaccines[vaccineID]
                    if vac_data == nil then continue end

                    local ov_data = vac_data.occopation
                    if ov_data == nil then continue end

                    zbl.f.Infect_Proximity(v:GetNWInt("zbl_Vaccine",-1),1, v:GetPos(),  ov_data.infection_radius, ov_data.infection_chance)
                end
            end
        end
    end)
end

// Tells us if a player is infected by virus in its occopating phase
function zbl.f.OV_IsContaminated(ply)
    return IsValid(zbl.Player_OV[zbl.f.Player_GetID(ply)])
end

function zbl.f.OV_AddPlayer(ply)
    zbl.f.Debug("zbl.f.OV_AddPlayer: " .. tostring(ply))
    zbl.Player_OV[zbl.f.Player_GetID(ply)] = ply
end

function zbl.f.OV_RemovePlayer(steamid)
    zbl.f.Debug("zbl.f.OV_RemovePlayer: " .. tostring(steamid))
    zbl.Player_OV[steamid] = nil
end

////////////////////////////////////////////
////////////////////////////////////////////
