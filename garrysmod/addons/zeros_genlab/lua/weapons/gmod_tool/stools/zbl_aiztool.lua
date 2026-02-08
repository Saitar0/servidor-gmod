AddCSLuaFile()

TOOL.Category = "Zeros GenLab"
TOOL.Name = "#Anti Infection Zone"
TOOL.Command = nil
TOOL.ClientConVar["ZoneRadius"] = 500


if (CLIENT) then
	language.Add("tool.zbl_aiztool.name", "Zeros GenLab - Anti Infection Zone")
	language.Add("tool.zbl_aiztool.desc", "LeftClick: Creates a Anti Infection Zone. \nRightClick: Removes a Anti Infection Zone.")
	language.Add("tool.zbl_aiztool.0", "LeftClick: Creates a Anti Infection Zone.")
end


function TOOL:LeftClick(trace)
	local trEnt = trace.Entity

	if trEnt:IsPlayer() then return false end

	if (CLIENT) then return end

	if (trEnt:GetClass() == "worldspawn") then

		if trace.Hit and trace.HitPos and zbl.f.InDistance(trace.HitPos, self:GetOwner():GetPos(), 3000) and zbl.f.IsAdmin(self:GetOwner()) then

			local _radius = self:GetClientNumber("ZoneRadius", 3)

			zbl.f.AIZ_AddPos(trace.HitPos,_radius,self:GetOwner())
		end

		return true
	else
		return false
	end
end

function TOOL:RightClick(trace)
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return end

	if trace.Hit and trace.HitPos then
		if zbl.f.InDistance(trace.HitPos, self:GetOwner():GetPos(), 1000) and zbl.f.IsAdmin(self:GetOwner()) then
			zbl.f.AIZ_RemovePos(trace.HitPos, self:GetOwner(),self:GetClientNumber("ZoneRadius", 3))
		end

		return true
	else
		return false
	end
end

function TOOL:Deploy()
	if SERVER then
		if zbl.f.IsAdmin(self:GetOwner()) == false then return end
		zbl.f.AIZ_ShowAll(self:GetOwner())
	end
end

function TOOL:Holster()
	if SERVER then
		zbl.f.AIZ_HideAll(self:GetOwner())
	end
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.zbl_aiztool.name",
		Description = "#tool.zbl_aiztool.desc"
	})


	CPanel:NumSlider("Zone Radius", "zbl_aiztool_ZoneRadius", 100, 2000, 0)


	CPanel:AddControl("label", {
		Text = "Saves all the Anti Infection Zones that are currently on the Map"
	})

	CPanel:Button("Save Anti Infection Zone", "zbl_debug_AIZ_SavePos")

	CPanel:AddControl("label", {
		Text = " "
	})
	CPanel:AddControl("label", {
		Text = "Removes all the Anti Infection Zones that are currently on the Map"
	})

	CPanel:Button("Remove Anti Infection Zones", "zbl_debug_AIZ_RemovePos")
end
