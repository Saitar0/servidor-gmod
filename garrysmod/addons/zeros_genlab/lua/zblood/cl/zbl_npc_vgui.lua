if not CLIENT then return end

zbl = zbl or {}
zbl.f = zbl.f or {}
zbl.vgui = zbl.vgui or {}

zbl.vgui.actions = zbl.vgui.actions or {}

zbl.vgui.NPCInterface = zbl.vgui.NPCInterface or {}
zbl.vgui.Main = zbl.vgui.Main or {}
zbl.vgui.Sell = zbl.vgui.Sell or {}
zbl.vgui.Quest = zbl.vgui.Quest or {}

local wMod = ScrW() / 1920
local hMod = ScrH() / 1080



/////// GENERAL //////////////////
// This gets called when we open the npc interface
net.Receive("zbl_NPC_OpenMenu", function(len)
	zbl.f.Debug("zbl_NPC_OpenMenu len: " .. len)

	local dataLength = net.ReadUInt(16)
	local boardDecompressed = util.Decompress(net.ReadData(dataLength))
	local flaskdata = util.JSONToTable(boardDecompressed)

	LocalPlayer().zbl_Flasks = flaskdata
	LocalPlayer().zbl_NPC = net.ReadEntity()
	LocalPlayer().zbl_SelectedFlask = nil
	LocalPlayer().zbl_QuestID = net.ReadInt(16)
	LocalPlayer().zbl_Quest_Start = net.ReadInt(16)
	//LocalPlayer().zbl_Quest_Completed = net.ReadBool()

	zbl.f.Debug("Quest_ID: " .. LocalPlayer().zbl_QuestID)
	zbl.f.Debug("Quest_Start: " .. LocalPlayer().zbl_Quest_Start)
	//zbl.f.Debug("Quest_Completed: " .. tostring(LocalPlayer().zbl_Quest_Completed))

	zbl.vgui.actions.OpenUI()
end)

net.Receive("zbl_NPC_CloseMenu", function(len)
	zbl.vgui.actions.CloseUI()
end)

// Gets called once the quest failed to update the interface
net.Receive("zbl_OnQuestFailed", function(len)
	zbl.f.Debug("zbl_OnQuestFailed len: " .. len)

	if IsValid(zbl_NPC_Interface) then

		zbl.f.Debug("Quest Vars reset!")
		LocalPlayer().zbl_QuestID = -1
		LocalPlayer().zbl_Quest_Start = -1
		LocalPlayer().zbl_Quest_Completed = false

		timer.Simple(0,function()
			zbl.vgui.SellInterface()
			zbl.vgui.QuestInterface()

			zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestFailed"],3)
		end)
	end
end)

// Gets called once the player completed the quest
net.Receive("zbl_OnQuestCompleted", function(len)
	zbl.f.Debug("zbl_OnQuestCompleted len: " .. len)

	local dataLength = net.ReadUInt(16)
	local boardDecompressed = util.Decompress(net.ReadData(dataLength))
	local flaskdata = util.JSONToTable(boardDecompressed)

	LocalPlayer().zbl_Flasks = flaskdata

	if IsValid(zbl_NPC_Interface) then

		zbl.f.Debug("Quest Vars reset!")
		LocalPlayer().zbl_QuestID = -1
		LocalPlayer().zbl_Quest_Start = -1
		LocalPlayer().zbl_Quest_Completed = true

		timer.Simple(0,function()
			zbl.vgui.SellInterface()
			zbl.vgui.QuestInterface()
		end)
	end
end)


net.Receive("zbl_NPC_NotFinishYet", function(len)
	zbl.f.Debug("zbl_NPC_NotFinishYet len: " .. len)

	if IsValid(zbl_NPC_Interface) then

		LocalPlayer():EmitSound("zbl_error")
		zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestNotFinished"],3)
	end
end)


// Quick function to draw blur
local function DrawBlur(p, a, d)
	local x, y = p:LocalToScreen(0, 0)
	surface.SetDrawColor(zbl.default_colors["white01"])
	surface.SetMaterial(zbl.default_materials["blur"])

	for i = 1, d do
		zbl.default_materials["blur"]:SetFloat("$blur", (i / d) * a)
		zbl.default_materials["blur"]:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
	end
end


////// INIT //////////////////
function zbl.vgui.NPCInterface:Init()
	self:SetSize(900 * wMod, 670 * hMod)
	self:Center()
	self:MakePopup()
	self:SetDraggable(true)
	self:SetSizable(false)
	self:ShowCloseButton(false)
	self:SetTitle("")

	local title = vgui.Create("DPanel", self)
	title:SetPos(20 * wMod, 20 * hMod)
	title:SetSize(410 * wMod, 40 * hMod)
	title.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["grey_light"])
		draw.DrawText(zbl.config.NPC.name, "zbl_vgui_npc_title", 10 * wMod, 5 * hMod, zbl.default_colors["virus_red"], TEXT_ALIGN_LEFT)
	end
	zbl.vgui.Main.title = title

	local button_close = vgui.Create("DButton", self)
	button_close:SetPos(840 * wMod, 20 * hMod)
	button_close:SetSize(40 * wMod, 40 * hMod)
	button_close:SetText("")
	button_close.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["virus_red"])

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_close"])
		surface.DrawTexturedRect(5 * wMod, 5 * hMod, 30 * wMod, 30 * hMod)

		if s:IsHovered() then
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
		end
	end
	button_close.DoClick = function()
		zbl.vgui.actions.CloseUI()
	end
	zbl.vgui.Main.close = button_close


	timer.Simple(0,function()
		zbl.vgui.SellInterface()
		zbl.vgui.QuestInterface()
	end)
end
function zbl.vgui.NPCInterface:Paint(w,h)
	draw.RoundedBox( 5, 0, 0, w, h, zbl.default_colors["grey_dark"] )
end


function zbl.vgui.QuestInterface()

	if IsValid(zbl.vgui.Quest.MainPanel) then
		zbl.vgui.Quest.MainPanel:Remove()
	end

	local MainPanel = vgui.Create("DPanel", zbl_NPC_Interface)
	MainPanel:SetPos(20 * wMod, 70 * hMod)
	MainPanel:SetSize(410 * wMod, 580 * hMod)
	MainPanel.Paint = function(s, w, h)
	end
	zbl.vgui.Quest.MainPanel = MainPanel

	local ModelPanel = vgui.Create("Panel", MainPanel)
	ModelPanel:SetPos(0 * wMod, 0 * hMod)
	ModelPanel:SetSize(410 * wMod, 350 * hMod)
	ModelPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["grey_light"])

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_npc_bg"])
		surface.DrawTexturedRect(0,0,w,h)

	end
	zbl.vgui.Quest.ModelPanel = ModelPanel

	local DModelPanel = vgui.Create("DModelPanel", ModelPanel)
	DModelPanel:SetSize(ModelPanel:GetWide(), ModelPanel:GetTall())
	DModelPanel:SetPos(0 * wMod, 0 * hMod)
	DModelPanel:SetModel("models/zerochain/props_bloodlab/zbl_hazmat_npc.mdl")
	DModelPanel:SetAutoDelete(true)
	DModelPanel:SetColor(zbl.config.NPC.SkinColor)
	DModelPanel.GotHurt = false
	DModelPanel.ResetAnim = false
	DModelPanel.LayoutEntity = function(s)

		s.Entity:SetAngles(Angle(0, 45, 0))
		local size1, size2 = s.Entity:GetRenderBounds(0, 0)
		local size = (-size1 + size2):Length()
		s:SetFOV(12)
		s:SetCamPos(Vector(size * 1, size * 1, size * 1))
		s:SetLookAt((size1 + size2) / 2 + Vector(0, 0, size * 0.25))

		// Animation
		if s.GotHurt == true then
			if s.ResetAnim == true then
				s.Entity:SetCycle(0)
				s.ResetAnim = false
			end

			s.Entity:ResetSequence(s.Entity:LookupSequence("photo_react_blind"))
			s.Entity:SetPlaybackRate(2)
		else
			s.Entity:ResetSequence(s.Entity:LookupSequence("lineidle03"))
			s.Entity:SetPlaybackRate(1)
		end

		if s.Entity:GetCycle() >= 1 then
			s.Entity:SetCycle(0)

			if DModelPanel.GotHurt == true then
				DModelPanel.GotHurt = false
			end
		end

		s:RunAnimation()
	end
	DModelPanel.DoClick = function()
		LocalPlayer():EmitSound("zbl_npc_staph")
		DModelPanel.GotHurt = true
		DModelPanel.ResetAnim = true
		zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_FacePunch"],1)
	end
	zbl.vgui.Quest.DModel = DModelPanel

	// The Speech Bubble
	local SpeechPanel = vgui.Create("Panel", DModelPanel)
	SpeechPanel:SetPos(0 * wMod, 270 * hMod)
	SpeechPanel:SetSize(410 * wMod, 50 * hMod)
	SpeechPanel.SpeechText = "nil"
	SpeechPanel.SpeechFont = "zbl_vgui_npc_speechbubble"
	SpeechPanel.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["black02"])
		draw.DrawText(s.SpeechText, s.SpeechFont, 205 * wMod, 11 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)
	end
	zbl.vgui.Quest.SpeechBubble = SpeechPanel

	// Does the npc give us another quest?
	if LocalPlayer().zbl_QuestID ~= -1 then

		// Is the Quest currently in progress?
		if LocalPlayer().zbl_Quest_Start ~= -1 then
			zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestUpdate"],1)
		else
			zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestProposal"],0)
		end

		zbl.vgui.CreateJobInfo()
	else
		if LocalPlayer().zbl_Quest_Completed == true then
			zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestCompleted"],3)
			LocalPlayer():EmitSound("zbl_succees")
			zbl.vgui.CreateQuestCompleted()
			LocalPlayer().zbl_Quest_Completed = false
		else
			zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_Greeting"],2)
			zbl.vgui.CreateJobInfo()
		end
	end
end
function zbl.vgui.CreateJobInfo()

	if IsValid(zbl.vgui.Quest.JobInfoPanel) then
		zbl.vgui.Quest.JobInfoPanel:Remove()
	end

	if LocalPlayer().zbl_QuestID <= 0 then

		zbl.vgui.CreateNoQuest()
		return
	end


	local quest_config = zbl.config.NPC.quests[LocalPlayer().zbl_QuestID]
	local quest_data = zbl.Quests[quest_config.q_type]

	local InfoPanel = vgui.Create("Panel", zbl.vgui.Quest.MainPanel)
	InfoPanel:SetPos(0 * wMod, 370 * hMod)
	InfoPanel:SetSize(410 * wMod, 210 * hMod)
	InfoPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, 100 * hMod, zbl.default_colors["grey_light"])

		surface.SetDrawColor(zbl.default_colors["white03"])
		surface.SetMaterial(quest_data.icon)
		surface.DrawTexturedRect(310 * wMod, 0 * hMod, 100 * wMod, 100 * hMod)
	end
	zbl.vgui.Quest.JobInfoPanel = InfoPanel




	local jobname = vgui.Create("DLabel", InfoPanel)
	jobname:SetPos(10 * wMod, 5 * hMod)
	jobname:SetSize(400 * wMod, 60 * hMod)
	jobname:SetText(quest_config.name)
	jobname:SetFont("zbl_vgui_npc_button")
	jobname:SetContentAlignment(7)
	jobname:SetTextColor(quest_data.color)
	zbl.vgui.Quest.JobName = jobname

	/*
	local desc = quest_data.desc
	if quest_config.count then
		desc = string.Replace(desc,"$count",quest_config.count)
	end

	if quest_config.virus_id then
		desc = string.Replace(desc,"$virusname",zbl.config.Vaccines[quest_config.virus_id].name)
	elseif quest_config.sample_class then
		desc = string.Replace(desc,"$entityname",quest_config.sample_class)
	end
	*/



	local jobdesc = vgui.Create("DLabel", InfoPanel)
	jobdesc:SetPos(10 * wMod, 35 * hMod)
	jobdesc:SetSize(330 * wMod, 150 * hMod)
	jobdesc:SetText(quest_config.desc)
	jobdesc:SetWrap(true)
	jobdesc:SetFont("zbl_vgui_npc_job_desc")
	jobdesc:SetContentAlignment(7)
	jobdesc:SetTextColor(zbl.default_colors["white01"])
	zbl.vgui.Quest.JobDesc = jobdesc



	if LocalPlayer().zbl_Quest_Start == -1 then

		local accept_job = vgui.Create("DButton", InfoPanel)
		accept_job:SetPos(213 * wMod, 175 * hMod)
		accept_job:SetSize(197 * wMod, 35 * hMod)
		accept_job:SetText("")
		accept_job.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["cure_green"])

			draw.DrawText(zbl.language.NPC["Quest_Accept"], "zbl_vgui_npc_button", 98.5 * wMod, 2 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

			if s:IsHovered() then
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
			end
		end
		accept_job.DoClick = function()
			zbl.vgui.actions.AcceptQuest()
		end
		zbl.vgui.Quest.RequestJob = accept_job

		local decline_job = vgui.Create("DButton", InfoPanel)
		decline_job:SetPos(0 * wMod, 175 * hMod)
		decline_job:SetSize(197 * wMod, 35 * hMod)
		decline_job:SetText("")
		decline_job.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["virus_red"])

			draw.DrawText(zbl.language.NPC["Quest_Decline"], "zbl_vgui_npc_button", 98.5 * wMod, 2 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

			if s:IsHovered() then
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
			end
		end
		decline_job.DoClick = function()
			zbl.vgui.actions.DeclineQuest()
		end
		zbl.vgui.Quest.DeclineJob = decline_job
	else

		local cancel_job = vgui.Create("DButton", InfoPanel)
		cancel_job:SetPos(0 * wMod, 175 * hMod)
		cancel_job:SetSize(197 * wMod, 35 * hMod)
		cancel_job:SetText("")
		cancel_job.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["virus_red"])

			draw.DrawText(zbl.language.NPC["Quest_Cancel"], "zbl_vgui_npc_button", 98.5 * wMod, 2 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

			if s:IsHovered() then
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
			end
		end
		cancel_job.DoClick = function()

			zbl.vgui.actions.CancelQuest()
		end
		zbl.vgui.Quest.CancelJob = cancel_job



		local finish_job = vgui.Create("DButton", InfoPanel)
		finish_job:SetPos(213 * wMod, 175 * hMod)
		finish_job:SetSize(197 * wMod, 35 * hMod)
		finish_job:SetText("")
		finish_job.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["cure_green"])

			draw.DrawText(zbl.language.NPC["Quest_Finish"], "zbl_vgui_npc_button", 98.5 * wMod, 2 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

			if s:IsHovered() then
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
			end
		end
		finish_job.DoClick = function()
			zbl.vgui.actions.FinishQuest()
		end
		zbl.vgui.Quest.FinishJob = finish_job

	end


	local InfoPanel01 = vgui.Create("Panel", InfoPanel)
	InfoPanel01:SetPos(0 * wMod, 115 * hMod)
	InfoPanel01:SetSize(410 * wMod, 45 * hMod)
	InfoPanel01.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, 197 * wMod, h, zbl.default_colors["grey_light"])
		draw.RoundedBox(5, 213 * wMod, 0, 197 * wMod, h, zbl.default_colors["grey_light"])
		//draw.RoundedBox(0, 0, 0, w, h, zbl.default_colors["white02"])

		if quest_config.dna_reward then
			surface.SetDrawColor(zbl.default_colors["sample_blue"])
			surface.SetMaterial(zbl.default_materials["zbl_dna_icon"])
			surface.DrawTexturedRect(325 * wMod, 5 * hMod, 30,30)
		end
	end

	local jobtime = vgui.Create("DButton", InfoPanel01)
	jobtime:SetPos(0 * wMod, 0 * hMod)
	jobtime:SetSize(197 * wMod, InfoPanel01:GetTall())
	jobtime:SetText(zbl.f.FormatTime(quest_config.time))
	jobtime:SetFont("zbl_vgui_npc_job_reward")
	jobtime:SetContentAlignment(5)
	jobtime:SetTextColor(zbl.default_colors["abillity_yellow"])
	jobtime:SetTooltip(zbl.language.NPC["Quest_ToolTip_Time"])
	jobtime.Think = function(s)
		if LocalPlayer().zbl_Quest_Start ~= -1 and quest_config.time then

			local countdown = math.Clamp((LocalPlayer().zbl_Quest_Start + quest_config.time) - CurTime(),0,99999999999)
			countdown = zbl.f.FormatTime(countdown)

			s:SetText(countdown)
		end
	end
	jobtime.Paint = function(s, w, h) end
	zbl.vgui.Quest.JobTime = jobtime

	if quest_config.dna_reward then
		local reward = quest_config.money_reward
		reward = zbl.f.CurrencyPos(reward, zbl.config.Currency)
		local jobreward = vgui.Create("DButton", InfoPanel01)
		jobreward:SetPos(230 * wMod, 0 * hMod)
		jobreward:SetSize(105 * wMod, InfoPanel01:GetTall())
		jobreward:SetText("+" .. reward)
		jobreward:SetFont("zbl_vgui_npc_job_reward")
		jobreward:SetContentAlignment(4)
		jobreward:SetTextColor(zbl.default_colors["cure_green"])
		jobreward:SetTooltip(zbl.language.NPC["Quest_ToolTip_Reward"])
		jobreward.Paint = function(s, w, h) end
		zbl.vgui.Quest.JobMoney = jobreward

		local jobreward_dna = vgui.Create("DButton", InfoPanel01)
		jobreward_dna:SetPos(290 * wMod, 0 * hMod)
		jobreward_dna:SetSize(105 * wMod, InfoPanel01:GetTall())
		jobreward_dna:SetText("+" .. quest_config.dna_reward)
		jobreward_dna:SetFont("zbl_vgui_npc_job_reward")
		jobreward_dna:SetContentAlignment(6)
		jobreward_dna:SetTextColor(zbl.default_colors["sample_blue"])
		jobreward_dna:SetTooltip(zbl.language.NPC["Quest_ToolTip_Reward"])
		jobreward_dna.Paint = function(s, w, h) end
		zbl.vgui.Quest.JobDNA = jobreward_dna
	else
		local reward = quest_config.money_reward
		reward = zbl.f.CurrencyPos(reward, zbl.config.Currency)
		local jobreward = vgui.Create("DButton", InfoPanel01)
		jobreward:SetPos(213 * wMod, 0 * hMod)
		jobreward:SetSize(197 * wMod, InfoPanel01:GetTall())
		jobreward:SetText("+" .. reward)
		jobreward:SetFont("zbl_vgui_npc_job_reward")
		jobreward:SetContentAlignment(5)
		jobreward:SetTextColor(zbl.default_colors["cure_green"])
		jobreward:SetTooltip(zbl.language.NPC["Quest_ToolTip_Reward"])
		jobreward.Paint = function(s, w, h) end
		zbl.vgui.Quest.JobMoney = jobreward
	end
end
function zbl.vgui.CreateQuestCompleted()
	if not IsValid(zbl.vgui.Quest.MainPanel) then return end

	if IsValid(zbl.vgui.Quest.JobInfoPanel) then
		zbl.vgui.Quest.JobInfoPanel:Remove()
	end


	local InfoPanel = vgui.Create("Panel", zbl.vgui.Quest.MainPanel)
	InfoPanel:SetPos(0 * wMod, 370 * hMod)
	InfoPanel:SetSize(410 * wMod, 210 * hMod)
	InfoPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, 100 * hMod, zbl.default_colors["grey_light"])
	end
	zbl.vgui.Quest.JobInfoPanel = InfoPanel

	local info = vgui.Create("DLabel", zbl.vgui.Quest.JobInfoPanel)
	info:SetPos(0 * wMod, 0 * hMod)
	info:SetSize(410 * wMod, 100 * hMod)
	info:SetText("[ " .. zbl.language.NPC["Quest_Completed"] .. " ]")
	info:SetFont("zbl_vgui_npc_info")
	info:SetContentAlignment(5)
	info:SetTextColor(zbl.default_colors["grey05"])
	zbl.vgui.Quest.QuestCompleteInfo = info
end

function zbl.vgui.CreateNoQuest()
	if not IsValid(zbl.vgui.Quest.MainPanel) then return end

	if IsValid(zbl.vgui.Quest.JobInfoPanel) then
		zbl.vgui.Quest.JobInfoPanel:Remove()
	end


	local InfoPanel = vgui.Create("Panel", zbl.vgui.Quest.MainPanel)
	InfoPanel:SetPos(0 * wMod, 370 * hMod)
	InfoPanel:SetSize(410 * wMod, 210 * hMod)
	InfoPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, 100 * hMod, zbl.default_colors["grey_light"])
	end
	zbl.vgui.Quest.JobInfoPanel = InfoPanel

	local info = vgui.Create("DLabel", zbl.vgui.Quest.JobInfoPanel)
	info:SetPos(0 * wMod, 0 * hMod)
	info:SetSize(410 * wMod, 100 * hMod)
	info:SetText("[ " .. zbl.language.NPC["Quest_NotAvailable"] .. " ]")
	info:SetFont("zbl_vgui_npc_info")
	info:SetContentAlignment(5)
	info:SetTextColor(zbl.default_colors["grey05"])
	zbl.vgui.Quest.QuestCompleteInfo = info
end


function zbl.vgui.SellInterface()

	if IsValid(zbl.vgui.Sell.MainPanel) then
		zbl.vgui.Sell.MainPanel:Remove()
	end

	local MainPanel = vgui.Create("DPanel", zbl_NPC_Interface)
	MainPanel:SetPos(450 * wMod, 70 * hMod)
	MainPanel:SetSize(430 * wMod, 580 * hMod)
	MainPanel.Paint = function(s, w, h) end
	zbl.vgui.Sell.MainPanel = MainPanel

	local ModelPanel = vgui.Create("Panel", MainPanel)
	ModelPanel:SetPos(0 * wMod, 0 * hMod)
	ModelPanel:SetSize(430 * wMod, 350 * hMod)
	ModelPanel.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["grey_light"])
	end
	zbl.vgui.Sell.ModelPanel = ModelPanel

	local DModelPanel = vgui.Create("DModelPanel", ModelPanel)
	DModelPanel:SetSize(430 * wMod, 350 * hMod)
	DModelPanel:SetPos(0 * wMod, 0 * hMod)
	DModelPanel:SetModel("models/zerochain/props_bloodlab/zbl_injector.mdl")
	DModelPanel:SetAutoDelete(true)
	DModelPanel:SetMouseInputEnabled( false )
	DModelPanel:SetColor(zbl.default_colors["white05"])
	DModelPanel.Mat = "models/wireframe"
	DModelPanel.LayoutEntity = function(s)
		s.Entity:SetMaterial(s.Mat)
		s.Entity:SetAngles(Angle(0, 45 * CurTime(), 0))
		s:SetFOV(20)
		s:SetCamPos(Vector(50,0,0))
		s:SetLookAt(Vector(0,0,1.5))
	end
	zbl.vgui.Sell.DModel = DModelPanel

	local BlurPanel = vgui.Create("Panel", ModelPanel)
	BlurPanel:SetPos(10 * wMod, 10 * hMod)
	BlurPanel:SetSize(410 * wMod, 330 * hMod)
	BlurPanel.Paint = function(s, w, h)
		DrawBlur( s, 1,3 )
	end
	zbl.vgui.Sell.BlurPanel = BlurPanel


	// Create chamber buttons which display the vaccines the player has in his gun currently
	zbl.vgui.Sell.FlaskButtons = {}
	local flask_count = #LocalPlayer().zbl_Flasks
	for i = 1, flask_count do

		local radius = math.Clamp((140 / 12) * flask_count, 120 , 140)

		local start_x, start_y = 215, 175
		local x, y = 0, 0
		local a = math.rad((i / flask_count) * 360)

		x = start_x + math.sin(a + 0.5) * radius
		y = start_y + math.cos(a + 0.5) * radius

		local b_size = 128 - (64 / 12) * flask_count
		local b_off = b_size / 2

		local flask_data = LocalPlayer().zbl_Flasks[i]
		local vaccine_data
		local isvirus

		if flask_data.gt == 2 then
			vaccine_data = zbl.config.Vaccines[flask_data.gv]
			isvirus = vaccine_data.isvirus
		end

		local flask_button = vgui.Create("DButton", ModelPanel)
		flask_button:SetPos((x - b_off) * wMod, (y - b_off) * hMod)
		flask_button:SetSize(b_size * wMod, b_size * hMod)
		flask_button:SetText("")

		if flask_data.gt ~= 0 then
			if flask_data.gt == 1 then
				// Sample
				flask_button:SetTooltip(zbl.language.General["Sample"] .. " - " .. flask_data.gn)
			elseif flask_data.gt == 2 then
				// Virus
				if isvirus then
					flask_button:SetTooltip(zbl.language.General["Virus"] .. " - " .. flask_data.gn)
				else
					flask_button:SetTooltip(zbl.language.General["Abillity"] .. " - " .. flask_data.gn)
				end
			elseif flask_data.gt == 3 then
				// Cure
				flask_button:SetTooltip(zbl.language.General["Cure"] .. " - " .. flask_data.gn)
			end
		end
		flask_button.Paint = function(s, w, h)

			//BG
			surface.SetDrawColor(zbl.default_colors["black03"])
			surface.SetMaterial(zbl.default_materials["zbl_hexagon_icon"])
			surface.DrawTexturedRect(0, 0, w, h)

			local icon
			local color

			if flask_data.gt == 1 then


				// Sample
				color = zbl.default_colors["sample_blue"]
				icon = zbl.default_materials["zbl_dna_icon"]
			elseif flask_data.gt == 2 then

				// Vaccine
				// Is it virus?
				if isvirus then

					color = zbl.default_colors["virus_red"]
					icon = zbl.default_materials["zbl_virus_icon"]
				else
					// Abillity
					color = zbl.default_colors["abillity_yellow"]
					icon = zbl.default_materials["zbl_abillity_icon"]
				end
			elseif flask_data.gt == 3 then

				// Cure
				color = zbl.default_colors["cure_green"]
				icon = zbl.default_materials["zbl_cure_icon"]
			end

			if icon and color then

				if i == LocalPlayer().zbl_SelectedFlask then
					surface.SetDrawColor(zbl.default_colors["black04"])
					surface.SetMaterial(zbl.default_materials["zbl_hexagon_icon"])
					surface.DrawTexturedRect(0,0,w,h)

					surface.SetDrawColor(zbl.default_colors["white01"])
					surface.SetMaterial(icon)
					surface.DrawTexturedRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76)

					surface.SetDrawColor(zbl.default_colors["white01"])
					surface.SetMaterial(zbl.default_materials["zbl_hexagon_outline"])
					surface.DrawTexturedRect(0,0,w,h)


				else
					surface.SetDrawColor(color)
					surface.SetMaterial(zbl.default_materials["zbl_hexagon_icon"])
					surface.DrawTexturedRect(0,0,w,h)

					surface.SetDrawColor(zbl.default_colors["black02"])
					surface.SetMaterial(icon)
					surface.DrawTexturedRect(w * 0.12, h * 0.12, w * 0.76, h * 0.76)
				end
			end

			if flask_data.gt ~= 0 and s:IsHovered() then

				surface.SetDrawColor(zbl.default_colors["white01"])
				surface.SetMaterial(zbl.default_materials["zbl_hexagon_outline"])
				surface.DrawTexturedRect(0,0,w,h)
			end
		end
		flask_button.DoClick = function()
			zbl.vgui.actions.SelectFlask(i)
		end
		zbl.vgui.Sell.FlaskButtons[i] = flask_button
	end

	zbl.vgui.CreateFlaskInfo()
end
function zbl.vgui.CreateFlaskInfo()

	if IsValid(zbl.vgui.Sell.FlaskInfoPanel) then
		zbl.vgui.Sell.FlaskInfoPanel:Remove()
	end

	local InfoPanel = vgui.Create("Panel", zbl.vgui.Sell.MainPanel)
	InfoPanel:SetPos(0 * wMod, 370 * hMod)
	InfoPanel:SetSize(430 * wMod, 210 * hMod)
	InfoPanel.Paint = function(s, w, h)
		//draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["cure_green"])
		draw.RoundedBox(5, 0, 0, w,  160 * hMod, zbl.default_colors["grey_light"])
	end
	zbl.vgui.Sell.FlaskInfoPanel = InfoPanel


	if LocalPlayer().zbl_SelectedFlask == nil then return end
	local flask_data = LocalPlayer().zbl_Flasks[LocalPlayer().zbl_SelectedFlask]

	if flask_data == nil then return end

	if flask_data.gt == 0 then return end

	// Here we generate the name and desc according to the gen type
	local gen_name
	local gen_desc
	local gen_color
	if flask_data.gt == 1 then
		// Can this sample value be found in the vaccine config?
		// If yes then this means it is a virus sample which can only be found in virusnodes
		local vaccine_data = zbl.config.Vaccines[flask_data.gv]
		if vaccine_data then
			gen_name = flask_data.gn
			gen_desc = zbl.language.NPC["SampleInfo_Virus"]
		else
			gen_name = flask_data.gn
			gen_desc = string.Replace(zbl.language.NPC["SampleInfo_Other"], "$Name", flask_data.gn)
		end

		gen_color = zbl.default_colors["sample_blue"]
	elseif flask_data.gt == 2 then
		local vaccine_data = zbl.config.Vaccines[flask_data.gv]

		if vaccine_data.isvirus then
			gen_name = flask_data.gn
			gen_desc = vaccine_data.desc
			gen_color = zbl.default_colors["virus_red"]
		else
			gen_name =  flask_data.gn
			gen_desc = vaccine_data.desc
			gen_color = zbl.default_colors["abillity_yellow"]
		end
	elseif flask_data.gt == 3 then
		local vaccine_data = zbl.config.Vaccines[flask_data.gv]
		gen_name = flask_data.gn

		gen_desc = zbl.language.General["Cure_desc"]
		gen_desc = string.Replace(gen_desc,"$VaccineName",gen_name)
		gen_desc = string.Replace(gen_desc,"$ImmunityTime",zbl.f.FormatTime(vaccine_data.cure.immunity_time))

		gen_color = zbl.default_colors["cure_green"]
	end

	local CanSell = flask_data.gt == 2 or flask_data.gt == 3


	local flask_name = vgui.Create("DLabel", InfoPanel)
	flask_name:SetPos(10 * wMod, 5 * hMod)
	flask_name:SetSize(410 * wMod, 60 * hMod)
	flask_name:SetText(gen_name)
	flask_name:SetFont("zbl_vgui_npc_button")
	flask_name:SetContentAlignment(7)
	flask_name:SetTextColor(gen_color)
	zbl.vgui.Sell.FlaskName = flask_name

	if CanSell then


		local InfoPanel01 = vgui.Create("Panel", InfoPanel)
		InfoPanel01:SetPos(0 * wMod, 175 * hMod)
		InfoPanel01:SetSize(215 * wMod, 36 * hMod)
		InfoPanel01.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["grey_light"])
		end

		local vaccine_data = zbl.config.Vaccines[flask_data.gv]

		local reward = vaccine_data.price
		reward = zbl.f.CurrencyPos(reward, zbl.config.Currency)

		local flask_price = vgui.Create("DLabel", InfoPanel01)
		flask_price:SetPos(0 * wMod, 0 * hMod)
		flask_price:SetSize(215 * wMod, 40 * hMod)
		flask_price:SetText("+" .. reward)
		flask_price:SetFont("zbl_vgui_npc_job_reward")
		flask_price:SetContentAlignment(5)
		flask_price:SetTextColor(zbl.default_colors["cure_green"])
		zbl.vgui.Sell.FlaskPrice = flask_price

		local sell_button = vgui.Create("DButton", InfoPanel)
		sell_button:SetPos(230 * wMod, 175 * hMod)
		sell_button:SetSize(200 * wMod, 36 * hMod)
		sell_button:SetText("")
		sell_button.Paint = function(s, w, h)
			draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["cure_green"])

			draw.DrawText(zbl.language.NPC["Sell"], "zbl_vgui_npc_button", 100 * wMod, 2 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER)

			if s:IsHovered() then
				draw.RoundedBox(5, 0, 0, w, h, zbl.default_colors["white02"])
			end
		end
		sell_button.DoClick = function()
			zbl.vgui.actions.SellFlask()
		end
		zbl.vgui.Sell.SellButton = sell_button
	elseif flask_data.gt == 1 then
		local sample_info = vgui.Create("DLabel", InfoPanel)
		sample_info:SetPos(10 * wMod, 100 * hMod)
		sample_info:SetSize(410 * wMod, 50 * hMod)
		sample_info:SetText("[ " .. zbl.language.NPC["DNA_SellInfo"] .. " ]")
		sample_info:SetFont("zbl_vgui_npc_info")
		sample_info:SetContentAlignment(5)
		sample_info:SetTextColor(zbl.default_colors["grey05"])
		zbl.vgui.Sell.SampleInfo = sample_info
	end

	local flask_desc = vgui.Create("DLabel", InfoPanel)
	flask_desc:SetPos(10 * wMod, 35 * hMod)
	flask_desc:SetSize(410 * wMod, 150 * hMod)
	flask_desc:SetText(gen_desc)
	flask_desc:SetWrap(true)
	flask_desc:SetFont("zbl_vgui_npc_job_desc")
	flask_desc:SetContentAlignment(7)
	flask_desc:SetTextColor(zbl.default_colors["white01"])
	zbl.vgui.Sell.FlaskDesc = flask_desc
end


////// Actions //////////////////
function zbl.vgui.actions.OpenUI()
	zbl.f.Debug("zbl.vgui.actions.OpenUI")

	if IsValid(zbl_NPC_Interface) then
		zbl_NPC_Interface:Remove()
	end

	zbl_NPC_Interface = vgui.Create("zbl.vgui.NPCInterface")
end

function zbl.vgui.actions.CloseUI()
	zbl.f.Debug("zbl.vgui.actions.CloseUI")

	LocalPlayer().zbl_NPC = nil

	if IsValid(zbl_NPC_Interface) then
		zbl_NPC_Interface:Remove()
	end
end

function zbl.vgui.actions.SpeechBubble(text,fadeout_time)
	zbl.f.Debug("zbl.vgui.actions.SpeechBubble: " .. text)

	zbl.vgui.Quest.SpeechBubble:AlphaTo( 255, 0, 0)
	zbl.vgui.Quest.SpeechBubble.SpeechText = text
	zbl.vgui.Quest.SpeechBubble.SpeechFont = zbl.f.GetFontFromTextSize(text,50,"zbl_vgui_npc_speechbubble","zbl_vgui_npc_speechbubble_small")


	if fadeout_time > 0 then
		zbl.vgui.Quest.SpeechBubble:AlphaTo( 0, 1, fadeout_time)
	end
end


function zbl.vgui.actions.SelectFlask(id)
	zbl.f.Debug("zbl.vgui.actions.SelectFlask: " .. id)
	local flask_data = LocalPlayer().zbl_Flasks[id]

	if flask_data.gt ~= 2 and flask_data.gt ~= 3 and flask_data.gt ~= 1 then return end
	LocalPlayer().zbl_SelectedFlask = id
	LocalPlayer():EmitSound("zbl_ui_click")

	zbl.vgui.CreateFlaskInfo()
end

function zbl.vgui.actions.SellFlask()
	zbl.f.Debug("zbl.vgui.actions.SellFlask")

	LocalPlayer():EmitSound("zbl_ui_click")

	local flask_data = LocalPlayer().zbl_Flasks[LocalPlayer().zbl_SelectedFlask]
	if flask_data.gt ~= 2 and flask_data.gt ~= 3 then
		surface.PlaySound("common/warning.wav")
		notification.AddLegacy(zbl.language.NPC["DNA_SellNotify"], NOTIFY_ERROR, 3)
		return
	end

	net.Start("zbl_NPC_Sell")
	net.WriteEntity(LocalPlayer().zbl_NPC)
	net.WriteInt(LocalPlayer().zbl_SelectedFlask, 16)
	net.SendToServer()

	// Reset the data from this flask as if it was sold
	LocalPlayer().zbl_Flasks[LocalPlayer().zbl_SelectedFlask] = {
		gt = 0,
		gv = 0,
		gn = "",
	}

	LocalPlayer().zbl_SelectedFlask = -1

	if IsValid(zbl.vgui.Sell.FlaskInfoPanel) then
		zbl.vgui.Sell.FlaskInfoPanel:Remove()
	end

	// Rebuild the sell interface
	zbl.vgui.SellInterface()
end


function zbl.vgui.actions.AcceptQuest()
	zbl.f.Debug("zbl.vgui.actions.AcceptQuest")

	LocalPlayer():EmitSound("zbl_ui_click")

	local quest_config = zbl.config.NPC.quests[LocalPlayer().zbl_QuestID]
	if quest_config == nil then return end

	// If the player doesent have enough space in his gun then we dont allow him to take this quest
	if #LocalPlayer().zbl_Flasks < quest_config.count then
		zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Quest_FlaskCapacity"],2)
		return
	end

	LocalPlayer().zbl_Quest_Start = CurTime()
	zbl.vgui.Quest.DeclineJob:Remove()
	zbl.vgui.Quest.RequestJob:Remove()

	timer.Simple(1,function()
		if IsValid(zbl_NPC_Interface) and zbl and zbl.vgui and zbl.vgui.Quest then
			zbl.vgui.CreateJobInfo()
		end
	end)


	zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestAccept"],2)

	net.Start("zbl_NPC_AcceptQuest")
	net.WriteEntity(LocalPlayer().zbl_NPC)
	net.SendToServer()
end

function zbl.vgui.actions.DeclineQuest()
	zbl.f.Debug("zbl.vgui.actions.DeclineQuest")

	LocalPlayer():EmitSound("zbl_ui_click")

	zbl.vgui.Quest.RequestJob:Remove()
	zbl.vgui.Quest.DeclineJob:Remove()
	LocalPlayer().zbl_QuestID = -1

	zbl.vgui.CreateJobInfo()

	zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestDecline"],2)
	net.Start("zbl_NPC_DeclineQuest")
	net.WriteEntity(LocalPlayer().zbl_NPC)
	net.SendToServer()
end

function zbl.vgui.actions.CancelQuest()
	zbl.f.Debug("zbl.vgui.actions.CancelQuest")

	LocalPlayer():EmitSound("zbl_ui_click")

	zbl.vgui.Quest.CancelJob:Remove()
	LocalPlayer().zbl_QuestID = -1

	zbl.vgui.CreateJobInfo()

	zbl.vgui.actions.SpeechBubble(zbl.language.NPC["Dialog_QuestDecline"],2)

	net.Start("zbl_NPC_CancelQuest")
	net.WriteEntity(LocalPlayer().zbl_NPC)
	net.SendToServer()
end

function zbl.vgui.actions.FinishQuest()
	zbl.f.Debug("zbl.vgui.actions.FinishQuest")

	LocalPlayer():EmitSound("zbl_ui_click")

	zbl.vgui.Quest.CancelJob:SetVisible(false)
	zbl.vgui.Quest.FinishJob:SetVisible(false)

	timer.Simple(1,function()
		if IsValid(zbl_NPC_Interface) and zbl and zbl.vgui and zbl.vgui.Quest then
			if IsValid(zbl.vgui.Quest.CancelJob) then
				zbl.vgui.Quest.CancelJob:SetVisible(true)
			end
			if IsValid(zbl.vgui.Quest.FinishJob) then
				zbl.vgui.Quest.FinishJob:SetVisible(true)
			end
		end
	end)

	net.Start("zbl_NPC_FinishQuest")
	net.WriteEntity(LocalPlayer().zbl_NPC)
	net.SendToServer()
end


vgui.Register("zbl.vgui.NPCInterface", zbl.vgui.NPCInterface, "DFrame")
