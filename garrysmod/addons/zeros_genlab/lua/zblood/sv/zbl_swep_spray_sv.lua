if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}


function zbl.f.Spray_GetTarget(swep)
	local tr = swep.Owner:GetEyeTrace()
	local ent = tr.Entity

	if tr.Hit == false then return end
	if not IsValid(ent) then return end

	if not ent:IsPlayer() then return end

	if zbl.f.InDistance(swep.Owner:GetPos(), ent:GetPos(), 200) == false then return end

	return ent
end

function zbl.f.Spray_Initialize(swep)
	zbl.f.Debug("zbl.f.Spray_Initialize")
	swep:SetHoldType(swep.HoldType)
	swep:SetBusy(false)

	swep.IsSpraying = false
end

function zbl.f.Spray_Primary(swep)

	if swep:GetBusy() == true then
		return false
	end

	if swep:GetSprayAmount() <= 0 then
		swep:SetBusy(false)
		swep.Owner:StripWeapon("zbl_spray")
		return false
	end

	swep.Owner:EmitSound("zbl_spray")
	zbl.f.CreateNetEffect("player_disinfect",swep.Owner)

	swep:SetSprayAmount(swep:GetSprayAmount() - zbl.config.DisinfectantSpray.UsagePerClick)

	zbl.f.Spray_PlayShootAnim(swep)

	local tr = swep.Owner:GetEyeTrace()
	if tr.Hit and zbl.f.InDistance(swep.Owner:GetPos(), tr.HitPos, 200) and IsValid(tr.Entity) then

		local ent = tr.Entity
		if ent:GetClass() == "zbl_virusnode" then
			ent:TakeDamage( zbl.config.DisinfectantSpray.VirusNode_Damage, swep.Owner, swep )
		elseif ent:GetClass() == "zbl_corpse" then
			SafeRemoveEntity(ent)
		elseif zbl.f.Ctmn_CanBeContaminated(ent) then

			if zbl.f.Ctmn_IsObjectContaminated(ent) then
				zbl.f.Ctmn_ObjectSanitise(ent)
			end

			zbl.f.Spray_ShowObjectStatus(swep,ent)

		elseif ent:IsPlayer() and ent:Alive() and zbl.f.OV_IsContaminated(ent) then
			zbl.f.Player_ForceCure(ent)
		end
	end

	swep:SetNextPrimaryFire(CurTime() + swep.Primary.Delay)
end

util.AddNetworkString("zbl_spray_scan")
function zbl.f.Spray_ShowObjectStatus(swep,ent)

	// Shows the object current contamination status
	net.Start("zbl_spray_scan")
	net.WriteEntity(ent)
	net.Send(swep.Owner)
end
function zbl.f.Spray_Secondary(swep)

	swep:SetNextSecondaryFire(CurTime() + swep.Secondary.Delay)
end

function zbl.f.Spray_Equip(swep)
	zbl.f.Debug("zbl.f.Spray_Equip")
	zbl.f.Spray_PlayDrawAnim(swep)
end

function zbl.f.Spray_Deploy(swep)
	zbl.f.Debug("zbl.f.Spray_Deploy")

	zbl.f.Timer_Remove("zbl_spray_drawanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_spray_shootanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_spray_reloadanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_spray_shootanim_end_" .. swep:EntIndex() .. "_timer")

	swep.IsSpraying = false

	zbl.f.Spray_PlayDrawAnim(swep)
end

function zbl.f.Spray_Holster(swep)
	zbl.f.Debug("zbl.f.Spray_Holster")

	zbl.f.Timer_Remove("zbl_spray_drawanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_spray_shootanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_spray_reloadanim_" .. swep:EntIndex() .. "_timer")
	zbl.f.Timer_Remove("zbl_spray_shootanim_end_" .. swep:EntIndex() .. "_timer")

	swep.IsSpraying = false

	swep:SendWeaponAnim(ACT_VM_HOLSTER)

	swep:SetBusy(false)
end



function zbl.f.Spray_PlayShootAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	if swep.IsSpraying == false then
		swep:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		//swep.Owner:SetAnimation(PLAYER_ATTACK1)
		swep.IsSpraying = true
	end

	local timerID = "zbl_spray_shootanim_" .. swep:EntIndex() .. "_timer"
	zbl.f.Timer_Remove(timerID)

	zbl.f.Timer_Create(timerID,0.1,1,function()
		zbl.f.Timer_Remove(timerID)

		if IsValid(swep) and IsValid(swep.Owner) and IsValid(swep.Owner:GetActiveWeapon()) and swep.Owner:GetActiveWeapon():GetClass() == "zbl_spray"  then

			swep:SetBusy(true)

			swep:SendWeaponAnim(ACT_VM_THROW)
			//swep.Owner:SetAnimation(PLAYER_ATTACK1)
			local timerID01 = "zbl_spray_shootanim_end_" .. swep:EntIndex() .. "_timer"
			zbl.f.Timer_Create(timerID01,0.1,1,function()
				zbl.f.Timer_Remove(timerID01)

				swep.IsSpraying = false
				zbl.f.Spray_PlayIdleAnim(swep)
			end)
		end
	end)
end

function zbl.f.Spray_PlayDrawAnim(swep)
	if not IsValid(swep) then return end // Safety first!

	swep:SetBusy(true)

	swep.Owner:SetAnimation(PLAYER_IDLE)
	swep:SendWeaponAnim(ACT_VM_DRAW) // Play draw anim

	local timerID = "zbl_spray_drawanim_" .. swep:EntIndex() .. "_timer"
	zbl.f.Timer_Remove(timerID)

	zbl.f.Timer_Create(timerID,0.5,1,function()
		zbl.f.Timer_Remove(timerID)

		if IsValid(swep) and IsValid(swep.Owner) and IsValid(swep.Owner:GetActiveWeapon()) and swep.Owner:GetActiveWeapon():GetClass() == "zbl_spray"  then

			zbl.f.Spray_PlayIdleAnim(swep)
		end
	end)
end

function zbl.f.Spray_PlayIdleAnim(swep)
	if not IsValid(swep) then return end // Safety first!
	zbl.f.Debug("zbl.f.Spray_PlayIdleAnim")
	swep:SendWeaponAnim(ACT_VM_IDLE)
	swep.Owner:SetAnimation(PLAYER_IDLE)

	swep:SetBusy(false)
end
