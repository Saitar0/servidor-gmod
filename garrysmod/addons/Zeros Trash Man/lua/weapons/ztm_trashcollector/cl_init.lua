include("shared.lua")

SWEP.PrintName = "Trash Collector" // The name of your SWEP
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true // Do you want the SWEP to have a crosshair?

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self.LastEffect = 1

	self.TrashIncrease = false
	self.LastTrash = 0
end

function SWEP:SecondaryAttack()

	//self:SetNextSecondaryFire(CurTime() + 0.3)
end


function SWEP:LoopedSound(soundfile, shouldplay,pitch)

	if shouldplay then
		if self.Sounds == nil then
			self.Sounds = {}
		end

		if self.Sounds[soundfile] == nil then
			self.Sounds[soundfile] = CreateSound(self, soundfile)
		end

		if self.Sounds[soundfile]:IsPlaying() == false then
			self.Sounds[soundfile]:Play()
			self.Sounds[soundfile]:ChangeVolume(0.4, 0)
			self.Sounds[soundfile]:ChangePitch(pitch,0)
		end
	else
		if self.Sounds == nil then
			self.Sounds = {}
		end

		if self.Sounds[soundfile] ~= nil and self.Sounds[soundfile]:IsPlaying() == true then
			self.Sounds[soundfile]:ChangeVolume(0, 0)
			self.Sounds[soundfile]:Stop()
			self.Sounds[soundfile] = nil
		end
	end
end

function SWEP:Think()


	local interval = ztm.config.TrashSWEP.level[self:GetPlayerLevel()].primaty_interval
	local pitch = 90 + ((10 / 3) * (3-interval))
	pitch = math.Clamp(pitch,85,115)
	self:LoopedSound("ztm_airsuck_loop", self:GetIsCollectingTrash() and self.TrashIncrease == false,pitch)

	self:LoopedSound("ztm_trashsuck_loop", self.TrashIncrease,100)


	if CurTime() > self.LastEffect then


		local _trash = self:GetTrash()

		if _trash > self.LastTrash then
			self.TrashIncrease = true
		else
			self.TrashIncrease = false
		end
		self.LastTrash = _trash


		if self:GetIsCollectingTrash() then

			local ve = GetViewEntity()

			if ve:GetClass() == "player" then
				local vm = LocalPlayer():GetViewModel(0)


				if self.TrashIncrease then

					ztm.f.ParticleEffectAttach("ztm_airsuck_trash", PATTACH_POINT_FOLLOW, vm, 2)
				else
					ztm.f.ParticleEffectAttach("ztm_airsuck", PATTACH_POINT_FOLLOW, vm, 2)
				end

			else

				if self.TrashIncrease then

					ztm.f.ParticleEffectAttach("ztm_airsuck_trash", PATTACH_POINT_FOLLOW, self, 1)
				else
					ztm.f.ParticleEffectAttach("ztm_airsuck", PATTACH_POINT_FOLLOW, self, 1)
				end
			end
		end

		self.LastEffect = CurTime() + 0.5
	end
end


function SWEP:PrimaryAttack()

	local ve = GetViewEntity()

	if ve:GetClass() == "player" then
		ParticleEffect("ztm_air_burst", LocalPlayer():EyePos() + LocalPlayer():EyeAngles():Forward() * 5,LocalPlayer():EyeAngles(), self)
	end

	//self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:StopAirSound()
	self:StopSound("ztm_airsuck_loop")
	self:StopSound("ztm_trashsuck_loop")

	if self.Sounds == nil then return end

	for k, v in pairs(self.Sounds) do
		if v and v:IsPlaying() then
			v:Stop()
		end
	end
end

function SWEP:OnRemove()
	self:StopAirSound()
end


function SWEP:Holster(swep)
	self:StopAirSound()
end
