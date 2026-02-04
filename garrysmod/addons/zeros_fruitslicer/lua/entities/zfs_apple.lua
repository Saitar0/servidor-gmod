---------------------------------------------------------------
------ Model & Design by: Zerochain | Coding by : Zerochain ---
---------------------------------------------------------------
AddCSLuaFile()
DEFINE_BASECLASS("zfs_fruit")
ENT.Spawnable = false
ENT.Base = "zfs_fruit"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PrintName = "Apple"
ENT.Category = "Zeros FruitSlicer"
ENT.Model = "models/zerochain/fruitslicerjob/fs_apple.mdl"
ENT.PrepareAmount = 8
ENT.ChangeColorAtBodygroup = -1
ENT.LastBodygroup_Color = nil
ENT.AngleOffset = -90

function ENT:Initialize()
    return self.BaseClass.Initialize(self)
end

function ENT:Interact_VFX_SFX()
    self:CreateEffect_Table("zfs_banana", "zfs_sfx_apple", self, self:GetAngles(), self:GetPos())

    return self.BaseClass.Interact_VFX_SFX(self)
end
