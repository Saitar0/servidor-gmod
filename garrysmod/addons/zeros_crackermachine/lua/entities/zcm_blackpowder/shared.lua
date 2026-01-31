ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_crackermaker/zcm_blackpowder.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "BlackPowder"
ENT.Category = "Zeros Crackermachine"
ENT.RenderGroup = RENDERGROUP_OPAQUE


function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Destroyed")

    if (SERVER) then
        self:SetDestroyed(false)
    end
end
