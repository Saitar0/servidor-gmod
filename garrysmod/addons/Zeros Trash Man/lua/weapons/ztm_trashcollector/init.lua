AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SWEP.Weight = 5

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)

	self.LastTrashHit = 1
	self.LastTrash = 0
	self.TrashIncrease = false
end


function SWEP:PrimaryAttack()

	if self:GetIsBusy() == false then
		self:SetIsBusy(true)
		self:DoPrimaryAnims()
	end

	self:SetNextPrimaryFire(CurTime() + ztm.config.TrashSWEP.level[self:GetPlayerLevel()].primaty_interval + 0.1)
end

function SWEP:DoPrimaryAnims()
	if not IsValid(self) then return end // Safety first!

	self:SetLast_Primary(CurTime())

	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) // Play primary anim

	local interval = ztm.config.TrashSWEP.level[self:GetPlayerLevel()].primaty_interval
	local vm_speed = math.Clamp(0.8 / interval,1.7,3)

	self.Owner:GetViewModel():SetPlaybackRate(vm_speed)

	self.Owner:SetAnimation(PLAYER_ATTACK1)

	ztm.f.SWEP_TrashCollector_Primary(self)

	local timerID = "ztm_tc_primaryanim_" .. self:EntIndex() .. "_timer"
	ztm.f.Timer_Remove(timerID)

	ztm.f.Timer_Create(timerID,interval,1,function()
		ztm.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self.Owner) then
			self:Stop_PrimaryAnims()
		end
	end)
end

function SWEP:Stop_PrimaryAnims()

	self.Owner:GetViewModel():SetPlaybackRate(1)


	if IsValid(self.Owner) and IsValid(self.Owner:GetActiveWeapon()) and  self.Owner:GetActiveWeapon():GetClass() == "ztm_trashcollector" then
		self:PlayIdleAnim()
	end
end




function SWEP:SecondaryAttack()

	if self:GetIsBusy() == false and self:GetTrash() < ztm.config.TrashSWEP.level[self:GetPlayerLevel()].inv_cap then

		self:SetIsBusy(true)
		self:DoSecondaryAnims()
	end

	self:SetNextSecondaryFire(CurTime() + ztm.config.TrashSWEP.level[self:GetPlayerLevel()].secondary_interval)
end

function SWEP:DoSecondaryAnims()
	if not IsValid(self) then return end // Safety first!

	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK) // Play primary anim
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:EmitSound("ztm_airsuck_start")

	local timerID = "ztm_tc_secondaryanim_" .. self:EntIndex() .. "_timer"
	ztm.f.Timer_Remove(timerID)

	ztm.f.Timer_Create(timerID,0.6,1,function()
		ztm.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self.Owner) then
			self:CollectTrash()
		end
	end)
end

function SWEP:CollectTrash()

	self:SetIsCollectingTrash(true)

	// This collects the trash from the pile we are looking at,
	ztm.f.SWEP_TrashCollector_Secondary(self)


	local _trash = self:GetTrash()
	if _trash > self.LastTrash then
		self.TrashIncrease = true
	else
		self.TrashIncrease = false
	end
	self.LastTrash = _trash

	if self.TrashIncrease then
		self.Owner:GetViewModel():SetBodygroup(0,1)
	else
		self.Owner:GetViewModel():SetBodygroup(0,0)
	end

	self:SetLast_Secondary(CurTime())
	self.LastTrashHit = CurTime() + ztm.config.TrashSWEP.level[self:GetPlayerLevel()].secondary_interval
end


function SWEP:Stop_SecondaryAnims()
	self.TrashIncrease = false
	self.Owner:GetViewModel():SetBodygroup(0,0)

	self.Owner:EmitSound("ztm_airsuck_stop")

	self:SetIsCollectingTrash(false)

	if IsValid(self.Owner) and IsValid(self.Owner:GetActiveWeapon()) and  self.Owner:GetActiveWeapon():GetClass() == "ztm_trashcollector" then
		self:PlayIdleAnim()
	end

	self:SetIsBusy(false)

	self.LastTrashHit = CurTime() + 0.5
end


function SWEP:Think()

	if self:GetIsCollectingTrash() == true and self.LastTrashHit < CurTime() then

		if self:GetTrash() < ztm.config.TrashSWEP.level[self:GetPlayerLevel()].inv_cap and IsValid(self.Owner) and self.Owner:KeyDown(IN_ATTACK2) then

			self:CollectTrash()
		else
			self:Stop_SecondaryAnims()
		end
	end
end






function SWEP:Deploy()
	// Initializes the Level Data if it doesent exist allready
	ztm.data.Init(self.Owner)

	self:SetPlayerLevel(self.Owner.ztm_data.lvl)
	self:SetPlayerXP(self.Owner.ztm_data.xp)
	self.Owner:SetAnimation(PLAYER_IDLE)

	self:PlayDrawAnim()

	return true
end

function SWEP:PlayDrawAnim()
	if not IsValid(self) then return end // Safety first!

	self:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "ztm_tc_drawanim_" .. self:EntIndex() .. "_timer"
	ztm.f.Timer_Remove(timerID)

	ztm.f.Timer_Create(timerID,0.64,1,function()
		ztm.f.Timer_Remove(timerID)

		if IsValid(self) and IsValid(self.Owner) then
			self:PlayIdleAnim()
		end
	end)
end

function SWEP:PlayIdleAnim()
	if not IsValid(self) then return end // Safety first!
	self:SendWeaponAnim(ACT_VM_IDLE) // Player idle anim
	self.Owner:SetAnimation(PLAYER_IDLE)

	self:SetIsBusy(false)
end

function SWEP:Holster(swep)

	self:SendWeaponAnim(ACT_VM_HOLSTER)


	if IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetBodygroup(0,0)
	end


	self:SetIsCollectingTrash(false)
	self:SetIsBusy(false)

	ztm.f.Timer_Remove("ztm_tc_drawanim_" .. self:EntIndex() .. "_timer")
	ztm.f.Timer_Remove("ztm_tc_secondaryanim_" .. self:EntIndex() .. "_timer")
	ztm.f.Timer_Remove("ztm_tc_primaryanim_" .. self:EntIndex() .. "_timer")

	return true
end


function SWEP:OnRemove()
	if IsValid(self.Owner) and IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():SetBodygroup(0,0)
	end
end


function SWEP:ShouldDropOnDie()
	return false
end
