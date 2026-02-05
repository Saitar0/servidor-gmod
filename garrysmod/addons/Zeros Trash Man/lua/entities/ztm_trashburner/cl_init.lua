include("shared.lua")

function ENT:Initialize()
	ztm.f.EntList_Add(self)

	self.LastTrash = 0

	self.IsBurning = false
	self.IsClosed = false

	ztm.f.PlayClientAnimation(self, "open", 1)
end

function ENT:Draw()
	self:DrawModel()

	ztm.f.UpdateEntityVisuals(self)

	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:DrawButton(texta, textb, x, y, w, h, hover, state, locked)
	if hover and locked == false then
		draw.RoundedBox(5, x, y, w, h, ztm.default_colors["blue02"])
	else
		draw.RoundedBox(5, x, y, w, h, ztm.default_colors["blue03"])
	end

	if state then
		draw.DrawText(texta, "ztm_trashburner_font02", x + 50, y + 25, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
	else
		draw.DrawText(textb, "ztm_trashburner_font02", x + 50, y + 25, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
	end

	if locked then
		draw.RoundedBox(5, x, y, w, h, ztm.default_colors["black01"])
	end
end

function ENT:DrawInfo()
	cam.Start3D2D(self:LocalToWorld(Vector(-40,0,78)), self:LocalToWorldAngles(Angle(0,-90,90)), 0.1)

		draw.RoundedBox( 5, -120, 115,240,150, ztm.default_colors["blue01"] )
		local _trash = self:GetTrash()

		if self.IsBurning then
			draw.RoundedBox( 5, -105, 127,210,50, ztm.default_colors["black01"] )
			// The expected time
			local exp_time = math.Clamp(_trash * ztm.config.TrashBurner.burn_time,1,ztm.config.TrashBurner.burn_load * ztm.config.TrashBurner.burn_time)

			local time = CurTime() - self:GetStartTime()
			local size = (210 / exp_time) * time
			draw.RoundedBox( 5, -105, 127,size,50, ztm.default_colors["red01"] )
		end

		draw.DrawText( _trash .. ztm.config.UoW, "ztm_trashburner_font01", 0, 125, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)

		self:DrawButton(ztm.language.General["Open"],ztm.language.General["Close"],-105,182.5,100,75,self:OnCloseButton(LocalPlayer()),self.IsClosed,self.IsBurning)

		self:DrawButton(ztm.language.General["Start"],ztm.language.General["Start"],5,182.5,100,75,self:OnStartButton(LocalPlayer()),self.IsBurning,self.IsClosed == false or self.LastTrash <= 0 or self.IsBurning )

	cam.End3D2D()
end


function ENT:Think()

	ztm.f.LoopedSound(self, "ztm_trashburner_burning", self:GetIsBurning())

	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		local _isclosed = self:GetIsClosed()
		if self.IsClosed ~= _isclosed then
			self.IsClosed = _isclosed

			if self.IsClosed then
				ztm.f.PlayClientAnimation(self, "close", 1)
				self:EmitSound("ztm_trashburner_door")
				timer.Simple(1,function()
					if IsValid(self) then
						self:StopSound("ztm_trashburner_door")
						self:EmitSound("ztm_trashburner_close")
					end
				end)
			else
				ztm.f.PlayClientAnimation(self, "open", 1)
				self:EmitSound("ztm_trashburner_door")
				timer.Simple(1,function()
					if IsValid(self) then
						self:StopSound("ztm_trashburner_door")
						self:EmitSound("ztm_trashburner_open")
					end
				end)
			end
		end

		local _isburning = self:GetIsBurning()
		if self.IsBurning ~= _isburning then
			self.IsBurning = _isburning

			if self.IsBurning then
				ztm.f.ParticleEffectAttach("ztm_burn", PATTACH_POINT_FOLLOW, self, 1)
				ztm.f.ParticleEffectAttach("ztm_smoke", PATTACH_POINT_FOLLOW, self, 2)
				ztm.f.ParticleEffectAttach("ztm_smoke", PATTACH_POINT_FOLLOW, self, 3)
			else
				self:StopParticles()
			end
		end


		local _trash = self:GetTrash()

		if self.LastTrash ~= _trash then

			if _trash > self.LastTrash then
				self:SetBodygroup(1,1)
				ztm.f.PlayClientAnimation(self, "add_trash", 2)
				self:EmitSound("ztm_trash_throw")
				timer.Simple(0.3,function()
					if IsValid(self) then

						local effects = {"ztm_trash_break01","ztm_trash_break02","ztm_trash_break03"}
						ztm.f.ParticleEffect(effects[ math.random( #effects ) ],self:GetPos() + self:GetUp() * 15 + self:GetForward() * -35, Angle(), self)
						self:EmitSound("ztm_trash_break")

						ztm.f.PlayClientAnimation(self, "trash_idle", 1)
						self:SetBodygroup(1,0)
					end
				end)
			end

			self.LastTrash = _trash

			local max = ztm.config.TrashBurner.burn_load

			if self.LastTrash <= 0 then
				self:SetBodygroup(0,0)
			elseif self.LastTrash < max * 0.3 then
				self:SetBodygroup(0,1)
			elseif self.LastTrash < max * 0.6 then
				self:SetBodygroup(0,2)
			elseif self.LastTrash >= max * 0.9 then
				self:SetBodygroup(0,3)
			end
		end
	else
		self.IsBurning = false
		self.IsClosed = false
	end

	self:SetNextClientThink(CurTime())
	return true
end

function ENT:UpdateVisuals()
	if self.IsClosed then
		ztm.f.PlayClientAnimation(self, "close", 5)
	else
		ztm.f.PlayClientAnimation(self, "open", 5)
	end

	if self.IsBurning then
		self:StopParticles()
		ztm.f.ParticleEffectAttach("ztm_burn", PATTACH_POINT_FOLLOW, self, 1)
		ztm.f.ParticleEffectAttach("ztm_smoke", PATTACH_POINT_FOLLOW, self, 2)
		ztm.f.ParticleEffectAttach("ztm_smoke", PATTACH_POINT_FOLLOW, self, 3)
	else
		self:StopParticles()
	end

	local max = ztm.config.TrashBurner.burn_load

	if self.LastTrash <= 0 then
		self:SetBodygroup(0,0)
	elseif self.LastTrash < max * 0.3 then
		self:SetBodygroup(0,1)
	elseif self.LastTrash < max * 0.6 then
		self:SetBodygroup(0,2)
	elseif self.LastTrash >= max * 0.9 then
		self:SetBodygroup(0,3)
	end
end



function ENT:Remove()
	self:StopParticles()
	self:StopSound("ztm_trashburner_door")
	self:StopSound("ztm_trashburner_burning")
end
