include("shared.lua")
include("zfruitslicer/sh/zfs_config.lua")

net.Receive("zfs_knife_FX", function(len, ply)
	local effectInfo = net.ReadTable()

	if (effectInfo) then
		if (effectInfo.parent == nil) then return end

		if (IsValid(effectInfo.parent)) then
			if (effectInfo.sound) then
				effectInfo.parent:EmitSound(effectInfo.sound)
			end

			if (effectInfo.effect) then
					local ang = effectInfo.ang or Angle(0, 0, 0)
					ParticleEffect(effectInfo.effect, effectInfo.pos, ang, effectInfo.parent)
			end
		end
	end
end)

SWEP.PrintName = "Knife" -- The name of your SWEP
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true -- Do you want the SWEP to have a crosshair?

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
	self.Owner:DoAttackEvent()
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
end

function SWEP:SecondaryAttack()
	self.Owner:DoAttackEvent()
	self:SendWeaponAnim(ACT_VM_MISSCENTER)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:Equip()
end
