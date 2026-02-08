if SERVER then return end

zbl = zbl or {}
zbl.f = zbl.f or {}


zbl_HotSpots_Hints = {}

net.Receive("zbl_hotspot_showall", function(len)
	zbl.f.Debug("zbl_hotspot_showall Len: " .. len)

	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)

	if positions then
		zbl_HotSpots_Hints = positions
	end
end)

net.Receive("zbl_hotspot_hideall", function(len)
	zbl_HotSpots_Hints = {}
end)

local function HasToolActive()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		local tool = ply:GetTool()

		if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "zbl_hotspotspawner" and tool.Name == "#Hotspot Spawner" then
			return true
		else
			return false
		end
	else
		return false
	end
end


hook.Add("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_hotspotspawner", function()
	if HasToolActive() then
		local tr = LocalPlayer():GetEyeTrace()
		if tr.Hit and not IsValid(tr.Entity) and zbl.f.InDistance(tr.HitPos, LocalPlayer():GetPos(),3000) then
			render.SetColorMaterial()
			render.DrawSphere(tr.HitPos,50, 12, 12, zbl.default_colors["hotspot_red"])
			render.DrawWireframeSphere(tr.HitPos, 50, 12, 12, zbl.default_colors["hotspot_red"], true)
		end


		for k, v in pairs(zbl_HotSpots_Hints) do
			if v then
				render.SetColorMaterial()
				render.DrawSphere( v, 50, 12,12, zbl.default_colors["hotspot_red"] )
				render.DrawWireframeSphere( v, 50, 12, 12, zbl.default_colors["hotspot_red"],false )
			end
		end
	end
end)
