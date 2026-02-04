if not CLIENT then return end
local scale = 1.3
local wMod = (ScrW() / 1920) * scale
local hMod = (ScrH() / 1080) * scale
local ZFS_SellMenu = {}
local zfl_material_main = Material("materials/zfruitslicer/ui/zfs_ui_sellbox_main.png", "smooth")
local zfl_material_main_indicator = Material("materials/zfruitslicer/ui/zfs_ui_sellbox_indicator.png", "smooth")
local zfl_material_bBuy = Material("materials/zfruitslicer/ui/zfs_ui_sellbox_button.png", "smooth")
local zfl_material_bClose = Material("materials/zfruitslicer/ui/zfs_ui_sellbox_close.png", "smooth")
local zfl_material_HealthBar = Material("materials/zfruitslicer/ui/fs_ui_bar.png", "smooth")

function ZFS_SellMenu:Init()
	self:SetSize(1400 * wMod, 800 * hMod)
	self:Center()
	self:MakePopup()
	local product = zfs.config.FruitCups[LocalPlayer().zfs_SelectedItem]
	local topping = zfs.config.Toppings[LocalPlayer().zfs_SelectedTopping]
	local price = LocalPlayer().zfs_Price
	zfsmain = {}
	zfsmain.indicator = vgui.Create("DImage", self)
	zfsmain.indicator:SetSize(1400 * wMod, 800 * hMod)
	zfsmain.indicator:SetPos(0 * wMod, 0 * hMod)
	zfsmain.indicator:SetMaterial(zfl_material_main_indicator)
	local indicatorColor = Color(product.fruitColor.r, product.fruitColor.g, product.fruitColor.b, 255)
	local h = ColorToHSV(indicatorColor)
	indicatorColor = HSVToColor(h, 0.7, 0.9)
	zfsmain.indicator:SetImageColor(indicatorColor)

	zfsmain.cap = vgui.Create("DImage", self)
	zfsmain.cap:SetSize(1400 * wMod, 800 * hMod)
	zfsmain.cap:SetPos(0 * wMod, 0 * hMod)
	zfsmain.cap:SetImage("materials/zfruitslicer/ui/zfs_ui_sellbox_cap.png")
	zfsmain.close = vgui.Create("DButton", self)
	zfsmain.close:SetText("")
	zfsmain.close:SetPos(910 * wMod, 230 * hMod)
	zfsmain.close:SetSize(50 * wMod, 50 * hMod)

	zfsmain.close.DoClick = function()
		self:SetVisible(false)
		net.Start("zfs_ItemBuyUpdate_cl")
		local tableinfo = {}
		tableinfo.ID = LocalPlayer().zfs_SelectedItem
		tableinfo.ItemEntIndex = LocalPlayer().zfs_ItemEntIndex
		tableinfo.WantsToBuy = false
		tableinfo.Price = LocalPlayer().zfs_Price
		net.WriteTable(tableinfo)
		net.SendToServer()
	end

	zfsmain.close.Paint = function(s, w, h)
		if zfsmain.close:IsHovered() then
			surface.SetDrawColor(255, 110, 102, 255)
		else
			surface.SetDrawColor(239, 64, 54, 255)
		end

		surface.SetMaterial(zfl_material_bClose)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zfsmain.purchase = vgui.Create("DButton", self)
	zfsmain.purchase:SetText(zfs.language.Shop.Item_PurchaseButton)
	zfsmain.purchase:SetTextColor(Color(255, 255, 255))
	zfsmain.purchase:SetFont("zfs_VGUIButtonfont01")
	zfsmain.purchase:SetPos(501 * wMod, 600 * hMod)
	zfsmain.purchase:SetSize(175 * wMod, 50 * hMod)

	zfsmain.purchase.DoClick = function()
		local tableinfo = {}
		tableinfo.ID = LocalPlayer().zfs_SelectedItem
		tableinfo.ItemEntIndex = LocalPlayer().zfs_ItemEntIndex
		tableinfo.Price = price
		tableinfo.ToppingID = LocalPlayer().zfs_SelectedTopping
		tableinfo.WantsToBuy = true
		-- This Sends the purchase request to the Server
		net.Start("zfs_ItemBuyUpdate_cl")
		net.WriteTable(tableinfo)
		net.SendToServer()
	end

	zfsmain.purchase.Paint = function(s, w, h)
		if zfsmain.purchase:IsHovered() then
			surface.SetDrawColor(155, 206, 160, 255)
		else
			surface.SetDrawColor(57, 181, 75, 255)
		end

		surface.SetMaterial(zfl_material_bBuy)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zfsmain.icon = vgui.Create("DImage", self)
	zfsmain.icon:SetSize(130 * wMod, 130 * hMod)
	zfsmain.icon:SetPos(515 * wMod, 107 * hMod)
	zfsmain.icon:SetImage(product.Icon)

	zfsmain.itemName = vgui.Create("DLabel", self)
	zfsmain.itemName:SetPos(460 * wMod, 225 * hMod)
	zfsmain.itemName:SetSize(400 * wMod, 100 * hMod)
	zfsmain.itemName:SetFont("zfs_VGUIfont03")
	zfsmain.itemName:SetText(product.Name)
	zfsmain.itemName:SetTextColor(indicatorColor)

	zfsmain.priceValue = vgui.Create("DLabel", self)
	zfsmain.priceValue:SetPos(470 * wMod, 263 * hMod)
	zfsmain.priceValue:SetSize(200 * wMod, 100 * hMod)
	zfsmain.priceValue:SetFont("zfs_VGUIfont01")
	zfsmain.priceValue:SetText(tostring(price) .. zfs.config.Currency)
	zfsmain.priceValue:SetTextColor(Color(141, 198, 63))

	zfsmain.healthBar = vgui.Create("DImage", self)
	zfsmain.healthBar:SetPos(470 * wMod, 345 * hMod)
	zfsmain.healthBar:SetSize(225 * wMod, 30 * hMod)
	zfsmain.healthBar.Paint = function(s, w, h)
		surface.SetDrawColor(0, 0, 0, 125)
		surface.SetMaterial(zfl_material_HealthBar)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	zfsmain.healthText = vgui.Create("DLabel", self)
	zfsmain.healthText:SetPos(480 * wMod, 311 * hMod)
	zfsmain.healthText:SetSize(200 * wMod, 100 * hMod)
	zfsmain.healthText:SetFont("zfs_VGUIfont01")
	zfsmain.healthText:SetText(zfs.language.VGUI.HealthBoni)
	zfsmain.healthText:SetTextColor(Color(25, 25, 25))

	-- This gives the player the Default Health of the Fruitcup
	local extraHealth = 25 + zfs.config.Max_HealthReward * zfs.f.CalculateFruitVarationBoni(zfs.config.FruitCups[LocalPlayer().zfs_SelectedItem])
	extraHealth = math.Clamp(extraHealth, 0, zfs.config.Max_HealthReward)
	extraHealth = math.Round(extraHealth)
	zfsmain.healthValue = vgui.Create("DLabel", self)
	zfsmain.healthValue:SetPos(645 * wMod, 311 * hMod)
	zfsmain.healthValue:SetSize(200 * wMod, 100 * hMod)
	zfsmain.healthValue:SetFont("zfs_VGUIfont01")
	zfsmain.healthValue:SetText("+" .. tostring(extraHealth))
	zfsmain.healthValue:SetTextColor(Color(255, 255, 255))

	local descriptionColor = Color(product.fruitColor.r, product.fruitColor.g, product.fruitColor.b, 255)
	local ih = ColorToHSV(descriptionColor)
	descriptionColor = HSVToColor(ih, 0, 0.2)
	zfsmain.description = vgui.Create("DLabel", self)
	zfsmain.description:SetPos(480 * wMod, 465 * hMod)
	zfsmain.description:SetSize(225 * wMod, 400 * hMod)
	zfsmain.description:SetFont("zfs_VGUIfont02")
	zfsmain.description:SetColor(descriptionColor)
	zfsmain.description:SetText(product.Info)
	zfsmain.description:SetWrap(true)
	zfsmain.description:SetAutoStretchVertical(true)

	zfsmain.Topping_Name = vgui.Create("DLabel", self)
	zfsmain.Topping_Name:SetPos(835 * wMod, 345 * hMod)
	zfsmain.Topping_Name:SetSize(200 * wMod, 100 * hMod)
	zfsmain.Topping_Name:SetFont("zfs_VGUIfont01")
	zfsmain.Topping_Name:SetText(tostring(topping.Name))
	zfsmain.Topping_Name:SetTextColor(Color(57, 95, 178))

	local toppingInfo = string.Replace(tostring(topping.Info), "\n", "  ")
	zfsmain.Topping_Desc = vgui.Create("DLabel", self)
	zfsmain.Topping_Desc:SetPos(835 * wMod, 375 * hMod)
	zfsmain.Topping_Desc:SetSize(130 * wMod, 100 * hMod)
	zfsmain.Topping_Desc:SetFont("zfs_VGUI_Desc")
	zfsmain.Topping_Desc:SetText(toppingInfo)
	zfsmain.Topping_Desc:SetTextColor(Color(25, 25, 25))
	zfsmain.Topping_Desc:SetWrap(true)

	-- Only create the Topping Model snapshot and Benefits List if the Selected topping item from the table is not 1 aka No Topping
	if (LocalPlayer().zfs_SelectedTopping ~= 1) then
		zfsmain.Topping_Icon = vgui.Create("SpawnIcon", self)
		zfsmain.Topping_Icon:SetSize(60 * wMod, 60 * hMod)
		zfsmain.Topping_Icon:SetPos(770 * wMod, 378 * hMod)
		zfsmain.Topping_Icon:SetModel(topping.Model)
		zfsmain.Benefitspanel = vgui.Create("Panel", self)
		zfsmain.Benefitspanel:SetPos(754 * wMod, 439 * hMod)
		zfsmain.Benefitspanel:SetSize(210 * wMod, 180 * hMod)

		zfsmain.Benefitspanel.Paint = function(s, w, h)
			surface.SetDrawColor(75, 75, 75, 0)
			surface.DrawRect(0, 0, w, h)
		end

		ZFS_SellMenu_Benefits(zfsmain.Benefitspanel, 1, topping)
	else
		zfsmain.Topping_Icon = vgui.Create("DImage", self)
		zfsmain.Topping_Icon:SetSize(60 * wMod, 60 * hMod)
		zfsmain.Topping_Icon:SetPos(770 * wMod, 378 * hMod)
		zfsmain.Topping_Icon:SetImage("materials/zfruitslicer/ui/zfs_ui_nothing.png")
		zfsmain.Topping_Icon:SetImageColor(Color(255, 25, 25))
	end
end

function ZFS_SellMenu_Benefits(parent, content, topping)
	zfsBenefits = {}
	zfsBenefits.panel = vgui.Create("DScrollPanel", parent)
	zfsBenefits.panel:SetSize(210 * wMod, 180 * hMod)
	zfsBenefits.panel:DockMargin(10 * wMod, 4 * hMod, 10 * wMod, 10 * hMod)
	zfsBenefits.panel:Dock(FILL)

	zfsBenefits.panel.Paint = function(self, w, h)
		surface.SetDrawColor(75, 75, 75, 0)
		surface.DrawRect(0, 0, w, h)
	end

	zfsBenefits.panel:GetVBar().Paint = function() return true end
	zfsBenefits.panel:GetVBar().btnUp.Paint = function() return true end
	zfsBenefits.panel:GetVBar().btnDown.Paint = function() return true end
	zfsBenefits.panel:GetVBar().btnGrip.Paint = function() return true end
	zfsBenefits.list = vgui.Create("DIconLayout", zfsBenefits.panel)
	zfsBenefits.list:SetSize(210 * wMod, 180 * hMod)
	zfsBenefits.list:SetPos(0 * wMod, 0 * hMod)
	zfsBenefits.list:SetSpaceY(3 * hMod)
	local itemPaddingX = 15 * wMod

	if topping.ToppingBenefits ~= nil then
		for k, v in pairs(topping.ToppingBenefits) do

			zfsBenefits[k] = zfsBenefits.list:Add("DPanel")
			zfsBenefits[k]:SetSize(zfsBenefits.list:GetWide(), 30 * hMod)

			zfsBenefits[k].Paint = function(self, w, h)
				surface.SetDrawColor(0, 0, 0, 0)
				surface.DrawRect(0, 0, w, h)
			end

			zfsBenefits[k].iconBG = vgui.Create("DImage", zfsBenefits[k])
			zfsBenefits[k].iconBG:SetSize(32 * wMod, 32 * hMod)
			zfsBenefits[k].iconBG:SetPos((itemPaddingX - 1) * wMod, -1 * hMod)
			zfsBenefits[k].iconBG:SetImage("materials/zfruitslicer/ui/zfs_ui_toppingbg.png")
			zfsBenefits[k].iconBG:SetImageColor(Color(255, 255, 255, 75))

			zfsBenefits[k].icon = vgui.Create("DImage", zfsBenefits[k])
			zfsBenefits[k].icon:SetSize(29 * wMod, 29 * hMod)
			zfsBenefits[k].icon:SetPos((itemPaddingX + 0.1) * wMod, 1 * hMod)
			zfsBenefits[k].icon:SetImage(zfs.utility.BenefitsIcons[k])

			zfsBenefits[k].BName = vgui.Create("DLabel", zfsBenefits[k])
			zfsBenefits[k].BName:SetSize(100 * wMod, 35 * hMod)
			zfsBenefits[k].BName:SetPos((itemPaddingX + 35) * wMod, -8 * hMod)
			zfsBenefits[k].BName:SetFont("zfs_VGUIBenefitFont01")
			zfsBenefits[k].BName:SetText(tostring(k))
			zfsBenefits[k].BName:SetTextColor(Color(0, 0, 0))
			local bInfo

			if (k == "Health") then
				bInfo = "+" .. tostring(v)
			elseif (k == "ParticleEffect") then
				bInfo = tostring(v)
			elseif (k == "SpeedBoost") then
				bInfo = "+" .. tostring(v)
			elseif (k == "AntiGravity") then
				bInfo = "+" .. tostring(v)
			elseif (k == "Ghost") then
				bInfo = "(" .. tostring(v) .. "/255)"
			elseif (k == "Drugs") then
				bInfo = tostring(v)
			end

			zfsBenefits[k].BValue = vgui.Create("DLabel", zfsBenefits[k])
			zfsBenefits[k].BValue:SetSize(100 * wMod, 35 * hMod)
			zfsBenefits[k].BValue:SetPos((itemPaddingX + 35) * wMod, 7 * hMod)
			zfsBenefits[k].BValue:SetFont("zfs_VGUIBenefitFont02")
			zfsBenefits[k].BValue:SetText(tostring(bInfo))
			zfsBenefits[k].BValue:SetTextColor(Color(25, 150, 25))
		end
	end
end

function ZFS_SellMenu:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(zfl_material_main)
	surface.DrawTexturedRect(0 * wMod, 0 * hMod, w, h)
end

vgui.Register("ZEROSFS_ItemBuy", ZFS_SellMenu, "Panel")

net.Receive("zfs_ItemBuy_net", function(len)
	local tableinfo = net.ReadTable()
	LocalPlayer().zfs_SelectedItem = tableinfo.ProductID
	LocalPlayer().zfs_SelectedTopping = tableinfo.ToppingID
	LocalPlayer().zfs_Price = tableinfo.Price
	LocalPlayer().zfs_ItemEntIndex = tableinfo.ItemEntIndex

	-- I remove the old panel instead of enable its visibility since updating
	-- all the informations would be the same as creating it from scratch
	if IsValid(ZFS_SellMenu_PANEL) then
		ZFS_SellMenu_PANEL:Remove()
	end

	ZFS_SellMenu_PANEL = vgui.Create("ZEROSFS_ItemBuy")
end)

net.Receive("zfs_ItemSellWindowClose_sv", function(len)
	if IsValid(ZFS_SellMenu_PANEL) then
		ZFS_SellMenu_PANEL:SetVisible(false)
	end
end)

--Change Price VGUI
local ZFS_PriceChanger = {}
local zfl_material_field = Material("materials/zfruitslicer/ui/zfs_ui_changeprice.png")

function ZFS_PriceChanger:Init()
	self:SetSize(600 * wMod, 200 * hMod)
	self:Center()
	self:MakePopup()
	zfsChangePanel = {}
	zfsChangePanel.close = vgui.Create("DButton", self)
	zfsChangePanel.close:SetText(zfs.language.Shop.ChangePrice_Cancel)
	zfsChangePanel.close:SetTextColor(Color(255, 255, 255))
	zfsChangePanel.close:SetFont("zfs_ChangePriceButtonFont01")
	zfsChangePanel.close:SetPos(503.5 * wMod, 0.8 * hMod)
	zfsChangePanel.close:SetSize(99 * wMod, 26.8 * hMod)

	zfsChangePanel.close.DoClick = function()
		if IsValid(self) then
			self:SetVisible(false)
		end
	end

	zfsChangePanel.close.Paint = function(self, w, h)
		if zfsChangePanel.close:IsHovered() then
			surface.SetDrawColor(255, 255, 255, 100)
		else
			surface.SetDrawColor(0, 0, 0, 0)
		end

		surface.DrawRect(0, 0, w, h)
	end

	zfsChangePanel.PriceField = vgui.Create("DTextEntry", self) -- create the form as a child of frame
	zfsChangePanel.PriceField:SetPos(142 * wMod, 88 * hMod)
	zfsChangePanel.PriceField:SetSize(320 * wMod, 50 * hMod)
	zfsChangePanel.PriceField:SetNumeric(true)
	zfsChangePanel.PriceField:SetFont("zfs_TextFieldFont01")
	zfsChangePanel.PriceField:SetTextColor(Color(148, 167, 142, 255))

	zfsChangePanel.PriceField.OnChange = function(self)
		inputVal = self:GetValue()
	end

	zfsChangePanel.symbol01 = vgui.Create("DLabel", self)
	zfsChangePanel.symbol01:SetPos(38 * wMod, 60 * hMod)
	zfsChangePanel.symbol01:SetSize(100 * wMod, 200 * hMod)
	zfsChangePanel.symbol01:SetFont("zfs_SymboldFont01")
	zfsChangePanel.symbol01:SetColor(Color(230, 236, 202))
	zfsChangePanel.symbol01:SetText(zfs.config.Currency)
	zfsChangePanel.symbol01:SetAutoStretchVertical(true)
	zfsChangePanel.symbol02 = vgui.Create("DLabel", self)
	zfsChangePanel.symbol02:SetPos(500 * wMod, 60 * hMod)
	zfsChangePanel.symbol02:SetSize(100 * wMod, 200 * hMod)
	zfsChangePanel.symbol02:SetFont("zfs_SymboldFont01")
	zfsChangePanel.symbol02:SetColor(Color(230, 236, 202))
	zfsChangePanel.symbol02:SetText(zfs.config.Currency)
	zfsChangePanel.symbol02:SetAutoStretchVertical(true)
	zfsChangePanel.ChangePrice = vgui.Create("DButton", self)
	zfsChangePanel.ChangePrice:SetText(zfs.language.Shop.ChangePrice_Confirm)
	zfsChangePanel.ChangePrice:SetTextColor(Color(255, 255, 255))
	zfsChangePanel.ChangePrice:SetFont("zfs_ChangePriceButtonFont01")
	zfsChangePanel.ChangePrice:SetPos(0 * wMod, 0 * hMod)
	zfsChangePanel.ChangePrice:SetSize(107 * wMod, 27 * hMod)

	zfsChangePanel.ChangePrice.DoClick = function()
		if (inputVal ~= nil) then
			net.Start("zfs_ItemPriceChange_sv")
			local PriceChangeInfo = {}
			PriceChangeInfo.ChangedPrice = tonumber(inputVal)
			PriceChangeInfo.Shop = LocalPlayer().zfs_Shop
			net.WriteTable(PriceChangeInfo)
			net.SendToServer()
			self:SetVisible(false)
		end
	end

	zfsChangePanel.ChangePrice.Paint = function(self, w, h)
		if zfsChangePanel.ChangePrice:IsHovered() then
			surface.SetDrawColor(255, 255, 255, 100)
		else
			surface.SetDrawColor(0, 0, 0, 0)
		end

		surface.DrawRect(0, 0, w, h)
	end
end

function ZFS_PriceChanger:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(zfl_material_field)
	surface.DrawTexturedRect(0, 0, w, h)
end

function ZFS_PriceChanger:UpdateInfo()
	local product_ConfigID = zfs.config.FruitCups[LocalPlayer().zfs_SelectedItem]
	local CustomPrice = LocalPlayer().zfs_Price
	local visualPrice

	if (CustomPrice < zfs.config.PriceMinimum or CustomPrice > zfs.config.PriceMaximum) then
		visualPrice = product_ConfigID.Price
	else
		visualPrice = LocalPlayer().zfs_Price
	end

	return visualPrice
end

vgui.Register("ZEROSFS_price_ItemBuy", ZFS_PriceChanger, "EditablePanel")

net.Receive("zfs_ItemPriceChange_cl", function(len)
	local customPriceInfo = net.ReadTable()
	LocalPlayer().zfs_Price = customPriceInfo.Price
	LocalPlayer().zfs_SelectedItem = customPriceInfo.selectedItem
	LocalPlayer().zfs_Shop = customPriceInfo.Shop

	if IsValid(ZFS_PriceChanger_PANEL) then
		ZFS_PriceChanger_PANEL:SetVisible(true)
	else
		ZFS_PriceChanger_PANEL = vgui.Create("ZEROSFS_price_ItemBuy")
	end
end)
