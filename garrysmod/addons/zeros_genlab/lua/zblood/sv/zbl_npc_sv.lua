if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

zbl.NPC = zbl.NPC or {}

/*
    The player can sell Virus/Cures to the NPC

    You can also request a job from the NPC like
        getting a specific players blood sample (time limit)
        infecting a player with a virus you need to make (time limit)
        healing atleast 5 people in the next 60 minutes or so
        getting a sample from a virus node which exists somewhere

*/


function zbl.f.NPC_Add(npc)
    table.insert(zbl.NPC,npc)
end

function zbl.f.NPC_Remove(npc)
    table.RemoveByValue(zbl.NPC,npc)
end

function zbl.f.NPC_OnUse(npc,ply)

    if zbl.f.IsResearcher(ply) == false then
        zbl.f.Notify(ply, zbl.language.General["Wrong Job"], 1)
        return
    end

    // Open NPC Interface
    zbl.f.NPC_OpenMenu(npc,ply)
end

// Open NPC Interface
util.AddNetworkString("zbl_NPC_OpenMenu")
function zbl.f.NPC_OpenMenu(npc,ply)
    zbl.f.Debug("zbl.f.NPC_OpenMenu")

    local swep = ply:GetWeapon( "zbl_gun" )

    if not IsValid(swep) then
        zbl.f.Notify(ply, "You dont have a Injector Gun", 1)
        return
    end

    // Lets generate a random quest for the player
    if ply.zbl_Quest == nil or (ply.zbl_Quest.start_time == -1 and (ply.zbl_Quest.request_time + zbl.config.NPC.quest_cooldown) < CurTime()) then
        local rnd_id = math.random(#zbl.config.NPC.quests)

        ply.zbl_Quest = {
            id = rnd_id,
            request_time = CurTime(),
            start_time = -1,
            accepted = false,
            npc = npc
        }

        zbl.f.Debug("New Quest ID: " .. rnd_id)
    end

    /*
    // Tells us if the player did everything needed to fullfill the quest
    local completed = false
    if ply.zbl_Quest and ply.zbl_Quest.id ~= -1 and ply.zbl_Quest.accepted == true then
        completed = zbl.f.Quest_CheckProgress(ply)
        if completed then
            zbl.f.Quest_OnCompleted(ply)
        end
    end
    */

    // Makes the flask table a bit smaller for networking
    local reduced_tbl = {}
    for k,v in pairs(swep.Flasks) do
        local name = v.GenName
        reduced_tbl[k] = {
            gt = v.GenType,
            gv = v.GenValue,
            gn = name,
        }
    end

    timer.Simple(0,function()
        if IsValid(ply) then


            local dataString = util.TableToJSON(reduced_tbl)
            local dataCompressed = util.Compress(dataString)
            net.Start("zbl_NPC_OpenMenu")
            net.WriteUInt(#dataCompressed, 16)
            net.WriteData(dataCompressed, #dataCompressed)
            net.WriteEntity(npc)
            net.WriteInt(ply.zbl_Quest.id,16)
            net.WriteInt(ply.zbl_Quest.start_time,16)
            //net.WriteBool(completed)
            net.Send(ply)
        end
    end)
end

// Forces the interface to be closed
util.AddNetworkString("zbl_NPC_CloseMenu")
function zbl.f.NPC_ForceCloseMenu(ply)
    zbl.f.Debug("zbl.f.NPC_ForceCloseMenu")

    net.Start("zbl_NPC_CloseMenu")
    net.Send(ply)
end

util.AddNetworkString("zbl_NPC_Sell")
net.Receive("zbl_NPC_Sell", function(len, ply)
    zbl.f.Debug("zbl_NPC_Sell len: " .. len)

    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local npc = net.ReadEntity()
    local id = net.ReadInt(16)
    if id == nil then return end
    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zbl_npc" then return end
    if zbl.f.InDistance(ply:GetPos(), npc:GetPos(), 600) == false then return end

    zbl.f.NPC_Sell(npc,ply,id)
end)
function zbl.f.NPC_Sell(npc,ply,flask_id)
    zbl.f.Debug("zbl.f.NPC_Sell")

    local swep = ply:GetWeapon("zbl_gun")

    if not IsValid(swep) then return end
    if swep.Flasks == nil then return end

    local flask_data = swep.Flasks[flask_id]
    if flask_data == nil then return end

    if flask_data.GenType ~= 2 and flask_data.GenType ~= 3 then return end

    local vaccine_data = zbl.config.Vaccines[flask_data.GenValue]

    local money = 0

    // Vaccine/Virus
    if flask_data.GenType == 2 then

        money = vaccine_data.price

    // Cure
    elseif flask_data.GenType == 3 then

        money = vaccine_data.cure.price
    end

    // Remove Flask from player swep
    zbl.f.Injector_EmptyLiquid(swep,flask_id)

    // Give player the money
    zbl.f.GiveMoney(ply, money)

    zbl.f.Notify(ply, string.Replace(zbl.language.General["ReceivedMoney"],"$Money",zbl.f.CurrencyPos(money, zbl.config.Currency)), 4)
    ply:EmitSound("zbl_cash")
end

util.AddNetworkString("zbl_NPC_AcceptQuest")
net.Receive("zbl_NPC_AcceptQuest", function(len, ply)
    zbl.f.Debug("zbl_NPC_AcceptQuest len: " .. len)

    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local npc = net.ReadEntity()
    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zbl_npc" then return end
    if zbl.f.InDistance(ply:GetPos(), npc:GetPos(), 600) == false then return end

    zbl.f.NPC_AcceptQuest(npc,ply)
end)
function zbl.f.NPC_AcceptQuest(npc,ply)
    zbl.f.Debug("zbl.f.NPC_AcceptQuest")
    zbl.f.Quest_OnStart(ply,ply.zbl_Quest.id)
end

util.AddNetworkString("zbl_NPC_DeclineQuest")
net.Receive("zbl_NPC_DeclineQuest", function(len, ply)
    zbl.f.Debug("zbl_NPC_DeclineQuest len: " .. len)

    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local npc = net.ReadEntity()
    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zbl_npc" then return end
    if zbl.f.InDistance(ply:GetPos(), npc:GetPos(), 600) == false then return end

    zbl.f.NPC_DeclineQuest(npc,ply)
end)
function zbl.f.NPC_DeclineQuest(npc,ply)
    zbl.f.Debug("zbl.f.NPC_CancelQuest")
    zbl.f.Quest_Stop(zbl.f.Player_GetID(ply),ply)
end

util.AddNetworkString("zbl_NPC_CancelQuest")
net.Receive("zbl_NPC_CancelQuest", function(len, ply)
    zbl.f.Debug("zbl_NPC_CancelQuest len: " .. len)

    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local npc = net.ReadEntity()
    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zbl_npc" then return end
    if zbl.f.InDistance(ply:GetPos(), npc:GetPos(), 600) == false then return end

    zbl.f.NPC_CancelQuest(npc,ply)
end)
function zbl.f.NPC_CancelQuest(npc,ply)
    zbl.f.Debug("zbl.f.NPC_CancelQuest")
    zbl.f.Quest_Stop(zbl.f.Player_GetID(ply),ply)
end

util.AddNetworkString("zbl_NPC_FinishQuest")
util.AddNetworkString("zbl_NPC_NotFinishYet")
net.Receive("zbl_NPC_FinishQuest", function(len, ply)
    zbl.f.Debug("zbl_NPC_FinishQuest len: " .. len)

    if not IsValid(ply) then return end
    if zbl.f.Player_Timeout(ply) then return end
    local npc = net.ReadEntity()
    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zbl_npc" then return end
    if zbl.f.InDistance(ply:GetPos(), npc:GetPos(), 600) == false then return end

    zbl.f.NPC_FinishQuest(npc,ply)
end)
function zbl.f.NPC_FinishQuest(npc,ply)
    zbl.f.Debug("zbl.f.NPC_CancelQuest")

    local completed = false
    if ply.zbl_Quest and ply.zbl_Quest.id ~= -1 and ply.zbl_Quest.accepted == true then
        completed = zbl.f.Quest_CheckProgress(ply)
        if completed then
            zbl.f.Quest_OnCompleted(ply)
        else
            // Send player back the result
            net.Start("zbl_NPC_NotFinishYet")
            net.Send(ply)
        end
    end
end










// Save functions
concommand.Add( "zbl_save_npc", function( ply, cmd, args )
    if IsValid(ply) and zbl.f.IsAdmin(ply) then
        zbl.f.Notify(ply, "NPC entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zbl.f.NPC_Save()
    end
end )

concommand.Add( "zbl_remove_npc", function( ply, cmd, args )
    if IsValid(ply) and zbl.f.IsAdmin(ply) then
        zbl.f.Notify(ply, "NPC entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zbl.f.NPC_RemoveData()
    end
end )

function zbl.f.NPC_Save()
    local data = {}

    for u, j in pairs(ents.FindByClass("zbl_npc")) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    if data == nil or table.Count(data) <= 0 then return end

    if not file.Exists("zbl", "DATA") then
        file.CreateDir("zbl")
    end
    if table.Count(data) > 0 then
        file.Write("zbl/" .. string.lower(game.GetMap()) .. "_npc" .. ".txt", util.TableToJSON(data))
    end
end

function zbl.f.NPC_Load()
    if file.Exists("zbl/" .. string.lower(game.GetMap()) .. "_npc" .. ".txt", "DATA") then
        local data = file.Read("zbl/" .. string.lower(game.GetMap()) .. "_npc" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("zbl_npc")
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()

                local phys = ent:GetPhysicsObject()

                if IsValid(phys) then
                    phys:Wake()
                    phys:EnableMotion(false)
                end
            end

            print("[Zeros GenLab] Finished loading NPC Entities.")
        end
    else
        print("[Zeros GenLab] No map data found for NPC entities. Please place some and do !zbl_save in chat to create the data.")
    end
end

function zbl.f.NPC_RemoveData()
    if file.Exists("zbl/" .. string.lower(game.GetMap()) .. "_npc" .. ".txt", "DATA") then
        file.Delete("zbl/" .. string.lower(game.GetMap()) .. "_npc" .. ".txt")
    end

    for k, v in pairs(ents.FindByClass("zbl_npc")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

hook.Add("InitPostEntity", "zbl_SpawnNPC", zbl.f.NPC_Load)
hook.Add("PostCleanupMap", "zbl_SpawnNPCPostCleanUp", zbl.f.NPC_Load)
