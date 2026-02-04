---------------------------------------------------------------
------ Model & Design by: Zerochain | Coding by : Zerochain ---
---------------------------------------------------------------
AddCSLuaFile()
DEFINE_BASECLASS("zfs_fruit")
ENT.Spawnable = false
ENT.Base = "zfs_fruit"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PrintName = "Melon"
ENT.Category = "Zeros FruitSlicer"
ENT.Model = "models/zerochain/fruitslicerjob/fs_melon.mdl"
ENT.PrepareAmount = 5
ENT.ChangeColorAtBodygroup = -1
ENT.LastBodygroup_Color = nil
ENT.AngleOffset = 0

function ENT:Initialize()
    return self.BaseClass.Initialize(self)
end

function ENT:Finish_VFX_SFX()
    self:CreateEffect_Table(nil, "zfs_sfx_melon_finish", self, self:GetAngles(), self:GetPos())

    return self.BaseClass.Finish_VFX_SFX(self)
end

function ENT:Interact_VFX_SFX()
    self:CreateEffect_Table("zfs_melon", "zfs_sfx_melon", self, self:GetAngles(), self:GetPos())

    return self.BaseClass.Interact_VFX_SFX(self)
end
