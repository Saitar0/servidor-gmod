AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	zbl.f.Spray_Initialize(self)
end

function SWEP:Deploy()
	zbl.f.Spray_Deploy(self)

	return true
end

function SWEP:PrimaryAttack()
	zbl.f.Spray_Primary(self)
end

function SWEP:SecondaryAttack()
	zbl.f.Spray_Secondary(self)
end

function SWEP:Equip()
	zbl.f.Spray_Equip(self)
end

function SWEP:Holster(swep)
	zbl.f.Spray_Holster(self)

	return true
end

function SWEP:ShouldDropOnDie()
	return false
end
