ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Model =  "models/zerochain/props_bloodlab/zbl_virusknot.mdl"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.PrintName = "Virus Node"
ENT.Category = "Zeros GenLab"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "VHealth")

    if (SERVER) then
        self:SetVHealth(zbl.config.VirusHotspots.node_health_default)
    end
end
