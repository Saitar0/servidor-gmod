if not CLIENT then return end
CreateConVar("ztm_cl_vfx_drawui", "1", {FCVAR_ARCHIVE})

local function ztrashman_createpanel(name, CPanel, cmds)
	local panel = vgui.Create("DPanel")
	local title = vgui.Create("DLabel", panel)

	panel:SetSize(250 , 35 + (35 * table.Count(cmds)))
	//panel:Dock(FILL)
	//panel:DockMargin(0, 0, 0, 0)
	panel:SetPaintBackground(true)
	panel:SetBackgroundColor(ztm.default_colors["blue01"])

	title:SetPos(5, 5)
	title:SetText(name)
	title:SetFont("ztm_settings_font01")
	title:SetSize(panel:GetWide(), 25)
	title:SetTextColor(ztm.default_colors["white01"])

	for k, v in pairs(cmds) do
		local button = vgui.Create("DButton", panel)
		button:SetPos(5,35 * k)
		//button:SetText(v.name)
		button:SetSize(panel:GetWide(), 30)
		button:SetText("")
		button.DoClick = function()
			LocalPlayer():ConCommand(v.cmd)
		end
		button.Paint = function(s,w,h)

			if s:IsHovered() then
				draw.RoundedBox(5, 0 , 0, w, h,  ztm.default_colors["blue02"])
			else
				draw.RoundedBox(5, 0 , 0, w, h,  ztm.default_colors["blue03"])
			end
			draw.DrawText(v.name, "ztm_settings_font02", w / 2, h / 3, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
		end
	end

	CPanel:AddPanel(panel)
end

local function ztrashman_admin_settings(CPanel)

	ztrashman_createpanel("All",CPanel,{
		[1] = {name = "Save", cmd = "ztm_save_all"},
		[2] = {name = "Remove", cmd = "ztm_remove_all"},
	})

	ztrashman_createpanel("Trashburners",CPanel,{
		[1] = {name = "Save", cmd = "ztm_save_trashburner"},
		[2] = {name = "Remove", cmd = "ztm_remove_trashburner"},
	})

	ztrashman_createpanel("Recyclers",CPanel,{
		[1] = {name = "Save", cmd = "ztm_save_recycler"},
		[2] = {name = "Remove", cmd = "ztm_remove_recycler"},
	})

	ztrashman_createpanel("Buyermachines",CPanel,{
		[1] = {name = "Save", cmd = "ztm_save_buyermachine"},
		[2] = {name = "Remove", cmd = "ztm_remove_buyermachine"},
	})

	ztrashman_createpanel("Leafpiles",CPanel,{
		[1] = {name = "Save", cmd = "ztm_save_leafpile"},
		[2] = {name = "Refresh", cmd = "ztm_debug_leafpile_refresh"},
		[3] = {name = "Remove", cmd = "ztm_remove_leafpile"},
	})

	ztrashman_createpanel("Manholes",CPanel,{
		[1] = {name = "Save", cmd = "ztm_save_manhole"},
		[2] = {name = "Remove", cmd = "ztm_remove_manhole"},
	})

	ztrashman_createpanel("Trash Spawns",CPanel,{
		[1] = {name = "Save", cmd = "ztm_save_trash"},
		[2] = {name = "Remove", cmd = "ztm_remove_trash"},
	})


end


hook.Add( "PopulateToolMenu", "ztm_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "Trashman", "ztm_Admin_Settings", "Admin Settings", "", "", ztrashman_admin_settings)
end )

hook.Add( "AddToolMenuCategories", "ztm_CreateCategories", function()
	spawnmenu.AddToolCategory( "Options", "Trashman", "Trashman" );
end )
