if not CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}
local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

hook.Add("PostDrawHUD", "ZCM.PostDrawHUD.CL.MachineCrateBuilder", function()
	local firework = LocalPlayer():GetNWInt("zcm_firework", 0)

	if firework > 0 then

		local Ypos = GetConVar("zcm_cl_hud_YPos"):GetFloat() or 1

		draw.RoundedBox(20, wMod * -50, hMod * 400 + Ypos, wMod * 150, hMod * 100, zcm.default_colors["black04"])

		surface.SetDrawColor(zcm.default_colors["white01"])
		surface.SetMaterial(zcm.default_materials["fireworkpack"])
		surface.DrawTexturedRect(wMod * 1, hMod * 400 + Ypos, wMod * 100, hMod * 100)

		draw.SimpleText(firework, "zcm_hud_font02", wMod * 45, hMod * 450 + Ypos, zcm.default_colors["black01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(firework, "zcm_hud_font01", wMod * 45, hMod * 450 + Ypos, zcm.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)
