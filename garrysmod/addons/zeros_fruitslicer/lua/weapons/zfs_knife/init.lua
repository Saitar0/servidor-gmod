AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("zfruitslicer/sh/zfs_config.lua")
SWEP.Weight = 5

util.AddNetworkString("zfs_knife_FX")

function SWEP:CreateEffect_Table(effect, sound, parent, angle, position)
	net.Start("zfs_knife_FX")
	local effectInfo = {}
	effectInfo.effect = effect
	effectInfo.sound = sound
	effectInfo.pos = position
	effectInfo.ang = angle
	effectInfo.parent = parent
	net.WriteTable(effectInfo)
	net.SendPVS(self:GetPos())
end

--SWEP:Initialize\\
--Tells the script what to do when the player "Initializes" the SWEP.
function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.selectedEffect = 1
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:SlicerFruit()
	local tr = self.Owner:GetEyeTrace()
	self.Owner:DoAttackEvent()
	self:SendWeaponAnim(ACT_VM_MISSCENTER)

	local rnda = -self.Primary.Recoil
	local rndb = self.Primary.Recoil * math.random(-1, 1)
	self.Owner:ViewPunch(Angle(rnda, rndb, rnda))

	if (self.Owner:GetPos():Distance(tr.HitPos) < 100) then
		for i, k in pairs(ents.FindInSphere(tr.HitPos, 30)) do
			if (IsValid(k) and zfs_ents[k:GetClass()]) then
				k:Interact(self.Owner)
				break
			end
		end
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
end

function SWEP:PrimaryAttack()
	self:SlicerFruit()
end

function SWEP:SecondaryAttack()
	self:SlicerFruit()
end

--Tells the script what to do when the player "Initializes" the SWEP.
function SWEP:Equip()
	self:SendWeaponAnim(ACT_VM_DRAW) -- View model animation
	self.Owner:SetAnimation(PLAYER_IDLE) -- 3rd Person Animation
end

function SWEP:Reload()
	if ((self.lastReload or CurTime()) > CurTime()) then return end
	self.lastReload = CurTime() + 1
end

function SWEP:ShouldDropOnDie()
	return false
end
