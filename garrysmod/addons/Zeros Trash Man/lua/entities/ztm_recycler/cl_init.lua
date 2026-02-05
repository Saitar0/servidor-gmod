include("shared.lua")

function ENT:Initialize()
	ztm.f.EntList_Add(self)

	self.LastTrash = 0

	self.RecycleStage = 0

	self.LastBlockUpdate = 0

	ztm.f.PlayClientAnimation(self, "open", 1)
end

function ENT:Draw()
	self:DrawModel()

	ztm.f.UpdateEntityVisuals(self)

	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()
	cam.Start3D2D(self:LocalToWorld(Vector(35.5,5.6,78.5)), self:LocalToWorldAngles(Angle(0,90,90)), 0.1)

		draw.RoundedBox( 5, -180, 85,360,215, ztm.default_colors["blue01"] )
		local _stype = self:GetSelectedType()
		local _rtypeData = ztm.config.Recycler.recycle_types[_stype]
		local _trash = self:GetTrash()

		if self.RecycleStage ~= 0 then
			draw.RoundedBox( 5, -150, 165,300,50, ztm.default_colors["black01"] )
			local time = CurTime() - self:GetStartTime()
			local size = (300 / _rtypeData.recycle_time) * time
			draw.RoundedBox( 5, -150, 165,size,50, ztm.default_colors["red01"] )
			draw.DrawText(ztm.language.General["Recycling"] .. "...", ztm.f.GetFontFromTextSize(ztm.language.General["Recycling"],15,"ztm_recycler_font01","ztm_recycler_font01_small"), 0, 165, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)

			draw.DrawText(_trash .. ztm.config.UoW , "ztm_recycler_font01", 0, 100, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)

		else

			// SWITCH Left
			if self:OnSwitchButton_Left(LocalPlayer()) then
				draw.RoundedBox( 5, -150, 165,50,50, ztm.default_colors["blue02"] )

			else
				draw.RoundedBox( 5, -150, 165,50,50, ztm.default_colors["blue03"] )

			end
			draw.DrawText( "<", "ztm_recycler_font01", -125, 166, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)


			// SWITCH Right
			if self:OnSwitchButton_Right(LocalPlayer()) then
				draw.RoundedBox( 5, 100, 165,50,50, ztm.default_colors["blue02"] )

			else
				draw.RoundedBox( 5, 100, 165,50,50, ztm.default_colors["blue03"] )

			end
			draw.DrawText( ">", "ztm_recycler_font01", 125, 166, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)


			draw.DrawText( _rtypeData.name, "ztm_recycler_font02", 0, 167, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
			draw.DrawText(" [ " .. _rtypeData.trash_per_block .. ztm.config.UoW .. " | " .. _rtypeData.recycle_time .. " s ]", "ztm_recycler_font03", 0, 190, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)


			// Recycle Button
			if _trash >= _rtypeData.trash_per_block then

				if self:OnStartButton(LocalPlayer()) then
					draw.RoundedBox( 5, -150, 230,300,50, ztm.default_colors["blue02"]  )
				else
					draw.RoundedBox( 5, -150, 230,300,50,ztm.default_colors["blue03"] )
				end
				draw.DrawText( ztm.language.General["Recycle"], ztm.f.GetFontFromTextSize(ztm.language.General["Recycle"],15,"ztm_recycler_font01","ztm_recycler_font01_small"), 0, 230, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
			else
				draw.RoundedBox( 5, -150, 230,300,50,ztm.default_colors["blue03"] )

				draw.DrawText( ztm.language.General["Recycle"], ztm.f.GetFontFromTextSize(ztm.language.General["Recycle"],15,"ztm_recycler_font01","ztm_recycler_font01_small"), 0, 230, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				draw.RoundedBox( 5, -150, 230,300,50,ztm.default_colors["black01"] )
			end

			draw.DrawText(_trash .. ztm.config.UoW, "ztm_recycler_font01", 0, 100, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)

		end

	cam.End3D2D()
end


function ENT:Think()

	ztm.f.LoopedSound(self, "ztm_recycler_grind", self.RecycleStage == 2)
	ztm.f.LoopedSound(self, "ztm_recycler_trashfall", self.RecycleStage == 2)
	ztm.f.LoopedSound(self, "ztm_conveyorbelt_loop", true)


	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		if IsValid(self.csBlockModel) then

			if self.csBlockModel:GetNoDraw() == false then
				local attach = self:GetAttachment(1)
				if attach then
					local ang = attach.Ang
					ang:RotateAroundAxis(attach.Ang:Forward(),-90)
					ang:RotateAroundAxis(attach.Ang:Up(),90)
					self.csBlockModel:SetPos(attach.Pos)
					self.csBlockModel:SetAngles(ang)
				end

				local time = CurTime() - self:GetStartTime()

				if time > self.LastBlockUpdate then
					self.LastBlockUpdate = time + 0.1

					local _recycle_data = ztm.config.Recycler.recycle_types[self:GetSelectedType()]
					local bHeight = (1 / _recycle_data.recycle_time) * time

					local mat = Matrix()
					mat:Scale(Vector(1, 1, math.Clamp(bHeight,0,1)))
					self.csBlockModel:EnableMatrix("RenderMultiply", mat)

					self.csBlockModel:SetMaterial(_recycle_data.mat, true)
				end
			end
		else
			self.csBlockModel = ClientsideModel("models/zerochain/props_trashman/ztm_recycleblock.mdl")
			if IsValid(self.csBlockModel) then
				self.csBlockModel:SetNoDraw(true)
			end
		end


		local _recyclestage = self:GetRecycleStage()
		if self.RecycleStage ~= _recyclestage then
			self.RecycleStage = _recyclestage

			if self.RecycleStage == 0 then

				self:EmitSound("ztm_trashburner_door")
				timer.Simple(1,function()
					if IsValid(self) then
						self:EmitSound("ztm_trashburner_open")
					end
				end)

				ztm.f.PlayClientAnimation(self, "open", 1)

				self.csBlockModel:SetNoDraw(true)

			elseif self.RecycleStage == 1 then

				ztm.f.PlayClientAnimation(self, "close", 1)
				self:EmitSound("ztm_trashburner_door")
				timer.Simple(1,function()
					if IsValid(self) then
						self:EmitSound("ztm_trashburner_close")
					end
				end)
				self.csBlockModel:SetNoDraw(true)

			elseif self.RecycleStage == 2 then

				ztm.f.PlayClientAnimation(self, "recycle", 1)
				self.LastBlockUpdate = 0
				self.csBlockModel:SetNoDraw(false)

				ztm.f.ParticleEffectAttach("ztm_trashfall",  PATTACH_POINT_FOLLOW , self, 2)

			elseif self.RecycleStage == 3 then

				self:StopParticlesNamed("ztm_trashfall")
				ztm.f.PlayClientAnimation(self, "output", 1)

				self:EmitSound("ztm_trashburner_door")
				timer.Simple(1,function()
					if IsValid(self) then
						self:EmitSound("ztm_trashburner_open")
					end
				end)

				self.csBlockModel:SetNoDraw(false)
				local _recycle_type = ztm.config.Recycler.recycle_types[self:GetSelectedType()]
				self.csBlockModel:SetMaterial(_recycle_type.mat, true)
			end
		end

		local _trash = self:GetTrash()
		if self.LastTrash ~= _trash then


			if _trash > self.LastTrash then
				self:SetBodygroup(1,1)
				ztm.f.PlayClientAnimation(self, "add_trash", 1.5)
				self:EmitSound("ztm_trash_throw")
				timer.Simple(0.6,function()
					if IsValid(self) then

						local effects = {"ztm_trash_break01","ztm_trash_break02","ztm_trash_break03"}
						ztm.f.ParticleEffect(effects[ math.random( #effects ) ],self:GetPos() + self:GetUp() * 15 + self:GetRight() * -35, Angle(), self)

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
		self.RecycleStage = -1
		self.LastBlockUpdate = 0

		self:StopParticlesNamed("ztm_trashfall")

		if IsValid(self.csBlockModel) then
			self.csBlockModel:Remove()
		end
	end

	self:SetNextClientThink(CurTime())
	return true
end

function ENT:UpdateVisuals()

	self:StopParticlesNamed("ztm_trashfall")

	if self.RecycleStage == 0 then
		ztm.f.PlayClientAnimation(self, "open", 5)

	elseif self.RecycleStage == 1 then
		ztm.f.PlayClientAnimation(self, "close", 5)

	elseif self.RecycleStage == 2 then
		ztm.f.PlayClientAnimation(self, "recycle", 1)
		ztm.f.ParticleEffectAttach("ztm_trashfall",  PATTACH_POINT_FOLLOW , self, 2)

	elseif self.RecycleStage == 3 then
		ztm.f.PlayClientAnimation(self, "output", 1)

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


function ENT:OnRemove()
	self:StopSound("ztm_recycler_grind")
	self:StopSound("ztm_recycler_trashfall")
	self:StopSound("ztm_conveyorbelt_loop")

	if IsValid(self.csBlockModel) then
		self.csBlockModel:Remove()
	end
end
