if SERVER then return end

ztm = ztm or {}
ztm.f = ztm.f or {}

function ztm.f.ToolGun_HasToolActive()
	local ply = LocalPlayer()

	if IsValid(ply) and ply:Alive() and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
		local tool = ply:GetTool()

		if tool and table.Count(tool) > 0 and IsValid(tool.SWEP) and tool.Mode == "ztm_trashspawner" and tool.Name == "#TrashSpawner" then
			return true
		else
			return false
		end
	else
		return false
	end
end

hook.Add("PostDrawTranslucentRenderables", "ztm_PostDrawTranslucentRenderables_trashspawner", function()
	if ztm.f.ToolGun_HasToolActive() then
		local tr = LocalPlayer():GetEyeTrace()
		if tr.Hit and not IsValid(tr.Entity) and ztm.f.InDistance(tr.HitPos, LocalPlayer():GetPos(), 300) then
			render.SetColorMaterial()
			render.DrawWireframeSphere(tr.HitPos, 1, 4, 4, ztm.default_colors["white01"], false)
		end
	end
end)







local wMod = ScrW() / 1920
local hMod = ScrH() / 1080
ztm_Trash_Hints = {}

net.Receive("ztm_trash_showall", function(len)

	local dataLength = net.ReadUInt(16)
	local d_Decompressed = util.Decompress(net.ReadData(dataLength))
	local positions = util.JSONToTable(d_Decompressed)

	if positions then
		ztm_Trash_Hints = positions
	end
end)

net.Receive("ztm_trash_hideall", function(len)

	ztm_Trash_Hints = {}
end)

function ztm.f.Trash_DrawHints()
	if ztm_Trash_Hints and table.Count(ztm_Trash_Hints) > 0 then
		for k, v in pairs(ztm_Trash_Hints) do
			if v then
				local pos = v:ToScreen()
				local size = 10
				surface.SetDrawColor(ztm.default_colors["red02"])
				surface.DrawRect(pos.x - (size * wMod) / 2, pos.y - (size * hMod) / 2, size * wMod, size * hMod)
			end
		end
	end
end

hook.Add("HUDPaint", "ztm_HUDPaint_TrashHints", ztm.f.Trash_DrawHints)
