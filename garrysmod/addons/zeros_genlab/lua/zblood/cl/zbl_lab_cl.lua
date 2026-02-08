if SERVER then return end
zbl = zbl or {}
zbl.f = zbl.f or {}
zbl.Actions = zbl.Actions or {}

////////////////////////////////////////////
//////////////////// Main //////////////////
////////////////////////////////////////////
function zbl.f.Lab_Initialize(Lab)
	zbl.f.Debug("Lab_Initialize")

	zbl.f.EntList_Add(Lab)

	Lab.VGUI = {}
	Lab.VGUI.Research = {}
	Lab.VGUI.Analyze = {}
	Lab.VGUI.Mainmenu = {}



	// The selected vaccine list
	Lab.VaccineListID = 1

	// The selected vaccine
	Lab.VaccineID = 1

	// The current action state we are in
	Lab.LastActionState = -1

	// Tells us if the screen is clsoed
	Lab.IsClosed = true

	// Tells us if the screen is animating
	Lab.IsAnimating = false

	// PoseParameter to controll the open/close state of the screen
	Lab.pp_Screen = 0

	Lab.SelectedCure = false


	timer.Simple(0.3,function()
		if IsValid(Lab) then
			zbl.f.Lab_UpdateVisuals(Lab)
		end
	end)
end

// The Main Panel
function zbl.f.Lab_CreateMainInterface(Lab)
	zbl.f.Debug("Lab_CreateMainInterface")
	Lab.VGUI.Main = vgui.Create("DPanel")
	Lab.VGUI.Main:ParentToHUD()
	Lab.VGUI.Main:SetMouseInputEnabled(true)
	Lab.VGUI.Main:SetPos(0, 0)
	Lab.VGUI.Main:SetSize(650, 400)
	Lab.VGUI.Main.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["lab_blue_dark"])
	end

	zbl.f.Lab_RemoveAllInterfaces(Lab)

	if Lab.LastActionState == 0 then
		zbl.f.Lab_MainMenu(Lab)
	elseif Lab.LastActionState == 1 then
		zbl.f.Lab_ProcessPanel(Lab)
	elseif Lab.LastActionState == 2 then
		zbl.f.Lab_ProcessPanel(Lab)
	elseif Lab.LastActionState == 3 then
		zbl.f.Lab_ProcessPanel(Lab)
	end
end

// The Draw Function of the Interface
function zbl.f.Lab_Draw(Lab)

	zbl.f.UpdateEntityVisuals(Lab)

	if IsValid(Lab) then

		// Is the player in distance?
		if zbl.f.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 1600) and Lab.IsAnimating == false and Lab.IsClosed == false then

			zbl.f.Lab_DrawInterface(Lab)
		else

			Lab.VaccineListID = 1
			Lab.VaccineID = 1

			// Hide the interface
			if Lab.VGUI and IsValid(Lab.VGUI.Main) and Lab.VGUI.Main:IsVisible() == true then
				Lab.VGUI.Main:SetVisible(false)
				Lab.VGUI.Main:Remove()
			end
		end

		if GetConVar("zbl_cl_dynlight"):GetInt() == 1 and zbl.f.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 600) and Lab.LastActionState > 0 then
			// Create Dynamic light
			zbl.f.Lab_Light(Lab)
		end
	end
end

function zbl.f.Lab_Light(Lab)
	local dlight01 = DynamicLight(Lab:EntIndex())
	local pos = Lab:LocalToWorld(Vector(0,40,40))

	if dlight01 then
		dlight01.pos = pos
		dlight01.r = zbl.default_colors["lab_blue"].r
		dlight01.g = zbl.default_colors["lab_blue"].g
		dlight01.b = zbl.default_colors["lab_blue"].b
		dlight01.brightness = 2
		dlight01.Decay = 1000
		dlight01.Size = 200
		dlight01.DieTime = CurTime() + 1
	end
end

function zbl.f.Lab_UpdateVisuals(Lab)
	Lab.LastActionState = Lab:GetActionState()

	if Lab.LastActionState == 0 then

		zbl.f.Lab_Animate(Lab,"idle",1)
	elseif Lab.LastActionState == 1 or Lab.LastActionState == 2 or Lab.LastActionState == 3 then

		zbl.f.Lab_Animate(Lab,"spin",1)
	end
end

function zbl.f.Lab_DrawInterface(Lab)
	zbl.vgui.Start3D2D(Lab:LocalToWorld(Vector(25, -16.5, 61.7)), Lab:LocalToWorldAngles(Angle(0, 90, 90)), 0.05)

		if Lab.VGUI and IsValid(Lab.VGUI.Main) then

			if Lab.VGUI and IsValid(Lab.VGUI.Main) and Lab.VGUI.Main:IsVisible() == false then
				Lab.VGUI.Main:SetVisible(true)
			end

			// Draws the UI
			Lab.VGUI.Main:zbl_Paint3D2D()


			// Cursor
			if zbl.vgui.IsPointingPanel(Lab.VGUI.Main) then
				local x, y = zbl.f.GetCursorPosition(Lab.VGUI.Main)

				surface.SetDrawColor(zbl.default_colors["white01"])
				surface.SetMaterial(zbl.default_materials["zbl_cursor"])
				surface.DrawTexturedRect(x - 10, y - 10, 20, 20)
			end
		else
			zbl.f.Lab_CreateMainInterface(Lab)
		end

	zbl.vgui.End3D2D()
end

// Gets called when the Lab gets removed
function zbl.f.Lab_OnRemove(Lab)
	zbl.f.Debug("Lab_OnRemove")
	if IsValid(Lab) then
		if Lab.VGUI and IsValid(Lab.VGUI.Main) then
			zbl.f.Debug("Lab_Interface_Removed")
			Lab.VGUI.Main:Remove()
		end

		if Lab.SoundObj and Lab.SoundObj:IsPlaying() == true then
			Lab.SoundObj:ChangeVolume(0, 0)
			Lab.SoundObj:Stop()
		end
	end
end

function zbl.f.Lab_Animate(Lab,anim,speed)
	local _,dur = Lab:LookupSequence( anim )
	local time = dur / speed

	zbl.f.PlayAnimation(Lab,anim, speed)
	return time
end

// Gets called when the actionstate changes
function zbl.f.Lab_OnStateChange(Lab,newstate,oldstate)
	zbl.f.Debug("Lab_OnStateChange")


	// Starts the processing animation
	if newstate == 1 or newstate == 2 or newstate == 3 then

		local dur = zbl.f.Lab_Animate(Lab,"prep",1)

		timer.Simple(dur,function()
			if IsValid(Lab) and Lab.LastActionState == 1 or Lab.LastActionState == 2 or Lab.LastActionState == 3  then

				zbl.f.Lab_Animate(Lab,"spin",1)
			end
		end)
	end

	// Finishes the processing animation
	if newstate == 0 and (oldstate == 1 or oldstate == 2 or oldstate == 3) then

		local dur = 1
		if oldstate == 2 or oldstate == 3 then
			dur = zbl.f.Lab_Animate(Lab,"output",1)
		else
			dur = zbl.f.Lab_Animate(Lab,"finish",1)
		end

		timer.Simple(dur,function()
			if IsValid(Lab) and Lab.LastActionState == 0 then
				zbl.f.Lab_Animate(Lab,"idle",1)
			end
		end)
	end

	Lab.LastActionState = newstate

	if Lab.VGUI and IsValid(Lab.VGUI.Main) then

		zbl.f.Lab_RemoveAllInterfaces(Lab)

		if newstate == 0 then
			zbl.f.Lab_MainMenu(Lab)
		elseif newstate == 1 then
			zbl.f.Lab_ProcessPanel(Lab)
		elseif newstate == 2 then
			zbl.f.Lab_ProcessPanel(Lab)
		elseif newstate == 3 then
			zbl.f.Lab_ProcessPanel(Lab)
		end
	end
end

function zbl.f.Lab_Think(Lab)

	zbl.f.Lab_OpenClose(Lab)

	zbl.f.Lab_Sound(Lab)

	if zbl.f.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 1600) then

		local _state = Lab:GetActionState()
		if Lab.LastActionState ~= _state then
			zbl.f.Lab_OnStateChange(Lab,_state,Lab.LastActionState)
		end
	else
		if Lab.SoundObj and Lab.SoundObj:IsPlaying() == true then
			Lab.SoundObj:ChangeVolume(0, 0)
			Lab.SoundObj:Stop()
		end
	end
end

function zbl.f.Lab_Sound(Lab)
	if Lab.LastActionState > 0 then
		if Lab.SoundObj == nil then
			Lab.SoundObj = CreateSound(Lab, "zbl_lab_scan")
		end

		if Lab.SoundObj:IsPlaying() == false then
			Lab.SoundObj:Play()
			Lab.SoundObj:ChangeVolume(0.3, 0)
		end
	else
		if Lab.SoundObj and Lab.SoundObj:IsPlaying() == true then
			Lab.SoundObj:ChangeVolume(0, 0)
			Lab.SoundObj:Stop()
		end
	end
end

// Open Closes the Screen according to the distance
function zbl.f.Lab_OpenClose(Lab)

	if zbl.f.InDistance(LocalPlayer():GetPos(), Lab:GetPos(), 100) then
		if Lab.pp_Screen >= 1 then
			if Lab.IsClosed == true then
				Lab.IsClosed = false

				if Lab.VGUI and IsValid(Lab.VGUI.Main) then
					Lab.VGUI.Main:SetAlpha(0)
					Lab.VGUI.Main:AlphaTo( 255, 0.3, 0, function() end )
				end

				Lab:EmitSound("zbl_lab_stop")
				Lab:StopSound("zbl_lab_move")
			end

			Lab.IsAnimating = false
		else
			if Lab.IsAnimating == false then
				Lab.IsAnimating = true

				Lab:EmitSound("zbl_lab_move")
				Lab:StopSound("zbl_lab_stop")
			end

		end

		Lab.pp_Screen = math.Clamp(Lab.pp_Screen + 2 * FrameTime(), 0, 1)
		Lab:SetPoseParameter("zbl_screenmover", Lab.pp_Screen)
	else
		if Lab.pp_Screen <= 0 then
			if Lab.IsClosed == false then
				Lab.IsClosed = true

				Lab:EmitSound("zbl_lab_stop")
				Lab:StopSound("zbl_lab_move")
			end

			Lab.IsAnimating = false
		else
			if Lab.IsAnimating == false then
				Lab.IsAnimating = true

				Lab:EmitSound("zbl_lab_move")
				Lab:StopSound("zbl_lab_stop")
			end
		end

		Lab.pp_Screen = math.Clamp(Lab.pp_Screen - 2 * FrameTime(), 0, 1)
		Lab:SetPoseParameter("zbl_screenmover", Lab.pp_Screen)
	end
end

function zbl.f.Lab_RemoveAllInterfaces(Lab)
	zbl.f.Debug("Lab_RemoveAllInterfaces")

	if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
		Lab.VGUI.Mainmenu.MainPanel:Remove()
	end

	if Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
		Lab.VGUI.Analyze.MainPanel:Remove()
	end

	if Lab.VGUI and Lab.VGUI.Research and IsValid(Lab.VGUI.Research.MainPanel) then
		Lab.VGUI.Research.MainPanel:Remove()
	end

	if Lab.VGUI and IsValid(Lab.VGUI.ProcessPanel) then
		Lab.VGUI.ProcessPanel:Remove()
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
////////////// ProgressBar /////////////////
////////////////////////////////////////////
// Creates a process bar which shows the progress
function zbl.f.Lab_ProcessPanel(Lab)
	zbl.f.Debug("Lab_ProcessPanel")

	zbl.f.Lab_RemoveAllInterfaces(Lab)

	if Lab.VGUI and IsValid(Lab.VGUI.ProcessPanel) then
		Lab.VGUI.ProcessPanel:Remove()
	end

	local name = ""
	local status = ""
	local color = zbl.default_colors["virus_red"]
	local icon = zbl.default_materials["zbl_virus_icon"]

	if Lab.LastActionState == 1 then
		status = zbl.language.General["analyzing"]
		color = zbl.default_colors["sample_blue"]
		icon = zbl.default_materials["zbl_dna_icon"]
	elseif Lab.LastActionState == 2 then
		local vac_data = zbl.config.Vaccines[Lab:GetSelectedVaccine()]

		if vac_data.isvirus then
			color = zbl.default_colors["virus_red"]
			icon = zbl.default_materials["zbl_virus_icon"]
		else
			color = zbl.default_colors["abillity_yellow"]
			icon = zbl.default_materials["zbl_abillity_icon"]
		end

		status = zbl.language.General["creating"]
		name = vac_data.name
	elseif Lab.LastActionState == 3 then
		local vac_data = zbl.config.Vaccines[Lab:GetSelectedVaccine()]
		status = zbl.language.General["creating"]
		name = vac_data.name
		color = zbl.default_colors["cure_green"]
		icon = zbl.default_materials["zbl_cure_icon"]
	end

	Lab.VGUI.ProcessPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.ProcessPanel:SetPos(0, 0)
	Lab.VGUI.ProcessPanel:SetSize(650, 400)
	Lab.VGUI.ProcessPanel.LastPoint = - CurTime()
	Lab.VGUI.ProcessPanel.Points = "..."
	Lab.VGUI.ProcessPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, 45, zbl.default_colors["lab_blue_dark"])
		draw.RoundedBox(0, 80, 200, 500, 60, zbl.default_colors["lab_blue_light"])
		local time = Lab:GetProgressDuration() - math.Clamp(Lab:GetProgressEnd() - CurTime(), 0, 999999999)
		local width = (500 / Lab:GetProgressDuration()) * time
		draw.RoundedBox(0, 80, 200, width, 60, color)

		if Lab.LastActionState > 1 then
			draw.DrawText(name, "zbl_lab_button_main", w / 2, 115, color, TEXT_ALIGN_CENTER)

			surface.SetDrawColor(color)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(w / 2 - 50, 25, 100, 100)
		else
			surface.SetDrawColor(color)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect(w / 2 - 75, 25, 150, 150)
		end

		if (s.LastPoint + 1) < CurTime() then
			s.LastPoint = CurTime()

			if string.len(s.Points) >= 3 then
				s.Points = "."
			else
				s.Points = s.Points .. "."
			end
		end

		draw.DrawText(status .. s.Points, "zbl_lab_points", w / 2, 310, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////////// MainMenu //////////////////
////////////////////////////////////////////
// Creates the Main Interface
function zbl.f.Lab_MainMenu(Lab)
	zbl.f.Debug("Lab_MainMenu")

	zbl.f.Lab_RemoveAllInterfaces(Lab)

	if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
		Lab.VGUI.Mainmenu.MainPanel:Remove()
	end

	local owner = zbl.f.GetOwner(Lab)
	local name = ""
	if IsValid(owner) then
		name = owner:Nick()
		name = string.Replace(zbl.language.General["LabTitle"],"$PlayerName",name)
	end

	Lab.VGUI.Mainmenu.MainPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.Mainmenu.MainPanel:SetPos(0, 0)
	Lab.VGUI.Mainmenu.MainPanel:SetSize(650, 400)
	Lab.VGUI.Mainmenu.MainPanel.Paint = function(s, w, h)

		draw.RoundedBox(0, 0, 0, w,52, zbl.default_colors["lab_blue_light"])
		draw.DrawText(name, "zbl_lab_top_title", 30, 15, zbl.default_colors["white01"], TEXT_ALIGN_LEFT)
	end


	Lab.VGUI.Mainmenu.PointPanel = vgui.Create("DPanel",Lab.VGUI.Mainmenu.MainPanel)
	Lab.VGUI.Mainmenu.PointPanel:SetPos(50, 300)
	Lab.VGUI.Mainmenu.PointPanel:SetSize(150, 60)
	Lab.VGUI.Mainmenu.PointPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w,h, zbl.default_colors["lab_blue_light"])

		draw.DrawText(Lab:GetDNAPoints(), "zbl_lab_points", 90, 12, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_dna_icon"])
		surface.DrawTexturedRect(0, 0, 60,60)
	end

	Lab.VGUI.Mainmenu.Analyze = vgui.Create("DButton", Lab.VGUI.Mainmenu.MainPanel)
	Lab.VGUI.Mainmenu.Analyze:SetPos(205,90)
	Lab.VGUI.Mainmenu.Analyze:SetSize(240 , 70 )
	Lab.VGUI.Mainmenu.Analyze:SetAutoDelete(true)
	Lab.VGUI.Mainmenu.Analyze:SetText("")
	Lab.VGUI.Mainmenu.Analyze.Paint = function(s, w, h)


		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])

		draw.SimpleText(zbl.language.General["Analyze"], zbl.f.GetFontFromTextSize(zbl.language.General["Analyze"], 7, "zbl_lab_button_main", "zbl_lab_button_main_small"), 20, h / 2, zbl.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.default_colors["cure_green"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_analyze"])
		surface.DrawTexturedRect(170, 10, 50,50)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end

	end
	Lab.VGUI.Mainmenu.Analyze.DoClick = function()

		if zbl.f.IsOwner(LocalPlayer(), Lab) == false then
			surface.PlaySound("common/warning.wav")
			notification.AddLegacy(zbl.language.General["Wrong Owner"], NOTIFY_ERROR, 3)
			return
		end

		if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
			Lab.VGUI.Mainmenu.MainPanel:Remove()
		end
		Lab:EmitSound("zbl_ui_click")
		zbl.f.Lab_AnalyzeInterface(Lab)
	end

	Lab.VGUI.Mainmenu.Research = vgui.Create("DButton", Lab.VGUI.Mainmenu.MainPanel)
	Lab.VGUI.Mainmenu.Research:SetPos(205,180)
	Lab.VGUI.Mainmenu.Research:SetSize(240 , 70 )
	Lab.VGUI.Mainmenu.Research:SetAutoDelete(true)
	Lab.VGUI.Mainmenu.Research:SetText("")
	Lab.VGUI.Mainmenu.Research.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])

		draw.SimpleText(zbl.language.General["Create"],  zbl.f.GetFontFromTextSize(zbl.language.General["Create"],7,"zbl_lab_button_main","zbl_lab_button_main_small"), 20, h/2, zbl.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		surface.SetDrawColor(zbl.default_colors["abillity_yellow"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_create"])
		surface.DrawTexturedRect(170, 10, 50,50)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	Lab.VGUI.Mainmenu.Research.DoClick = function()

		if zbl.f.IsOwner(LocalPlayer(), Lab) == false then
			surface.PlaySound("common/warning.wav")
			notification.AddLegacy(zbl.language.General["Wrong Owner"], NOTIFY_ERROR, 3)
			return
		end

		if Lab.VGUI and Lab.VGUI.Mainmenu and IsValid(Lab.VGUI.Mainmenu.MainPanel) then
			Lab.VGUI.Mainmenu.MainPanel:Remove()
		end
		Lab:EmitSound("zbl_ui_click")
		zbl.f.Lab_VaccineInterface(Lab)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
//////////////// Analyze //////////////////
////////////////////////////////////////////

// Creates a table of numbers from the SampleSequence
local function CreateSampleSequence(Lab)
	local sequence = Lab:GetSampleSequence()
	sequence = string.Split(sequence,"_" )

	local seq_tbl = {}

	if sequence and #sequence > 0 then
		for k,v in pairs(sequence) do
			local val = tonumber(v)

			seq_tbl[k] = val
		end
	end

	return seq_tbl
end
net.Receive("zbl_Lab_Sample_Update", function(len)
	zbl.f.Debug("zbl_Lab_Sample_Update len: " .. len)

	local Lab = net.ReadEntity()

	if IsValid(Lab) and Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
		zbl.f.Lab_AnalyzeInterface(Lab)
	end
end)


// Creates the Analyze Interface
function zbl.f.Lab_AnalyzeInterface(Lab)
	zbl.f.Debug("Lab_AnalyzeInterface")

	if Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
		Lab.VGUI.Analyze.MainPanel:Remove()
	end

	Lab.VGUI.Analyze.MainPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.Analyze.MainPanel:SetPos(0, 0)
	Lab.VGUI.Analyze.MainPanel:SetSize(650, 400)
	Lab.VGUI.Analyze.MainPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w,52, zbl.default_colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Analyze"], "zbl_lab_top_title", 30 , 15 , zbl.default_colors["white01"], TEXT_ALIGN_LEFT)

		local tw,th = zbl.f.GetTextSize(zbl.language.General["Analyze"],"zbl_lab_top_title")

		surface.SetDrawColor(zbl.default_colors["cure_green"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_analyze"])
		surface.DrawTexturedRect(tw + 35, 17, 30,30)
	end


	Lab.VGUI.Analyze.DataPanel = vgui.Create("DPanel", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.DataPanel:SetPos(50, 60)
	Lab.VGUI.Analyze.DataPanel:SetSize(550, 85)
	Lab.VGUI.Analyze.DataPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Sample Count"] .. ": ", "zbl_lab_analyze_names", 20, 10, zbl.default_colors["white01"], TEXT_ALIGN_LEFT)
		draw.DrawText(zbl.language.General["Sample Variability"] .. ": ", "zbl_lab_analyze_names", 20, 45, zbl.default_colors["white01"], TEXT_ALIGN_LEFT)

		draw.DrawText(Lab:GetSampleCount(), "zbl_lab_analyze_names", 520, 10, zbl.default_colors["cure_green"], TEXT_ALIGN_RIGHT)
		draw.DrawText(Lab:GetSampleVariability(), "zbl_lab_analyze_names", 520, 45, zbl.default_colors["cure_green"], TEXT_ALIGN_RIGHT)
	end


	Lab.VGUI.Analyze.DataResultPanel = vgui.Create("DPanel", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.DataResultPanel:SetPos(50, 155)
	Lab.VGUI.Analyze.DataResultPanel:SetSize(550, 60)
	Lab.VGUI.Analyze.DataResultPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Reasearch Points"] .. ": ", "zbl_lab_analyze_names", 20, 15, zbl.default_colors["white01"], TEXT_ALIGN_LEFT)
		draw.DrawText("+" .. Lab:GetReward(), "zbl_lab_points", 520, 12, zbl.default_colors["sample_blue"], TEXT_ALIGN_RIGHT)

		surface.SetDrawColor(zbl.default_colors["sample_blue"])
		surface.SetMaterial(zbl.default_materials["zbl_dna_icon"])
		surface.DrawTexturedRect(400, 5, 50,50)
	end

	Lab.VGUI.Analyze.PointPanel = vgui.Create("DPanel",Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.PointPanel:SetPos(50, 300)
	Lab.VGUI.Analyze.PointPanel:SetSize(150, 60)
	Lab.VGUI.Analyze.PointPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w,h, zbl.default_colors["lab_blue_light"])

		draw.DrawText(Lab:GetDNAPoints(), "zbl_lab_points", 90, 12, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_dna_icon"])
		surface.DrawTexturedRect(0, 0, 60,60)
	end

	local seq = CreateSampleSequence(Lab)
	Lab.VGUI.Analyze.FlaskButtons = {}

	for i = 1, 12 do
		local bttn_val = seq[i] or -1
		local bttn = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
		bttn:SetPos(4 + (46.5 * i), 225)
		bttn:SetSize(40, 40)
		bttn:SetAutoDelete(true)
		bttn:SetText("")
		bttn.DNAVal = bttn_val
		bttn.Index = i
		bttn.Paint = function(s, w, h)
			if s.DNAVal > -1 then
				if s.DNAVal > 0 then

					surface.SetDrawColor(zbl.default_colors["sample_blue"])
				else
					surface.SetDrawColor(zbl.default_colors["virus_red"])
				end
			else

				surface.SetDrawColor(zbl.default_colors["black03"])
			end

			surface.SetMaterial(zbl.default_materials["zbl_hexagon_icon"])
			surface.DrawTexturedRect(0, 0, w,h)




			if s.DNAVal > -1 then
				/*
				surface.SetDrawColor(zbl.default_colors["white02"])
				surface.SetMaterial(zbl.default_materials["zbl_dna_icon"])
				surface.DrawTexturedRect(0, 0, w,h)
				*/
				draw.SimpleText(s.DNAVal, "zbl_lab_analyze_names", w / 2, h / 2, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

			if s.DNAVal > -1 and s.Hovered then

				surface.SetDrawColor(zbl.default_colors["white02"])
				surface.SetMaterial(zbl.default_materials["zbl_hexagon_icon"])
				surface.DrawTexturedRect(0, 0, w,h)
			end
		end
		bttn.DoClick = function()
			if bttn.DNAVal > -1 then
				Lab:EmitSound("zbl_ui_click")
				zbl.f.Lab_RemoveSample(Lab,bttn.Index)
				 bttn.DNAVal = -1
			end
		end

		Lab.VGUI.Analyze.FlaskButtons[i] = bttn
	end

	Lab.VGUI.Analyze.AnalyzeSamples = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.AnalyzeSamples:SetPos(340,280)
	Lab.VGUI.Analyze.AnalyzeSamples:SetSize(260 , 80 )
	Lab.VGUI.Analyze.AnalyzeSamples:SetAutoDelete(true)
	Lab.VGUI.Analyze.AnalyzeSamples:SetText("")
	Lab.VGUI.Analyze.AnalyzeSamples.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])

		local time = zbl.config.GenLab.time_per_sample * Lab:GetSampleCount()
		local t_mod = zbl.config.GenLab.time_modify[zbl.f.GetPlayerRank(LocalPlayer())]
		if t_mod == nil then
			t_mod = zbl.config.GenLab.time_modify["default"]
		end
		time = time * t_mod

		time = zbl.f.FormatTime(time)

		local tw,th = zbl.f.GetTextSize(time,"zbl_lab_analyze_names")

		//draw.DrawText(zbl.f.FormatTime(250), "zbl_lab_analyze_names", 35 ,30 , zbl.default_colors["abillity_yellow"], TEXT_ALIGN_LEFT)
		draw.SimpleText(time, "zbl_lab_analyze_names", 115, h / 2, zbl.default_colors["abillity_yellow"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.default_colors["abillity_yellow"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_time"])
		surface.DrawTexturedRect((115 - tw/2) - 35, 30, 25,25)

		surface.SetDrawColor(zbl.default_colors["cure_green"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_analyze"])
		surface.DrawTexturedRect(w-70, 10, 60,60)


		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	Lab.VGUI.Analyze.AnalyzeSamples.DoClick = function()
		zbl.f.Lab_AnalyzeSamples(Lab)
		Lab:EmitSound("zbl_ui_click")
	end


	Lab.VGUI.Analyze.RemoveSamples = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.RemoveSamples:SetPos(230 , 280 ) //410
	Lab.VGUI.Analyze.RemoveSamples:SetSize(80 , 80 )
	Lab.VGUI.Analyze.RemoveSamples:SetAutoDelete(true)
	Lab.VGUI.Analyze.RemoveSamples:SetText("")
	Lab.VGUI.Analyze.RemoveSamples.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])

		surface.SetDrawColor(zbl.default_colors["virus_red"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_remove"])
		surface.DrawTexturedRect(10, 10, 60,60)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	Lab.VGUI.Analyze.RemoveSamples.DoClick = function()
		zbl.f.Lab_RemoveSamples(Lab)
		Lab:EmitSound("zbl_ui_click")
	end




	Lab.VGUI.Analyze.BackToMain = vgui.Create("DButton", Lab.VGUI.Analyze.MainPanel)
	Lab.VGUI.Analyze.BackToMain:SetPos(608 , 15 )
	Lab.VGUI.Analyze.BackToMain:SetSize(30 , 30 )
	Lab.VGUI.Analyze.BackToMain:SetAutoDelete(true)
	Lab.VGUI.Analyze.BackToMain:SetText("")
	Lab.VGUI.Analyze.BackToMain.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["virus_red"])

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_close"])
		surface.DrawTexturedRect(5, 5, 20,20)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	Lab.VGUI.Analyze.BackToMain.DoClick = function()
		if Lab.VGUI and Lab.VGUI.Analyze and IsValid(Lab.VGUI.Analyze.MainPanel) then
			Lab.VGUI.Analyze.MainPanel:Remove()
		end
		zbl.f.Lab_MainMenu(Lab)
		Lab:EmitSound("zbl_ui_click")
	end
end

function zbl.f.Lab_AnalyzeSamples(Lab)

	if Lab:GetSampleCount() <= 0 then
		surface.PlaySound( "common/warning.wav" )
		notification.AddLegacy( zbl.language.General["NotEnoughSamples"], NOTIFY_ERROR, 3 )
		return
	end

	net.Start("zbl_Lab_AnalyzeSample_Request")
	net.WriteEntity(Lab)
	net.SendToServer()
end

// Removes all samples
function zbl.f.Lab_RemoveSamples(Lab)

	if Lab:GetSampleCount() <= 0 then
		surface.PlaySound( "common/warning.wav" )
		notification.AddLegacy( zbl.language.General["NotEnoughSamples"], NOTIFY_ERROR, 3 )
		return
	end

	net.Start("zbl_Lab_RemoveSamples")
	net.WriteEntity(Lab)
	net.SendToServer()
end

// Removes a specific sample
function zbl.f.Lab_RemoveSample(Lab,index)

	net.Start("zbl_Lab_Sample_Remove")
	net.WriteEntity(Lab)
	net.WriteInt(index,6)
	net.SendToServer()
end
////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
//////////////// Vaccines //////////////////
////////////////////////////////////////////
// Creates the Main Interface
function zbl.f.Lab_VaccineInterface(Lab)
	zbl.f.Debug("Lab_VaccineInterface")

	if Lab.VGUI and Lab.VGUI.Research and IsValid(Lab.VGUI.Research.MainPanel) then
		Lab.VGUI.Research.MainPanel:Remove()
	end

	Lab.VGUI.Research.MainPanel = vgui.Create("DPanel",Lab.VGUI.Main)
	Lab.VGUI.Research.MainPanel:SetPos(0, 0)
	Lab.VGUI.Research.MainPanel:SetSize(650, 400)
	Lab.VGUI.Research.MainPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w,52, zbl.default_colors["lab_blue_light"])

		draw.DrawText(zbl.language.General["Create"], "zbl_lab_top_title", 30 , 15 , zbl.default_colors["white01"], TEXT_ALIGN_LEFT)

		local tw,th = zbl.f.GetTextSize(zbl.language.General["Create"],"zbl_lab_top_title")

		surface.SetDrawColor(zbl.default_colors["abillity_yellow"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_create"])
		surface.DrawTexturedRect(tw + 35, 17, 30,30)
	end


	Lab.VGUI.Research.PointPanel = vgui.Create("DPanel",Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.PointPanel:SetPos(050, 300)
	Lab.VGUI.Research.PointPanel:SetSize(150, 60)
	Lab.VGUI.Research.PointPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w,h, zbl.default_colors["lab_blue_light"])

		draw.DrawText(Lab:GetDNAPoints(), "zbl_lab_points", 90, 12, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_dna_icon"])
		surface.DrawTexturedRect(0, 0, 60,60)
	end

	// Creates a side buttons for each 9 vaccines in the conifg
	Lab.VGUI.Research.VaccineListButtons = {}
	for i = 1,math.ceil(table.Count(zbl.config.Vaccines) / 6) do
		local butt = vgui.Create("DButton", Lab.VGUI.Research.MainPanel)

		butt:SetPos(19.5 , 60 + (i * 30) - 30 )
		butt:SetSize(25 , 25 )
		butt:SetAutoDelete(true)
		butt:SetText("")
		butt.Paint = function(s, w, h)
			if i ~= Lab.VaccineListID then
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])
			else
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["lab_blue_light"])

				surface.SetDrawColor(zbl.default_colors["white01"])
				surface.SetMaterial(zbl.default_materials["zbl_ex_square"])
				surface.DrawTexturedRect(0, 0, w, h)

			end

			draw.DrawText(i, "zbl_lab_create_category", 12 , 3 , zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

			if s.Hovered then
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
			end
		end
		butt.DoClick = function()
			// Create list with defined ending number i * 6
			zbl.f.Lab_VaccineList(Lab, math.Clamp(i * 6 - 5, 1, table.Count(zbl.config.Vaccines)))
			Lab.VaccineListID = i
			Lab:EmitSound("zbl_ui_click")
		end

		Lab.VGUI.Research.VaccineListButtons[i] = butt
	end

	Lab.VGUI.Research.BackToMain = vgui.Create("DButton", Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.BackToMain:SetPos(608 , 15 )
	Lab.VGUI.Research.BackToMain:SetSize(30 , 30 )
	Lab.VGUI.Research.BackToMain:SetAutoDelete(true)
	Lab.VGUI.Research.BackToMain:SetText("")
	Lab.VGUI.Research.BackToMain.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["virus_red"])

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_close"])
		surface.DrawTexturedRect(5, 5, 20,20)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	Lab.VGUI.Research.BackToMain.DoClick = function()
		if Lab.VGUI and Lab.VGUI.Research and IsValid(Lab.VGUI.Research.MainPanel) then
			Lab.VGUI.Research.MainPanel:Remove()
		end

		Lab:EmitSound("zbl_ui_click")

		Lab.VaccineListID = 1

		zbl.f.Lab_MainMenu(Lab)
	end

	zbl.f.Lab_VaccineList(Lab,1)
	zbl.f.Lab_VaccineInfo(Lab,1)
end

// Used for creating a line break in centerd text
local function DrawTextCentered_LineBreak(w, h, txt)
	if string.len(txt) > 12 then
		local _start, _end = string.find(txt, " ", 1, false)

		if _start then
			draw.SimpleText(string.sub(txt, 1, _start), "zbl_lab_item_name", w / 2, h - 30, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.sub(txt, _start + 1, string.len(txt)), "zbl_lab_item_name", w / 2, h - 15, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(txt, "zbl_lab_item_name", w / 2, h - 25, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	else
		draw.SimpleText(txt, "zbl_lab_item_name", w / 2, h - 25, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

// Creates the list of all the vaccines the user can create
function zbl.f.Lab_VaccineList(Lab,starting_id)

	zbl.f.Debug("Lab_VaccineList")
	if IsValid(Lab) and IsValid(Lab.VGUI.Research.ResearchPanel) then
		Lab.VGUI.Research.ResearchPanel:Remove()
	end

	Lab.VGUI.Research.ResearchPanel = vgui.Create("DPanel",Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.ResearchPanel:SetPos(50, 60)
	Lab.VGUI.Research.ResearchPanel:SetSize(300, 205)
	Lab.VGUI.Research.ResearchPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0 , 0, w, h,  zbl.default_colors["lab_blue_light"])
	end


	Lab.VGUI.Research.scrollpanel = vgui.Create("DScrollPanel", Lab.VGUI.Research.ResearchPanel)
	Lab.VGUI.Research.scrollpanel:DockMargin(10 , 10 , 10 , 10 )
	Lab.VGUI.Research.scrollpanel:Dock(FILL)
	Lab.VGUI.Research.scrollpanel:GetVBar().Paint = function() return true end
	Lab.VGUI.Research.scrollpanel:GetVBar().btnUp.Paint = function() return true end
	Lab.VGUI.Research.scrollpanel:GetVBar().btnDown.Paint = function() return true end
	Lab.VGUI.Research.scrollpanel.Paint = function(s, w, h)
	end



	// Here we create the Research items buttons
	if Lab.VGUI.Research.ResearchItems and IsValid(Lab.VGUI.Research.ResearchItems.list) then
		Lab.VGUI.Research.ResearchItems.list:Remove()
	end

	Lab.VGUI.Research.ResearchItems = {}
	Lab.VGUI.Research.ResearchItems.list = vgui.Create("DIconLayout", Lab.VGUI.Research.scrollpanel)
	Lab.VGUI.Research.ResearchItems.list:SetSize(285 , 285 )
	Lab.VGUI.Research.ResearchItems.list:SetPos(0 , 0 )
	Lab.VGUI.Research.ResearchItems.list:SetSpaceY(5)
	Lab.VGUI.Research.ResearchItems.list:SetSpaceX(5)
	Lab.VGUI.Research.ResearchItems.list:SetAutoDelete(true)
	Lab.VGUI.Research.ResearchItems.list.Paint = function(s, w, h)
	end


	for i = 1,table.Count(zbl.config.Vaccines) do
		if i < starting_id then continue end
		if i >= starting_id + 6 then continue end

		local vax_data = zbl.config.Vaccines[i]
		Lab.VGUI.Research.ResearchItems[i] = Lab.VGUI.Research.ResearchItems.list:Add("DPanel")
		Lab.VGUI.Research.ResearchItems[i]:SetSize(90, 90 )
		Lab.VGUI.Research.ResearchItems[i]:SetAutoDelete(true)
		Lab.VGUI.Research.ResearchItems[i].Paint = function(s, w, h)

			if vax_data.isvirus then
				draw.RoundedBox(12, 0 , 0, w, h,  zbl.default_colors["virus_red"])

				surface.SetDrawColor(zbl.default_colors["white01"])
				surface.SetMaterial(zbl.default_materials["zbl_virus_icon"])
				surface.DrawTexturedRect(20, 0, 50, 50)
			else
				draw.RoundedBox(12, 0 , 0, w, h,  zbl.default_colors["abillity_yellow"])

				surface.SetDrawColor(zbl.default_colors["white01"])
				surface.SetMaterial(zbl.default_materials["zbl_abillity_icon"])
				surface.DrawTexturedRect(20, 0, 50, 50)
			end

			DrawTextCentered_LineBreak(w,h,vax_data.name)
		end

		Lab.VGUI.Research.ResearchItems[i].RButton = vgui.Create("DButton", Lab.VGUI.Research.ResearchItems[i])
		Lab.VGUI.Research.ResearchItems[i].RButton:SetSize(90, 90 )
		Lab.VGUI.Research.ResearchItems[i].RButton:SetPos(0, 0)
		Lab.VGUI.Research.ResearchItems[i].RButton:SetAutoDelete(true)
		Lab.VGUI.Research.ResearchItems[i].RButton:SetText("")
		Lab.VGUI.Research.ResearchItems[i].RButton.Paint = function(s, w, h)
			if i == Lab.VaccineID then
				surface.SetDrawColor(zbl.default_colors["white01"])
				surface.SetMaterial(zbl.default_materials["zbl_ex_square"])
				surface.DrawTexturedRect(0, 0, w, h)
			end

			if s.Hovered then
				draw.RoundedBox(12, 0, 0, w, h, zbl.default_colors["white02"])
			end
		end
		Lab.VGUI.Research.ResearchItems[i].RButton.DoClick = function()
			Lab:EmitSound("zbl_ui_click")
			zbl.f.Lab_VaccineInfo(Lab,i)
		end
	end

	zbl.f.Lab_VaccineInfo(Lab,starting_id)
end

function zbl.f.Lab_VaccineInfo(Lab,vaccineID)

	zbl.f.Debug("Lab_VaccineInfo")
	if IsValid(Lab) and IsValid(Lab.VGUI.Research.VaccineInfo) then
		Lab.VGUI.Research.VaccineInfo:Remove()
	end

	Lab.VGUI.Research.VaccineInfo = vgui.Create("DPanel",Lab.VGUI.Research.MainPanel)
	Lab.VGUI.Research.VaccineInfo:SetPos(360, 60)
	Lab.VGUI.Research.VaccineInfo:SetSize(280, 320)
	Lab.VGUI.Research.VaccineInfo.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h * 0.35, zbl.default_colors["lab_blue_light"])
	end

	if vaccineID == nil then return end

	local vaccine_data = zbl.config.Vaccines[vaccineID]

	local vaccine_name = vgui.Create("DLabel", Lab.VGUI.Research.VaccineInfo)
	vaccine_name:SetSize(290, 35)
	vaccine_name:SetPos(5, 0)
	vaccine_name:SetAutoDelete(true)
	vaccine_name:SetFont("zbl_lab_top_title")
	vaccine_name:SetText(vaccine_data.name)
	if vaccine_data.isvirus then
		vaccine_name:SetTextColor(zbl.default_colors["virus_red"])
	else
		vaccine_name:SetTextColor(zbl.default_colors["abillity_yellow"])
	end
	vaccine_name:SetContentAlignment(7)
	vaccine_name:SetWrap(true)
	Lab.VGUI.Research.VaccineInfo_NamePanel = vaccine_name


	local desc = vaccine_data.desc
	if Lab.SelectedIsCure then
		desc = zbl.language.General["Cure_desc"]
		desc = string.Replace(desc,"$VaccineName",vaccine_data.name)
		desc = string.Replace(desc,"$ImmunityTime",zbl.f.FormatTime(vaccine_data.cure.immunity_time))
	end
	local vaccine_desc = vgui.Create("DLabel", Lab.VGUI.Research.VaccineInfo)
	vaccine_desc:SetSize(270, 50)
	vaccine_desc:SetPos(5, 40)
	vaccine_desc:SetAutoDelete(true)
	vaccine_desc:SetFont("zbl_lab_create_category")
	vaccine_desc:SetText(desc)
	vaccine_desc:SetContentAlignment(7)
	vaccine_desc:SetWrap(true)
	Lab.VGUI.Research.VaccineInfo_DescPanel = vaccine_desc

	Lab.VaccineID = vaccineID

	zbl.f.Lab_CreateVaccinePanel(Lab,false)
end

function zbl.f.Lab_CreateVaccinePanel(Lab,iscure)
	zbl.f.Debug("Lab_CreateVaccinePanel")

	Lab.SelectedIsCure = iscure

	local vaccine_data = zbl.config.Vaccines[Lab.VaccineID]

	if Lab.SelectedIsCure then
		Lab.ItemColor = zbl.default_colors["cure_green"]
	else
		if vaccine_data.isvirus then
			Lab.ItemColor = zbl.default_colors["virus_red"]
		else
			Lab.ItemColor = zbl.default_colors["abillity_yellow"]
		end
	end

	// Update Vaccine Name Color
	if IsValid(Lab.VGUI.Research.VaccineInfo_NamePanel) then
		Lab.VGUI.Research.VaccineInfo_NamePanel:SetTextColor(Lab.ItemColor)
	end

	// Update the Vaccine Desc if its a Cure or not
	if IsValid(Lab.VGUI.Research.VaccineInfo_DescPanel) then
		local desc = vaccine_data.desc
		if Lab.SelectedIsCure then
			desc = zbl.language.General["Cure_desc"]
			desc = string.Replace(desc,"$VaccineName",vaccine_data.name)
			desc = string.Replace(desc,"$ImmunityTime",zbl.f.FormatTime(vaccine_data.cure.immunity_time))
		end
		Lab.VGUI.Research.VaccineInfo_DescPanel:SetText(desc)
	end

	if IsValid(Lab) and IsValid(Lab.VGUI.Research.VaccineInfoPanel) then
		Lab.VGUI.Research.VaccineInfoPanel:Remove()
	end

	Lab.VGUI.Research.VaccineInfoPanel = vgui.Create("DPanel",Lab.VGUI.Research.VaccineInfo)
	Lab.VGUI.Research.VaccineInfoPanel:SetPos(0, 125)
	Lab.VGUI.Research.VaccineInfoPanel:SetSize(280, 175)
	Lab.VGUI.Research.VaccineInfoPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0 , 40, w, h-40,  zbl.default_colors["lab_blue_light"])
		draw.RoundedBox(0, 0, 30, w, 10, Lab.ItemColor)
	end

	local button_vac = vgui.Create("DButton", Lab.VGUI.Research.VaccineInfoPanel)
	button_vac:SetPos(0,0)
	button_vac:SetSize(30 , 30 )
	button_vac:SetAutoDelete(true)
	button_vac:SetText("")
	button_vac.Paint = function(s, w, h)
		if vaccine_data.isvirus then
			draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["virus_red"])

			surface.SetDrawColor(zbl.default_colors["white01"])
			surface.SetMaterial(zbl.default_materials["zbl_virus_icon"])
			surface.DrawTexturedRect(0, 0, w, h)
		else
			draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["abillity_yellow"])

			surface.SetDrawColor(zbl.default_colors["white01"])
			surface.SetMaterial(zbl.default_materials["zbl_abillity_icon"])
			surface.DrawTexturedRect(0, 0, w, h)
		end



		if s.Hovered then
			draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	button_vac.DoClick = function()
		zbl.f.Lab_CreateVaccinePanel(Lab,false)
		Lab:EmitSound("zbl_ui_click")
	end
	Lab.VGUI.Research.SelectVaccineCreation = button_vac


	local button_cure = vgui.Create("DButton", Lab.VGUI.Research.VaccineInfoPanel)
	button_cure:SetPos(30,0)
	button_cure:SetSize(30 , 30 )
	button_cure:SetAutoDelete(true)
	button_cure:SetText("")
	button_cure.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["cure_green"])

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_cure_icon"])
		surface.DrawTexturedRect(0, 0, w, h)

		if s.Hovered then
			draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	button_cure.DoClick = function()
		zbl.f.Lab_CreateVaccinePanel(Lab,true)
		Lab:EmitSound("zbl_ui_click")
	end
	Lab.VGUI.Research.SelectCureCreation = button_cure

	local res_time
	local res_points

	if Lab.SelectedIsCure then
		res_time = vaccine_data.research["cure_time"]
		res_points = vaccine_data.research["cure_points"]
	else
		res_time = vaccine_data.research["vaccine_time"]
		res_points = vaccine_data.research["vaccine_points"]
	end


	local t_mod = zbl.config.GenLab.time_modify[zbl.f.GetPlayerRank(LocalPlayer())]
	if t_mod == nil then
		t_mod = zbl.config.GenLab.time_modify["default"]
	end
	res_time = res_time * t_mod

	local vaccine_time = vgui.Create("DPanel", Lab.VGUI.Research.VaccineInfoPanel)
	vaccine_time:SetSize(110, 50)
	vaccine_time:SetPos(15, 65)
	vaccine_time:SetAutoDelete(true)
	vaccine_time.Paint = function(s, w, h)
		draw.DrawText(zbl.f.FormatTime(res_time), "zbl_lab_top_title", 35 , -3 , zbl.default_colors["abillity_yellow"], TEXT_ALIGN_LEFT)

		surface.SetDrawColor(zbl.default_colors["abillity_yellow"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_time"])
		surface.DrawTexturedRect(0, 0, 25,25)
	end
	Lab.VGUI.Research.VaccineInfo_TimePanel = vaccine_time

	local vaccine_points = vgui.Create("DPanel", Lab.VGUI.Research.VaccineInfoPanel)
	vaccine_points:SetSize(100, 50)
	vaccine_points:SetPos(15, 120)
	vaccine_points:SetAutoDelete(true)
	vaccine_points.Paint = function(s, w, h)
		draw.DrawText(res_points, "zbl_lab_top_title", 35 , -3 , zbl.default_colors["sample_blue"], TEXT_ALIGN_LEFT)

		surface.SetDrawColor(zbl.default_colors["sample_blue"])
		surface.SetMaterial(zbl.default_materials["zbl_dna_icon"])
		surface.DrawTexturedRect(-12, -10, 50,50)
	end
	Lab.VGUI.Research.VaccineInfo_PointPanel = vaccine_points

	Lab.VGUI.Research.CreateButton = vgui.Create("DButton", Lab.VGUI.Research.VaccineInfoPanel)
	Lab.VGUI.Research.CreateButton:SetPos(170,135)
	Lab.VGUI.Research.CreateButton:SetSize(100 , 30 )
	Lab.VGUI.Research.CreateButton:SetAutoDelete(true)
	Lab.VGUI.Research.CreateButton:SetText("")
	Lab.VGUI.Research.CreateButton.Paint = function(s, w, h)
		surface.SetDrawColor(Lab.ItemColor)
		surface.SetMaterial(zbl.default_materials["zbl_ex_square_wide"])
		surface.DrawTexturedRect(0, 0, w, h)

		draw.DrawText(zbl.language.General["Create"], "zbl_lab_create_bold", w / 2 , 5 , Lab.ItemColor, TEXT_ALIGN_CENTER)

		if s.Hovered then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	Lab.VGUI.Research.CreateButton.DoClick = function()
		if Lab.SelectedIsCure then
			zbl.f.Lab_CreateCure(Lab)
		else
			zbl.f.Lab_CreateVaccine(Lab)
		end
		Lab:EmitSound("zbl_ui_click")
	end
end

function zbl.f.Lab_CreateVaccine(Lab)
	zbl.f.Debug("Lab_CreateVaccine")
	local vaccine_data = zbl.config.Vaccines[Lab.VaccineID]

	if vaccine_data == nil then return end

	if table.Count(vaccine_data.research["ranks"]) > 0 and vaccine_data.research["ranks"][zbl.f.GetPlayerRank(LocalPlayer())] == nil then
		local txt_tbl = {}

		for k, v in pairs(vaccine_data.research["ranks"]) do
			table.insert(txt_tbl, k)
		end

		surface.PlaySound("common/warning.wav")
		notification.AddLegacy(zbl.language.General["Ranks"] .. ": " .. table.concat(txt_tbl, ", ", 1, #txt_tbl), NOTIFY_ERROR, 3)
		notification.AddLegacy(zbl.language.General["WrongRank"], NOTIFY_ERROR, 3)

		return
	end

	if Lab:GetDNAPoints() < vaccine_data.research["vaccine_points"] then
		surface.PlaySound("common/warning.wav")
		notification.AddLegacy(zbl.language.General["NotEnoughDNA"], NOTIFY_ERROR, 3)

		return
	end

	net.Start("zbl_Lab_CreateVaccine")
	net.WriteEntity(Lab)
	net.WriteInt(Lab.VaccineID, 16)
	net.SendToServer()
end

function zbl.f.Lab_CreateCure(Lab)
	zbl.f.Debug("Lab_CreateCure")
	local vaccine_data = zbl.config.Vaccines[Lab.VaccineID]

	if vaccine_data == nil then return end

	if table.Count(vaccine_data.research["ranks"]) > 0 and vaccine_data.research["ranks"][zbl.f.GetPlayerRank(LocalPlayer())] == nil then
		local txt_tbl = {}

		for k, v in pairs(vaccine_data.research["ranks"]) do
			table.insert(txt_tbl, k)
		end

		surface.PlaySound("common/warning.wav")
		notification.AddLegacy(zbl.language.General["Ranks"] .. ": " .. table.concat(txt_tbl, ", ", 1, #txt_tbl), NOTIFY_ERROR, 3)
		notification.AddLegacy(zbl.language.General["WrongRank"], NOTIFY_ERROR, 3)

		return
	end

	if Lab:GetDNAPoints() < vaccine_data.research["cure_points"] then
		surface.PlaySound("common/warning.wav")
		notification.AddLegacy(zbl.language.General["NotEnoughDNA"], NOTIFY_ERROR, 3)

		return
	end

	net.Start("zbl_Lab_CreateCure")
	net.WriteEntity(Lab)
	net.WriteInt(Lab.VaccineID, 16)
	net.SendToServer()
end
////////////////////////////////////////////
////////////////////////////////////////////
