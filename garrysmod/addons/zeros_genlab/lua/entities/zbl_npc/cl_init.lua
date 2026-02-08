include("shared.lua")


local mat = Material( "zerochain/props_bloodlab/hazmat/zbl_hazmat_skin_colormask" )

function ENT:Initialize()
	local col = zbl.f.ColorToVector(zbl.config.NPC.SkinColor)
	mat:SetVector("$color2", col)
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zbl_cl_drawui"):GetInt() == 1 and zbl.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()
	local Pos = self:GetPos() + self:GetUp() * 85
	Pos = Pos + self:GetUp() * math.abs(math.sin(CurTime()) * 1)
	local Ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
	cam.Start3D2D(Pos, Ang, 0.1)
		draw.SimpleText(zbl.config.NPC.name, "zbl_npc_title", 0, 0, zbl.default_colors["grey01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(zbl.config.NPC.name, "zbl_npc_title", 2, 2, zbl.config.NPC.SkinColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
