if not CLIENT then return end
local Created = false


zbl = zbl or {}
zbl.f = zbl.f or {}

CreateConVar("zbl_cl_particleeffects", "1", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_dynlight", "0", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_drawui", "1", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_decals", "1", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_epilepsy", "1", {FCVAR_ARCHIVE})

CreateConVar("zbl_cl_spray_pos_x", "50", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_spray_pos_y", "95", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_spray_scale", "1", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_spray_enabled", "1", {FCVAR_ARCHIVE})

CreateConVar("zbl_cl_mask_pos_x", "95", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_mask_pos_y", "10", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_mask_scale", "1", {FCVAR_ARCHIVE})
CreateConVar("zbl_cl_mask_enabled", "1", {FCVAR_ARCHIVE})



local function zbl_OptionPanel(name, CPanel, cmds)
	local panel = vgui.Create("DPanel")
	panel:SetSize(250 , 40 + (35 * table.Count(cmds)))
	panel.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, zbl.default_colors["grey_light"])
	end
	//panel:SetPaintBackground(true)
	//panel:SetBackgroundColor(zbl.default_colors["grey_light"])

	local title = vgui.Create("DLabel", panel)
	title:SetPos(10, 2.5)
	title:SetText(name)
	title:SetFont("zbl_settings_font01")
	title:SetSize(panel:GetWide(), 30)
	title:SetTextColor(zbl.default_colors["virus_red"])

	for k, v in pairs(cmds) do
		if v.class == "DNumSlider" then

			local item = vgui.Create("DNumSlider", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText(v.name)
			item:SetMin(v.min)
			item:SetMax(v.max)
			item:SetDecimals(v.decimal)
			item:SetDefaultValue(math.Clamp(math.Round(GetConVar(v.cmd):GetFloat(),v.decimal),v.min,v.max))
			item:ResetToDefaultValue()

			item.OnValueChanged = function(self, val)

				if (not Created) then
					RunConsoleCommand(v.cmd, tostring(val))
				end
			end

			timer.Simple(0.1, function()
				if (item) then
					item:SetValue(math.Clamp(math.Round(GetConVar(v.cmd):GetFloat(),v.decimal),v.min,v.max))
				end
			end)

		elseif v.class == "DCheckBoxLabel" then

			local item = vgui.Create("DCheckBoxLabel", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText( v.name )
			item:SetConVar( v.cmd )
			item:SetValue(0)
			item.OnChange = function(self, val)

				if (not Created) then
					if ((bVal and 1 or 0) == cvars.Number(v.cmd)) then return end
					RunConsoleCommand(v.cmd, tostring(val))
				end
			end

			timer.Simple(0.1, function()
				if (item) then
					item:SetValue(GetConVar(v.cmd):GetInt())
				end
			end)
		elseif v.class == "DButton" then
			local item = vgui.Create("DButton", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText( "" )
			//item:SetConsoleCommand( v.cmd )
			item.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["grey_lighter"])
				draw.SimpleText(v.name, "zbl_settings_font02", w / 2, h / 2, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if s.Hovered then
					draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white05"])
				end
			end
			item.DoClick = function()

				if zbl.f.IsAdmin(LocalPlayer()) == false then return end

				LocalPlayer():EmitSound("zbl_ui_click")

				if v.notify then

					notification.AddLegacy(  v.notify, NOTIFY_GENERIC, 2 )
				end
				LocalPlayer():ConCommand( v.cmd )

			end
		end
	end

	CPanel:AddPanel(panel)
end


local function BloodLab_settings(CPanel)
	Created = true
	CPanel:AddControl("Header", {
		Text = "Client Settings",
		Description = ""
	})

	zbl_OptionPanel("VFX",CPanel,{

		[1] = {name = "ParticleEffects",class = "DCheckBoxLabel", cmd = "zbl_cl_particleeffects"},
		[2] = {name = "Dynamiclight",class = "DCheckBoxLabel", cmd = "zbl_cl_dynlight"},
		[3] = {name = "Decals",class = "DCheckBoxLabel", cmd = "zbl_cl_decals"},
		[4] = {name = "Epilepsy SafeMode",class = "DCheckBoxLabel", cmd = "zbl_cl_epilepsy"},
	})

	zbl_OptionPanel("Disinfectant - UI",CPanel,{
		[1] = {name = "Show",class = "DCheckBoxLabel", cmd = "zbl_cl_spray_enabled"},
		[2] = {name = "Pos X",class = "DNumSlider", cmd = "zbl_cl_spray_pos_x",min = 0,max = 100,decimal = 0},
		[3] = {name = "Pos Y",class = "DNumSlider", cmd = "zbl_cl_spray_pos_y",min = 0,max = 100,decimal = 0},
		[4] = {name = "Scale",class = "DNumSlider", cmd = "zbl_cl_spray_scale",min = 0.5,max = 2,decimal = 1},
	})

	zbl_OptionPanel("Respirator - UI",CPanel,{
		[1] = {name = "Show",class = "DCheckBoxLabel", cmd = "zbl_cl_mask_enabled"},
		[2] = {name = "Pos X",class = "DNumSlider", cmd = "zbl_cl_mask_pos_x",min = 0,max = 100,decimal = 0},
		[3] = {name = "Pos Y",class = "DNumSlider", cmd = "zbl_cl_mask_pos_y",min = 0,max = 100,decimal = 0},
		[4] = {name = "Scale",class = "DNumSlider", cmd = "zbl_cl_mask_scale",min = 0.5,max = 2,decimal = 1},
	})

	timer.Simple(0.2, function()
		Created = false
	end)
end

local function BloodLab_admin_settings(CPanel)

	CPanel:AddControl("Header", {
		Text = "Admin Commands",
		Description = ""
	})

	zbl_OptionPanel("NPC",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zbl_save_npc"},
		[2] = {name = "Remove",class = "DButton", cmd = "zbl_remove_npc"},
	})

	zbl_OptionPanel("Virus HotSpots",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zbl_debug_VHS_SavePos"},
		[2] = {name = "Remove",class = "DButton", cmd = "zbl_debug_VHS_RemovePos"},
	})

	zbl_OptionPanel("Anti Infection Zone",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zbl_debug_AIZ_SavePos"},
		[2] = {name = "Remove",class = "DButton", cmd = "zbl_debug_AIZ_RemovePos"},
	})

	zbl_OptionPanel("Usefull Commands",CPanel,{
		[1] = {name = "Cure All",class = "DButton", cmd = "zbl_debug_ForceCure",notify = "Everyone got cured!"},
		[2] = {name = "Clear Contaminated Objects",class = "DButton", cmd = "zbl_debug_Ctmn_ClearObjects",notify = "Contaminated Object cleared!"},
		[3] = {name = "Remove all VirusNodes",class = "DButton", cmd = "zbl_debug_VN_removeall",notify = "Virusnodes removed!"},
		[4] = {name = "Remove all Corpses",class = "DButton", cmd = "zbl_debug_corpse_removeall",notify = "Corpses removed!"},
		[5] = {name = "Toggle Respirator Random",class = "DButton", cmd = "zbl_debug_GasMask_switch"},
		[6] = {name = "Spawn Flasks Random",class = "DButton", cmd = "zbl_debug_flask_random"},
		[7] = {name = "Spawn Blood Sample",class = "DButton", cmd = "zbl_debug_flask_blood_unique"},
	})
end

hook.Add("AddToolMenuCategories", "zbl_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "GenLab", "GenLab")
end)

hook.Add("PopulateToolMenu", "zbl_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "GenLab", "zbl_Settings", "Client Settings", "", "", BloodLab_settings)
	spawnmenu.AddToolMenuOption("Options", "GenLab", "zbl_Admin_Settings", "Admin Settings", "", "", BloodLab_admin_settings)
end)
