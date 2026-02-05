if CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

////////// SETUP /////////////////
local function SpawnProp(machine, model)
    local ent = ents.Create("zcm_animbase")
    ent:SetAngles(machine:GetAngles())
    ent:SetPos(machine:GetPos())
    ent:Spawn()
    ent:Activate()
    ent:SetModel(model)
    ent:SetParent(machine)

    return ent
end

function zcm.f.Machine_Setup(crackermachine)
    crackermachine:SetPaperRoller(SpawnProp(crackermachine, "models/zerochain/props_crackermaker/zcm_paperroller.mdl"))
    crackermachine:SetRollMover(SpawnProp(crackermachine, "models/zerochain/props_crackermaker/zcm_rollmover.mdl"))
    crackermachine:SetRollCutter(SpawnProp(crackermachine, "models/zerochain/props_crackermaker/zcm_cutter.mdl"))
    crackermachine:SetRollReleaser(SpawnProp(crackermachine, "models/zerochain/props_crackermaker/zcm_cutrollrelease.mdl"))
    crackermachine:SetRollPacker(SpawnProp(crackermachine, "models/zerochain/props_crackermaker/zcm_rollpacker.mdl"))
    crackermachine:SetRollBinder(SpawnProp(crackermachine, "models/zerochain/props_crackermaker/zcm_rollbinder.mdl"))
    crackermachine:SetPowderFiller(SpawnProp(crackermachine, "models/zerochain/props_crackermaker/zcm_powderfiller.mdl"))

    local BinderAttach = crackermachine:GetRollBinder():GetAttachment(1)
    local BindRoll_CrackerPack = ents.Create("zcm_crackerpack")
    BindRoll_CrackerPack:SetAngles(BinderAttach.Ang)
    BindRoll_CrackerPack:SetPos(BinderAttach.Pos)
    BindRoll_CrackerPack:Spawn()
    BindRoll_CrackerPack:Activate()
    BindRoll_CrackerPack:SetParent(crackermachine:GetRollBinder(), 1)
    crackermachine.BindRoll_CrackerPack = BindRoll_CrackerPack

    local Arm01Attach = crackermachine:GetPowderFiller():GetAttachment(1)
    local Arm01_CrackerPack = ents.Create("base_anim")
    Arm01_CrackerPack:SetAngles(Arm01Attach.Ang)
    Arm01_CrackerPack:SetPos(Arm01Attach.Pos)
    Arm01_CrackerPack:Spawn()
    Arm01_CrackerPack:Activate()
    Arm01_CrackerPack:SetModel("models/zerochain/props_crackermaker/zcm_crackerpack.mdl")
    Arm01_CrackerPack:SetNoDraw(true)
    Arm01_CrackerPack:SetBodygroup(0,1)
    Arm01_CrackerPack:SetBodygroup(1,1)
    Arm01_CrackerPack:SetParent(crackermachine:GetPowderFiller(), 1)
    crackermachine.Arm01_CrackerPack = Arm01_CrackerPack

    local Arm02Attach = crackermachine:GetPowderFiller():GetAttachment(2)
    local Arm02_CrackerPack = ents.Create("base_anim")
    Arm02_CrackerPack:SetAngles(Arm02Attach.Ang)
    Arm02_CrackerPack:SetPos(Arm02Attach.Pos)
    Arm02_CrackerPack:Spawn()
    Arm02_CrackerPack:Activate()
    Arm02_CrackerPack:SetModel("models/zerochain/props_crackermaker/zcm_crackerpack.mdl")
    Arm02_CrackerPack:SetNoDraw(true)
    Arm02_CrackerPack:SetBodygroup(0,1)
    Arm02_CrackerPack:SetBodygroup(1,1)
    Arm02_CrackerPack:SetParent(crackermachine:GetPowderFiller(), 2)
    crackermachine.Arm02_CrackerPack = Arm02_CrackerPack

    local FillerAttach = crackermachine:GetPowderFiller():GetAttachment(3)
    local Filler_CrackerPack = ents.Create("base_anim")
    Filler_CrackerPack:SetAngles(FillerAttach.Ang)
    Filler_CrackerPack:SetPos(FillerAttach.Pos)
    Filler_CrackerPack:Spawn()
    Filler_CrackerPack:Activate()
    Filler_CrackerPack:SetModel("models/zerochain/props_crackermaker/zcm_crackerpack.mdl")
    Filler_CrackerPack:SetNoDraw(true)
    Filler_CrackerPack:SetBodygroup(0,1)
    Filler_CrackerPack:SetBodygroup(1,1)
    Filler_CrackerPack:SetParent(crackermachine:GetPowderFiller(), 3)
    crackermachine.Filler_CrackerPack = Filler_CrackerPack
end

function zcm.f.Machine_Init(crackermachine)
    crackermachine.AttachCoolDown = false
    crackermachine.last_Tick = 0
    crackermachine.Making_PaperRolls = false
    crackermachine.Packing_Rolls = false
    crackermachine.Making_Firework = false
    crackermachine.ProducedFirework = 0

    zcm.f.Machine_Setup(crackermachine)
end


////////// INGREDIENTS /////////////////
function zcm.f.Machine_Touch(crackermachine,ent)
    if (crackermachine.AttachCoolDown) then return end

    if ent:GetClass() == "zcm_blackpowder" and crackermachine:GetBlackPowder() < zcm.config.CrackerMachine.BlackPowder_Cap then
        zcm.f.Machine_AddIngredient(crackermachine, ent, 1)
    elseif ent:GetClass() == "zcm_paperroll" and crackermachine:GetPaper() < zcm.config.CrackerMachine.Paper_Cap then
        zcm.f.Machine_AddIngredient(crackermachine, ent, 2)
    end

    zcm.f.Machine_AttachCoolDown(crackermachine)
end

function zcm.f.Machine_AttachCoolDown(crackermachine)
    crackermachine.AttachCoolDown = true

    timer.Simple(0.1, function()
        if (IsValid(crackermachine)) then
            crackermachine.AttachCoolDown = false
        end
    end)
end

function zcm.f.Machine_AddIngredient(crackermachine, ingredient, itype)
    if itype == 1 then
        crackermachine:SetBlackPowder(math.Clamp(crackermachine:GetBlackPowder() + zcm.config.BlackPowder.Amount, 0, zcm.config.CrackerMachine.BlackPowder_Cap))
    else
        crackermachine:SetPaper(math.Clamp(crackermachine:GetPaper() + zcm.config.Paper.Amount, 0, zcm.config.CrackerMachine.Paper_Cap))
        crackermachine:GetPaperRoller():SetBodygroup(1, 1)
        //crackermachine:GetPaperRoller():SetBodygroup(2, 1)
        crackermachine:GetRollBinder():SetBodygroup(0, 1)
    end

    ingredient:Remove()
end

function zcm.f.Machine_UseIngredient(crackermachine, itype)

    if itype == 1 then
        crackermachine:SetBlackPowder(crackermachine:GetBlackPowder() - zcm.config.CrackerMachine.Usage_BlackPowder)

        local blackpowder = crackermachine:GetBlackPowder()
        zcm.f.debug("Rest BlackPowder: " .. blackpowder)
    else
        crackermachine:SetPaper(crackermachine:GetPaper() - zcm.config.CrackerMachine.Usage_Paper)

        local paper = crackermachine:GetPaper()
        zcm.f.debug("Rest Paper: " .. paper)
        if paper <= 0 then
            crackermachine:GetPaperRoller():SetBodygroup(1,0)
        end
    end
end



////////// CHECKER FUNCTIONS /////////////////
// Check if we are ready to produce more PaperRolls
function zcm.f.Machine_PaperRoll_ProductionCheck(crackermachine)
    if crackermachine:GetPaper() >= zcm.config.CrackerMachine.Usage_Paper and crackermachine:GetPaperRolls() < zcm.config.CrackerMachine.PaperRoll_Cap then
        return true
    else
        return false
    end
end

// Check if we ahve enough space in the rollsbinder for more rolls
function zcm.f.Machine_RollBinder_FillCheck(crackermachine)
    if crackermachine:GetPaperRolls() >= 1 and crackermachine.Packing_Rolls == false and crackermachine.Making_Firework == false and crackermachine.BindRoll_CrackerPack:GetCrackerCount() < 37 then
        return true
    else
        return false
    end
end

// Check if we are ready to start the firework production
function zcm.f.Machine_Firework_ProductionCheck(crackermachine)
    if crackermachine.BindRoll_CrackerPack:GetCrackerCount() >= 37 and crackermachine:GetBlackPowder() >= zcm.config.CrackerMachine.Usage_BlackPowder and crackermachine.Making_Firework == false then
        zcm.f.debug("Machine_Firework_ProductionCheck: true")
        return true
    else
        zcm.f.debug("Machine_Firework_ProductionCheck: false")
        return false
    end
end


////////// PRODUCTION PROCESS /////////////////

// Switches between on or off
function zcm.f.Machine_Switch(crackermachine, ply)
    if crackermachine:OnSwitchButton(ply) then
        if crackermachine:GetRunning() then
            crackermachine:SetRunning(false)
        else
            crackermachine:SetRunning(true)
        end
        zcm.f.debug("Machine_Switch: " .. tostring(crackermachine:GetRunning()))

    elseif crackermachine:OnUpgradeButton(ply) then

        zcm.f.Machine_Upgrade(crackermachine,ply)

    end
end

// The Main logic of the machine
function zcm.f.Machine_Logic(crackermachine)
    if crackermachine:GetRunning() then

        // Start second process if we reached the needed paperroll count and have enough blackpowder
        if zcm.f.Machine_Firework_ProductionCheck(crackermachine) then
            crackermachine.Making_Firework = true
            crackermachine.Packing_Rolls = false
            crackermachine:SetProductionStage02(0)
            zcm.f.Machine_BindRolls(crackermachine)
        end

        // If we have PaperRolls and enough space in the binder then we fill them to the binder
        if zcm.f.Machine_RollBinder_FillCheck(crackermachine) then
            zcm.f.Machine_PackRolls(crackermachine)
            crackermachine.Packing_Rolls = true
        end

        // If we have enough paper and enough space in the rollpacker then we produce more
        if zcm.f.Machine_PaperRoll_ProductionCheck(crackermachine) and crackermachine.Making_PaperRolls == false then
            zcm.f.Machine_MakePaperRolls(crackermachine)
            crackermachine.Making_PaperRolls = true
        end
    end
end

// Makes the paper rolls out of paper
function zcm.f.Machine_MakePaperRolls(crackermachine)
    zcm.f.debug("zcm.f.Machine_MakePaperRolls")


    zcm.f.Machine_UseIngredient(crackermachine, 2)

    crackermachine:SetProductionStage01(1)
    crackermachine:GetPaperRoller():SetBodygroup(0,1)

    local m_speed = crackermachine:GetSpeed()

    timer.Simple(2 / m_speed,function()
        if IsValid(crackermachine) then
            crackermachine:GetRollMover():SetBodygroup(0,1)
        end
    end)
    timer.Simple(3 / m_speed,function()
        if IsValid(crackermachine) then
            zcm.f.Machine_MovePaperRolls(crackermachine)
        end
    end)
end

// Moves the paperroll to the cutter
function zcm.f.Machine_MovePaperRolls(crackermachine)
    zcm.f.debug("zcm.f.Machine_MovePaperRolls")

    crackermachine:GetPaperRoller():SetBodygroup(0,0)

    crackermachine:SetProductionStage01(2)

    local m_speed = crackermachine:GetSpeed()

    timer.Simple(0.57 / m_speed,function()
        if IsValid(crackermachine) then
            crackermachine:GetRollCutter():SetBodygroup(0,1)
            crackermachine:GetRollMover():SetBodygroup(0,0)
        end
    end)

    timer.Simple(1 / m_speed,function()
        if IsValid(crackermachine) then
            zcm.f.Machine_CutRolls(crackermachine)
        end
    end)
end

// Cuts the paperroll in to 4 paper rolls
function zcm.f.Machine_CutRolls(crackermachine)
    zcm.f.debug("zcm.f.Machine_CutRolls")

    crackermachine:GetPaperRoller():SetBodygroup(0,0)

    crackermachine:SetProductionStage01(3)

    local m_speed = crackermachine:GetSpeed()


    timer.Simple(1 / m_speed,function()
        if IsValid(crackermachine) then
            crackermachine:SetProductionStage01(4)
        end
    end)

    timer.Simple(1.25 / m_speed ,function()
        if IsValid(crackermachine) then
            local rollrea = crackermachine:GetRollReleaser()
            if IsValid(rollrea) then
                rollrea:SetBodygroup(0,1)
                rollrea:SetBodygroup(1,1)
                rollrea:SetBodygroup(2,1)
                rollrea:SetBodygroup(3,1)
            end
        end
    end)

    timer.Simple(1.2 / m_speed, function()
        if IsValid(crackermachine) then
            crackermachine:GetRollCutter():SetBodygroup(0, 0)
        end
    end)

    timer.Simple(3 / m_speed, function()
        if IsValid(crackermachine) then
            crackermachine:SetPaperRolls(crackermachine:GetPaperRolls() + 4)
            local rollrea = crackermachine:GetRollReleaser()

            if IsValid(rollrea) then
                rollrea:SetBodygroup(0, 0)
                rollrea:SetBodygroup(1, 0)
                rollrea:SetBodygroup(2, 0)
                rollrea:SetBodygroup(3, 0)
            end

            crackermachine.Making_PaperRolls = false
        end
    end)
end

// Packs the paperrolls in to the paperroll binder
function zcm.f.Machine_PackRolls(crackermachine)
    zcm.f.debug("zcm.f.Machine_PackRolls")

    crackermachine:SetProductionStage02(1)

    local m_speed = crackermachine:GetSpeed()

    // Insert animation roll and disable rolls
    timer.Simple(0.95 / m_speed,function()
        if IsValid(crackermachine) then
            zcm.f.Machine_PackPaperRoll(crackermachine)
        end
    end)

    // Finished if we still have space in the crackerpack then we allow more rolls to be filled in otherwhise the reset is gonna be made with the build firework funcion
    timer.Simple(1.25 / m_speed, function()
        if IsValid(crackermachine) and crackermachine.BindRoll_CrackerPack:GetCrackerCount() < 37 then
            crackermachine:SetProductionStage02(0)
            crackermachine.Packing_Rolls = false
        end
    end)
end

// A loop function to add the amount of paperrolls in the paperpack
function zcm.f.Machine_PackPaperRoll(crackermachine)
    crackermachine:SetPaperRolls(math.Clamp(crackermachine:GetPaperRolls() - 1,0,zcm.config.CrackerMachine.PaperRoll_Cap))
    crackermachine.BindRoll_CrackerPack:SetCrackerCount(math.Clamp(crackermachine.BindRoll_CrackerPack:GetCrackerCount() + 1,0,37))
    zcm.f.debug("PaperRolls InMachine: " .. crackermachine:GetPaperRolls())
    zcm.f.debug("PaperRolls InFirework: " .. crackermachine.BindRoll_CrackerPack:GetCrackerCount())
end

// Bind paper rolls together
function zcm.f.Machine_BindRolls(crackermachine)
    crackermachine:SetFinalStage(1)
    crackermachine:SetProductionStage02(2)
    crackermachine.BindRoll_CrackerPack:SetCrackerCount(37)

    local m_speed = crackermachine:GetSpeed()

    timer.Simple(2 / m_speed,function()
        if IsValid(crackermachine) then
            crackermachine:GetRollBinder():SetBodygroup(1,1)
        end
    end)
    timer.Simple(3 / m_speed,function()
        if IsValid(crackermachine) then
            crackermachine.BindRoll_CrackerPack:SetBodygroup(0,1)
            crackermachine:GetRollBinder():SetBodygroup(1,0)
        end
    end)
    timer.Simple(4 / m_speed,function()
        if IsValid(crackermachine) then
            zcm.f.Machine_FillRolls(crackermachine)
        end
    end)
end

// Filles the paperrollpack with BlackPowder
function zcm.f.Machine_FillRolls(crackermachine)
    crackermachine:SetFinalStage(2)
    crackermachine:SetProductionStage02(3)

    local m_speed = crackermachine:GetSpeed()


    // Moves paperrollpack to filler
    timer.Simple(1.7 / m_speed,function()
        if IsValid(crackermachine) then

            // Enable PaperRollPack on arm
            crackermachine.Arm01_CrackerPack:SetNoDraw(false)

            // Reset PaperRollPack on RollBinder
            crackermachine.BindRoll_CrackerPack:SetBodygroup(0,0)
            crackermachine.BindRoll_CrackerPack:SetCrackerCount(0)
        end
    end)

    // Enable Filler Pack
    timer.Simple(4 / m_speed,function()
        if IsValid(crackermachine) then
            crackermachine:SetFinalStage(3)
            // Disable PaperRollPack on arm
            crackermachine.Arm01_CrackerPack:SetNoDraw(true)

            // Enable FillerPack
            crackermachine.Filler_CrackerPack:SetNoDraw(false)
        end
    end)

    //Fill paperrolls with BlackPowder
    timer.Simple(7 / m_speed,function()
        if IsValid(crackermachine) then
            crackermachine:SetFinalStage(4)
            crackermachine.Filler_CrackerPack:SetBodygroup(2,1)
            zcm.f.Machine_UseIngredient(crackermachine, 1)
        end
    end)

    // Change Remove firework from machine
    timer.Simple(8.3 / m_speed,function()
        if IsValid(crackermachine) then

            crackermachine:SetFinalStage(5)

            // Disable filler pack
            crackermachine.Filler_CrackerPack:SetBodygroup(2,0)
            crackermachine.Filler_CrackerPack:SetNoDraw(true)

            //Enable arm02 pack
            crackermachine.Arm02_CrackerPack:SetBodygroup(2,1)
            crackermachine.Arm02_CrackerPack:SetNoDraw(false)
        end
    end)

    // Spawns the finished crackerpack
    timer.Simple(10 / m_speed,function()
        if IsValid(crackermachine) then
            //Disable arm02 pack
            crackermachine.Arm02_CrackerPack:SetBodygroup(2,0)
            crackermachine.Arm02_CrackerPack:SetNoDraw(true)

            // Spawn firework
            zcm.f.Machine_SpawnFirework(crackermachine)

            // Tell the roll binder that we are done making firework
            crackermachine.Making_Firework = false

            crackermachine:SetFinalStage(0)
        end
    end)
end

// Spawns the final product
function zcm.f.Machine_SpawnFirework(crackermachine)
    local attach = crackermachine:GetAttachment(1)
    local ent = ents.Create("zcm_firecracker")
    ent:SetAngles(attach.Ang)
    ent:SetPos(attach.Pos)
    ent:Spawn()
    ent:Activate()
    ent:SetPos(ent:GetPos() + ent:GetUp() * 25)

    local owner = zcm.f.GetOwner(ent)
    if owner then
        zcm.f.SetOwner(ent, owner)

        //Vrondakis
        if (zcm.config.VrondakisLevelSystem) then
            owner:addXP(zcm.config.Vrondakis["Producing"].XP, " ", true)
        end
    end

    if zcm.config.CrackerMachine.Upgrades.AutoUpgrade_Count > 0 then
        crackermachine.ProducedFirework = crackermachine.ProducedFirework + 1

        if crackermachine.ProducedFirework >= zcm.config.CrackerMachine.Upgrades.AutoUpgrade_Count and crackermachine:GetUpgradeLevel() < zcm.config.CrackerMachine.Upgrades.Count then
            zcm.f.Machine_LevelUp(crackermachine)
            crackermachine.ProducedFirework = 0
        end
    end
end



////////// LEVEL UPGRADES /////////////////
function zcm.f.Machine_Upgrade(crackermachine, ply)
    if table.Count(zcm.config.CrackerMachine.Upgrades.Ranks) > 0 and not table.HasValue(zcm.config.CrackerMachine.Upgrades.Ranks, ply:GetUserGroup()) then

        return
    end

    if crackermachine:GetUpgradeLevel() >= zcm.config.CrackerMachine.Upgrades.Count then
        zcm.f.Notify(ply, zcm.language.General["ReachedMaxLevel"], 1)

        return
    end

    if CurTime() < crackermachine:GetUCooldDown() then
        return
    end

    if not zcm.f.HasMoney(ply, zcm.config.CrackerMachine.Upgrades.Cost) then
        zcm.f.Notify(ply, zcm.language.General["NotEnoughMoney"], 1)

        return
    end

    zcm.f.TakeMoney(ply, zcm.config.CrackerMachine.Upgrades.Cost)

    crackermachine:EmitSound("zcm_sell")

    zcm.f.Machine_LevelUp(crackermachine)

    zcm.f.Notify(ply, zcm.language.General["MachineUpgraded"], 0)

    if crackermachine:GetUpgradeLevel() < zcm.config.CrackerMachine.Upgrades.Count then
        crackermachine:SetUCooldDown(CurTime() + zcm.config.CrackerMachine.Upgrades.Cooldown)
    end
end

function zcm.f.Machine_LevelUp(crackermachine)
    crackermachine:SetUpgradeLevel(crackermachine:GetUpgradeLevel() + 1)
    local newSpeed = (1.55 / zcm.config.CrackerMachine.Upgrades.Count) * crackermachine:GetUpgradeLevel()
    newSpeed = newSpeed + 1
    newSpeed = math.Round(newSpeed, 2)
    crackermachine:SetSpeed(newSpeed)
end
