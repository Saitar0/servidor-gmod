include("shared.lua")
SWEP.PrintName = "Disinfectant  Spray"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true -- Do you want the SWEP to have a crosshair?
local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastSprayAmount = -1
	self.AmountLevel = -1
end

function SWEP:SecondaryAttack()
end

function SWEP:PrimaryAttack()
end

function SWEP:Deploy()
end

function SWEP:Holster(swep)
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
	if GetConVar("zbl_cl_drawui"):GetInt() == 0 then return end
	if GetConVar("zbl_cl_spray_enabled"):GetInt() == 0 then return end
	local spray_amount = self:GetSprayAmount()

	if self.LastSprayAmount ~= spray_amount then
		self.LastSprayAmount = spray_amount
	end

	self.AmountLevel = self.AmountLevel - (10 * FrameTime())
	self.AmountLevel = math.Clamp(self.AmountLevel, self.LastSprayAmount, zbl.config.DisinfectantSpray.Amount)


	local pos_x = (1920 / 100) * GetConVar("zbl_cl_spray_pos_x"):GetInt()
	local pos_y = (1080 / 100) * GetConVar("zbl_cl_spray_pos_y"):GetInt()

	local scale = GetConVar("zbl_cl_spray_scale"):GetFloat()

	local width, height = 320 * scale, 50 * scale

	local bar_width = (width / zbl.config.DisinfectantSpray.Amount) * self.AmountLevel


	pos_x = pos_x - (width / 2)
	pos_y = pos_y - (height / 2)

	local sub_val = 10 * scale
	local brd_val = 5 * scale

	draw.RoundedBox(5, pos_x * wMod, pos_y * hMod, width * wMod, height * hMod, zbl.default_colors["disinfect_blue_dark"])
	draw.RoundedBox(5, (pos_x + brd_val) * wMod, (pos_y + brd_val) * hMod, (width - sub_val) * wMod, (height - sub_val) * hMod, zbl.default_colors["black03"])
	draw.RoundedBox(5, (pos_x + brd_val) * wMod, (pos_y + brd_val) * hMod, (bar_width - sub_val) * wMod, (height - sub_val) * hMod, zbl.default_colors["disinfect_blue_light"])
end

function SWEP:Think()
end
