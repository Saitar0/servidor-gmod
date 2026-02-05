/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not CLIENT then return end


local function Methlab2_settings(CPanel)
	CPanel:AddControl("Header", {
		Text = "Client Settings",
	})

	zclib.Settings.OptionPanel("VFX","",Color(50, 113, 207, 255),zclib.colors["ui02"],CPanel,{
		[1] = {name = "Dynamiclight",class = "DCheckBoxLabel", cmd = "zmlab2_cl_vfx_dynamiclight"},
		[2] = {name = "Effects",class = "DCheckBoxLabel", cmd = "zmlab2_cl_particleeffects"},
	})
end

local function Methlab2_admin_settings(CPanel)

	CPanel:AddControl("Header", {
		Text = "Admin Commands",
	})

	zclib.Settings.OptionPanel("Meth Buyer","This includes the Meth Buyer NPC and the\nDropOff Points.",Color(50, 113, 207, 255),zclib.colors["ui02"],CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zmlab2_sellsetup_save"},
		[2] = {name = "Delete",class = "DButton", cmd = "zmlab2_sellsetup_remove"},
	})

	zclib.Settings.OptionPanel("Public Setup","If the config is setup correctly such that owner\nchecks are disabled then you can build a\nwhole methlab as a public utility.",Color(50, 113, 207, 255),zclib.colors["ui02"],CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zmlab2_publicsetup_save"},
		[2] = {name = "Delete",class = "DButton", cmd = "zmlab2_publicsetup_remove"},
	})

	zclib.Settings.OptionPanel("Commands","Some usefull debug commands.",Color(50, 113, 207, 255),zclib.colors["ui02"],CPanel,{
		[1] = {name = "Spawn Methbag",class = "DButton", cmd = "zmlab2_debug_Meth_Test"},
		[2] = {name = "Spawn Methcrate",class = "DButton", cmd = "zmlab2_debug_Crate_Test"},
		[3] = {name = "Add Pollution",class = "DButton", cmd = "zmlab2_debug_PollutionSystem_AddPollution"},
		[4] = {name = "Clear Pollution",class = "DButton", cmd = "zmlab2_debug_PollutionSystem_ClearPollution"},
	})
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

hook.Add("AddToolMenuCategories", "zmlab2_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "zmlab2_options", "Methlab 2")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

hook.Add("PopulateToolMenu", "zmlab2_PopulateMenus", function()
	spawnmenu.AddToolMenuOption("Options", "zmlab2_options", "zmlab2_Settings", "Client Settings", "", "", Methlab2_settings)
	spawnmenu.AddToolMenuOption("Options", "zmlab2_options", "zmlab2_Admin_Settings", "Admin Settings", "", "", Methlab2_admin_settings)
end)

