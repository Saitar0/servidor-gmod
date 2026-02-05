include("shared.lua")

function ENT:Initialize()
	ztm.f.EntList_Add(self)
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("ztm_cl_vfx_drawui"):GetInt() == 1 and ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) and ztm.f.IsTrashman(LocalPlayer()) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()
	local Pos = self:GetPos() + Vector(0, 0, 35)
	local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

	cam.Start3D2D(Pos, Ang, 0.1)

		draw.RoundedBox(5, -5, 60 , 5, 100, ztm.default_colors["white01"])

		surface.SetDrawColor(ztm.default_colors["grey01"])
		surface.SetMaterial(ztm.default_materials["ztm_trash_icon"])
		surface.DrawTexturedRect(-100 ,-100 ,200 , 200)

		draw.DrawText(self:GetTrash() .. ztm.config.UoW, "ztm_trash_font02",0,-20, ztm.default_colors["black02"], TEXT_ALIGN_CENTER)
		draw.DrawText(self:GetTrash() .. ztm.config.UoW, "ztm_trash_font01",0,-20, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)

	cam.End3D2D()
end

function ENT:OnRemove()
	ztm.f.ParticleEffect("ztm_trash_break01", self:GetPos(), Angle(0,0,0), Entity(1))
	ztm.f.ParticleEffect("ztm_trash_break02", self:GetPos(), Angle(0,0,0), Entity(1))
	ztm.f.ParticleEffect("ztm_trash_break03", self:GetPos(), Angle(0,0,0), Entity(1))
end
