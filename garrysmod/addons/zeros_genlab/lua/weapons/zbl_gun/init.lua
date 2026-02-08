AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
SWEP.Weight = 5

function SWEP:Initialize()
	zbl.f.Injector_Initialize(self)
end

function SWEP:Deploy()
	zbl.f.Injector_Deploy(self)
	return true
end

function SWEP:PrimaryAttack()
	zbl.f.Injector_Primary(self)
end

function SWEP:SecondaryAttack()
	zbl.f.Injector_Secondary(self)
end

function SWEP:Equip()
	zbl.f.Injector_Equip(self)
end


function SWEP:Reload()
end


function SWEP:Holster(swep)
	zbl.f.Injector_Holster(self)

	return true
end

function SWEP:ShouldDropOnDie()
	return false
end
