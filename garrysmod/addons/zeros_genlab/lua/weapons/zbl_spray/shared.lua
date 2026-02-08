SWEP.PrintName = "Disinfectant Spray"
SWEP.Author = "Zero"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.AdminSpawnable = false
SWEP.Spawnable = true
SWEP.AutomaticFrameAdvance = true
SWEP.ViewModelFOV = 60
SWEP.ViewModel = "models/zerochain/props_bloodlab/zbl_v_spray.mdl"
SWEP.WorldModel = "models/zerochain/props_bloodlab/zbl_w_spray.mdl"
SWEP.UseHands = true
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "knife"
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = true
SWEP.Category = "Zeros GenLab"
SWEP.DrawAmmo = false
SWEP.base = "weapon_base"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 0.1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 0.25
SWEP.DisableDuplicator = true

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("zerochain/zblood/vgui/zbl_spray")
	SWEP.BounceWeaponIcon = false
end

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "SprayAmount")
	self:NetworkVar("Bool", 0, "Busy")

	if SERVER then
		self:SetSprayAmount(zbl.config.DisinfectantSpray.Amount)
		self:SetBusy(false)
	end
end
