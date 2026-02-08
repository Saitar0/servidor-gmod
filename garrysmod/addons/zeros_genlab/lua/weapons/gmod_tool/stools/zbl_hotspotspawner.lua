AddCSLuaFile()

TOOL.Category = "Zeros GenLab"
TOOL.Name = "#Hotspot Spawner"
TOOL.Command = nil


if (CLIENT) then
	language.Add("tool.zbl_hotspotspawner.name", "Zeros GenLab - Virus Hotspot Spawner")
	language.Add("tool.zbl_hotspotspawner.desc", "LeftClick: Creates a Virus HotSpot. \nRightClick: Removes a Virus HotSpot.")
	language.Add("tool.zbl_hotspotspawner.0", "LeftClick: Creates a Virus HotSpot.")
end


function TOOL:LeftClick(trace)
	local trEnt = trace.Entity

	if trEnt:IsPlayer() then return false end

	if (CLIENT) then return end

	if (trEnt:GetClass() == "worldspawn") then

		if trace.Hit and trace.HitPos and zbl.f.InDistance(trace.HitPos, self:GetOwner():GetPos(), 3000) and zbl.f.IsAdmin(self:GetOwner()) then
			local _ang = trace.HitNormal:Angle()
			_ang:RotateAroundAxis(_ang:Right(), -90)
			zbl.f.VHS_AddPos(trace.HitPos, _ang,self:GetOwner())
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
		if zbl.f.InDistance(trace.HitPos, self:GetOwner():GetPos(), 3000) and zbl.f.IsAdmin(self:GetOwner()) then
			zbl.f.VHS_RemovePos(trace.HitPos, self:GetOwner())
		end

		return true
	else
		return false
	end
end

function TOOL:Deploy()
	if SERVER then
		if zbl.f.IsAdmin(self:GetOwner()) == false then return end
		zbl.f.VHS_ShowAll(self:GetOwner())
	end
end

function TOOL:Holster()
	if SERVER then
		zbl.f.VHS_HideAll(self:GetOwner())
	end
end

function TOOL.BuildCPanel(CPanel)
	CPanel:AddControl("Header", {
		Text = "#tool.zbl_hotspotspawner.name",
		Description = "#tool.zbl_hotspotspawner.desc"
	})

	CPanel:AddControl("label", {
		Text = "Saves all the HotSpot points that are currently on the Map"
	})

	CPanel:Button("Save HotSpot points", "zbl_debug_VHS_SavePos")

	CPanel:AddControl("label", {
		Text = " "
	})
	CPanel:AddControl("label", {
		Text = "Removes all the HotSpot points that are currently on the Map"
	})

	CPanel:Button("Remove all HotSpot points", "zbl_debug_VHS_RemovePos")
end
