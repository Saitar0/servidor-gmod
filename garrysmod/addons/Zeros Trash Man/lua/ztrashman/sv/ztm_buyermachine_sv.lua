if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

ztm.buyermachines = ztm.buyermachines or {}

function ztm.f.Buyermachine_Initialize(Buyermachine)
    ztm.f.EntList_Add(Buyermachine)

    Buyermachine.PayoutMode = false
    Buyermachine.Wait = false

    table.insert(ztm.buyermachines,Buyermachine)
end

function ztm.f.Buyermachine_Touch(Buyermachine, other)
    if Buyermachine.Wait == true then return end
    if Buyermachine:GetIsInserting() then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "ztm_recycled_block" then return end
    if ztm.f.CollisionCooldown(other) then return end
    if IsValid(Buyermachine:GetMoneyEnt()) then return end

    ztm.f.Buyermachine_AddBlock(Buyermachine, other)
end

function ztm.f.Buyermachine_AddBlock(Buyermachine, block)
    Buyermachine:SetIsInserting(true)

    local block_value = ztm.config.Recycler.recycle_types[block:GetRecycleType()].money

    Buyermachine:SetBlockType(block:GetRecycleType())

    Buyermachine:SetMoney(Buyermachine:GetMoney() + block_value)

    SafeRemoveEntity(block)

    timer.Simple(1.7,function()
        if IsValid(Buyermachine) then
            Buyermachine:SetIsInserting(false)
        end
    end)
end

function ztm.f.Buyermachine_USE(Buyermachine,ply)
    if Buyermachine.Wait == true then return end
    if Buyermachine:GetIsInserting() then return end
    if IsValid(Buyermachine:GetMoneyEnt()) then return end

    if Buyermachine:OnPayoutButton(ply) then

        local cash = Buyermachine:GetMoney()
        if cash <= 0 then return end

        local modify = (1 / 100) * Buyermachine:GetPriceModify()
        cash = cash * modify

        Buyermachine:EmitSound("ztm_ui_click")

        // Custom Hook
        hook.Run("ztm_OnTrashBlockSold" ,ply, Buyermachine, cash)


        // Spawn money
        local pos = Buyermachine:GetPos() +  Buyermachine:GetUp() * 61.8 + Buyermachine:GetRight() * -17 + Buyermachine:GetForward() * -11.7
        local money = ztm.config.MoneySpawn(pos,cash)
        local ang = Buyermachine:GetAngles()
        ang:RotateAroundAxis(Buyermachine:GetUp(),90)
        money:SetAngles(ang)
        money:SetParent(Buyermachine)
        Buyermachine:SetMoney(0)
        Buyermachine:SetMoneyEnt(money)

        Buyermachine.PayoutMode = true
        Buyermachine.Wait = true
    end
end

function ztm.f.Buyermachine_Think(Buyermachine)
    if Buyermachine.PayoutMode == true and not IsValid(Buyermachine:GetMoneyEnt()) then
        Buyermachine.PayoutMode = false

        timer.Simple(1, function()
            if IsValid(Buyermachine) then
                Buyermachine.Wait = false
            end
        end)
    end
end



// Dynamic BuyRate
function ztm.f.Buyermachine_BuyerMarkt_TimerExist()
    if timer.Exists("ztm_buyermarkt_id") == false and ztm.config.Buyermachine.DynamicBuyRate then
        timer.Create("ztm_buyermarkt_id", ztm.config.Buyermachine.RefreshRate, 0, ztm.f.Buyermachine_ChangeMarkt)
    end
end

hook.Add("InitPostEntity", "ztm_buyermarkt_OnMapLoad", ztm.f.Buyermachine_BuyerMarkt_TimerExist)

function ztm.f.Buyermachine_RefreshBuyRate(Buyermachine)
    local newProfit = math.random(ztm.config.Buyermachine.MinBuyRate, ztm.config.Buyermachine.MaxBuyRate)
    ztm.f.Debug("ztm.f.Buyermachine_RefreshBuyRate: " .. newProfit .. "%")
    Buyermachine:SetPriceModify(newProfit)
end

function ztm.f.Buyermachine_ChangeMarkt()
    for k, v in pairs(ztm.buyermachines) do
        if IsValid(v) then
            ztm.f.Buyermachine_RefreshBuyRate(v)
        end
    end
end






// Save function
concommand.Add( "ztm_save_buyermachine", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Buyermachine entities have been saved for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Buyermachine_Save()
    end
end )

concommand.Add( "ztm_remove_buyermachine", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.Notify(ply, "Buyermachine entities have been removed for the map " .. game.GetMap() .. "!", 0)
        ztm.f.Buyermachine_Remove()
    end
end )

function ztm.f.Buyermachine_Save()
    local data = {}

    for u, j in pairs(ztm.buyermachines) do
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
        file.Write("ztm/" .. string.lower(game.GetMap()) .. "_buyermachines" .. ".txt", util.TableToJSON(data))
    end
end

function ztm.f.Buyermachine_Load()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_buyermachines" .. ".txt", "DATA") then
        local data = file.Read("ztm/" .. string.lower(game.GetMap()) .. "_buyermachines" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("ztm_buyermachine")
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

            print("[Zeros WeedFarm] Finished loading Buyermachine Entities.")
        end
    else
        print("[Zeros WeedFarm] No map data found for Buyermachine entities. Please place some and do !saveztm to create the data.")
    end
end

function ztm.f.Buyermachine_Remove()
    if file.Exists("ztm/" .. string.lower(game.GetMap()) .. "_buyermachines" .. ".txt", "DATA") then
        file.Delete("ztm/" .. string.lower(game.GetMap()) .. "_buyermachines" .. ".txt")
    end

    for k, v in pairs(ztm.buyermachines) do
        if IsValid(v) then
            v:Remove()
        end
    end
end
