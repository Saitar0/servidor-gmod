if SERVER then return end

zbl = zbl or {}
zbl.f = zbl.f or {}


local function HasToolActive()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		local tool = ply:GetTool()

		if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "zbl_aiztool" and tool.Name == "#Anti Infection Zone" then
			return true
		else
			return false
		end
	else
		return false
	end
end


zbl_AIZ_Hints = {}

net.Receive("zbl_aiz_showall", function(len)
	zbl.f.Debug("zbl_aiz_showall Len: " .. len)

	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)

	if positions then
		zbl_AIZ_Hints = positions
	end
end)

net.Receive("zbl_aiz_hideall", function(len)
	zbl_AIZ_Hints = {}
end)

hook.Add("PostDrawTranslucentRenderables", "zbl_PostDrawTranslucentRenderables_AIZ", function()
	if HasToolActive() then

		local tr = LocalPlayer():GetEyeTrace()
		if tr.Hit and not IsValid(tr.Entity) and zbl.f.InDistance(tr.HitPos, LocalPlayer():GetPos(), 3000) then
			local size = LocalPlayer():GetTool():GetClientNumber("ZoneRadius", 3)

			render.SetColorMaterial()
			render.DrawSphere(tr.HitPos, size, 12, 12, zbl.default_colors["aiz_green"])
			render.DrawWireframeSphere( tr.HitPos, size, 12, 12, zbl.default_colors["aiz_green"],true )
		end


		for k, v in pairs(zbl_AIZ_Hints) do
			if v then
				local pos = v.pos
				local size = v.radius or 100
				render.SetColorMaterial()
				render.DrawSphere( pos, size, 12,12, zbl.default_colors["aiz_green"] )
				render.DrawWireframeSphere( pos, size, 12, 12, zbl.default_colors["aiz_green"],false )
			end
		end
	end
end)
