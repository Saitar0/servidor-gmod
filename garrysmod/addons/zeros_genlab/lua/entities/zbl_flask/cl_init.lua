include("shared.lua")

function ENT:Initialize()
	zbl.f.EntList_Add(self)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:DrawInfo(txt01,txt02,icon,color)
	surface.SetDrawColor(color)
	surface.SetMaterial(zbl.default_materials["zbl_hexagon_icon"])
	surface.DrawTexturedRect(-80,-80,160,160)

	surface.SetDrawColor(zbl.default_colors["white01"])
	surface.SetMaterial(icon)
	surface.DrawTexturedRect(-70,-70,140,140)

	draw.SimpleText(txt01, "zbl_flask_font01", 0, 100, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if txt02 then
		draw.SimpleText(txt02, "zbl_flask_font02", 0, 130, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zbl_cl_drawui"):GetInt() == 1 and zbl.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) then
		cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 0)) + Vector(0, 0, 25), Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.1)

			local _type = self:GetGenType()
			local _val = self:GetGenValue()
			local _vacdata = zbl.config.Vaccines[_val]

			if _type == 1 then
				self:DrawInfo(self:GetGenName(), zbl.language.General["DNA"] .. ": " .. self:GetGenPoints(), zbl.default_materials["zbl_dna_icon"], zbl.default_colors["sample_blue"])
			elseif _type == 2 then
				if _vacdata then
					if _vacdata.isvirus then
						self:DrawInfo(_vacdata.name, nil, zbl.default_materials["zbl_virus_icon"], zbl.default_colors["virus_red"])
					else
						self:DrawInfo(_vacdata.name, nil, zbl.default_materials["zbl_abillity_icon"], zbl.default_colors["abillity_yellow"])
					end
				end
			elseif _type == 3 then
				self:DrawInfo(_vacdata.name, nil, zbl.default_materials["zbl_cure_icon"], zbl.default_colors["cure_green"])
			end

		cam.End3D2D()
	end
end
