if SERVER then return end

ztm = ztm or {}
ztm.f = ztm.f or {}

local last_entcatch = -1
local near_trashcans = {}

function ztm.f.PostDrawOpaqueRenderables_Trashcans()
	if IsValid(LocalPlayer()) and LocalPlayer():Alive() and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() ~= "ztm_trashcollector" then return end


	if CurTime() > last_entcatch then

		near_trashcans = {}

		for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(),500)) do
			if IsValid(v) and ztm.config.TrashCans.models[v:GetModel()] and v:GetNWInt("ztm_trash",nil) ~= nil and v:GetNWInt("ztm_trash") > 0 then

				table.insert(near_trashcans,v)
			end
		end

		last_entcatch = CurTime() + 1
	end

	if near_trashcans and table.Count(near_trashcans) > 0 then

		for k, v in pairs(near_trashcans) do
			if IsValid(v) then
				local pos = v:GetPos() + Vector(0,0,50)
				local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

				cam.Start3D2D(pos, ang, 0.1)

					draw.RoundedBox( 5, -5, 80 ,10,225 , ztm.default_colors["white01"] )

					surface.SetDrawColor(ztm.default_colors["grey01"])
					surface.SetMaterial(ztm.default_materials["ztm_trash_icon"])
					surface.DrawTexturedRect(-150 ,-150 ,300 , 300)

					draw.DrawText(v:GetNWInt("ztm_trash",0) .. ztm.config.UoW, "ztm_trash_font02", 0, -25, ztm.default_colors["black02"], TEXT_ALIGN_CENTER)
					draw.DrawText(v:GetNWInt("ztm_trash",0) .. ztm.config.UoW, "ztm_trash_font01", 0, -25, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				cam.End3D2D()
			end
		end
	end
end

hook.Add("PostDrawOpaqueRenderables", "PostDrawOpaqueRenderables_trashcans", function()
	if ztm.config.TrashCans.Enabled then
		ztm.f.PostDrawOpaqueRenderables_Trashcans()
	end
end)
