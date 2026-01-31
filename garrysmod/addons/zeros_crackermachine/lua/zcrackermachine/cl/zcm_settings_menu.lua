if not CLIENT then return end
local Created = false
CreateConVar("zcm_cl_vfx_updatedistance", "2500", {FCVAR_ARCHIVE})
CreateConVar("zcm_cl_vfx_effectcount", "25", {FCVAR_ARCHIVE})
CreateConVar("zcm_cl_sfx_volume", "0.6", {FCVAR_ARCHIVE})
CreateConVar("zcm_cl_hud_YPos", "1", {FCVAR_ARCHIVE})

local function zcrackermaker_settings(CPanel)
	Created = true
	CPanel:AddControl("Header", {
		Text = "Client Settings",
		Description = "Here you can change SFX and VFX Settings."
	})

	CPanel:AddControl("label", {
		Text = "__________________________________"
	})

	CPanel:AddControl("label", {
		Text = "This is the audio volume of the effects and machine."
	})

	local EffectVolume = CPanel:NumSlider("Volume", "zcm_cl_sfx_volume", 0, 1, 1)

	EffectVolume.OnChange = function(panel, bVal)
		if (not Created) then
			RunConsoleCommand("zcm_cl_sfx_volume", tostring(bVal))
		end
	end

	CPanel:AddControl("label", {
		Text = "__________________________________"
	})

	CPanel:AddControl("label", {
		Text = "This is the Distance for Rendering Effects."
	})

	local VFXUpdateDistance = CPanel:NumSlider("VFX Render Distance", "zcm_cl_vfx_updatedistance", 1000, 5000, 0)

	VFXUpdateDistance.OnChange = function(panel, bVal)
		if (not Created) then
			RunConsoleCommand("zcm_cl_vfx_updatedistance", tostring(bVal))
		end
	end

	CPanel:AddControl("label", {
		Text = "__________________________________"
	})

	CPanel:AddControl("label", {
		Text = "This is the max count of Cracker to be created at the same time to prevent Lag."
	})

	local VFXEffectOverFlow_count = CPanel:NumSlider("VFX Max Count", "zcm_cl_vfx_effectcount", 1, 120, 0)

	VFXEffectOverFlow_count.OnChange = function(panel, bVal)
		if (not Created) then
			RunConsoleCommand("zcm_cl_vfx_effectcount", tostring(bVal))
		end
	end


	CPanel:AddControl("label", {
		Text = "__________________________________"
	})

	CPanel:AddControl("label", {
		Text = "This is the Y Position of the HUD if the player picked up Firework."
	})

	local hMod = ScrH() / 1080


	local hudPos = CPanel:NumSlider("Y Position", "zcm_cl_hud_YPos", -500 * hMod, 500 * hMod, 0)

	hudPos.OnChange = function(panel, bVal)
		if (not Created) then
			RunConsoleCommand("zcm_cl_hud_YPos", tostring(bVal))
		end
	end

	timer.Simple(0.1, function()
		if (VFXUpdateDistance) then
			VFXUpdateDistance:SetValue(GetConVar("zcm_cl_vfx_updatedistance"):GetFloat())
		end

		if (VFXEffectOverFlow_count) then
			VFXEffectOverFlow_count:SetValue(GetConVar("zcm_cl_vfx_effectcount"):GetFloat())
		end

		if (EffectVolume) then
			EffectVolume:SetValue(math.Clamp(GetConVar("zcm_cl_sfx_volume"):GetFloat(), 0, 1))
		end

		if (hudPos) then
			hudPos:SetValue(math.Clamp(GetConVar("zcm_cl_hud_YPos"):GetFloat(), 1, 1000))
		end

		Created = false
	end)
end


hook.Add( "PopulateToolMenu", "PopulatezcmMenus", function()
	spawnmenu.AddToolMenuOption( "Options", "CrackerMaker", "zcm_Settings", "Client Settings", "", "", zcrackermaker_settings )
end )

hook.Add( "AddToolMenuCategories", "CreatezcmCategories", function()
	spawnmenu.AddToolCategory( "Options", "CrackerMaker", "CrackerMaker" );
end )
