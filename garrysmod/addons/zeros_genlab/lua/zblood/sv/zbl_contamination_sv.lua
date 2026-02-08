if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}



////////////////////////////////////////////
////////// Object Contamination  ///////////
////////////////////////////////////////////

// The contamination system handels the infection of player by objects and the contamination of objects by players

zbl.ContaminatedObjects = zbl.ContaminatedObjects or {}

if zbl.config.Contamination.enabled then
    timer.Simple(5,function()
        zbl.f.Ctmn_SetupTimer()
    end)
end

// Creates the global contamination timer
function zbl.f.Ctmn_SetupTimer()
    local timerid = "zbl_ctmn_timer"
    zbl.f.Timer_Remove(timerid)

    zbl.f.Timer_Create(timerid,1,0,function()
        for k,v in pairs(zbl.ContaminatedObjects) do

            if IsValid(v) then

                if CurTime() > v.zbl_InfectionTime then
                    zbl.f.Ctmn_ObjectSanitise(v)
                end
            else
                zbl.ContaminatedObjects[k] = nil
            end
        end
    end)
end

// Clears the object from any contamination
function zbl.f.Ctmn_ObjectSanitise(Object)
    if not IsValid(Object) then return end
    zbl.f.Debug("zbl.f.Ctmn_ObjectSanitise " .. tostring(Object))

    zbl.ContaminatedObjects[Object:EntIndex()] = nil

    Object:SetNWInt("zbl_Vaccine",-1)


    //Reset Virus material
    Object:SetMaterial( "", true )
end

// Contaminates the object
function zbl.f.Ctmn_ObjectContaminate(Object,virus_id)
    if not IsValid(Object) then return end

    if zbl.f.AIZ_NearZone(Object:GetPos()) then
        zbl.f.Debug("AIZ: Contamination Failed")
        return
    end

    zbl.f.Debug("zbl.f.Ctmn_ObjectContaminate " .. tostring(Object))
    local virus_data = zbl.config.Vaccines[virus_id]

    Object:SetNWInt("zbl_Vaccine",virus_id)

    Object.zbl_InfectionTime = CurTime() + virus_data.contamination.time

    zbl.ContaminatedObjects[Object:EntIndex()] = Object

    //Set Virus material
    if zbl.config.Contamination.visible == true and virus_data.mat then
        Object:SetMaterial(virus_data.mat, true)
    end
end

// Contaminates all object in proximity
function zbl.f.Ctmn_ProximityContaminate(pos, dist, virus_id)
    for a, w in pairs(ents.FindInSphere(pos, dist)) do
        if IsValid(w) and zbl.config.Contamination.ents[w:GetClass()] then
            zbl.f.Ctmn_ObjectContaminate(w, virus_id)
        end
    end
end

// Checks if the object can be contaminated
function zbl.f.Ctmn_CanBeContaminated(Object)

    return zbl.config.Contamination.ents[Object:GetClass()]
end

// Checks if the object is contaminated
function zbl.f.Ctmn_IsObjectContaminated(Object)
    return Object:GetNWInt("zbl_Vaccine",-1) ~= -1
end

// Used for detecting Object interfactions
hook.Add( "PlayerUse", "zbl_PlayerUse", function( ply, ent )
    if zbl.config.Contamination.enabled and IsValid(ent) and IsValid(ply) and (ply.zbl_NextObjectUse == nil or ply.zbl_NextObjectUse < CurTime()) and zbl.f.Ctmn_CanBeContaminated(ent) then

        ply.zbl_NextObjectUse = CurTime() + 1

        // Is the player allready infected?
        if zbl.f.Player_HasVaccine(ply) then
            // Player is allready sick!

            // Does the player contaminate the object?
            local virus_id = zbl.f.Player_GetVaccine(ply)
            local virus_data = zbl.config.Vaccines[virus_id]

            if virus_data and virus_data.isvirus and virus_data.contamination and zbl.f.RandomChance(virus_data.contamination.chance) then

                // Object contaminated!
                zbl.f.Ctmn_ObjectContaminate(ent,virus_id)
            end
        else
            // Player is not infected!

            // Is the object contaminated?
            if zbl.f.Ctmn_IsObjectContaminated(ent) then

                // Player infected!
                zbl.f.Player_Infect(ply,ent:GetNWInt("zbl_Vaccine",1),1)
            end
        end


        if zbl.config.Contamination.AutoContaminate.enabled and zbl.config.Contamination.AutoContaminate.HeavyUsePriority then
            if zbl.InteractedObjects[ent] == nil then
                zbl.InteractedObjects[ent] = 1
            else
                zbl.InteractedObjects[ent] = math.Clamp(zbl.InteractedObjects[ent] + 1,1,25)
            end
            zbl.f.Debug("InteractedObjects[" .. tostring(ent) .. "] Count: " .. zbl.InteractedObjects[ent])
        end
    end
end )

////////////////////////////////////////////
////////////////////////////////////////////






////////////////////////////////////////////
//////////// Auto Contamination  ///////////
////////////////////////////////////////////

// This system automaticly contaminates objects every interval

if zbl.config.Contamination.AutoContaminate.enabled then
    timer.Simple(5,function()
        zbl.f.Ctmn_Auto_SetupTimer()
    end)
end

zbl.InteractedObjects = zbl.InteractedObjects or {}

// Creates the global contamination timer
function zbl.f.Ctmn_Auto_SetupTimer()
    zbl.f.Debug("zbl.f.Ctmn_Auto_SetupTimer")

    local timerid = "zbl_ctmn_auto_timer"
    zbl.f.Timer_Remove(timerid)

    zbl.f.Timer_Create(timerid,zbl.config.Contamination.AutoContaminate.interval,0,function()

        zbl.f.Debug("zbl.f.Ctmn_AutoContaminate")

        local ent_pool = {}

        // Get All the entities which can be contaminated on the server
        if zbl.config.Contamination.AutoContaminate.HeavyUsePriority and table.Count(zbl.InteractedObjects) > 0 then
            for ent, count in pairs(zbl.InteractedObjects) do
                if IsValid(ent) and zbl.f.Ctmn_IsObjectContaminated(ent) == false then
                    for i = 1, (count or 1) do
                        table.insert(ent_pool, ent)
                    end
                end
            end

            // Lets reset the interacted table
            zbl.InteractedObjects = {}
        else

            for k, v in pairs(ents.GetAll()) do
                if IsValid(v) and zbl.f.Ctmn_CanBeContaminated(v) and zbl.f.Ctmn_IsObjectContaminated(v) == false then
                    table.insert(ent_pool, v)
                end
            end
        end

        ent_pool = zbl.f.table_randomize(ent_pool)
        zbl.f.Debug("zbl.f.Ctmn_AutoContaminate_EntityPool")
        zbl.f.Debug(ent_pool)
        local winner_ent = ent_pool[math.random(#ent_pool)]
        zbl.f.Debug("zbl.f.Ctmn_AutoContaminate_WinnerEntity " .. tostring(winner_ent))

        // Generate a random virus id according to the spawn chance
        local pool = {}
        for k, v in pairs(zbl.config.Contamination.AutoContaminate.virus_chance) do
            for i = 1, v do
                table.insert(pool, k)
            end
        end
        pool = zbl.f.table_randomize(pool)
        local virus_id = pool[math.random(#pool)]
        zbl.f.Debug("zbl.f.Ctmn_AutoContaminate_Virus " .. zbl.config.Vaccines[virus_id].name)

        zbl.f.Ctmn_ObjectContaminate(winner_ent,virus_id)


        //zbl.f.Timer_Remove("zbl_ctmn_auto_timer")
        //debugoverlay.Sphere(winner_ent:GetPos(), 15, 15, Color(0, 255, 0), true)
    end)
end

////////////////////////////////////////////
////////////////////////////////////////////
