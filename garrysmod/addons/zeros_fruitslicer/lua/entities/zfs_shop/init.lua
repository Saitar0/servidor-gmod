AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------
util.AddNetworkString("zfs_Debug")
util.AddNetworkString("zfs_AnimEvent")
util.AddNetworkString("zfs_ItemPriceChange_cl")
util.AddNetworkString("zfs_ItemPriceChange_sv")
util.AddNetworkString("zfs_ItemSellWindowClose_sv")
util.AddNetworkString("zfs_shop_FX")
util.AddNetworkString("zfs_UpdateStorage")

-- This Handels Price Change
net.Receive("zfs_ItemPriceChange_sv", function(len, ply)
	local ChangedPriceInfo = net.ReadTable()
	local newPrice = ChangedPriceInfo.ChangedPrice
	local shop = ChangedPriceInfo.Shop

	if (IsValid(shop) and shop:GetClass() == "zfs_shop") then
		if (newPrice < zfs.config.PriceMinimum) then
			zfs.f.Notify(ply, zfs.language.Shop.ChangePrice_PriceMinimum .. tostring(zfs.config.PriceMinimum) .. tostring(zfs.config.Currency), 1)

			return
		end

		if (newPrice > zfs.config.PriceMaximum) then
			zfs.f.Notify(ply, zfs.language.Shop.ChangePrice_PriceMaximum .. tostring(zfs.config.PriceMaximum) .. tostring(zfs.config.Currency), 1)

			return
		end

		local ahzdistance

		if ply:GetPos():Distance(shop:GetPos()) <= 200 then
			ahzdistance = true
		end

		if not ply:Alive() or not ahzdistance then return end
		-- Function do change price
		zfs.f.Notify(ply, zfs.language.Shop.ChangePrice_PriceChanged .. tostring(newPrice) .. tostring(zfs.config.Currency) .. "!", 0)
		shop:SetPPrice(newPrice)
	end
end)

--------------------------------
local iconSize = 50
local margin = 3
local ScreenW, ScreenH = 390, 260
local productBoxX, productBoxY = -ScreenW * 0.61, -ScreenH * 0.36
--------------------------------

-- Spawn
function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self:SetSkin(1)
	-- This function tells the Clients too use the Animation Played on Client instead of the animation data that gets send from the ServerAnim
	self:UseClientSideAnimation()
	self:SpawnWheel("r_wheel", 100)
	self:SpawnWheel("l_wheel", 100)

	-- Ensure any wheel props parented to this shop are aligned correctly.
	-- Use a short timer to run after spawn/parenting is complete.
	timer.Simple(0, function()
		if not IsValid(self) then return end
		for _, w in ipairs(ents.FindByModel("models/zerochain/fruitslicerjob/fs_wheel.mdl")) do
			if IsValid(w) and w:GetParent() == self then
				w:SetLocalAngles(Angle(0, 0, -90))
			end
		end
	end)
	self:SpawnMixer()
	self:SpawnFruitPile()
	self:SpawnWindows()
	self.Sweeteners = {}
	self.Sweeteners["Milk"] = self:SpawnSweetener("Milk", 0, 0, 10)
	self.Sweeteners["Coffe"] = self:SpawnSweetener("Coffe", 1, 11, 0)
	self.Sweeteners["Chocolate"] = self:SpawnSweetener("Chocolate", 2, 22, -10)

	--Thats the stuff we need do call with a little delay
	timer.Simple(1, function()
		if (self:IsValid()) then
			-- Our Sell Table and Product Count
			self.ProductCount = 0
			self:SetupSellTable()
			-- Resets all of our Vars
			self:action_Restart()
			self:ChangeState("DISABLED")
			self:CreateAnim_Table("idle_turnedoff", 1)
			self:StartStorage()
		end
	end)
	-- The States i use, just here as a reminder
	--["DISABLED"]
	--["MENU"]
	--["STORAGE"]
	--["ORDERING"]
	--["CONFIRMING_PRODUCT"]
	--["CUP_CHOOSETOPPING"]
	--["CONFIRMING_TOPPING"]
	--["WAIT_FOR_CUP"]
	--["SLICE_FRUITS"]
	--["WAIT_FOR_SWEETENER"]
	--["FILLING_SWEETENER"]
	--["WAIT_FOR_MIXERBUTTON"]
	--["MIXING"]
end

-- For Render reason we spawn the windows as a seperate model
function ENT:SpawnWindows()
	local ent = ents.Create("zfs_glass")
	ent:SetAngles(self:GetAngles())
	ent:SetPos(self:GetPos())
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	self:DeleteOnRemove(ent)
end

-- This Spawns the Wheels
function ENT:SpawnWheel(attach, angoffset)
	local ent = ents.Create("prop_physics")
	local attachId = self:LookupAttachment(attach)
	local attachInfo = nil

	if attachId and attachId > 0 then
		attachInfo = self:GetAttachment(attachId)
	end

	if not attachInfo or not attachInfo.Pos then
		attachInfo = {Pos = self:GetPos() + self:GetForward() * 10 + self:GetRight() * 0, Ang = self:GetAngles()}
	end

	local ang = attachInfo.Ang or self:GetAngles()

	-- Try an axis/angle that better matches the wheel model orientation.
	-- Use different rotation for left/right attachments to correct mirroring.
	local lower = string.lower(attach or "")
	if string.find(lower, "r_") or string.find(lower, "right") then
		ang:RotateAroundAxis(ang:Forward(), -90)
	elseif string.find(lower, "l_") or string.find(lower, "left") then
		ang:RotateAroundAxis(ang:Forward(), 90)
	else
		ang:RotateAroundAxis(ang:Forward(), 90)
	end

	-- Apply the model-specific angle offset (keeps ability to tweak left/right wheels)
	ang:RotateAroundAxis(ang:Up(), angoffset or 0)

	ent:SetAngles(ang)
	ent:SetPos(attachInfo.Pos)
	ent:SetModel("models/zerochain/fruitslicerjob/fs_wheel.mdl")
	ent:Spawn()
	ent:Activate()
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	-- Parent the wheel to the shop and freeze its movement so it visually stays
	-- attached without creating physics constraints that can affect the shop.
	if attachId and attachId > 0 then
		ent:SetParent(self, attachId)
	else
		ent:SetParent(self)
	end

	-- Snap to the parent's attachment and lock movement
	ent:SetLocalPos(Vector(0, 0, 0))
	-- Apply the desired angle as local angles so the ang/angoffset take effect
	if IsValid(self) then
		local localAng = self:WorldToLocalAngles(ang)
		-- Force wheels to a fixed local orientation so they're always aligned
		ent:SetLocalAngles(Angle(0, 0, -90))
	else
		ent:SetLocalAngles(Angle(0, 0, 0))
	end
	ent:SetMoveType(MOVETYPE_NONE)

	-- Keep collisions from interfering
	pcall(function()
		constraint.NoCollide(ent, self, 0, 0)
	end)

	-- Prevent players from moving the wheel with Physgun/Toolgun
	ent.PhysgunPickup = function() return false end
	ent.CanTool = function() return false end

	-- If a physics object exists, freeze it as a fallback
	local wheelPhys = ent:GetPhysicsObject()
	if IsValid(wheelPhys) then
		wheelPhys:Wake()
		wheelPhys:EnableMotion(false)
	end

	self:DeleteOnRemove(ent)
end

-- This Spawns Our Sweeteners
function ENT:SpawnSweetener(sweettype, skin, right, AngleOffset)
	local ent = ents.Create("zfs_sweetener_base")
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), -90 + AngleOffset)
	ent:SetAngles(ang)
	ent:SetPos(self:GetAttachment(self:LookupAttachment("workplace")).Pos + self:GetUp() * 6 + self:GetForward() * -12 + self:GetForward() * right)
	ent:Spawn()
	ent:Activate()
	ent:SetParent(self)
	ent:SetSkin(skin)
	ent:SetNoDraw(true)
	ent.SweetenerType = sweettype
	self:DeleteOnRemove(ent)

	return ent
end

-- This Spawns Mixer
function ENT:SpawnMixer()
	local ent = ents.Create("zfs_mixer")
	local attachInfo = self:GetAttachment(self:LookupAttachment("mixer_floor"))
	local ang = attachInfo.Ang
	ang:RotateAroundAxis(self:GetUp(), -90)
	ent:SetAngles(ang)
	ent:SetPos(attachInfo.Pos)
	ent:Spawn()
	ent:Activate()
	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_NONE)
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = ent:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	-- Prevent Physgun/Toolgun interaction and freeze movement (visual only, parent keeps it attached)
	ent:SetParent(self, self:LookupAttachment("mixer_floor"))
	ent.PhysgunPickup = function() return false end
	ent.CanTool = function() return false end
	self.Mixer = ent
	self:DeleteOnRemove(ent)
end

-- This Spawns FruitPile
function ENT:SpawnFruitPile()
	local ent = ents.Create("zfs_anim")
	ent:SetAngles(self:GetAngles())
	ent:SetPos(self:GetAttachment(self:LookupAttachment("fruitlift")).Pos + self:GetUp() * -0.1)
	ent:Spawn()
	ent:Activate()
	ent:SetModel("models/zerochain/fruitslicerjob/fs_fruitpile.mdl")
	ent:SetParent(self, self:LookupAttachment("fruitlift"))
	ent:SetModelScale(0.8)
	self:DeleteOnRemove(ent)
end

-- Fills our storage on Init
function ENT:StartStorage()
	for k, v in pairs(zfs.config.StartStorage) do
		self:FillStorage(k, v, false)
	end
end

-- Adds a specified fruit and amount in our storage
function ENT:FillStorage(fruittype, amount, PlaySound)
	if self.StoredIngrediens == nil then
		self.StoredIngrediens = {}
	end

	local inStoreFruits = self.StoredIngrediens[fruittype]

	if inStoreFruits == nil then
		inStoreFruits = 0
	end

	self.StoredIngrediens[fruittype] = inStoreFruits + amount
	self:UpdateNetStorage()

	if (PlaySound) then
		self:CreateEffect_Table(nil, "zfs_sfx_FillStorage", self, self:GetAngles(), self:GetPos(), nil)
	end
end

-- Removes a specified fruit and amount from our storage
function ENT:RemoveStorage(fruittype, amount)
	if self.StoredIngrediens == nil then
		self.StoredIngrediens = {}
	end

	local inStoreFruits = self.StoredIngrediens[fruittype]

	if inStoreFruits == nil then
		inStoreFruits = 0
	end

	self.StoredIngrediens[fruittype] = inStoreFruits - amount
	self:UpdateNetStorage()
end

-- This sends our current Storage to the Client
function ENT:UpdateNetStorage()
	if (self.StoredIngrediens == nil or table.Count(self.StoredIngrediens) <= 0) then
		print("StoredIngrediens is nil!")

		return
	end

	local svStorage = self.StoredIngrediens
	net.Start("zfs_UpdateStorage")
	net.WriteEntity(self)
	net.WriteTable(svStorage)
	net.SendPVS(self:GetPos())
end

-- This is gonna setups our SellTable
function ENT:SetupSellTable()
	local tableCount = 16
	local moveSize = 8
	local x, y = 1, 1
	local currpos = 2

	for i = 0, tableCount - 1 do
		local attach = self:GetAttachment(self:LookupAttachment("sellpoint"))
		local pos = attach.Pos + (self:GetForward() * x) + (self:GetRight() * y)

		if (zfs.config.Debug) then
			net.Start("zfs_Debug")
			net.WriteVector(pos)
			net.WriteColor(Color(0, 255, 0))
			net.Broadcast()
		end

		if self.SellTable == nil then
			self.SellTable = {}
		end

		self.SellTable[i] = {}
		self.SellTable[i].Pos = self:WorldToLocal(pos)
		self.SellTable[i].IsEmpty = true
		self.SellTable[i].Entity = nil

		if (currpos > 8) then
			currpos = 1
			y = y + moveSize
			x = 1
		else
			x = x + moveSize
			currpos = currpos + 1
		end
	end
end

-- This is gonna Search a empty positon on our table
function ENT:FindEmptyPosOnSellTable()
	local freePos

	for i = 0, table.Count(self.SellTable) - 1 do
		if (self.SellTable[i].IsEmpty) then
			freePos = i
			break
		end
	end

	if (freePos) then
		return freePos
	else
		if (zfs.config.Debug) then
			print("Sell Place Full!")
		end

		return false
	end
end

-- This Adds a Product to our SellTable
function ENT:AddProductToSellTable(Product)
	self.ProductCount = self.ProductCount + 1
	local EMPTY_Pos = self:FindEmptyPosOnSellTable()
	Product.SellTable_Index = EMPTY_Pos
	self.SellTable[EMPTY_Pos].Entity = Product
	self.SellTable[EMPTY_Pos].IsEmpty = false
	Product:SetPos(self.SellTable[EMPTY_Pos].Pos)
	local ang = self:GetAttachment(self:LookupAttachment("sellpoint")).Ang
	Product:SetAngles(ang)
end

-- This Removes a Product from our SellTable
function ENT:RemoveProductToSellTable(Product, index)
	self.ProductCount = self.ProductCount - 1
	self.SellTable[index].Entity:Remove()
	self.SellTable[index].Entity = nil
	self.SellTable[index].IsEmpty = true
end

-- Here we look if we have a free place on our table
function ENT:Has_SellTable_EmptySpot()
	local freePos

	for i = 0, table.Count(self.SellTable) - 1 do
		if (self.SellTable[i].IsEmpty) then
			freePos = i
			break
		end
	end

	if (freePos) then
		if (zfs.config.Debug) then
			print("free Place at position: " .. freePos)
		end

		return true
	else
		if (zfs.config.Debug) then
			print("Sell Place Full!")
		end

		return false
	end
end

--This creates a Trace for determining if the Screen got hit
function ENT:Use(activator, caller)

	if (not zfs.f.IsOwner(activator, self)) then
		zfs.f.Notify(activator, zfs.language.Shop.NotOwner, 1)

		return
	end

	if (not zfs.f.HasAllowedJob(activator, zfs.config.AllowedJobs)) then
		return
	end

	if (self:GetIsBusy()) then return end
	local localTrace
	localTrace = caller:GetEyeTrace()

	if (localTrace and caller:GetPos():Distance(localTrace.HitPos) < 300 and localTrace.Entity and localTrace.Entity == self) then
		self:UseLogic(localTrace, caller)
	end
end

--Here do we check what Button the trace is hitting
function ENT:UseLogic(trace, caller)
	local lTrace = self:WorldToLocal(trace.HitPos)

	if (self:GetCurrentState() == "WAIT_FOR_CUP" and lTrace.x < -26 and lTrace.x > -42 and lTrace.y < 25 and lTrace.y > 13 and lTrace.z < 51 and lTrace.z > 35) then
		self:action_PlaceCup()
	end

	self:GUILogic(trace, caller)
end

--Check if we are inside a 2D area relativ from the Root of the Entity
function ENT:CalcWorldElementPos(trace, xStart, xEnd, yStart, yEnd)
	if trace.x < xStart and trace.x > xEnd and trace.y < yStart and trace.y > yEnd then
		return true
	else
		return false
	end
end

-- This return true if the values are inside the Local Vector relative too the Screen
function ENT:CalcLocalScreenPos(trace, xStart, xEnd, yStart, yEnd)
	local attach = self:GetAttachment(self:LookupAttachment("screen"))
	local AttaPos = attach.Pos
	local AttaAng = attach.Ang
	AttaAng:RotateAroundAxis(AttaAng:Up(), -90)
	AttaAng:RotateAroundAxis(AttaAng:Right(), 180)
	local lpos = WorldToLocal(trace.HitPos, Angle(0, 0, 0), AttaPos, AttaAng)

	if lpos.x < xStart and lpos.x > xEnd and lpos.y < yStart and lpos.y > yEnd then
		return true
	else
		return false
	end
end

-- Our UI Logic
function ENT:GUILogic(trace, caller)
	local rootTrace = self:WorldToLocal(trace.HitPos)

	-- Check if we hit the Screen
	if (self:CalcLocalScreenPos(trace, 14, -14, 8.5, -8.5)) then
		if (self:GetCurrentState() == "DISABLED") then
			-- Enables the Stand and goes to the menu
			if (self:CalcWorldElementPos(rootTrace, -18.5, -30, 19.7, 17)) then
				self:action_Enable()
			end
		elseif (self:GetCurrentState() == "MENU") then
			-- Disable
			if (self:CalcWorldElementPos(rootTrace, -12, -20, 20, 18.2)) then
				self:action_Disable()
			end

			--Make Product
			if (self:CalcWorldElementPos(rootTrace, -21, -29, 20, 18.2)) then
				self:action_MakeProduct()
			end

			--Show Storage
			if (self:CalcWorldElementPos(rootTrace, -29, -37, 20, 18.2)) then
				self:action_GoToStorage()
			end
		elseif (self:GetCurrentState() == "STORAGE") then
			-- BackToTheMenu
			if (self:CalcWorldElementPos(rootTrace, -33, -37.5, 21, 20.5)) then
				self:action_GoToMenu()
			end
		elseif (self:GetCurrentState() == "ORDERING" and self:GetTSelectedItem() == -1) then
			-- BackToTheMenu
			if (self:CalcWorldElementPos(rootTrace, -33, -37.5, 21, 20.5)) then
				self:action_GoToMenu()
			end

			if (self.ProductCount < 16) then
				self:ui_ProductSelection(trace)
			else
				zfs.f.Notify(ply, zfs.language.Shop.SellTableFull, 1)
			end
		elseif (self:GetCurrentState() == "CONFIRMING_PRODUCT" and self:GetTSelectedItem() ~= -1) then
			-- Change Price
			-- Open vgui for custom price text entry
			if (zfs.config.CustomPrice and self:CalcWorldElementPos(rootTrace, -34, -37, 20.25, 19.7) and self:GetTSelectedItem()) then
				net.Start("zfs_ItemPriceChange_cl")
				local PriceChangeInfo = {}
				PriceChangeInfo.Price = self:GetPPrice()
				PriceChangeInfo.selectedItem = self:GetTSelectedItem()
				PriceChangeInfo.Shop = self
				net.WriteTable(PriceChangeInfo)
				net.Send(caller)
			end

			-- Confirm
			if (self:CalcWorldElementPos(rootTrace, -12, -23, 17.3, 16.6) and not self:MissingFruits(zfs.config.FruitCups[self:GetTSelectedItem()])) then
				self:action_ConfirmItem()
			end

			--Cancel
			if (self:CalcWorldElementPos(rootTrace, -25, -36, 17.3, 16.6)) then
				self:action_CancelItem()
				self:ChangeState("ORDERING")
			end
		elseif (self:GetCurrentState() == "CUP_CHOOSETOPPING") then
			self:ui_ToppingSelection(trace)

			if (self:GetTSelectedTopping() ~= -1) then
				self:ChangeState("CONFIRMING_TOPPING")
			end

			-- Cancel
			if (self:CalcWorldElementPos(rootTrace, -33, -37.5, 21, 20.5)) then
				self:action_CancelItem()
			end
		elseif (self:GetCurrentState() == "CONFIRMING_TOPPING" and self:GetTSelectedTopping() ~= -1) then
			if (self:GetTSelectedTopping() ~= -1) then
				-- Confirm
				if (self:CalcWorldElementPos(rootTrace, -12, -23, 17.5, 16.5)) then
					self:action_ConfirmTopping()
				end

				--Cancel
				if (self:CalcWorldElementPos(rootTrace, -25, -36, 17.5, 16.5)) then
					self:action_CancelTopping()
				end
			end
		end
	end
end

--Check if we clicked a Product
function ENT:ui_ProductSelection(trace)
	local attach = self:GetAttachment(self:LookupAttachment("screen"))
	local AttaPos = attach.Pos
	local AttaAng = attach.Ang
	AttaAng:RotateAroundAxis(AttaAng:Up(), -90)
	AttaAng:RotateAroundAxis(AttaAng:Right(), 180)

	for i, k in pairs(zfs.config.FruitCups) do
		local x, y = self:Calc_NextLine(i, iconSize, margin, productBoxX, productBoxY)
		local newVec = Vector(x, y, 1)
		local size = Vector(25, 25, -10)
		newVec:Add(size)
		newVec:Mul(0.07)
		local wpos = LocalToWorld(newVec, Angle(0, 0, 0), AttaPos, AttaAng)

		if (trace.HitPos:Distance(wpos) < 1.8) then
			self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
			self:SetTSelectedItem(i)
			self:SetPPrice(zfs.config.FruitCups[self:GetTSelectedItem()].Price)
			self:ChangeState("CONFIRMING_PRODUCT")
		end
	end
end

--Check if we clicked a Topping
function ENT:ui_ToppingSelection(trace)
	local attach = self:GetAttachment(self:LookupAttachment("screen"))
	local AttaPos = attach.Pos
	local AttaAng = attach.Ang
	AttaAng:RotateAroundAxis(AttaAng:Up(), -90)
	AttaAng:RotateAroundAxis(AttaAng:Right(), 180)

	for i, k in pairs(zfs.utility.SortedToppingsTable) do
		local x, y = self:Calc_NextLine(i, iconSize, margin, productBoxX, productBoxY)
		local newVec = Vector(x, y, 1)
		local size = Vector(25, 25, -10)
		newVec:Add(size)
		newVec:Mul(0.07)
		local wpos = LocalToWorld(newVec, Angle(0, 0, 0), AttaPos, AttaAng)

		if (trace.HitPos:Distance(wpos) < 1.8) then
			self:SetTSelectedTopping(i)
			self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
		end
	end
end

-- Calculate all of the Item Positions
function ENT:Calc_NextLine(itemCount, aiconSize, amargin, aproductBoxX, aproductBoxY)
	local ypos = 0
	local xpos = 0
	local rowCount = 7

	if (itemCount > rowCount * 3) then
		ypos = aproductBoxY + (aiconSize * 3 + amargin * 4)
		xpos = aproductBoxX + (aiconSize + amargin) * (itemCount - (rowCount * 3))
	elseif (itemCount > rowCount * 2) then
		ypos = aproductBoxY + (aiconSize * 2 + amargin * 3)
		xpos = aproductBoxX + (aiconSize + amargin) * (itemCount - (rowCount * 2))
	elseif (itemCount > rowCount) then
		ypos = aproductBoxY + (aiconSize + amargin * 2)
		xpos = aproductBoxX + (aiconSize + amargin) * (itemCount - rowCount)
	else
		ypos = aproductBoxY + amargin
		xpos = aproductBoxX + (aiconSize + amargin) * itemCount
	end

	return xpos, ypos
end

--Check if we have enough Fruits do make the Product
function ENT:MissingFruits(fruitcupdata)
	local missingFruits = {}
	local hasMissingFruits = false

	for k, v in pairs(fruitcupdata.recipe) do
		local StoredFruitCount = self.StoredIngrediens[k]

		if (StoredFruitCount == nil) then
			StoredFruitCount = 0
		end

		if (StoredFruitCount < v) then
			missingFruits[k] = v - StoredFruitCount
		end
	end

	for k, v in pairs(missingFruits) do
		if (v > 0) then
			hasMissingFruits = true
			break
		end
	end

	if (hasMissingFruits) then
		zfs.f.Notify(self:CPPIGetOwner(), zfs.language.Shop.MissingFruits, 1)
	end

	return hasMissingFruits
end

-- Gets called when we change the State
function ENT:ChangeState(state)
	if (self:GetCurrentState() == state) then
		if (zfs.config.Debug) then
			print("Cant change to " .. state .. " since its allready in that state")
		end

		return
	end

	if (zfs.config.Debug) then
		print("State Changed too " .. state)
	end

	self:SetCurrentState(state)
end

-- Is used for locking the controlls and telling the Player to wait
function ENT:SetBusy(time)
	self:SetIsBusy(true)

	timer.Simple(time, function()
		if (IsValid(self)) then
			self:SetIsBusy(false)
		end
	end)
end

-- Go Back to the Main Menu
function ENT:action_Disable()
	if (self.PublicEntity) then return end

	self:SetBusy(2)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	self:CreateEffect_Table(nil, "zfs_sfx_ToogleMachine", self, self:GetAngles(), self:GetPos(), nil)

	if (zfs.config.Debug) then
		print("You disabled the stand")
	end

	self:SetSkin(1)
	self.Mixer:AnimSequence("close", "idle", 1)
	self:AnimSequence("dessamble", "idle_turnedoff", 1)
	self:ChangeState("DISABLED")
end

-- Enable The Machine
function ENT:action_Enable()
	self:SetBusy(2)
	self:SetPos(self:GetPos() + self:GetUp() * 0.5)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	self:CreateEffect_Table(nil, "zfs_sfx_ToogleMachine", self, self:GetAngles(), self:GetPos(), nil)

	if (zfs.config.Debug) then
		print("You enabled the stand")
		print("Its frozen now")
	end

	self:SetSkin(0)
	self.Mixer:AnimSequence("open", "idle_open", 1)
	self:AnimSequence("assemble", "idle_turnedon", 1)
	self:action_GoToMenu()
end

-- Goes to the Menu
function ENT:action_GoToMenu()
	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	self:ChangeState("MENU")
end

-- Goes to the Storage
function ENT:action_GoToStorage()
	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	self:ChangeState("STORAGE")
	self:UpdateNetStorage()
end

-- Starts a Order
function ENT:action_MakeProduct()
	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	self:ChangeState("ORDERING")
end

-- Confirms the selected Product
function ENT:action_ConfirmItem()
	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	local product = zfs.config.FruitCups[self:GetTSelectedItem()]
	self:util_Add_NeedFruits("zfs_melon", product.recipe["zfs_melon"])
	self:util_Add_NeedFruits("zfs_banana", product.recipe["zfs_banana"])
	self:util_Add_NeedFruits("zfs_coconut", product.recipe["zfs_coconut"])
	self:util_Add_NeedFruits("zfs_pomegranate", product.recipe["zfs_pomegranate"])
	self:util_Add_NeedFruits("zfs_strawberry", product.recipe["zfs_strawberry"])
	self:util_Add_NeedFruits("zfs_kiwi", product.recipe["zfs_kiwi"])
	self:util_Add_NeedFruits("zfs_lemon", product.recipe["zfs_lemon"])
	self:util_Add_NeedFruits("zfs_orange", product.recipe["zfs_orange"])
	self:util_Add_NeedFruits("zfs_apple", product.recipe["zfs_apple"])

	if (zfs.config.Debug) then
		print("You need to cut")
		PrintTable(self.NeededFruits)
		print("-----------------")
	end

	self:ChangeState("CUP_CHOOSETOPPING")
end

-- Confirms the Topping
function ENT:action_ConfirmTopping()
	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	local selectedTopping = zfs.config.Toppings[self:GetTSelectedTopping()]

	-- Does the Owner have the right Ulx Group to choose this topping?
	if (table.Count(selectedTopping.UlxGroup_create) > 0 and not selectedTopping.UlxGroup_create[self:CPPIGetOwner():GetNWString("usergroup")]) then
		local allowedGroups = table.ToString(zfs.f.CreateAllowList(selectedTopping.UlxGroup_create), nil, false)
		zfs.f.Notify(self:CPPIGetOwner(), tostring(zfs.language.Shop.SelectTopping_WrongUlx01 .. allowedGroups), 3)
		zfs.f.Notify(self:CPPIGetOwner(), zfs.language.Shop.SelectTopping_WrongUlx02, 1)

		return
	end

	local topping = zfs.config.Toppings[self:GetTSelectedTopping()]

	if (zfs.config.Debug) then
		print("Selected Topping: " .. topping.Name)
	end

	self:ChangeState("WAIT_FOR_CUP")
end

-- This Places our Cup
function ENT:action_PlaceCup()
	if (self.Cup_InWork == nil) then
		local ent = ents.Create("zfs_fruitcup_base")
		ent:SetAngles(self:GetAngles())
		ent:SetPos(self:GetAttachment(self:LookupAttachment("cupwait")).Pos)
		ent:Spawn()
		ent:SetParent(self, self:LookupAttachment("cupwait"))
		ent:Activate()
		ent:PhysicsInitSphere(0.1, "default")
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetUp(), -115)
		ent:SetAngles(ang)
		self.Cup_InWork = ent
		self:DeleteOnRemove(ent)
	else
		self.Cup_InWork:SetNoDraw(false)
	end

	-- Gives us the Count how many fruits we have for later use
	self.FruitsToSlice = table.Count(self.NeededFruits)
	self:CreateEffect_Table(nil, "zfs_sfx_cup_placed", self, self:GetAngles(), self:GetPos(), nil)

	if (zfs.config.Debug) then
		print("Cup got placed")
	end

	self:action_GetFruit()
end

-- Called when we press the Cancel Product Button
function ENT:action_CancelItem()
	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	self:action_Restart()
end

-- Called when we press the Cancel Topping Button
function ENT:action_CancelTopping()
	self:CreateEffect_Table(nil, "zfs_sfx_item_select", self, self:GetAngles(), self:GetPos(), nil)
	self:ChangeState("CUP_CHOOSETOPPING")
	self:SetTSelectedTopping(-1)
end

-- Checks if there still is a Fruit for us to cut
function ENT:action_GetFruit()
	local toCut = nil

	for k, v in ipairs(self.NeededFruits) do
		if (v ~= nil) then
			toCut = v
			break
		end
	end

	if (toCut ~= nil) then
		self:action_PlaceFruit(toCut)

		if (zfs.config.Debug) then
			print("You got " .. table.Count(self.NeededFruits) .. " left to cut.")
			PrintTable(self.NeededFruits)
			print("-----------------")
		end
	else
		if (zfs.config.Debug) then
			print("Fruits are done, Now mix")
		end

		self:ChangeState("WAIT_FOR_SWEETENER")
		self:action_ShowSweetener()
	end
end

-- Places a Fruit we need do cut
function ENT:action_PlaceFruit(fruit)
	if (zfs.config.Debug) then
		print("Place fruit " .. fruit)
	end

	local ent = ents.Create(fruit)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), ent.AngleOffset)
	ent:SetAngles(ang)
	ent:SetPos(self:GetAttachment(self:LookupAttachment("workplace")).Pos + self:GetUp() * 1)
	ent:Spawn()
	ent:SetParent(self, self:LookupAttachment("workplace"))
	ent:Activate()
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	ent:CPPISetOwner(self:CPPIGetOwner())
	ent.WorkStation = self

	--self:CreateEffect_Table(nil,"zfs_sfx_cup_placed",self,self:GetAngles(),self:GetPos())
	if (zfs.config.Debug) then
		print("Fruit got placed")
	end

	self:ChangeState("SLICE_FRUITS")
end

-- Places the sliced fruit in to the Mixer
function ENT:action_FillMixer(fruit)
	-- This Spawn the sliced fruit prop in too the mixer
	local FruitEnt = ents.Create("prop_dynamic")
	FruitEnt:SetModel("models/zerochain/fruitslicerjob/fs_slicedfruits.mdl")
	FruitEnt:Spawn()
	FruitEnt:Activate()
	self:DeleteOnRemove(FruitEnt)
	local fruitPos = self.Mixer:LocalToWorld(self.Mixer:GetUp() * 5 + self.Mixer:GetUp() * self.mixerStack)
	FruitEnt:SetPos(fruitPos)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self.Mixer:GetUp(), math.random(0, 360))
	FruitEnt:SetAngles(ang)
	FruitEnt:SetParent(self)
	-- This Sets the bodygroup of the sliced fruits for the mixer
	local curFruit = fruit:GetClass()

	if (curFruit == "zfs_melon") then
		FruitEnt:SetBodygroup(0, 0)
	elseif (curFruit == "zfs_pomegranate") then
		FruitEnt:SetBodygroup(0, 1)
	elseif (curFruit == "zfs_coconut") then
		FruitEnt:SetBodygroup(0, 2)
	elseif (curFruit == "zfs_banana") then
		FruitEnt:SetBodygroup(0, 3)
	elseif (curFruit == "zfs_lemon") then
		FruitEnt:SetBodygroup(0, 4)
	elseif (curFruit == "zfs_kiwi") then
		FruitEnt:SetBodygroup(0, 5)
	elseif (curFruit == "zfs_orange") then
		FruitEnt:SetBodygroup(0, 6)
	elseif (curFruit == "zfs_strawberry") then
		FruitEnt:SetBodygroup(0, 7)
	elseif (curFruit == "zfs_apple") then
		FruitEnt:SetBodygroup(0, 8)
	end

	-- This Offsets the next sliced fruit
	if (self.FruitsToSlice > 6) then
		self.mixerStack = self.mixerStack + (10 / self.FruitsToSlice)
	else
		self.mixerStack = self.mixerStack + 1
	end

	--Adds the sliced fruit in to our Mixer
	table.insert(self.FruitsInMixer, FruitEnt)
	-- Removes the sliced fruit from our todo slice list
	self:util_Remove_NeedFruits(fruit:GetClass())
	-- This removes the Fruit prop
	fruit:Remove()
	self:action_GetFruit()
end

-- Show Sweeteners
function ENT:action_ShowSweetener()
	-- Show all the Sweeteners
	for i, k in pairs(self.Sweeteners) do
		if (IsValid(self.Sweeteners[i])) then
			self.Sweeteners[i]:SetNoDraw(false)
		end
	end

	self.Sweeteners["Coffe"]:SetPos(self:GetAttachment(self:LookupAttachment("workplace")).Pos + self:GetUp() * 1 + self:GetForward() * -12 + self:GetForward() * 0)
	self.Sweeteners["Milk"]:SetPos(self:GetAttachment(self:LookupAttachment("workplace")).Pos + self:GetUp() * 1 + self:GetForward() * -12 + self:GetForward() * 11)
	self.Sweeteners["Chocolate"]:SetPos(self:GetAttachment(self:LookupAttachment("workplace")).Pos + self:GetUp() * 1 + self:GetForward() * -12 + self:GetForward() * 22)
end

-- Add Sweetener
function ENT:action_AddSweetener(sweettype)
	self:ChangeState("FILLING_SWEETENER")
	self:SetBusy(4)

	-- This hides all the other Sweetener
	for i, k in pairs(self.Sweeteners) do
		if (IsValid(self.Sweeteners[i]) and i ~= sweettype) then
			self.Sweeteners[i]:SetNoDraw(true)
			self.Sweeteners[i]:SetPos(self:GetAttachment(self:LookupAttachment("fruitlift")).Pos)
		end
	end

	self.Sweeteners[sweettype]:SetPos(self:GetAttachment(self:LookupAttachment("mixer_floor")).Pos + self:GetUp() * 20)
end

-- Starts the Mixer
function ENT:action_StartMixer()
	-- This clears all the props in the mixer
	for i, k in pairs(self.FruitsInMixer) do
		if (IsValid(self.FruitsInMixer[i])) then
			self.FruitsInMixer[i]:Remove()
		end
	end

	-- This creats all of the SFX & VFX of the Mixer
	self.Mixer:CreateAnim_Table("mix", 2)
	self:CreateEffect_Table(nil, "zfs_sfx_startmixer", self, self:GetAngles(), self:GetPos(), nil)
	self:CreateEffect_Table(nil, "zfs_sfx_mix", self, self:GetAngles(), self:GetPos(), nil)
	self.Mixer:SetBodygroup(0, 1)
	self.Mixer:SetColor(zfs.config.FruitCups[self:GetTSelectedItem()].fruitColor)
	self:ChangeState("MIXING")
	self:SetBusy(8)

	timer.Simple(8, function()
		if (IsValid(self)) then
			self.Mixer:CreateAnim_Table("open", 1)
			self.Mixer:SetBodygroup(0, 0)
			--self.Mixer:SetSkin(0)
			self.Mixer:SetColor(Color(255, 255, 255))
			self:action_FinishCup()
		end
	end)
end

-- Creats our Finished Product
function ENT:action_FinishCup()
	-- This removes our work in progress Cup
	self.Cup_InWork:SetNoDraw(true)
	-- This Creates our product
	local productData = zfs.config.FruitCups[self:GetTSelectedItem()]
	local product = ents.Create("zfs_fruitcup_base")
	product:Spawn()
	product:Activate()
	product:SetParent(self)
	product:SetColor(productData.fruitColor)
	product:SetModelScale(1)
	product:SetBodygroup(0, 1)

	-- This Creates our Topping
	if (self:GetTSelectedTopping() ~= 1) then
		local toppingData = zfs.utility.SortedToppingsTable[self:GetTSelectedTopping()]
		local topping = ents.Create("zfs_topping")
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetUp(), 90)
		topping:SetAngles(ang)
		topping:SetPos(product:GetPos() + product:GetUp() * 10)
		topping:Spawn()
		topping:SetParent(product)
		topping:Activate()
		topping:SetModel(toppingData.Model)
		topping:SetModelScale(toppingData.mScale)
	end

	-- Everyone can buy it but its stell a entity from the shop owner
	product:CPPISetOwner(self:CPPIGetOwner())
	-- Add our fruit cup to a free spot on our World/Lua Table
	self:AddProductToSellTable(product)
	-- This Allows the Item do get sold
	product:SetReadydoSell(true)
	-- Here we tell our Cup what item he is from the config
	product.ProductID = self:GetTSelectedItem()
	-- Here we tell our Cup what his topping is
	product.ToppingID = self:GetTSelectedTopping()

	-- This Sets the Price of our Cup
	if (zfs.config.CustomPrice) then
		product:SetPrice(self:GetPPrice() + zfs.config.Toppings[self:GetTSelectedTopping()].ExtraPrice)
	else
		-- Here we calculate what the Fruit varation boni is
		PriceBoni = zfs.f.CalculateFruitVarationBoni(productData) * zfs.config.FruitMultiplicator
		FruitVariationCharge = math.Round(productData.Price * PriceBoni)
		product:SetPrice(self:GetPPrice() + FruitVariationCharge + zfs.config.Toppings[self:GetTSelectedTopping()].ExtraPrice)
	end

	-- Here we remove the used fruits from our storage
	for k, v in pairs(productData.recipe) do
		if (v > 0) then
			self:RemoveStorage(k, v)
		end
	end

	self:action_Restart()
end

-- Restarts the whole Progress
function ENT:action_Restart()
	-- Here we reset our Fruit Bowl that has all our cutted fruit
	self.FruitsInMixer = {}
	table.Empty(self.FruitsInMixer)
	-- Here we reset our needed Fruits
	self.NeededFruits = {}
	table.Empty(self.NeededFruits)
	-- Product Fruits Count
	self.FruitsToSlice = nil
	-- Resets our MixerStuff
	self.Mixer:SetBodygroup(0, 0)
	self.Mixer:SetSkin(0)
	self.Mixer:SetColor(Color(255, 255, 255))
	--Network Var Setup
	self:SetPPrice(-1)
	self:SetTSelectedItem(-1)
	self:SetTSelectedTopping(-1)
	--Start State
	self.mixerStack = 0
	self:ChangeState("MENU")
end

-- This Function gets called from the cup when someone buys it
function ENT:action_SellCup(cup, aply, price)
	if (zfs.config.Debug) then
		print("Buyer: " .. aply:Nick())
		print("Sold Cup EntIndex: " .. cup:EntIndex())
		print(cup.PrintName .. " Sold!")
	end

	self:CreateEffect_Table("zfs_sell_effect", "zfs_cup_sold", self, cup:GetAngles(), cup:GetPos(), nil)

	if gmod.GetGamemode().Name == "DarkRP" then
		-- The Indicators for the Purchase
		local PurchaseInfo = string.Replace(zfs.language.Shop.ItemBought, "$itemName", tostring(zfs.config.FruitCups[cup.ProductID].Name))
		PurchaseInfo = string.Replace(PurchaseInfo, "$itemPrice", tostring(price))
		PurchaseInfo = string.Replace(PurchaseInfo, "$currency", zfs.config.Currency)
		zfs.f.Notify(aply, PurchaseInfo, 0)
	end

	-- The Topping Consume Info we tell the Player
	zfs.f.Notify(aply, zfs.config.Toppings[cup.ToppingID].ConsumInfo, 0)
	-- This gives the player the Default Health of the Fruitcup
	local extraHealth = 25 + zfs.config.Max_HealthReward * zfs.f.CalculateFruitVarationBoni(zfs.config.FruitCups[cup.ProductID])
	extraHealth = math.Clamp(extraHealth, 0, zfs.config.Max_HealthReward)
	extraHealth = math.Round(extraHealth)

	-- Prefer directly setting health to avoid DarkRPVar warnings when
	-- the 'Energy' DarkRPVar isn't registered. Only use DarkRP Energy
	-- if the hungermod is enabled AND the DarkRP functions exist.
	if (zfs.config.UseHungermod and DarkRP and type(aply.getDarkRPVar) == "function" and type(aply.setSelfDarkRPVar) == "function" and DarkRP.RegisteredDarkRPVars and DarkRP.RegisteredDarkRPVars["Energy"]) then
		local newEnergy = (aply:getDarkRPVar("Energy") or 100) + (extraHealth or 1)
		aply:setSelfDarkRPVar("Energy", newEnergy)
	else
		local newHealth = aply:Health() + extraHealth

		if (zfs.config.HealthCap and newHealth > zfs.config.MaxHealthCap) then
			newHealth = zfs.config.MaxHealthCap
			zfs.f.Notify(aply, zfs.language.Benefit.CantAdd_ExtraHealth, 1)
		end

		aply:SetHealth(newHealth)
	end

	-- This gives the player all the Extra Benefits from the Topping
	for k, v in pairs(zfs.config.Toppings[cup.ToppingID].ToppingBenefits) do
		if (k ~= nil) then
			zfs.Benefits[k](aply, cup.ToppingID, true)
		end
	end

	-- This makes the Money Transaction
	if gmod.GetGamemode().Name == "DarkRP" then
		self:CPPIGetOwner():addMoney(price)
		aply:addMoney(-price)
	end

	-- This Removes the Cup from Table and World
	self:RemoveProductToSellTable(cup, cup.SellTable_Index)
end

-- These Functions Add/Remove Fruit to/From the NeededFruits Table
function ENT:util_Add_NeedFruits(fruit, amount)
	for i = 1, amount do
		table.insert(self.NeededFruits, fruit)
	end

	if (zfs.config.Debug) then
		print("Added " .. amount .. " " .. fruit .. " to the NeedCutBowl.")
	end
end

function ENT:util_Remove_NeedFruits(fruit)
	table.RemoveByValue(self.NeededFruits, fruit)

	if (zfs.config.Debug) then
		print("Removed " .. fruit .. " from the NeedCutBowl.")
	end
end

-- Animation
function ENT:CreateAnim_Table(anim, speed)
	if (game.SinglePlayer()) then return end
	zfs.f.CreateAnimTable(self, anim, speed)
end

function ENT:AnimSequence(anim1, anim2, speed)

	zfs.f.CreateAnimTable(self, anim1, speed)
	timer.Simple(self:SequenceDuration(self:GetSequence()), function()
		if (not IsValid(self)) then return end
		zfs.f.CreateAnimTable(self, anim2, speed)
	end)
end

-- Effects
function ENT:CreateEffect_Table(effect, sound, parent, angle, position, attach)
	zfs.f.CreateEffectTable(effect, sound, parent, angle, position, attach)
end

-- Here we make sure the players cant pick up the shop when its running
local function ShopPickup(aply, ent)
	if (ent:GetClass() == "zfs_shop") then
		if (ent:GetCurrentState() == "DISABLED") then
			return true
		else
			return false
		end
	end
end

hook.Add("PhysgunPickup", "AllowShopPickUp", ShopPickup)
