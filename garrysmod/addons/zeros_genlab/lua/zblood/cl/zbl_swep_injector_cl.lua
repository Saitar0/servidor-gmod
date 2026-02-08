if SERVER then return end
zbl = zbl or {}
zbl.f = zbl.f or {}


function zbl.f.Injector_Initialize(swep)
	zbl.f.Debug("zbl.f.Injector_Initialize")

	swep:SetHoldType(swep.HoldType)
end

function zbl.f.Injector_Primary(swep)
end

function zbl.f.Injector_Secondary(swep)
end

function zbl.f.Injector_Equip(swep)
end

function zbl.f.Injector_Deploy(swep)
end

function zbl.f.Injector_Holster(swep)
end

function zbl.f.Injector_Think(swep)
end

local Show_Help = false
local TEX_SIZE = 512
local RTTexture = GetRenderTarget( "zbl_injector_screen_rt", TEX_SIZE, TEX_SIZE )
local matScreen = Material( "zerochain/props_bloodlab/injector/zbl_injector_screen" )

local mat_paths = {
	["Virus"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_virus"),
	["Sample"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_sample"),
	["Cure"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_cure"),
	["Abillity"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_abillity"),
	["Help"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_help"),
	["Hexagon"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_hexagon"),
	["Hexagon_Outline"] = surface.GetTextureID("zerochain/zblood/swep_icons/zbl_icon_hexagon_outline"),
}


local function DrawTitle(text,col)
	local font =  zbl.f.GetFontFromTextSize(text,15,"zbl_gun_font01","zbl_gun_font01_small")
	draw.RoundedBox(1, 0, 0, TEX_SIZE, TEX_SIZE / 7, zbl.default_colors["black04"])
	draw.SimpleText(text, font, TEX_SIZE / 2, 32, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function DrawBackground(_type, color)
	draw.RoundedBox(1, 0, 0, TEX_SIZE, TEX_SIZE, color)

	if _type then
		local size = 150
		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetTexture(mat_paths[_type])
		surface.DrawTexturedRect(TEX_SIZE / 2 - size / 2, 70, size, size)
	end
end

local function DrawFlaskIcon(swep,color, pos,count)

	local x,y = 117,375

	x = x + (55 * pos)

	if pos > 6 then
		y = y + 55
		x = x - (55 * 6)
	end

	x = x - 55

	surface.SetDrawColor(color)
	surface.SetTexture(mat_paths["Hexagon"])
	surface.DrawTexturedRect( -25 + x, -25 + y, 50, 50)

	if pos == count then
		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetTexture(mat_paths["Hexagon_Outline"])
		surface.DrawTexturedRect( -25 + x, -25 + y, 50, 50)
	end
end

local function DrawFlaskCount(swep)
	local sequence = swep:GetFlaskSequence()
	local count = swep:GetSelectedFlask()
	sequence = string.Split(sequence,"_" )

	if sequence and #sequence > 0 then
		for k,v in pairs(sequence) do
			local val = tonumber(v)

			if val > 100 then
				// Ability
				DrawFlaskIcon(swep,zbl.default_colors["abillity_yellow"], k,count)
			else
				if val == 0 then
					// Empty
					DrawFlaskIcon(swep,zbl.default_colors["grey01"], k,count)
				elseif val == 1 then
					//Sample
					DrawFlaskIcon(swep,zbl.default_colors["sample_blue"], k,count)
				elseif val == 2 then
					//Virus
					DrawFlaskIcon(swep,zbl.default_colors["virus_red"], k,count)
				elseif val == 3 then
					// Cure
					DrawFlaskIcon(swep,zbl.default_colors["cure_green"], k,count)
				end
			end
		end
	end
end

// A quick fix for a line return
local function DrawGenName(str,len)
	local name = str
	local _start, _end = string.find(name, " ", 1, false)

	if string.len(name) > len and _start then
		draw.SimpleText(string.sub(name, 1, _start - 1), "zbl_gun_name", TEX_SIZE / 2, 240, zbl.default_colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(string.sub(name, _start + 1, string.len(name)), "zbl_gun_name", TEX_SIZE / 2, 280, zbl.default_colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(name, "zbl_gun_name", TEX_SIZE / 2, 240, zbl.default_colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

local function DrawHelp(txt,key,_y)
	local font =  zbl.f.GetFontFromTextSize(txt,12,"zbl_gun_font04","zbl_gun_font04_small")

	draw.RoundedBox(1, 0, _y + 25, TEX_SIZE, TEX_SIZE / 10, zbl.default_colors["black03"])
	draw.SimpleText(txt, font, 100, 52 + _y, zbl.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("[ " .. string.upper(language.GetPhrase(input.GetKeyName(key))) .. " ]", "zbl_gun_font02", TEX_SIZE - 100, 52 + _y, zbl.default_colors["white01"], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

function zbl.f.Injector_DrawMain(swep)

	local _type = swep:GetGenType()
	local _value = swep:GetGenValue()

	if _type == 1 then
		DrawBackground("Sample", zbl.default_colors["sample_blue"])

		draw.SimpleText(swep:GetGenName() or "Patient", zbl.f.GetFontFromTextSize(swep:GetGenName(),18,"zbl_gun_name","zbl_gun_name_small"),TEX_SIZE / 2, 240, zbl.default_colors["black04"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("+" .. swep:GetGenPoints(), "zbl_gun_dna", TEX_SIZE / 2, 295, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetTexture(mat_paths["Sample"])
		surface.DrawTexturedRect(170, 270, 60,60)

		DrawTitle(zbl.language.General["DNASample"], zbl.default_colors["sample_blue"])
	elseif _type == 2 then

		if zbl.config.Vaccines[_value].isvirus then
			DrawBackground("Virus", zbl.default_colors["virus_red"])
			DrawTitle(zbl.language.General["Virus"],zbl.default_colors["virus_red"])
		else
			DrawBackground("Abillity", zbl.default_colors["abillity_yellow"])
			DrawTitle(zbl.language.General["Abillity"],zbl.default_colors["abillity_yellow"])
		end
		DrawGenName(zbl.config.Vaccines[_value].name,15)
	elseif _type == 3 then

		DrawBackground("Cure", zbl.default_colors["cure_green"])
		DrawTitle(zbl.language.General["Cure"],zbl.default_colors["cure_green"])
		DrawGenName(zbl.config.Vaccines[_value].name,15)
	else
		DrawBackground(nil, zbl.default_colors["grey01"])
		DrawTitle(zbl.language.Gun["Empty"],zbl.default_colors["grey01"])
	end

	draw.RoundedBox(1, 0, TEX_SIZE - 175, TEX_SIZE,175, zbl.default_colors["black04"])
	draw.SimpleText("[ " .. string.upper(language.GetPhrase(input.GetKeyName(zbl.config.InjectorGun.Keys.Help))) .. " ] " .. zbl.language.Gun["Help"], "zbl_gun_font04", TEX_SIZE / 2, 480, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	//draw.SimpleText("[ " .. string.upper(language.GetPhrase(input.GetKeyName(zbl.config.InjectorGun.Keys.Help))) .. " ]", "zbl_gun_font04", 225, 480, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	DrawFlaskCount(swep)
end

function zbl.f.Injector_DrawHelp(swep)
	draw.RoundedBox(1, 0, 0, TEX_SIZE, TEX_SIZE, zbl.default_colors["grey01"])


	surface.SetDrawColor(zbl.default_colors["white06"])
	surface.SetTexture(mat_paths["Help"])
	surface.DrawTexturedRect(TEX_SIZE * 0.1, TEX_SIZE * 0.125, TEX_SIZE * 0.8, TEX_SIZE * 0.8)

	DrawTitle(zbl.language.Gun["Help"],zbl.default_colors["grey01"])

	DrawHelp(zbl.language.Gun["Inject"] .. ":", MOUSE_LEFT, 75)
	DrawHelp(zbl.language.Gun["Collect"] .. ":", MOUSE_RIGHT, 135)
	DrawHelp(zbl.language.Gun["Drop"] .. ":", zbl.config.InjectorGun.Keys.ExtractFlask, 195)
	DrawHelp(zbl.language.Gun["Self Inject"] .. ":", zbl.config.InjectorGun.Keys.SelfInject, 255)
	DrawHelp(zbl.language.Gun["Delete"] .. ":", zbl.config.InjectorGun.Keys.EmptyFlask, 315)
	DrawHelp(zbl.language.Gun["Switch"] .. ":", zbl.config.InjectorGun.Keys.SwitchFlask, 375)
	DrawHelp(zbl.language.Gun["Scan"] .. ":", zbl.config.InjectorGun.Keys.ScanArea, 435)
end

function zbl.f.Injector_DrawScreen(swep)

	// Set the material of the screen to our render target
	matScreen:SetTexture( "$basetexture", RTTexture )

	// Set up our view for drawing to the texture
	render.PushRenderTarget( RTTexture )
		cam.Start2D()

			if Show_Help then
				zbl.f.Injector_DrawHelp(swep)
			else
				zbl.f.Injector_DrawMain(swep)
			end

		cam.End2D()
	render.PopRenderTarget()
end

function zbl.f.Injector_DrawHUD(swep)

	zbl.f.Injector_DrawScreen(swep)
end

hook.Add("PlayerButtonDown", "zbl_PlayerButtonDown_Injector", function(ply, key)
	if IsValid(ply) then

		local swep = ply:GetActiveWeapon()

		if IsValid(swep) and swep:GetClass() == "zbl_gun" and key == zbl.config.InjectorGun.Keys.Help and (ply.zbl_LastKey == nil or ply.zbl_LastKey < CurTime()) then
			ply.zbl_LastKey = CurTime() + 0.2

			ply:EmitSound("zbl_ui_click")

			// Toggle Help menu
			Show_Help = not Show_Help
		end
	end
end)



// SCAN FUNCTION
local scanmat = Material("zerochain/zblood/scan_mat")
local ObjectList = ObjectList or {}

net.Receive("zbl_scan_pulse", function(len)
	zbl.f.Debug("zbl_scan_pulse Len: " .. len)

	local pos = net.ReadVector()

	if pos then

		zbl.f.ParticleEffect("zbl_scan", pos, Angle(0,0,0), Entity(1))


		for a, w in pairs(ents.FindInSphere(pos, zbl.config.InjectorGun.Scan.radius)) do
			if IsValid(w) /*and w ~= LocalPlayer()*/ and ((w:IsPlayer() and w:Alive()) or zbl.config.Contamination.ents[w:GetClass()] or w:GetClass() == "zbl_virusnode" or w:GetClass() == "zbl_corpse") and LocalPlayer():IsLineOfSightClear( w ) then
				ObjectList[w:EntIndex()] = {
					ent = w,
					time = CurTime() + zbl.config.InjectorGun.Scan.duration
				}
			end
		end
	end
end)

// Called from the spray entity to show the object status
net.Receive("zbl_spray_scan", function(len)
	zbl.f.Debug("zbl_spray_scan Len: " .. len)

	local _ent = net.ReadEntity()

	if IsValid(_ent) and zbl.config.Contamination.ents[_ent:GetClass()] then

		ObjectList[_ent:EntIndex()] = {
			ent = _ent,
			time = CurTime() + 1,
			hide_info = true,
			got_sprayed = true
		}
	end
end)


local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

local function DrawVaccineInfo(target)
	local vac_id = target:GetNWInt("zbl_Vaccine", -1)
	local vac_stage = target:GetNWInt("zbl_VaccineStage", 1)
	local pos = target:LocalToWorld(target:OBBCenter())

	//if zbl.f.InDistance(pos, LocalPlayer():GetPos(), 500) == false then return end

	pos = pos:ToScreen()

	local _type = 0
	/*
		0 = Clean
		1 = Virus
		2 = Abillity
	*/
	local _name = ""
	local _info = zbl.language.General["Clean"]
	local _icon = zbl.default_materials["zbl_icon_clean"]
	local _color = zbl.default_colors["white01"]
	if vac_id ~= -1 then
		local _vacdata = zbl.config.Vaccines[vac_id]

		if _vacdata.isvirus then
			_type = 1
			_icon = zbl.default_materials["zbl_virus_icon"]
			_color = zbl.default_colors["virus_red"]
		else
			_type = 2
			_icon = zbl.default_materials["zbl_abillity_icon"]
			_color = zbl.default_colors["abillity_yellow"]
		end

		_name = _vacdata.name
		_info = zbl.language.Gun["Stage"] .. ": " .. vac_stage
	else
		_type = 0
		_info = zbl.language.General["Clean"]
	end

	cam.Start2D()

		surface.SetDrawColor(zbl.default_colors["white01"])
		surface.SetMaterial(zbl.default_materials["zbl_icon_scan"])
		surface.DrawTexturedRect(pos.x - 20 * wMod, pos.y - 40 * hMod, 80 * wMod, 80 * hMod)

		surface.SetDrawColor(_color)
		surface.SetMaterial(_icon)
		surface.DrawTexturedRect(pos.x - 20 * wMod, pos.y - 20 * hMod, 40 * wMod, 40 * hMod)


		if target:GetClass() == "zbl_corpse" then
			draw.SimpleText(target:GetPlayerName(), "zbl_gun_scan01", pos.x + 22 * wMod, pos.y -35 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		if _name == "" then
			draw.SimpleText(_info, "zbl_gun_scan01", pos.x + 22 * wMod, pos.y + 10 * hMod, zbl.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		else

			draw.SimpleText(_info, "zbl_gun_scan01", pos.x + 22 * wMod, pos.y + 10 * hMod , zbl.default_colors["white01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(_name, "zbl_gun_scan01", pos.x + 22 * wMod, pos.y - 13 * hMod, _color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	cam.End2D()
end

function zbl.f.Scanner_DrawScannedObjects()

	if ObjectList == nil then return end

	for a, w in pairs(ObjectList) do
		if IsValid(w.ent) and w.time > CurTime() then

			render.MaterialOverride(scanmat)

			local newColor
			if w.got_sprayed then

				newColor = zbl.default_colors["clean_blue"]

			elseif w.ent:GetClass() == "zbl_virusnode" then

				newColor = zbl.default_colors["virus_red"]

			elseif w.ent:GetClass() == "zbl_corpse" then

				newColor = zbl.default_colors["virus_red"]

			else

				local vacID = w.ent:GetNWInt("zbl_Vaccine", -1)

				if vacID == -1 then

					newColor = zbl.default_colors["white04"]
				else
					local vacData = zbl.config.Vaccines[vacID]
					if vacData.isvirus then

						newColor = zbl.default_colors["virus_red"]
					else

						newColor = zbl.default_colors["abillity_yellow"]
					end
				end
			end

			// Decrease brightness according to time
			local t = math.Clamp(w.time - CurTime(),0,zbl.config.InjectorGun.Scan.duration)
			if t < 2 then
				t = (1 / 2) * t
				newColor = Color(newColor.r * t, newColor.g * t, newColor.b * t)
			end

			// Convert to normalized decimal
			newColor = zbl.f.ColorToVector(newColor)

			// Set color modulation
			render.SetColorModulation(newColor.x, newColor.y, newColor.z)

			w.ent:DrawModel()

			render.MaterialOverride()
			render.ModelMaterialOverride()
			render.SetColorModulation(1, 1, 1)

			if zbl.config.InjectorGun.Scan.show_info and w.hide_info == nil then
				DrawVaccineInfo(w.ent)
			end

		else
			ObjectList[a] = nil
		end
	end
end

hook.Add("PostDrawTranslucentRenderables", "zbl_Injector_Scan", function(depth, skybox)
	if skybox then return end
	if depth then return end
	zbl.f.Scanner_DrawScannedObjects()
end)
