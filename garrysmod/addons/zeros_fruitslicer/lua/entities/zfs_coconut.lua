---------------------------------------------------------------
------ Model & Design by: Zerochain | Coding by : Zerochain ---
---------------------------------------------------------------
AddCSLuaFile()
DEFINE_BASECLASS("zfs_fruit")
ENT.Spawnable = false
ENT.Base = "zfs_fruit"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PrintName = "Coconut"
ENT.Category = "Zeros FruitSlicer"
ENT.Model = "models/zerochain/fruitslicerjob/fs_coconut.mdl"
ENT.PrepareAmount = 6
ENT.ChangeColorAtBodygroup = 5
ENT.LastBodygroup_Color = Color(255, 255, 255, 255)
ENT.AngleOffset = 90

function ENT:Initialize()
    self:SetColor(HSVToColor(math.random(70, 100), 1, 1))

    return self.BaseClass.Initialize(self)
end

function ENT:Finish_VFX_SFX()
    self:CreateEffect_Table(nil, "zfs_sfx_coconut_finish", self, self:GetAngles(), self:GetPos())

    return self.BaseClass.Finish_VFX_SFX(self)
end

function ENT:Interact_VFX_SFX()
    self:CreateEffect_Table("zfs_coconut", "zfs_sfx_coconut", self, self:GetAngles(), self:GetPos())

    return self.BaseClass.Interact_VFX_SFX(self)
end
