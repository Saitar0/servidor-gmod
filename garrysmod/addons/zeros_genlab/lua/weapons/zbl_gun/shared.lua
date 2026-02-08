SWEP.PrintName = "Injector"
SWEP.Author = "Zero"
SWEP.Instructions = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.AdminSpawnable = false
SWEP.Spawnable = true

SWEP.AutomaticFrameAdvance = true
SWEP.ViewModelFOV = 75
SWEP.ViewModel = "models/zerochain/props_bloodlab/zbl_v_injector01.mdl"
SWEP.WorldModel = "models/zerochain/props_bloodlab/zbl_w_injector01.mdl"
SWEP.UseHands = true

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = true
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.HoldType = "pistol"
SWEP.FiresUnderwater = false
SWEP.Weight = 5
SWEP.DrawCrosshair = true
SWEP.Category = "Zeros GenLab"
SWEP.DrawAmmo = false
SWEP.base = "weapon_base"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Recoil = 1
SWEP.Primary.Delay = 0.25

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Recoil = 1
SWEP.Secondary.Delay = 0.25

SWEP.DisableDuplicator = true

if CLIENT then
	SWEP.WepSelectIcon = surface.GetTextureID("zerochain/zblood/vgui/zbl_gun")
	SWEP.BounceWeaponIcon = false
end


function SWEP:SetupDataTables()

	// What type of GenType are we having inside the gun
	/*
		0 = Empty
		1 = Sample
		2 = Vaccine
		3 = Cure
	*/

	self:NetworkVar("Int", 3, "SelectedFlask")
	self:NetworkVar("Bool", 0, "Busy")


	self:NetworkVar("Int", 0, "GenType")
	self:NetworkVar("Int", 1, "GenValue")
	self:NetworkVar("String", 0, "GenName")
	self:NetworkVar("Int", 2, "GenPoints")
	self:NetworkVar("String", 1, "GenClass")

	self:NetworkVar("String", 2, "FlaskSequence")


	/////////

	if SERVER then
		self:SetFlaskSequence("")
		self:SetSelectedFlask(1)
		self:SetBusy(false)

		self:SetGenType(0)
		self:SetGenValue(0)
		self:SetGenName("")
		self:SetGenPoints(0)
		self:SetGenClass("")
	end
end
