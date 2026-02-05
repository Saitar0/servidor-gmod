include("shared.lua")

function ENT:Initialize()
	ztm.f.EntList_Add(self)

	self.Closed = true
	self.LastTrash = -1
	self.RenderStencil = false

	ztm.manhole_stencils[self:EntIndex()] = self
end


function ENT:Draw()
	self:DrawModel()

	if GetConVar("ztm_cl_vfx_drawui"):GetInt() == 1 and ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 500) and self.Closed == false and self.LastTrash > 0 and ztm.f.IsTrashman(LocalPlayer()) then
		self:DrawInfo()
	end
end

function ENT:DrawInfo()

	local pos = self:GetPos() + Vector(0, 0, 50)
	local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)

	cam.Start3D2D(pos, ang, 0.1)
		draw.RoundedBox(5, -5, 80 , 5, 250,ztm.default_colors["white01"])

		surface.SetDrawColor(ztm.default_colors["grey01"])
		surface.SetMaterial(ztm.default_materials["ztm_trash_icon"])
		surface.DrawTexturedRect(-100 ,-100 ,200 , 200)

		draw.DrawText(self.LastTrash .. ztm.config.UoW, "ztm_trash_font02",0,-20, ztm.default_colors["black02"], TEXT_ALIGN_CENTER)
		draw.DrawText(self.LastTrash .. ztm.config.UoW, "ztm_trash_font01",0,-20, ztm.default_colors["white01"], TEXT_ALIGN_CENTER)

	cam.End3D2D()
end


function ENT:Think()

	ztm.f.LoopedSound(self, "ztm_manhole_water", self.Closed == false and self.LastTrash <= 0)


	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 300) then

		if IsValid(self.csModel) then

			self.csModel:SetPos(self:GetPos())
			self.csModel:SetAngles(self:GetAngles())

			local _trash = self:GetTrash()

			if _trash ~= self.LastTrash then

				//Trash got removed so we create effect
				if self.LastTrash > _trash then

					//ztm.f.TrashEffect(self, self:GetPos() + self:GetUp() * 5  + self:GetRight() * math.Rand(-15, 15) + self:GetForward() * math.Rand(-15, 15))
				end

				self.LastTrash = _trash



				if self.LastTrash > 0 then
					self.csModel:SetBodygroup(0,1)
				else
					self.csModel:SetBodygroup(0,0)
				end
			end
		end
	else
		self.LastTrash = -1
	end

	if ztm.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 800) then

		local closed  = self:GetIsClosed()

		if self.Closed ~= closed then
			self.Closed = closed

			if self.Closed then
				self:EmitSound("ztm_manhole_close")
				ztm.f.PlayClientAnimation(self, "close", 1)
				timer.Simple(0.9,function()
					if IsValid(self) then
						self.RenderStencil = false
					end
				end)
			else
				self:EmitSound("ztm_manhole_open")
				self.RenderStencil = true
				ztm.f.PlayClientAnimation(self, "open", 1)

			end
		end
	end

	self:SetNextClientThink(CurTime())
	return true
end

function ENT:OnRemove()

	self:StopSound("ztm_manhole_water")

	if IsValid(self.csModel) then
		self.csModel:Remove()
	end
end
