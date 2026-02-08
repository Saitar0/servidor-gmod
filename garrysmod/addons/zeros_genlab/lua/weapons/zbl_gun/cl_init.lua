include("shared.lua")
SWEP.PrintName = "Injector"
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

function SWEP:Initialize()
	zbl.f.Injector_Initialize(self)
end

function SWEP:SecondaryAttack()
	zbl.f.Injector_Secondary(self)
end

function SWEP:PrimaryAttack()
	zbl.f.Injector_Primary(self)
end

function SWEP:Deploy()
	zbl.f.Injector_Deploy(self)
end

function SWEP:Holster(swep)
	zbl.f.Injector_Holster(self)
end

function SWEP:Reload()
end

function SWEP:DrawHUD()
	zbl.f.Injector_DrawHUD(self)
end

function SWEP:Think()
	zbl.f.Injector_Think(self)
end
