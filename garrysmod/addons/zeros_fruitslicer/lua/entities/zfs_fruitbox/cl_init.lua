include("shared.lua")
local IngrediensIcons = {}
IngrediensIcons["zfs_melon"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_watermelon.png", "smooth")
IngrediensIcons["zfs_banana"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_banana.png", "smooth")
IngrediensIcons["zfs_coconut"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_coconut.png", "smooth")
IngrediensIcons["zfs_pomegranate"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_pomegranate.png", "smooth")
IngrediensIcons["zfs_strawberry"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_strawberry.png", "smooth")
IngrediensIcons["zfs_kiwi"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_kiwi.png", "smooth")
IngrediensIcons["zfs_lemon"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_lemon.png", "smooth")
IngrediensIcons["zfs_orange"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_orange.png", "smooth")
IngrediensIcons["zfs_apple"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_apple.png", "smooth")

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()

	if (LocalPlayer():GetPos():Distance(self:GetPos()) < 300) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), -90)
	Pos = Pos + self:GetUp() * 16
	local iconSize = 100
	cam.Start3D2D(Pos, Ang, 0.2)
		surface.SetDrawColor(Color(255, 255, 255, 255))
		surface.SetMaterial(IngrediensIcons[self.FruitType])
		surface.DrawTexturedRect(-iconSize / 2, -iconSize / 2, iconSize, iconSize)
		draw.NoTexture()
		draw.DrawText(tostring(self.FruitAmount), "zfs_buttonfont01", 25, -25, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	cam.End3D2D()
end
