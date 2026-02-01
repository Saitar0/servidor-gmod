include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if (LocalPlayer():GetPos():Distance(self:GetPos()) < 200) then
		self:DrawInterface()
	end
end

function ENT:DrawTranslucent()
	self:Draw()
end

local ScreenW, ScreenH = 390, 260
local Assemble = Material("materials/zfruitslicer/ui/zfs_ui_assmble.png", "smooth")
local Dessamble = Material("materials/zfruitslicer/ui/zfs_ui_desamble.png", "smooth")
local Storage = Material("materials/zfruitslicer/ui/fs_ui_storage.png", "smooth")
local productBG = Material("materials/zfruitslicer/ui/zfs_ui_productbg.png", "smooth")
local TakeACupImg = Material("materials/zfruitslicer/ui/zfs_ui_takeacup.png", "smooth")
local StartTheBlender = Material("materials/zfruitslicer/ui/zfs_ui_starttheblender.png", "smooth")
local SliceFruitsImg = Material("materials/zfruitslicer/ui/zfs_ui_slicefruit.png", "smooth")
local productHover = Material("materials/zfruitslicer/ui/zfs_ui_product_hover.png", "smooth")
local MakeProductImg = Material("materials/zfruitslicer/ui/zfs_ui_makeproduct.png", "smooth")
local ChooseSweetenerImg = Material("materials/zfruitslicer/ui/zfs_ui_chooseswetener.png", "smooth")

local IngrediensIcons = {}
IngrediensIcons["zfs_melon"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_watermelon.png", "smooth")
IngrediensIcons["zfs_banana"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_banana.png", "smooth")
IngrediensIcons["zfs_coconut"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_coconut.png", "smooth")
IngrediensIcons["zfs_pomegranate"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_pomegranate.png", "smooth")
IngrediensIcons["zfs_strawberry"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_strawberry.png", "smooth")
IngrediensIcons["zfs_kiwi"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_kiwi.png", "smooth")
IngrediensIcons["zfs_lemon"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_lemon.png", "smooth")
IngrediensIcons["zfs_orange"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_orange.png", "smooth")
IngrediensIcons["zfs_apple"] = Material("materials/zfruitslicer/ui/ingrediens/zfs_apple.png", "smooth")

local iconSize = 50
local productBoxX, productBoxY = -ScreenW * 0.61, -ScreenH * 0.36
local margin = 3
local ButtonYes = Color(109, 151, 106, 255)
local ButtonNo = Color(151, 106, 106, 255)

function ENT:Initialize()
	self.initialdiff = 100000000000000000000
	self.lastHitItem = nil
	self.nearestItem = nil
	self.IsHovering = false
	self:CreateToppingModelSnapshots()
	self:SetupDerma2D3D()
end

-- Creats other needed Derma stuff for 2D3D
function ENT:SetupDerma2D3D()
	-- Creats our product info label
	self.PDescription = vgui.Create("DLabel", self.Mframe)
	self.PDescription:SetPos(245, 25)
	self.PDescription:SetSize(130, 50)
	self.PDescription:SetFont("zfs_ProductInfo")
	self.PDescription:SetColor(Color(255, 255, 255, 255))
	self.PDescription:SetText("lorem upsum ddf du bist so ganz und so sun")
	self.PDescription:SetWrap(true)
	self.PDescription:SetPaintedManually(true)
	self.PDescription:SetVisible(false)
	self.PDescription:SetAutoStretchVertical(true)
end

-- This Creates all the UI Model Snapshots for the Topping selection Base on Initialize
function ENT:CreateToppingModelSnapshots()
	self.MSpawnIcons = {}
	self.Mframe = vgui.Create("DFrame")
	self.Mframe:SetSize(ScreenW, ScreenH)
	self.Mframe:SetPos(0, 0)
	self.Mframe:SetPaintedManually(true)

	for i, k in pairs(zfs.utility.SortedToppingsTable) do
		local x, y = self:Calc_NextLine(7, i, iconSize, margin, -46, 5)
		self.MSpawnIcons[i] = vgui.Create("SpawnIcon", self.Mframe) -- SpawnIcon
		self.MSpawnIcons[i]:SetPos(x, y)
		self.MSpawnIcons[i]:SetSize(40, 40)
		self.MSpawnIcons[i]:SetModel(k.Model) -- Model we want for this spawn icon

		if (i == 1) then
			self.MSpawnIcons[i]:SetPaintedManually(false)
		else
			self.MSpawnIcons[i]:SetPaintedManually(true)
		end
	end
end

--This Creates a UI Model Snapshot for our Topping Confirmation
function ENT:CreateSelectedToppingModel(i, x, y)
	self.selectedToppingModel = vgui.Create("SpawnIcon", self.Mframe) -- SpawnIcon
	self.selectedToppingModel:SetPos(x, y)
	self.selectedToppingModel:SetSize(60, 60)
	self.selectedToppingModel:SetModel(zfs.utility.SortedToppingsTable[i].Model) -- Model we want for this spawn icon
end

--This Draw out interface
function ENT:DrawInterface()
	local attach = self:GetAttachment(self:LookupAttachment("screen"))
	local Pos = attach.Pos
	local Ang = attach.Ang
	Ang:RotateAroundAxis(Ang:Up(), 90)
	cam.Start3D2D(Pos, Ang, 0.07)

	if (self:GetIsBusy()) then
		self:ui_IsBusy()
	elseif (self:GetCurrentState() == "DISABLED") then
		self:ui_EnableStand()
	elseif (self:GetCurrentState() == "MENU") then
		self:BaseScreen("ZerosFruitSlicer OS v1.0")
		self:ui_ShowStorage()
		self:ui_MakeProduct()
		if (self:GetPublicEntity() == false) then
			self:ui_Disable()
		end
	elseif (self:GetCurrentState() == "STORAGE") then
		self:BaseScreen(zfs.language.Shop.StorageTitle)
		self:ui_Cancel(zfs.language.Shop.StorageBackButton)
		self:ui_Storage()
	elseif (self:GetCurrentState() == "ORDERING" and self:GetTSelectedItem() == -1) then
		self:BaseScreen(zfs.language.Shop.Screen_Product_Select)
		self:ui_Cancel(zfs.language.Shop.Screen_Cancel)
		self:ui_ProductSelection()
	elseif (self:GetCurrentState() == "CONFIRMING_PRODUCT") then
		--self:UpdateNetStorage()
		self:ui_ProductConfirmation()
	elseif (self:GetCurrentState() == "CUP_CHOOSETOPPING") then
		self:BaseScreen(zfs.language.Shop.Screen_Topping_Select)
		self:ui_Cancel(zfs.language.Shop.Screen_Cancel)
		self:ui_ToppingSelection()
	elseif (self:GetCurrentState() == "CONFIRMING_TOPPING") then
		self:BaseScreen(zfs.language.Shop.Screen_Confirm_Topping)
		self:ui_ToppingConfirmation()
	elseif (self:GetCurrentState() == "WAIT_FOR_CUP") then
		self:BaseScreen("")
		--self:ui_Cancel(zfs.language.Shop.Screen_Cancel)
		self:ui_InfoBox(zfs.language.Shop.Screen_Info01, "TakeCup")
	elseif (self:GetCurrentState() == "SLICE_FRUITS") then
		self:BaseScreen("")
		self:ui_InfoBox(zfs.language.Shop.Screen_Info02, "SliceFruits")
	elseif (self:GetCurrentState() == "WAIT_FOR_SWEETENER") then
		self:BaseScreen("")
		self:ui_InfoBox(zfs.language.Shop.Screen_Info04, "ChooseSweetener")
	elseif (self:GetCurrentState() == "WAIT_FOR_MIXERBUTTON") then
		self:BaseScreen("")
		self:ui_InfoBox(zfs.language.Shop.Screen_Info03, "StartTheBlender")
	end

	cam.End3D2D()
	local offset = self:GetForward() * 13 + attach.Ang:Right() * -6.5
	cam.Start3D2D(Pos + offset, Ang, 0.07)

	if (self:GetCurrentState() == "CONFIRMING_PRODUCT") then
		self.PDescription:PaintManual()
	elseif (self:GetCurrentState() == "CUP_CHOOSETOPPING") then
		-- This Rebuilds makes sure our model snapshot gets rebuild
		if (self.selectedToppingModel) then
			self.selectedToppingModel = nil
		end

		-- This Renders all our Topping Model Snapshots
		for i, k in pairs(self.MSpawnIcons) do
			if (i ~= 1) then
				self.MSpawnIcons[i]:PaintManual()
			end
		end
	elseif (self:GetCurrentState() == "CONFIRMING_TOPPING") then
		-- This Renders the Model Snapshot if its not number 1 aka the Cancel Icon
		if (self:GetTSelectedTopping() ~= 1) then
			local selectedTopping = self:GetTSelectedTopping()

			if (self.selectedToppingModel) then
				self.selectedToppingModel:PaintManual()
			else
				self:CreateSelectedToppingModel(selectedTopping, 18, 11)
			end
		end
	end

	cam.End3D2D()
end

-- This creates the Main Screen Frame
function ENT:BaseScreen(toptitle)
	draw.RoundedBox(2, -ScreenW * 0.5, -130, ScreenW, ScreenH, Color(25, 25, 25))
	draw.RoundedBox(0, -ScreenW * 0.48, -ScreenH * 0.363, ScreenW * 0.96, ScreenH * 0.834, Color(40, 40, 40))
	draw.RoundedBox(0, -ScreenW * 0.5, -ScreenH * 0.39, ScreenW, 2, Color(200, 200, 200))
	draw.DrawText(toptitle, "zfs_MainBoxTitle", -ScreenW * 0.475, -ScreenW * 0.315, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
end

-- This adds te Cancel button to the menu
local ButtonBackToMain = Color(172, 46, 46)

function ENT:ui_Cancel(text)
	local ButtonBackToMainColor

	if (self:CalcWorldElementPos(-33, -37.5, 21, 20.5)) then
		local h, s, v = ColorToHSV(ButtonBackToMain)
		ButtonBackToMainColor = HSVToColor(h, s, v)
	else
		local h, s, v = ColorToHSV(ButtonBackToMain)
		ButtonBackToMainColor = HSVToColor(h, s, v - 0.3)
	end

	--Buttons
	draw.RoundedBox(3, ScreenW * 0.32, -ScreenH * 0.465, ScreenW * 0.16, ScreenH * 0.058, ButtonBackToMainColor)
	draw.DrawText(text, "zfs_BaseCancel", ScreenW * 0.4, -ScreenH * 0.468, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end

-- This tells the Player do wait
function ENT:ui_IsBusy()
	self:BaseScreen("ZerosFruitSlicer OS v1.0")
	draw.DrawText(zfs.language.Shop.Screen_Wait, "zfs_buttonfont01", 0, -ScreenH * 0.07, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
end

-- This asks us if we want do enable the stand
function ENT:ui_EnableStand()
	self:BaseScreen("ZerosFruitSlicer OS v1.0")
	local buttonAssemblesColor

	if (self:CalcWorldElementPos(-18.5, -30, 19.7, 17)) then
		buttonAssemblesColor = Color(125, 125, 125, 255)
	else
		buttonAssemblesColor = Color(75, 75, 75, 255)
	end

	local xSize, ySize = ScreenW * 0.4, ScreenH * 0.55
	local xPos, yPos = -ScreenW * 0.22, -ScreenH * 0.23
	surface.SetDrawColor(buttonAssemblesColor)
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(xPos, yPos, xSize, ySize)
	draw.NoTexture()
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(Assemble)
	surface.DrawTexturedRect(xPos, yPos, xSize, ySize)
	draw.NoTexture()

	if (self:CalcWorldElementPos(-18.5, -30, 19.7, 17)) then
		surface.SetDrawColor(Color(125, 255, 125))
		surface.SetMaterial(productHover)
		surface.DrawTexturedRect(xPos, yPos, xSize, ySize)
		draw.NoTexture()
	end
end

-- This adds the disable button to the menu
function ENT:ui_Disable()
	local xSize, ySize = ScreenW * 0.3, ScreenH * 0.4
	local xPos, yPos = -ScreenW * 0.47, -ScreenH * 0.345
	-- Disable Button
	local buttonDessambleColor

	if (self:CalcWorldElementPos(-12, -20, 20, 18.2)) then
		buttonDessambleColor = Color(0, 255, 0, 0)
	else
		buttonDessambleColor = Color(0, 0, 0, 150)
	end

	surface.SetDrawColor(Color(125, 125, 125, 255))
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(xPos, yPos, xSize, ySize)
	draw.NoTexture()
	surface.SetDrawColor(buttonDessambleColor)
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(xPos, yPos, xSize, ySize)
	draw.NoTexture()
	surface.SetDrawColor(225, 225, 225, 255)
	surface.SetMaterial(Dessamble)
	surface.DrawTexturedRect(xPos, yPos, xSize, ySize)
	draw.NoTexture()

	if (self:CalcWorldElementPos(-12, -20, 20, 18.2)) then
		surface.SetDrawColor(Color(125, 255, 125))
		surface.SetMaterial(productHover)
		surface.DrawTexturedRect(xPos, yPos, xSize, ySize)
		draw.NoTexture()
	end
end

-- This adds the MakeProduct button to the menu
function ENT:ui_MakeProduct()
	local xSize, ySize = ScreenW * 0.3, ScreenH * 0.4
	local xPos, yPos = -ScreenW * 0.47, -ScreenH * 0.345
	local buttonMakeProduct

	if (self:CalcWorldElementPos(-21, -29, 20, 18.2)) then
		buttonMakeProduct = Color(0, 255, 0, 0)
	else
		buttonMakeProduct = Color(0, 0, 0, 150)
	end

	surface.SetDrawColor(Color(125, 125, 125, 255))
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(xPos + 125, yPos, xSize, ySize)
	draw.NoTexture()
	surface.SetDrawColor(buttonMakeProduct)
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(xPos + 125, yPos, xSize, ySize)
	draw.NoTexture()
	surface.SetDrawColor(225, 225, 225, 255)
	surface.SetMaterial(MakeProductImg)
	surface.DrawTexturedRect(xPos + 104, yPos, xSize * 1.4, ySize)
	draw.NoTexture()

	if (self:CalcWorldElementPos(-21, -29, 20, 18.2)) then
		surface.SetDrawColor(Color(125, 255, 125))
		surface.SetMaterial(productHover)
		surface.DrawTexturedRect(xPos + 125, yPos, xSize, ySize)
		draw.NoTexture()
	end
end

-- This adds the ShowStorage button to the menu
function ENT:ui_ShowStorage()
	local xSize, ySize = ScreenW * 0.3, ScreenH * 0.4
	local xPos, yPos = -ScreenW * 0.47, -ScreenH * 0.345
	local buttonMakeProduct

	if (self:CalcWorldElementPos(-29, -37, 20, 18.2)) then
		buttonMakeProduct = Color(0, 255, 0, 0)
	else
		buttonMakeProduct = Color(0, 0, 0, 150)
	end

	surface.SetDrawColor(Color(125, 125, 125, 255))
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(xPos + 250, yPos, xSize, ySize)
	draw.NoTexture()
	surface.SetDrawColor(buttonMakeProduct)
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(xPos + 250, yPos, xSize, ySize)
	draw.NoTexture()
	surface.SetDrawColor(225, 225, 225, 255)
	surface.SetMaterial(Storage)
	surface.DrawTexturedRect(xPos + 262, yPos + 12, xSize / 1.3, ySize / 1.3)
	draw.NoTexture()

	if (self:CalcWorldElementPos(-29, -37, 20, 18.2)) then
		surface.SetDrawColor(Color(125, 255, 125))
		surface.SetMaterial(productHover)
		surface.DrawTexturedRect(xPos + 250, yPos, xSize, ySize)
		draw.NoTexture()
	end
end

-- Here we fill our Table with the current Storage of fruits we have on the Server
function ENT:cl_UpdateStorage(svFruitStorage)
	if self.StoredFruits == nil then
		self.StoredFruits = {}
	end

	self.StoredFruits = svFruitStorage
end

net.Receive("zfs_UpdateStorage", function(len, ply)
	local shop = net.ReadEntity()
	local svStorage = net.ReadTable()

	if (IsValid(shop) and svStorage ~= nil and table.Count(svStorage) > 0) then
		shop:cl_UpdateStorage(svStorage)
	else
		print("Something is nil, Contact FruitslicerScript Creator")
	end
end)

-- The Storage UI
function ENT:ui_Storage()
	local xSize, ySize = ScreenW * 0.15, ScreenH * 0.2
	local xPos, yPos = -ScreenW * 0.46, -ScreenH * 0.345
	self:ui_FruitStorageItems(self.StoredFruits, xPos, yPos, xSize, ySize)
end

-- This adds a Fruit Storage UI Element if we have the fruit in our storage
function ENT:ui_FruitStorageItems(fruits, x, y, sizeX, sizeY)
	if (fruits == nil or table.Count(fruits) <= 0) then
		print("FruitArray is nil!")

		return
	end

	local rowCount = 5
	local itemCount = 0
	local nextX = 0
	local nextY = 0

	for k, v in pairs(fruits) do
		if (fruits[k] > 0) then
			if (itemCount > rowCount) then
				nextY = 54
				nextX = 60 * (itemCount - rowCount * 1.21)
				itemCount = itemCount + 1
			else
				itemCount = itemCount + 1
				nextX = 60 * (itemCount - rowCount * 0.21)
			end

			surface.SetDrawColor(zfs.config.Item_BG)
			surface.SetMaterial(productBG)
			surface.DrawTexturedRect(x + nextX, y + nextY, sizeX, sizeY)
			draw.NoTexture()
			surface.SetDrawColor(225, 225, 225, 255)
			surface.SetMaterial(IngrediensIcons[k])
			surface.DrawTexturedRect(x + nextX, y + nextY, sizeX, sizeY)
			draw.NoTexture()
			surface.SetDrawColor(Color(0, 0, 0, 25))
			surface.SetMaterial(productBG)
			surface.DrawTexturedRect(x + nextX, y + nextY, sizeX, sizeY)
			draw.NoTexture()
			draw.DrawText(tostring(v), "zfs_ProductTitle", x + nextX + 30, y + nextY + 15, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		end
	end
end

-- This asKs us if we are happy with ous selection
function ENT:ui_InfoBox(info, status)
	draw.DrawText(info, "zfs_InfoBoxTextfont01", ScreenW * -0.45, ScreenH * -0.35, Color(218, 28, 92, 255), TEXT_ALIGN_LEFT)

	if (status == "TakeCup") then
		surface.SetDrawColor(225, 225, 225, 255)
		surface.SetMaterial(TakeACupImg)
		surface.DrawTexturedRect(-ScreenW * 0.481, -ScreenH * 0.54, ScreenW * 0.85, ScreenH)
		draw.NoTexture()
	elseif (status == "SliceFruits") then
		surface.SetDrawColor(225, 225, 225, 255)
		surface.SetMaterial(SliceFruitsImg)
		surface.DrawTexturedRect(-ScreenW * 0.4, -ScreenH * 0.365, ScreenW * 0.85, ScreenH * 0.8)
		draw.NoTexture()
	elseif (status == "ChooseSweetener") then
		surface.SetDrawColor(225, 225, 225, 255)
		surface.SetMaterial(ChooseSweetenerImg)
		surface.DrawTexturedRect(-ScreenW * 0.48, -ScreenH * 0.31, ScreenW * 0.96, ScreenH * 0.78)
		draw.NoTexture()
	elseif (status == "StartTheBlender") then
		surface.SetDrawColor(225, 225, 225, 255)
		surface.SetMaterial(StartTheBlender)
		surface.DrawTexturedRect(-ScreenW * 0.48, -ScreenH * 0.31, ScreenW * 0.96, ScreenH * 0.9)
		draw.NoTexture()
	end
end

-- This displays the ProductSelection
function ENT:ui_ProductSelection()
	-- This disables our Product Info again
	if (self.PDescription:IsValid() and self.PDescription:IsVisible()) then
		self.PDescription:SetVisible(false)
	end

	for i, k in pairs(zfs.config.FruitCups) do
		local x, y = self:Calc_NextLine(7, i, iconSize, margin, productBoxX, productBoxY)
		-- This changes its background color
		local iconBG_Color = zfs.config.Item_BG
		surface.SetDrawColor(iconBG_Color)
		surface.SetMaterial(productBG)
		surface.DrawTexturedRect(x, y, iconSize, iconSize)
		draw.NoTexture()
		surface.SetDrawColor(Color(255, 255, 255))
		surface.SetMaterial(Material(k.Icon))
		surface.DrawTexturedRect(x, y, iconSize, iconSize)
		draw.NoTexture()

		-- This enables the hover element
		if (self:HoverOverButton(self:CalcElementPos(x, y, Vector(25, 25, -10)))) then
			surface.SetDrawColor(Color(125, 255, 125))
			surface.SetMaterial(productHover)
			surface.DrawTexturedRect(x, y, iconSize, iconSize)
			draw.NoTexture()
		end
	end
end
-- This ask´s us if we are happy with our product selection
function ENT:ui_ProductConfirmation()
	local selectedItem = zfs.config.FruitCups[self:GetTSelectedItem()]
	local iconBG_Color = zfs.config.Item_BG
	local buttonYesColor

	if (self:CalcWorldElementPos(-12, -23, 17.3, 16.6)) then
		local h, s, v = ColorToHSV(ButtonYes)
		buttonYesColor = HSVToColor(h, s, v)
	else
		local h, s, v = ColorToHSV(ButtonYes)
		buttonYesColor = HSVToColor(h, s, v - 0.3)
	end

	local buttonNoColor

	if (self:CalcWorldElementPos(-25, -36, 17.3, 16.6)) then
		local h, s, v = ColorToHSV(ButtonNo)
		buttonNoColor = HSVToColor(h, s, v)
	else
		local h, s, v = ColorToHSV(ButtonNo)
		buttonNoColor = HSVToColor(h, s, v - 0.3)
	end

	self:BaseScreen(zfs.language.Shop.Screen_Confirm_Product)
	--Buttons
	draw.RoundedBox(7, -ScreenW * 0.45, ScreenH * 0.28, ScreenW * 0.4, ScreenH * 0.15, buttonYesColor)
	draw.DrawText(zfs.language.Shop.Screen_Confirm_Yes, "zfs_buttonfont01", -ScreenW * 0.25, ScreenH * 0.28, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	draw.RoundedBox(7, ScreenW * 0.05, ScreenH * 0.28, ScreenW * 0.4, ScreenH * 0.15, buttonNoColor)
	draw.DrawText(zfs.language.Shop.Screen_Confirm_No, "zfs_buttonfont01", ScreenW * 0.25, ScreenH * 0.28, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	local x = -ScreenW * 0.455
	local y = -ScreenH * 0.35
	local tIconSize = iconSize * 1.5
	draw.RoundedBox(0, -ScreenW * 0.48, -ScreenH * 0.358, ScreenW * 0.96, ScreenH * 0.31, Color(100, 100, 100))
	draw.DrawText(tostring(selectedItem.Name), "zfs_ProductTitle", -ScreenW * 0.25, -ScreenH * 0.36, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)

	-- Sets and enables our Derma Product Info Label
	if (self.PDescription:IsValid() and not self.PDescription:IsVisible()) then
		self.PDescription:SetText(tostring(selectedItem.Info))
		self.PDescription:SetVisible(true)

		if (zfs.config.CustomPrice) then
			self.PDescription:SetPos(88, 45)
			self.PDescription:SetSize(250, 50)
		else
			self.PDescription:SetPos(245, 5)
			self.PDescription:SetSize(130, 50)
		end
	end

	local prize

	if zfs.config.CustomPrice then
		local buttonEditColor

		if (self:CalcWorldElementPos(-34, -37, 20.20, 19.7)) then
			buttonEditColor = Color(255, 90, 70)
		else
			buttonEditColor = Color(45, 45, 70)
		end

		draw.RoundedBox(3, ScreenW * 0.355, -ScreenH * 0.33, ScreenW * 0.1, ScreenH * 0.08, buttonEditColor)
		draw.DrawText("...", "zfs_EditButton", ScreenW * 0.405, -ScreenH * 0.345, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
		prize = self:GetPPrice()
		draw.DrawText(zfs.language.Shop.Screen_Product_Price, "zfs_Infofont03", -ScreenW * 0.25, -ScreenH * 0.26, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
		draw.DrawText(tostring(prize) .. zfs.config.Currency, "zfs_Infofont03", -ScreenW * 0.11, -ScreenH * 0.26, Color(0, 200, 0, 255), TEXT_ALIGN_LEFT)
	else
		draw.RoundedBox(0, ScreenW * 0.145, -ScreenH * 0.34, ScreenW * 0.325, ScreenH * 0.27, Color(0, 0, 0, 100))
		draw.RoundedBox(0, -ScreenW * 0.248, -ScreenH * 0.13, ScreenW * 0.38, ScreenH * 0.005, Color(150, 150, 150))
		-- Here we calculate what the Fruit varation boni is
		PriceBoni = zfs.f.CalculateFruitVarationBoni(selectedItem) * zfs.config.FruitMultiplicator
		ExtraFruitPrice = math.Round(selectedItem.Price * PriceBoni)
		draw.DrawText(zfs.language.Shop.Screen_Product_BasePrice, "zfs_Infofont03", -ScreenW * 0.25, -ScreenH * 0.27, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
		draw.DrawText(zfs.language.Shop.Screen_Product_FruitBoni, "zfs_Infofont03", -ScreenW * 0.25, -ScreenH * 0.2, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
		-- The Base Price
		draw.DrawText(tostring(selectedItem.Price) .. zfs.config.Currency, "zfs_Infofont03", ScreenW * 0.135, -ScreenH * 0.27, Color(0, 200, 200, 255), TEXT_ALIGN_RIGHT)
		-- The FruitVariation Extra Cost
		draw.DrawText("+" .. tostring(ExtraFruitPrice) .. zfs.config.Currency, "zfs_Infofont03", ScreenW * 0.135, -ScreenH * 0.2, Color(0, 200, 200, 255), TEXT_ALIGN_RIGHT)
		-- The Final Price
		draw.DrawText("+" .. tostring(selectedItem.Price + ExtraFruitPrice) .. zfs.config.Currency, "zfs_Infofont03", ScreenW * 0.135, -ScreenH * 0.125, Color(0, 200, 0, 255), TEXT_ALIGN_RIGHT)
	end

	surface.SetDrawColor(iconBG_Color)
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(x, y, tIconSize, tIconSize)
	draw.NoTexture()
	surface.SetDrawColor(Color(255, 255, 255))
	surface.SetMaterial(Material(selectedItem.Icon))
	surface.DrawTexturedRect(x, y, tIconSize, tIconSize)
	draw.NoTexture()
	self.cl_NeededFruits = {}
	-- Here we are gonna show what ingrediens are needed
	self:util_Add_NeedFruits("zfs_melon", selectedItem.recipe["zfs_melon"])
	self:util_Add_NeedFruits("zfs_banana", selectedItem.recipe["zfs_banana"])
	self:util_Add_NeedFruits("zfs_coconut", selectedItem.recipe["zfs_coconut"])
	self:util_Add_NeedFruits("zfs_pomegranate", selectedItem.recipe["zfs_pomegranate"])
	self:util_Add_NeedFruits("zfs_strawberry", selectedItem.recipe["zfs_strawberry"])
	self:util_Add_NeedFruits("zfs_kiwi", selectedItem.recipe["zfs_kiwi"])
	self:util_Add_NeedFruits("zfs_lemon", selectedItem.recipe["zfs_lemon"])
	self:util_Add_NeedFruits("zfs_orange", selectedItem.recipe["zfs_orange"])
	self:util_Add_NeedFruits("zfs_apple", selectedItem.recipe["zfs_apple"])
	draw.DrawText(zfs.language.Shop.Screen_Product_Ingrediens, "zfs_ProductInfo", -ScreenW * 0.45, -ScreenH * 0.04, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	local ingrediensBoxX, ingrediensBoxY = -ScreenW * 0.53, ScreenH * 0.02
	local ingrediensSize = 30
	local needFruitsCount = {}
	needFruitsCount["zfs_melon"] = 0
	needFruitsCount["zfs_banana"] = 0
	needFruitsCount["zfs_coconut"] = 0
	needFruitsCount["zfs_pomegranate"] = 0
	needFruitsCount["zfs_strawberry"] = 0
	needFruitsCount["zfs_kiwi"] = 0
	needFruitsCount["zfs_lemon"] = 0
	needFruitsCount["zfs_orange"] = 0
	needFruitsCount["zfs_apple"] = 0

	if (self.StoredFruits ~= nil) then
		for i, k in pairs(self.cl_NeededFruits) do
			needFruitsCount[k] = needFruitsCount[k] + 1
			local ax, ay = self:Calc_NextLine(11, i, ingrediensSize, 2, ingrediensBoxX, ingrediensBoxY)
			local iconBG_Color01

			if (self.StoredFruits[k] == nil) then
				iconBG_Color01 = Color(175, 50, 50)
			elseif (needFruitsCount[k] > self.StoredFruits[k]) then
				iconBG_Color01 = Color(175, 50, 50)
			else
				iconBG_Color01 = zfs.config.Item_BG
			end

			surface.SetDrawColor(iconBG_Color01)
			surface.SetMaterial(productBG)
			surface.DrawTexturedRect(ax, ay, ingrediensSize, ingrediensSize)
			draw.NoTexture()
			surface.SetDrawColor(Color(255, 255, 255))
			surface.SetMaterial(IngrediensIcons[k])
			surface.DrawTexturedRect(ax, ay, ingrediensSize, ingrediensSize)
			draw.NoTexture()
		end
	end
end

-- Adds the amount of fruits in our Needed Fruits Table
function ENT:util_Add_NeedFruits(fruit, amount)
	for i = 1, amount do
		table.insert(self.cl_NeededFruits, fruit)
	end
end

-- This displays the ToppingSelection
function ENT:ui_ToppingSelection()
	for i, k in pairs(zfs.utility.SortedToppingsTable) do
		local x, y = self:Calc_NextLine(7, i, iconSize, margin, productBoxX, productBoxY)
		-- This Sets the BG Color of the bg icon
		local iconBG_Color

		if (table.Count(k.UlxGroup_create) > 0) then
			iconBG_Color = zfs.config.Restricted_Topping_BG
		else
			iconBG_Color = zfs.config.Item_BG
		end

		local h, s, v = ColorToHSV(Color(iconBG_Color.r, iconBG_Color.g, iconBG_Color.b))

		-- This changes the item Color if we hover
		if (self:HoverOverButton(self:CalcElementPos(x, y, Vector(25, 25, -10)))) then
			iconBG_Color = HSVToColor(h, s, v + 0.15)
			--self.lastHitItem = i
		else
			iconBG_Color = HSVToColor(h, s, v - 0.15)
		end

		surface.SetDrawColor(iconBG_Color)
		surface.SetMaterial(productBG)
		surface.DrawTexturedRect(x, y, iconSize, iconSize)
		draw.NoTexture()

		if (i == 1) then
			surface.SetDrawColor(Color(255, 0, 0))
			surface.SetMaterial(Material(k.Icon))
			surface.DrawTexturedRect(x, y, iconSize, iconSize)
			draw.NoTexture()
		else
			if (k.Icon ~= nil) then
				surface.SetDrawColor(Color(255, 255, 255))
				surface.SetMaterial(Material(k.Icon))
				surface.DrawTexturedRect(x, y, iconSize, iconSize)
				draw.NoTexture()
			end
		end

		-- This enables the hover element
		if (self:HoverOverButton(self:CalcElementPos(x, y, Vector(25, 25, -10)))) then
			surface.SetDrawColor(Color(125, 255, 125))
			surface.SetMaterial(productHover)
			surface.DrawTexturedRect(x, y, iconSize, iconSize)
			draw.NoTexture()
		end
	end
end

-- This ask´s us if we are happy with our topping selection
function ENT:ui_ToppingConfirmation()
	local selectedTopping = zfs.utility.SortedToppingsTable[self:GetTSelectedTopping()]
	local iconBG_Color

	if (table.Count(selectedTopping.UlxGroup_create) > 0) then
		iconBG_Color = zfs.config.Restricted_Topping_BG
	else
		iconBG_Color = zfs.config.Item_BG
	end

	local buttonYesColor

	if (self:CalcWorldElementPos(-12, -23, 17.5, 16.5)) then
		local h, s, v = ColorToHSV(ButtonYes)
		buttonYesColor = HSVToColor(h, s, v)
	else
		local h, s, v = ColorToHSV(ButtonYes)
		buttonYesColor = HSVToColor(h, s, v - 0.3)
	end

	local buttonNoColor

	if (self:CalcWorldElementPos(-25, -36, 17.5, 16.5)) then
		local h, s, v = ColorToHSV(ButtonNo)
		buttonNoColor = HSVToColor(h, s, v)
	else
		local h, s, v = ColorToHSV(ButtonNo)
		buttonNoColor = HSVToColor(h, s, v - 0.3)
	end

	--Buttons
	draw.RoundedBox(7, -ScreenW * 0.45, ScreenH * 0.25, ScreenW * 0.4, ScreenH * 0.2, buttonYesColor)
	draw.DrawText(zfs.language.Shop.Screen_Confirm_Yes, "zfs_buttonfont01", -ScreenW * 0.25, ScreenH * 0.28, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	draw.RoundedBox(7, ScreenW * 0.05, ScreenH * 0.25, ScreenW * 0.4, ScreenH * 0.2, buttonNoColor)
	draw.DrawText(zfs.language.Shop.Screen_Confirm_No, "zfs_buttonfont01", ScreenW * 0.25, ScreenH * 0.28, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	local x = -ScreenW * 0.45
	local y = -ScreenH * 0.346
	local tIconSize = iconSize * 1.5
	local bIconSize = iconSize * 0.46
	-- Benefits
	draw.RoundedBox(0, ScreenW * 0.267, -ScreenH * 0.345, ScreenW * 0.2, ScreenH * 0.567, Color(75, 75, 75))

	-- Adds all benefit items to our list
	if (table.Count(selectedTopping.ToppingBenefits) > 0) then
		local pos = 0
		local yPos = -ScreenH * 0.33
		local itemMargin = 5

		for k, v in pairs(selectedTopping.ToppingBenefits) do
			draw.RoundedBox(0, ScreenW * 0.279, yPos + pos, ScreenW * 0.18, ScreenH * 0.09, Color(100, 100, 100))
			local bInfo
			local bInfo_color = Color(255, 255, 255, 255)
			local bInfo_align = TEXT_ALIGN_CENTER
			local bInfo_posX = ScreenW * 0.4
			local bInfo_posy = yPos + pos

			if (k == "Health") then
				bInfo = "+" .. tostring(v)

				draw.Text({
					text = bInfo,
					pos = {bInfo_posX, bInfo_posy + 13},
					font = "zfs_BenefitsInfofont01",
					xalign = bInfo_align,
					yalign = bInfo_align,
					color = bInfo_color
				})
			elseif (k == "ParticleEffect") then
				bInfo = "Effect"
				draw.DrawText(bInfo, "zfs_BenefitsInfofont01", bInfo_posX, bInfo_posy + 5, bInfo_color, bInfo_align)
			elseif (k == "SpeedBoost") then
				bInfo = "+" .. tostring(v)

				draw.Text({
					text = bInfo,
					pos = {bInfo_posX, bInfo_posy + 13},
					font = "zfs_BenefitsInfofont01",
					xalign = bInfo_align,
					yalign = bInfo_align,
					color = bInfo_color
				})
			elseif (k == "AntiGravity") then
				bInfo = "+" .. tostring(v)

				draw.Text({
					text = bInfo,
					pos = {bInfo_posX, bInfo_posy + 13},
					font = "zfs_BenefitsInfofont01",
					xalign = bInfo_align,
					yalign = bInfo_align,
					color = bInfo_color
				})
			elseif (k == "Ghost") then
				bInfo = "(" .. tostring(v) .. "/255)"

				draw.Text({
					text = bInfo,
					pos = {bInfo_posX, bInfo_posy + 13},
					font = "zfs_BenefitsInfofont01",
					xalign = bInfo_align,
					yalign = bInfo_align,
					color = bInfo_color
				})
			elseif (k == "Drugs") then
				bInfo = tostring(v)

				draw.Text({
					text = bInfo,
					pos = {bInfo_posX, bInfo_posy + 13},
					font = "zfs_BenefitsInfofont01",
					xalign = bInfo_align,
					yalign = bInfo_align,
					color = bInfo_color
				})
			end

			surface.SetMaterial(Material(zfs.utility.BenefitsIcons[k], "smooth"))
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(x + ScreenW * 0.73, yPos + pos, bIconSize, bIconSize)
			draw.NoTexture()
			pos = pos + bIconSize + itemMargin
		end
	end

	if (selectedTopping.ToppingBenefit_Duration > 0) then
		local duration = tostring(selectedTopping.ToppingBenefit_Duration) .. "s"
		draw.DrawText(duration, "zfs_ProductDuration", ScreenW * 0.25, -ScreenH * 0.34, Color(0, 165, 213, 255), TEXT_ALIGN_RIGHT)
	end

	draw.DrawText(tostring(selectedTopping.Name), "zfs_ProductTitle", -ScreenW * 0.25, -ScreenH * 0.35, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	draw.DrawText(tostring(selectedTopping.Info), "zfs_ToppingInfo", -ScreenW * 0.25, -ScreenH * 0.175, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	--draw.RoundedBox( 0, -ScreenW*0.247, -ScreenH*0.343, ScreenW*0.495, 1,  Color(150,150,150) )
	--draw.RoundedBox( 0, -ScreenW*0.247, -ScreenH*0.26, ScreenW*0.495, 1,  Color(150,150,150) )
	draw.RoundedBox(0, -ScreenW * 0.247, -ScreenH * 0.19, ScreenW * 0.495, 1, Color(150, 150, 150))
	draw.RoundedBox(0, -ScreenW * 0.247, -ScreenH * 0.06, ScreenW * 0.495, 1, Color(150, 150, 150))
	draw.DrawText(zfs.language.Shop.Screen_Topping_Price, "zfs_ProductPrice", -ScreenW * 0.25, -ScreenH * 0.25, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	draw.DrawText("+" .. tostring(selectedTopping.ExtraPrice) .. zfs.config.Currency, "zfs_ProductPrice", ScreenW * 0.25, -ScreenH * 0.25, Color(0, 200, 0, 255), TEXT_ALIGN_RIGHT)
	surface.SetDrawColor(iconBG_Color)
	surface.SetMaterial(productBG)
	surface.DrawTexturedRect(x, y, tIconSize, tIconSize)
	draw.NoTexture()

	-- This renders our Cancel Icon
	if (self:GetTSelectedTopping() == 1) then
		surface.SetDrawColor(Color(255, 0, 0))
		surface.SetMaterial(Material(selectedTopping.Icon))
		surface.DrawTexturedRect(x, y, tIconSize, tIconSize)
		draw.NoTexture()
	end

	--Acces Information
	draw.RoundedBox(0, -ScreenW * 0.45, -ScreenH * 0.03, ScreenW * 0.7, ScreenH * 0.25, Color(75, 75, 75))
	local allowedGroups

	-- Checks the selected Topping is creation exlusive for a ulx Group
	if (table.Count(selectedTopping.UlxGroup_create) > 0) then
		allowedGroups = table.ToString(zfs.f.CreateAllowList(selectedTopping.UlxGroup_create), nil, false)
	else
		allowedGroups = zfs.language.Shop.Screen_Topping_NoRestricted
	end

	draw.DrawText(zfs.language.Shop.Screen_Topping_Add_Restricted, "zfs_AcessInfofont01", -ScreenW * 0.44, -ScreenH * 0.02, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	draw.DrawText(allowedGroups, "zfs_AcessInfofont02", -ScreenW * 0.44, ScreenH * 0.03, zfs.config.Restricted_Topping_BG, TEXT_ALIGN_LEFT)
	local allowedGroupsConsume
	local allowedJobsConsume

	-- Checks the selected Topping is consumbtion exlusive for a ulx Group or job
	if (table.Count(selectedTopping.UlxGroup_consume) > 0 or table.Count(selectedTopping.Job_consume) > 0) then
		allowedGroupsConsume = table.ToString(zfs.f.CreateAllowList(selectedTopping.UlxGroup_consume), nil, false)
		allowedJobsConsume = table.ToString(zfs.f.CreateAllowList(selectedTopping.Job_consume), nil, false)
	else
		allowedGroupsConsume = zfs.language.Shop.Screen_Topping_NoRestricted
		allowedJobsConsume = " "
	end

	draw.DrawText(zfs.language.Shop.Screen_Topping_Consum_Restricted, "zfs_AcessInfofont01", -ScreenW * 0.44, ScreenH * 0.1, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
	draw.DrawText(allowedGroupsConsume .. " " .. allowedJobsConsume, "zfs_AcessInfofont02", -ScreenW * 0.44, ScreenH * 0.15, zfs.config.Restricted_Topping_BG, TEXT_ALIGN_LEFT)
end

-- This gives us the World position of the UI element relativ too the root bone
function ENT:CalcWorldElementPos(xStart, xEnd, yStart, yEnd)
	local trace = LocalPlayer():GetEyeTrace().HitPos
	local tracePos = self:WorldToLocal(trace)

	if tracePos.x < xStart and tracePos.x > xEnd and tracePos.y < yStart and tracePos.y > yEnd then
		return true
	else
		return false
	end
end

-- This gives us the World position of the UI element relativ too the Screen
function ENT:CalcElementPos(x, y, size)
	local attach = self:GetAttachment(self:LookupAttachment("screen"))
	local AttaPos = attach.Pos
	local AttaAng = attach.Ang
	AttaAng:RotateAroundAxis(AttaAng:Up(), -90)
	AttaAng:RotateAroundAxis(AttaAng:Right(), 180)
	local newVec = Vector(x, y, 1)
	newVec:Add(size)
	newVec:Mul(0.07)
	local wpos = LocalToWorld(newVec, Angle(0, 0, 0), AttaPos, AttaAng)

	return wpos
end

--This finds the nearerst item
function ENT:CalcNearestItem(wpos, key)
	local trace = LocalPlayer():GetEyeTrace()
	local currentdiff = wpos:Distance(trace.HitPos)

	if (currentdiff < self.initialdiff) then
		self.initialdiff = currentdiff
		self.nearestItem = key
	end
	-- selectedkey now holds key for closest match
	-- values[selectedkey] gives you the (first) closest value
end

-- This Calculates if we Hover over a Item
function ENT:HoverOverButton(wpos)
	local trace = LocalPlayer():GetEyeTrace()

	if (trace.HitPos:Distance(wpos) < 1.8) then
		return true
	else
		return false
	end
end

-- This Calculates the position for each item in the fruitcups config list
function ENT:Calc_NextLine(rowCount, itemCount, aiconSize, amargin, aproductBoxX, aproductBoxY)
	local ypos = 0
	local xpos = 0

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

-- This creates the DynamicLight
function ENT:Lights()
	if (self:GetCurrentState() ~= "DISABLED") then
		local dlight = DynamicLight(LocalPlayer():EntIndex())

		if (dlight) then
			dlight.pos = self:GetAttachment(self:LookupAttachment("workplace")).Pos + self:GetUp() * 30
			dlight.r = 255
			dlight.g = 8
			dlight.b = 60
			dlight.brightness = 1
			dlight.Decay = 1000
			dlight.Size = 256
			dlight.DieTime = CurTime() + 1
		end
	end
end

-- This creates the frezzing effect
function ENT:FrozzeEffect()
	if ((self.lastFrozze or CurTime()) > CurTime()) then return end
	self.lastFrozze = CurTime() + 2

	if (IsValid(self) and self:GetCurrentState() ~= "DISABLED" and nil) then
		local attach = self:GetAttachment(9)

		if (attach) then
			local attachPos = attach.Pos

			if (attachPos) then
				local ang = self:GetAngles()
				local pos = attachPos + self:GetUp() * 36
				ParticleEffect("zfs_frozen_effect", pos, ang, self)
			end
		end
	end
end

function ENT:SweetenerFillSound()
	if (self:GetCurrentState() == "FILLING_SWEETENER") then
		local SweetenerFillSound = CreateSound(self, "zfs_sfx_sweetener")

		if self.SoundObj == nil then
			self.SoundObj = SweetenerFillSound
		end

		if self.SoundObj:IsPlaying() == false then
			self.SoundObj:Play()
			self.SoundObj:ChangeVolume(0, 0)
			self.SoundObj:ChangeVolume(0.5, 1)

			timer.Simple(4.1, function()
				if (IsValid(self)) then
					self.SoundObj:Stop()
				end
			end)
		end
	end
end

-- Animation
function ENT:Think()
	self:Lights()
	self:FrozzeEffect()
	self:SweetenerFillSound()
	self:SetNextClientThink(CurTime())

	return true
end

-- Debug
net.Receive("zfs_Debug", function(len, ply)
	local pos = net.ReadVector()
	local size = Vector(25, 25, 25)
	size:Mul(0.07)
	debugoverlay.Sphere(pos, 1, 15, Color(255, 0, 0), true)
end)
