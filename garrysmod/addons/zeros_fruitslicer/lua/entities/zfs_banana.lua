---------------------------------------------------------------
------ Model & Design by: Zerochain | Coding by : Zerochain ---
---------------------------------------------------------------
AddCSLuaFile()
DEFINE_BASECLASS("zfs_fruit")
ENT.Spawnable = false
ENT.Base = "zfs_fruit"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PrintName = "Banana"
ENT.Category = "Zeros FruitSlicer"
ENT.Model = "models/zerochain/fruitslicerjob/fs_banana.mdl"
ENT.PrepareAmount = 5
ENT.ChangeColorAtBodygroup = 1
ENT.LastBodygroup_Color = Color(255, 255, 255, 255)
ENT.AngleOffset = 0

function ENT:Initialize()
    self:SetColor(HSVToColor(math.random(45, 65), 1, 1))

    return self.BaseClass.Initialize(self)
end

function ENT:Interact_VFX_SFX()
    self:CreateEffect_Table("zfs_banana", "zfs_sfx_banana", self, self:GetAngles(), self:GetPos())

    return self.BaseClass.Interact_VFX_SFX(self)
end
