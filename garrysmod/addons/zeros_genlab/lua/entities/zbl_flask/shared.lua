ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/zerochain/props_bloodlab/zbl_flask.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Gen Flask"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    // 0 = Empty
    // 1 = Sample - From a Player
    // 2 = Vaccine - Either a Virus or a Ability Boost
    // 3 = Cure - Cures the Player sickness

    self:NetworkVar("Int", 0, "GenType")
    self:NetworkVar("Int", 1, "GenValue")
    self:NetworkVar("String", 0, "GenName")
    self:NetworkVar("Int", 2, "GenPoints")
    self:NetworkVar("String", 1, "GenClass")

    if (SERVER) then
        self:SetGenType(0)
        self:SetGenValue(0)
        self:SetGenName("")
        self:SetGenPoints(0)
        self:SetGenClass("")
    end
end
