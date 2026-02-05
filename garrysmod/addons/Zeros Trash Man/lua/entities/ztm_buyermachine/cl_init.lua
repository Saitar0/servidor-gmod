include("shared.lua")

function ENT:Initialize()
	ztm.f.EntList_Add(self)

	self.LastMoney = 0

	self.IsInserting = false

	self.LastMoneyEnt = nil

	self.HasMoney = false

	self.PayoutMode = false

	self:DrawShadow(false)
	ztm.buyermachine_stencils[self:EntIndex()] = self
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Draw()
	self:DrawModel()

	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()
	cam.Start3D2D(self:LocalToWorld(Vector(0,10,104)), self:LocalToWorldAngles(Angle(0,180,90)), 0.1)


		draw.RoundedBox( 5, -180, 85,360,200, ztm.default_colors["blue01"] )
		if self.PayoutMode then

			surface.SetDrawColor(ztm.default_colors["white01"])
			surface.SetMaterial(ztm.default_materials["ztm_cathead"])
			surface.DrawTexturedRect(-100 ,80 ,200 , 200)

		elseif self.IsInserting then

			draw.DrawText(ztm.language.General["Wait"] .. "...", "ztm_recycler_font01", 0, 165, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
		else
			if IsValid(self:GetMoneyEnt()) then
				local h_offset = 25 * math.abs(math.sin(CurTime()) * 1)
				draw.DrawText("⇓", "ztm_buyermachine_font02", 150, 150 + h_offset, ztm.default_colors["white01"], TEXT_ALIGN_RIGHT)

				draw.DrawText("- " .. ztm.language.General["TakeMoney"] .. " -", "ztm_buyermachine_font01", 0, 170, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
			else
				local modify = (1 / 100) * self:GetPriceModify()
				local _money = self:GetMoney() * modify

				if _money > 0 then
					if self:OnPayoutButton(LocalPlayer()) then
						draw.RoundedBox( 5, -130, 190,260,60, ztm.default_colors["blue02"] )
					else
						draw.RoundedBox( 5, -130, 190,260,60, ztm.default_colors["blue03"] )
					end
					draw.DrawText(ztm.language.General["Payout"], "ztm_recycler_font01", 0, 195, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				else

					draw.DrawText("- " .. ztm.language.General["InsertRecycledTrash"] .. " -", ztm.f.GetFontFromTextSize(ztm.language.General["InsertRecycledTrash"],25,"ztm_buyermachine_font01","ztm_buyermachine_font01_small"), 0, 210, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				end
				if ztm.config.Buyermachine.DynamicBuyRate then

					local clean_profit = (100 * modify) - 100
					if clean_profit >= 0 then
						clean_profit = "+" .. clean_profit
					end

					draw.DrawText(_money .. ztm.config.Currency .. " " .. clean_profit .. "%", "ztm_recycler_font01", 0, 115, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				else
					draw.DrawText(_money .. ztm.config.Currency, "ztm_recycler_font01", 0, 115, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)
				end

			end
		end

	cam.End3D2D()
end


function ENT:Think()

	ztm.f.LoopedSound(self, "ztm_conveyorbelt_loop", true)


	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then


		if IsValid(self.csModel) then
			self.csModel:SetPos(self:GetPos())
			self.csModel:SetAngles(self:GetAngles())
		end



		local _isinserting = self:GetIsInserting()
		if self.IsInserting ~= _isinserting then
			self.IsInserting = _isinserting


			if self.IsInserting then

				ztm.f.PlayClientAnimation(self, "insert", 0.5)

				if IsValid(self.csBlockModel) then
					local _recycle_type = ztm.config.Recycler.recycle_types[self:GetBlockType()]
					self.csBlockModel:SetMaterial(_recycle_type.mat, true)
				end
			else

				ztm.f.PlayClientAnimation(self, "idle", 1)
			end
		end


		local _money = self:GetMoney()
		if self.LastMoney ~= _money then
			self.LastMoney = _money
		end

		local _moneyent = self:GetMoneyEnt()

		if self.LastMoneyEnt ~= _moneyent then
			self.LastMoneyEnt = _moneyent

			if IsValid(_moneyent) then
				self.HasMoney = true
			end
		end


		if self.HasMoney == true and not IsValid(self.LastMoneyEnt) then
			self:EmitSound("ztm_buyermachine_payout")
			self.HasMoney = false
			self.PayoutMode = true

			timer.Simple(1,function()
				if IsValid(self) then
					self.PayoutMode = false
				end
			end)
		end


	else
		self.IsInserting = false
	end

	self:SetNextClientThink(CurTime())
	return true
end

function ENT:OnRemove()
	self:StopSound("ztm_conveyorbelt_loop")

	if IsValid(self.csModel) then
		self.csModel:Remove()
	end

	if IsValid(self.csBlockModel) then
		self.csBlockModel:Remove()
	end
end
