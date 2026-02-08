
// Returns how high the chance is to get infected
local function InfectionDanger()

	local closest_treat
	local lastDist = 99999999
	local pos = LocalPlayer():GetPos()
	for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), zbl.config.McPhone.scan_radius)) do
		if IsValid(v) and (v:IsPlayer() and v:Alive() and v ~= LocalPlayer()) or zbl.config.Contamination.ents[v:GetClass()] or v:GetClass() == "zbl_virusnode" then
			if v:GetClass() == "zbl_virusnode" then
				local dist = v:GetPos():DistToSqr(pos)

				if dist < lastDist then
					closest_treat = v
					lastDist = dist
				end
			else
				local vac = v:GetNWInt("zbl_Vaccine", -1)

				if vac ~= -1 and vac > 0 and zbl.config.Vaccines[vac].isvirus then
					local dist = v:GetPos():DistToSqr(pos)

					if dist < lastDist then
						closest_treat = v
						lastDist = dist
					end
				end
			end
		end
	end

	local final = 0
	if IsValid(closest_treat) then
		local dist_sqr = closest_treat:GetPos():DistToSqr(pos)
		final = (100 / (300 * 300)) * dist_sqr
		final = math.Clamp(100 - final, 0, 100)
	end


	return math.Round(final)
end

local module_id = #McPhone.Modules + 1

McPhone.Modules[module_id] = {}

McPhone.Modules[module_id].name = "Genetic Surprise™"

McPhone.Modules[module_id].icon = "zerochain/zblood/mcphone/zbl_mcphone_app_icon.png"

McPhone.Modules[module_id].openMenu = function()

	if !McPhone.UI or !McPhone.UI.Menu then return end

	local m_list, m_numbers, m_send, m_reed

	function m_list()
		McPhone.UI.Menu:Clear()
		McPhone.UI.Menu:SetPos( 20, 140 )
		McPhone.UI.Menu:SetSize( 270, 256 )
		McPhone.UI.Menu.List = true
		McPhone.UI.Menu:EnableHorizontal( true )

		local frame = vgui.Create( "DPanel" )
		frame:SetSize( 256, 256 )
		frame:SetDisabled( true )
		frame.InfectChance = 0
		frame.IsScanning = false
		frame.Paint = function(self, w, h)
			draw.RoundedBox(1, 0, 0, w, h, zbl.default_colors["black04"])

			if self.IsScanning == false then
				draw.RoundedBox(1, 10, 200, 240, 30, zbl.default_colors["black03"])
				draw.SimpleText(zbl.language.Gun["Scan"], "zbl_lab_button_main", w / 2, 215, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			draw.SimpleText("Infection risk: " .. self.InfectChance .. "%", "zbl_lab_analyze_names", 10, 180, zbl.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(zbl.default_colors["white06"])
			surface.SetMaterial(zbl.default_materials["zbl_mask_off"])
			surface.DrawTexturedRect(53, 15, 150,150)

			if IsValid(LocalPlayer().zbl_GasMask_model) then
				surface.SetDrawColor(zbl.default_colors["cure_green"])
				surface.SetMaterial(zbl.default_materials["zbl_mask_on"])
				surface.DrawTexturedRect(53, 15, 150, 150)
				draw.SimpleText(math.Round((100 / zbl.config.Respirator.Uses) * LocalPlayer():GetNWInt("zbl_RespiratorUses", 0)) .. "%", "zbl_lab_analyze_names", w / 2, 105, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		timer.Simple(0, function()
			frame:SetDisabled( false )
		end)

		McPhone.zbl_main = frame
		McPhone.UI.Menu:AddItem(frame)

		McPhone.UI.Buttons.Left = {nil,nil,nil}
		McPhone.UI.Buttons.Middle = {"mc_phone/icons/buttons/id4.png",McPhone.McPhone.Colors["green"], function()
			if McPhone.zbl_scanner then return end

			local scan_start = CurTime()
			McPhone.zbl_scanner = vgui.Create("DPanel", frame)
			McPhone.zbl_scanner:SetSize(240, 30)
			McPhone.zbl_scanner:SetPos(10, 200)

			McPhone.zbl_scanner.Paint = function(self, w, h)
				draw.RoundedBox(1, 0, 0, w, h, zbl.default_colors["black03"])
				draw.RoundedBox(1, 0, 0, (w / zbl.config.McPhone.scan_duration) * (CurTime() - scan_start), h, zbl.default_colors["cure_green"])
			end

			LocalPlayer():EmitSound("zbl_ui_click")
			McPhone.zbl_main.IsScanning = true

			timer.Simple(zbl.config.McPhone.scan_duration, function()

				if IsValid(McPhone.zbl_scanner) then
					McPhone.zbl_scanner:Remove()
					McPhone.zbl_scanner = nil
				end

				if IsValid(McPhone.zbl_main) then
					McPhone.zbl_main.IsScanning = false

					if McPhone.zbl_main:IsVisible() then
						LocalPlayer():EmitSound("zbl_scan_action")
						McPhone.zbl_main.InfectChance = InfectionDanger()
					end
				end
			end)

		end}
		McPhone.UI.Buttons.Right = {"mc_phone/icons/buttons/id15.png",McPhone.McPhone.Colors["red"], nil}
	end
	m_list()
end
