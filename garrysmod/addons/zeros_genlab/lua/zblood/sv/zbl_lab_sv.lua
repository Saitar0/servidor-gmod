if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

// Called when the player joins the server
function zbl.f.Lab_Initialize(Lab)
    zbl.f.EntList_Add(Lab)

    Lab.AllowInput = true

    Lab.Samples = {}
    Lab.SampleCooldown = {}

    timer.Simple(0,function()
        if IsValid(Lab) then
            zbl.f.Lab_Data_Init(Lab,zbl.f.GetOwner(Lab))
        end
    end)
end

function zbl.f.Lab_Touch(Lab,other)
    if not IsValid(Lab) then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "zbl_flask" then return end
    if zbl.f.CollisionCooldown(other) then return end
    if Lab.AllowInput == false then return end

    zbl.f.Lab_AddSample(Lab,other)
end

// Blocks the touch input for a certain amount of time
function zbl.f.Lab_BlockTouchInput(Lab,time)
    Lab.AllowInput = false
    timer.Simple(time,function()
        if IsValid(Lab) then
            Lab.AllowInput = true
        end
    end)
end

// Tells us if this sample is a duplicate
function zbl.f.Lab_Sample_IsDuplicate(Lab,gen_val)
    local IsDuplicate = false
    for k,v in pairs(Lab.Samples) do
        if v and v.id == gen_val then
            IsDuplicate = true
            break
        end
    end
    return IsDuplicate
end

// Returns the cooldown this sample id has
function zbl.f.Lab_Sample_HasCooldown(Lab,gen_val)
    if Lab.SampleCooldown[gen_val] and Lab.SampleCooldown[gen_val] > CurTime() then
        return math.Round(Lab.SampleCooldown[gen_val] - CurTime())
    else
        return false
    end
end

function zbl.f.Lab_AddSample(Lab,flask)
    if Lab:GetSampleCount() >= 12 then return end
    if flask:GetGenType() ~= 1 then return end
    zbl.f.Debug("zbl.f.Lab_AddSample")

    // This can be a Blood/DNA or Virus sample
    local sample_data = {
        id = flask:GetGenValue(),
        type = flask:GetGenType(),
        name = flask:GetGenName(),
        points = flask:GetGenPoints(),
        class = flask:GetGenClass()
    }
    zbl.f.Lab_AddSampleData(Lab,sample_data)

    SafeRemoveEntity(flask)
end

function zbl.f.Lab_AddSampleData(Lab,sample_data)
    zbl.f.Debug("zbl.f.Lab_AddSampleData")

    local IsDuplicate = zbl.f.Lab_Sample_IsDuplicate(Lab,sample_data.id)
    local HasCooldown = zbl.f.Lab_Sample_HasCooldown(Lab,sample_data.id)

    local labPos = Lab:GetPos()
    for k, v in pairs(zbl_PlayerList) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and zbl.f.InDistance(v:GetPos(), labPos, 300) then
            if IsDuplicate then
                zbl.f.Notify(v, zbl.language.General["DuplicatePenalty"], 1)
            end

            if HasCooldown then
                zbl.f.Notify(v, zbl.language.General["CooldownPenalty"] .. " " .. zbl.f.FormatTime(HasCooldown), 1)
            end
        end
    end

    table.insert(Lab.Samples,sample_data)

    Lab:SetSampleCount(Lab:GetSampleCount() + 1)

    zbl.f.Lab_SampleChanged(Lab)

    zbl.f.Lab_UpdateBodygroup(Lab)
end

function zbl.f.Lab_RemoveSampleData(Lab,pos)
    table.remove(Lab.Samples,pos)

    Lab:SetSampleCount(Lab:GetSampleCount() - 1)

    zbl.f.Lab_SampleChanged(Lab)

    zbl.f.Lab_UpdateBodygroup(Lab)
end

function zbl.f.Lab_UpdateBodygroup(Lab)
    zbl.f.Debug("zbl.f.Lab_UpdateBodygroup")

    for i = 1, 12 do
        Lab:SetBodygroup(i-1, 0)
    end

    for i = 1, Lab:GetSampleCount() do
        Lab:SetBodygroup(i-1, 1)
    end
end

// This recalculates the SampleVariability, Reward and SampleSequence for all of the samples currently in the Lab
// Returns a value which defines how many diffrent samples there are currently in the lab and inflicts penalty on duplicates samples or samples with a cooldown
// This also generates the SampleSequence String
function zbl.f.Lab_SampleChanged(Lab)
    //zbl.f.Debug("zbl.f.Lab_SampleChanged")
    local Variability = 0
    local uniq_samples = {}
    local reward = 0

    // Creates a string sequence which tells us
    // Which sample is worth how many dna points
    local sequence = ""

    for k,v in pairs(Lab.Samples) do

        local b_var = 1
        local _points = 0

        // Is this exact sample allready in the lab?
        if uniq_samples[v.id] == nil then

            // Did this sample allready got used in the last 15 minutes or so
            if Lab.SampleCooldown[v.id] and Lab.SampleCooldown[v.id] > CurTime() then

                Variability = Variability + (b_var * zbl.config.GenLab.cooldown_penalty)
                _points = math.Round(v.points * zbl.config.GenLab.cooldown_penalty)
            else
                Variability = Variability + b_var
                _points = v.points
            end

            uniq_samples[v.id] = true
        else

            Variability = Variability + (b_var * zbl.config.GenLab.duplicate_penalty)
            _points = math.Round(v.points * zbl.config.GenLab.duplicate_penalty)
        end

        reward = reward + _points

        sequence = sequence .. _points

        if k < #Lab.Samples then
            sequence = sequence .. "_"
        end
    end

    // New Sample Sequence
    Lab:SetSampleSequence(sequence)

    // New Reward
    Lab:SetReward(reward)

    // New Variability
    Lab:SetSampleVariability(math.Round(Variability))

    local timerid = "zbl_SampleUpdate_Delay" .. Lab:EntIndex()
    zbl.f.Timer_Remove(timerid)
    zbl.f.Timer_Create(timerid,0.25,1,function()
        if IsValid(Lab) then
            zbl.f.Lab_SampleUpdate(Lab)
        end
    end)
end

function zbl.f.Lab_OnRemove(Lab)
    zbl.f.Debug("zbl.f.Lab_OnRemove")
    local entIndex = Lab:EntIndex()
    zbl.f.Timer_Remove("zbl_CreateCure_" .. entIndex)
    zbl.f.Timer_Remove("zbl_CreateVaccine_" .. entIndex)
    zbl.f.Timer_Remove("zbl_AnalyzeSample_" .. entIndex)
    zbl.f.Timer_Remove("zbl_SampleUpdate_Delay" .. entIndex)
end

// Informs the owner that the sample count got updated
util.AddNetworkString("zbl_Lab_Sample_Update")
function zbl.f.Lab_SampleUpdate(Lab)
    zbl.f.Debug("zbl.f.Lab_SampleUpdate")

    local ply = zbl.f.GetOwner(Lab)
    if IsValid(ply) then
        net.Start("zbl_Lab_Sample_Update")
        net.WriteEntity(Lab)
        net.Send(ply)
    end
end

// Gets called from the client and tells the lab which sample to remove
util.AddNetworkString("zbl_Lab_Sample_Remove")
net.Receive("zbl_Lab_Sample_Remove", function(len, ply)
    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local ent = net.ReadEntity()
    local index = net.ReadInt(6)
    if not IsValid(ent) then return end
    if ent:GetClass() ~= "zbl_lab" then return end
    if zbl.f.InDistance(ply:GetPos(), ent:GetPos(), 600) == false then return end
    if zbl.f.IsOwner(ply, ent) == false then return end
    if ent:GetActionState() ~= 0 then return end
    if ent:GetSampleCount() <= 0 then return end
    zbl.f.Lab_SampleRemove(ent,ply,index)
end)
function zbl.f.Lab_SampleRemove(Lab,ply,index)
    zbl.f.Debug("zbl.f.zbl_Lab_Sample_Remove")

    local s_data = Lab.Samples[index]

    if s_data == nil then return end

    local pos = Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 15 + Lab:GetRight() * 5

    zbl.f.Flask_Spawn(zbl.f.GetOwner(Lab),pos,s_data.type,s_data.id,s_data.name,s_data.points,s_data.class)

    zbl.f.Lab_RemoveSampleData(Lab,index)
end


util.AddNetworkString("zbl_Lab_AnalyzeSample_Request")
net.Receive("zbl_Lab_AnalyzeSample_Request", function(len, ply)
    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if ent:GetClass() ~= "zbl_lab" then return end
    if zbl.f.InDistance(ply:GetPos(), ent:GetPos(), 600) == false then return end
    if zbl.f.IsOwner(ply, ent) == false then return end
    if ent:GetActionState() ~= 0 then return end
    if ent:GetSampleCount() <= 0 then return end
    zbl.f.Lab_AnalyzeSample(ent,ply)
end)
function zbl.f.Lab_AnalyzeSample(Lab,ply)
    zbl.f.Debug("zbl.f.Lab_AnalyzeSample")

    Lab:SetActionState(1)

    Lab.AllowInput = false

    // Adds a cooldown for all the sample Ids which get now used
    for k,v in pairs(Lab.Samples) do
        Lab.SampleCooldown[v.id] = CurTime() + zbl.config.GenLab.sample_cooldown
    end


    local duration = zbl.config.GenLab.time_per_sample * Lab:GetSampleCount()
    local t_mod = zbl.config.GenLab.time_modify[zbl.f.GetPlayerRank(ply)]
    if t_mod == nil then
        t_mod = zbl.config.GenLab.time_modify["default"]
    end
    duration = duration * t_mod

    Lab:SetProgressEnd(CurTime() + duration)
    Lab:SetProgressDuration(duration)

    // Start Analyze Timer
    local timerid = "zbl_AnalyzeSample_" .. Lab:EntIndex()
    zbl.f.Timer_Remove(timerid)
    zbl.f.Timer_Create(timerid,duration,1,function()

        zbl.f.Timer_Remove(timerid)

        local _reward = Lab:GetReward()

        local owner = zbl.f.GetOwner(Lab)
        if IsValid(owner) then

            zbl.f.Notify(owner, "+ " .. _reward .. " " .. zbl.language.General["DNA"], 4)

            zbl.f.Lab_Data_AddPoints(owner,_reward)
        end

        Lab.Samples = {}
        Lab:SetSampleCount(0)
        Lab:SetReward(0)

        zbl.f.Lab_SampleChanged(Lab)
        zbl.f.Lab_UpdateBodygroup(Lab)

        Lab.AllowInput = true

        Lab:SetActionState(0)
    end)
end



util.AddNetworkString("zbl_Lab_RemoveSamples")
net.Receive("zbl_Lab_RemoveSamples", function(len, ply)
    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if ent:GetClass() ~= "zbl_lab" then return end
    if zbl.f.InDistance(ply:GetPos(), ent:GetPos(), 600) == false then return end
    if zbl.f.IsOwner(ply, ent) == false then return end
    if ent:GetActionState() ~= 0 then return end
    if ent:GetSampleCount() <= 0 then return end

    zbl.f.Lab_RemoveSamples(ent)

    // Lets make sure we wont allow any touch input for the next second
    zbl.f.Lab_BlockTouchInput(ent,1)
end)
function zbl.f.Lab_RemoveSamples(Lab)
    zbl.f.Debug("zbl.f.Lab_RemoveSamples")
    local start_pos = Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 15 + Lab:GetRight() * 5
    local pos = start_pos
    local x,y = 0,0
    local count = 0
    for k,v in pairs(Lab.Samples) do
        if v then
            pos = start_pos
            if count >= 4 then
                x = 0
                y = y + 15
                count = 0
            end

            pos = pos - Lab:GetRight() * x
            pos = pos + Lab:GetForward() * y
            x = x + 15
            count = count + 1

            zbl.f.Flask_Spawn(zbl.f.GetOwner(Lab),pos,v.type,v.id,v.name,v.points,v.class)
        end
    end
    Lab.Samples = {}
    Lab:SetSampleCount(0)

    zbl.f.Lab_SampleChanged(Lab)
    zbl.f.Lab_UpdateBodygroup(Lab)
end



util.AddNetworkString("zbl_Lab_CreateVaccine")
net.Receive("zbl_Lab_CreateVaccine", function(len, ply)
    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local ent = net.ReadEntity()
    local vaccID = net.ReadInt(16)
    if not IsValid(ent) then return end
    if ent:GetClass() ~= "zbl_lab" then return end
    if zbl.f.InDistance(ply:GetPos(), ent:GetPos(), 600) == false then return end
    if zbl.f.IsOwner(ply, ent) == false then return end
    if ent:GetActionState() ~= 0 then return end
    if vaccID == nil then return end

    zbl.f.Lab_CreateVaccine(ent,vaccID,ply)
end)
function zbl.f.Lab_CreateVaccine(Lab,VaccineID,ply)
    zbl.f.Debug("zbl.f.Lab_CreateVaccine")

    local vaccine_data = zbl.config.Vaccines[VaccineID]

    if vaccine_data == nil then return end

    if table.Count(vaccine_data.research["ranks"]) > 0 and vaccine_data.research["ranks"][zbl.f.GetPlayerRank(ply)] == nil then
        return
    end

    if Lab:GetDNAPoints() < vaccine_data.research["vaccine_points"] then
        return
    end

    Lab:SetActionState(2)

    Lab.AllowInput = false

    // lets remove any sample which are in the lab
    zbl.f.Lab_RemoveSamples(Lab)

    Lab:SetSelectedVaccine(VaccineID)


    local duration = vaccine_data.research["vaccine_time"]
    local t_mod = zbl.config.GenLab.time_modify[zbl.f.GetPlayerRank(ply)]
    if t_mod == nil then
        t_mod = zbl.config.GenLab.time_modify["default"]
    end
    duration = duration * t_mod

    Lab:SetProgressEnd(CurTime() + duration)
    Lab:SetProgressDuration(duration)


    Lab:SetSampleCount(1)
    zbl.f.Lab_UpdateBodygroup(Lab)

    // Start Analyze Timer
    local timerid = "zbl_CreateVaccine_" .. Lab:EntIndex()
    zbl.f.Timer_Remove(timerid)
    zbl.f.Timer_Create(timerid,duration,1,function()

        zbl.f.Timer_Remove(timerid)
        if not IsValid(Lab) then return end

        local owner = zbl.f.GetOwner(Lab)
        if IsValid(owner) then
            local currentPoints = zbl.f.Lab_Data_RemovePoints(owner,vaccine_data.research["vaccine_points"])
            Lab:SetDNAPoints(currentPoints)
        end

        Lab:SetSampleCount(0)

        zbl.f.Lab_UpdateBodygroup(Lab)

        Lab.AllowInput = true

        Lab:SetActionState(0)

        timer.Simple(0.5,function()
            if IsValid(ply) and IsValid(Lab) and VaccineID then
                vaccine_data = zbl.config.Vaccines[VaccineID]
                zbl.f.Flask_Spawn(ply,Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 25,2,VaccineID,vaccine_data.name,0,"")
            end
        end)
    end)
end

util.AddNetworkString("zbl_Lab_CreateCure")
net.Receive("zbl_Lab_CreateCure", function(len, ply)
    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local ent = net.ReadEntity()
    local vaccID = net.ReadInt(16)
    if not IsValid(ent) then return end
    if ent:GetClass() ~= "zbl_lab" then return end
    if zbl.f.InDistance(ply:GetPos(), ent:GetPos(), 600) == false then return end
    if zbl.f.IsOwner(ply, ent) == false then return end
    if ent:GetActionState() ~= 0 then return end
    if vaccID == nil then return end

    zbl.f.Lab_CreateCure(ent,vaccID,ply)
end)
function zbl.f.Lab_CreateCure(Lab,VaccineID,ply)
    zbl.f.Debug("zbl.f.Lab_CreateCure")

    local vaccine_data = zbl.config.Vaccines[VaccineID]

    if vaccine_data == nil then return end

    if table.Count(vaccine_data.research["ranks"]) > 0 and vaccine_data.research["ranks"][zbl.f.GetPlayerRank(ply)] == nil then
        return
    end

    if Lab:GetDNAPoints() < vaccine_data.research["cure_points"] then
        return
    end

    Lab:SetActionState(3)

    Lab.AllowInput = false

    // lets remove any sample which are in the lab
    zbl.f.Lab_RemoveSamples(Lab)

    Lab:SetSelectedVaccine(VaccineID)

    local duration = vaccine_data.research["cure_time"]
    local t_mod = zbl.config.GenLab.time_modify[zbl.f.GetPlayerRank(ply)]
    if t_mod == nil then
        t_mod = zbl.config.GenLab.time_modify["default"]
    end
    duration = duration * t_mod

    Lab:SetProgressEnd(CurTime() + duration)
    Lab:SetProgressDuration(duration)


    Lab:SetSampleCount(1)
    zbl.f.Lab_UpdateBodygroup(Lab)

    // Start Cure Timer
    local timerid = "zbl_CreateCure_" .. Lab:EntIndex()
    zbl.f.Timer_Remove(timerid)
    zbl.f.Timer_Create(timerid,duration,1,function()

        zbl.f.Timer_Remove(timerid)

        if not IsValid(Lab) then return end

        local owner = zbl.f.GetOwner(Lab)
        if IsValid(owner) then
            local currentPoints = zbl.f.Lab_Data_RemovePoints(owner,vaccine_data.research["vaccine_points"])
            Lab:SetDNAPoints(currentPoints)
        end

        Lab:SetSampleCount(0)

        zbl.f.Lab_UpdateBodygroup(Lab)

        Lab.AllowInput = true

        Lab:SetActionState(0)


        // Create Vaccine Cure Entity
        timer.Simple(0.5,function()
            if IsValid(ply) and IsValid(Lab) and VaccineID then
                vaccine_data = zbl.config.Vaccines[VaccineID]

                zbl.f.Flask_Spawn(ply,Lab:GetPos() + Lab:GetForward() * 55 + Lab:GetUp() * 25,3,VaccineID,vaccine_data.name,0,"")
            end
        end)
    end)
end






////////////////////////////////////////////
////////// Save/Load DNA Points  ///////////
////////////////////////////////////////////
// This keeps track on how many dna points each user has
zbl.DNAPoints = zbl.DNAPoints or {}

function zbl.f.Lab_Data_Init(Lab,ply)

    zbl.f.Debug("zbl.f.Lab_Data_Init: " .. ply:Nick())

    if not file.Exists("zbl", "DATA") then
        file.CreateDir("zbl")
    end

    if not file.Exists("zbl/data/", "DATA") then
        file.CreateDir("zbl/data/")
    end

    local plyID = ply:SteamID()
    local str = string.Replace(plyID,":","_")
    local _points = 0

    if file.Exists("zbl/data/" .. str .. ".txt", "DATA") then
        local data = file.Read("zbl/data/" .. str .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and data.Points then
            _points = data.Points
        end
    end

    Lab:SetDNAPoints(_points)

    zbl.DNAPoints[zbl.f.Player_GetID(ply)] = {
        points = _points
    }

    ply.zbl_Lab = Lab

    // Update if we should save this users data
    zbl.f.Lab_Data_Changed(ply)
end

function zbl.f.Lab_Data_AddPoints(ply,points)
    local steamid = zbl.f.Player_GetID(ply)
    zbl.DNAPoints[steamid].points = (zbl.DNAPoints[steamid].points or 0) + points

    // Update if we should save this users data
    zbl.f.Lab_Data_Changed(ply)

    // Updates the Lab Enitity of the player if he has one
    zbl.f.Lab_Data_UpdateEntity(ply)

    return zbl.DNAPoints[steamid].points
end

function zbl.f.Lab_Data_RemovePoints(ply,points)
    local steamid = zbl.f.Player_GetID(ply)
    zbl.DNAPoints[steamid].points = math.Clamp((zbl.DNAPoints[steamid].points or 0) - points, 0, 999999999)

    // Update if we should save this users data
    zbl.f.Lab_Data_Changed(ply)

    // Updates the Lab Enitity of the player if he has one
    zbl.f.Lab_Data_UpdateEntity(ply)

    return zbl.DNAPoints[steamid].points
end

// Updates the Lab entity of the player if he currently has one
function zbl.f.Lab_Data_UpdateEntity(ply)
    if not IsValid(ply) then return end
    zbl.f.Debug("zbl.f.Lab_Data_UpdateEntity")

    if IsValid(ply.zbl_Lab) then
        local steamid = zbl.f.Player_GetID(ply)
        ply.zbl_Lab:SetDNAPoints(zbl.DNAPoints[steamid].points)
    end
end

function zbl.f.Lab_Data_Changed(ply)
    local steamid = zbl.f.Player_GetID(ply)
    local _save = true
    if zbl.config.GenLab.Data.Whitelist and table.Count(zbl.config.GenLab.Data.Whitelist) > 0 and zbl.config.GenLab.Data.Whitelist[zbl.f.GetPlayerRank(ply)] == nil then
        _save = false
    end
    zbl.DNAPoints[steamid].save = _save

    zbl.f.Debug(zbl.DNAPoints)
end

function zbl.f.Lab_Data_PlayerDisconnect(steamid)
    zbl.f.Debug("zbl.f.Lab_Data_PlayerDisconnect")

    if zbl.DNAPoints[steamid] and zbl.DNAPoints[steamid].save == true then
        zbl.f.Lab_Data_Save(steamid)
    end

    zbl.DNAPoints[steamid] = nil
end

function zbl.f.Lab_Data_PlayerChangedJob(steamid)
    zbl.f.Debug("zbl.f.Lab_Data_PlayerChangedJob")

    if zbl.DNAPoints[steamid] and zbl.DNAPoints[steamid].save == true then
        zbl.f.Lab_Data_Save(steamid)
    end

    zbl.DNAPoints[steamid] = nil
end

function zbl.f.Lab_Data_Save(steamid)
    if zbl.config.GenLab.Data.Save == false then return end
    if zbl.DNAPoints[steamid] and zbl.DNAPoints[steamid].save == false then return end

    if zbl.DNAPoints[steamid] then
        local data = {
            Points = zbl.DNAPoints[steamid].points
        }
        local str = string.Replace(steamid,":","_")
        file.Write("zbl/data/" .. tostring(str) .. ".txt", util.TableToJSON(data))
        zbl.f.Debug("zbl.f.Lab_Data_Save")
    end
end

function zbl.f.Lab_Data_SaveAll()
    for k, v in pairs(zbl.DNAPoints) do
        zbl.f.Lab_Data_Save(k)
    end
end

function zbl.f.Lab_Data_AutoSave()
    if zbl.config.GenLab.Data.Save == false then return end
    if zbl.config.GenLab.Data.Save_Interval == -1 then return end

    if timer.Exists("zbl_DNAPoints_Autosave") then
        timer.Remove("zbl_DNAPoints_Autosave")
    end

    timer.Create("zbl_DNAPoints_Autosave", zbl.config.GenLab.Data.Save_Interval, 0, zbl.f.Lab_Data_SaveAll)
end

hook.Add("InitPostEntity", "zbl_DNAPoints_Autosave_OnMapLoad", zbl.f.Lab_Data_AutoSave)
////////////////////////////////////////////
////////////////////////////////////////////
