ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_bloodlab/zbl_lab.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "Gen Lab"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    // How many DNA Points are stored inside the lab
    self:NetworkVar("Int", 0, "DNAPoints")

    // What vaccine is selected for research
    self:NetworkVar("Int", 1, "SelectedVaccine")

    // How many bloodsamples are inside the lab
    self:NetworkVar("Int", 2, "SampleCount")

    // How many diffrent bloodsamples are inside the lab
    self:NetworkVar("Int", 3, "SampleVariability")

    // What state is the lab currently in
    self:NetworkVar("Int", 4, "ActionState")
    /*
        0 = Idle
        1 = Analyzing Blood
        2 = Making Vaccine
        3 = Making Cure
    */


    // Used to tell the clients when the progress is finished
    self:NetworkVar("Int", 5, "ProgressEnd")

    self:NetworkVar("Int", 6, "ProgressDuration")

    // This is the amount of DNA Points the player gets after all the samples got analyzed
    self:NetworkVar("Int", 7, "Reward")

    // This will be a string of DNA Point values
    // This will never be longer then 12 values because we only have 12 flasks room
    self:NetworkVar("String", 0, "SampleSequence")


    if (SERVER) then
        self:SetDNAPoints(0)

        self:SetSelectedVaccine(1)

        self:SetSampleCount(0)

        self:SetSampleVariability(0)

        self:SetActionState(0)

        self:SetProgressEnd(-1)
        self:SetProgressDuration(-1)

        self:SetReward(0)

        self:SetSampleSequence("")
    end
end
