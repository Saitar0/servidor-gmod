if not SERVER then return end
util.AddNetworkString("zfs_ItemBuyUpdate_cl")
local InteractDistance = 100

net.Receive("zfs_ItemBuyUpdate_cl", function(len, pl)
	local ItemInfo = net.ReadTable()
	local price = ItemInfo.Price
	local w_item = Entity(ItemInfo.ItemEntIndex)

	if (IsValid(w_item) and w_item:GetClass() == "zfs_fruitcup_base" and pl:GetPos():Distance(w_item:GetPos()) < 200) then
		-- Sets the Product InUse VAR
		w_item.IsInUseByOtherPlayer = ItemInfo.WantsToBuy

		-- Here we make the Transaction if the Product got sold
		if (ItemInfo.WantsToBuy) then
			-- If we are on DarkRp then check if the Player has enough money
			if (DarkRP and not pl:canAfford(price)) then
				zfs.f.Notify(pl, zfs.language.Shop.Item_NoMoney, 1)

				return
			end

			-- Check if we stand close enough to the shop and we are alive
			local ahzdistance

			for k, v in pairs(ents.FindByClass("zfs_shop")) do
				if pl:GetPos():Distance(v:GetPos()) <= InteractDistance then
					ahzdistance = true
					break
				end
			end

			if (not pl:Alive() or not ahzdistance) then return end

			-- Does the player have the right Ulx Group to Consume the topping of this Item?
			if (table.Count(zfs.config.Toppings[ItemInfo.ToppingID].UlxGroup_consume) > 0) then
				local permission = zfs.config.Toppings[ItemInfo.ToppingID].UlxGroup_consume[pl:GetNWString("usergroup")]

				if (permission == false or permission == nil) then
					local allowedGroups = table.ToString(zfs.f.CreateAllowList(zfs.config.Toppings[ItemInfo.ToppingID].UlxGroup_consume), nil, false)
					zfs.f.Notify(pl, zfs.language.Shop.Item_WrongUlx01 .. allowedGroups, 3)
					zfs.f.Notify(pl, zfs.language.Shop.Item_WrongUlx02, 1)

					return
				end
			end

			-- Does the player have the right Job to Consume the topping of this Item?
			if (table.Count(zfs.config.Toppings[ItemInfo.ToppingID].Job_consume) > 0) then
				local JobPermission = zfs.config.Toppings[ItemInfo.ToppingID].Job_consume[team.GetName(pl:Team())]

				if (JobPermission == false or JobPermission == nil) then
					local allowedJobs = table.ToString(zfs.f.CreateAllowList(zfs.config.Toppings[ItemInfo.ToppingID].Job_consume), nil, false)
					zfs.f.Notify(pl, zfs.language.Shop.Item_WrongJob01 .. allowedJobs, 3)
					zfs.f.Notify(pl, zfs.language.Shop.Item_WrongJob02, 1)

					return
				end
			end

			if (zfs.config.Debug) then
				print("-----------------")
				print("Received Benefits by " .. pl:Nick())
				PrintTable(zfs.config.Toppings[ItemInfo.ToppingID].ToppingBenefits)
				print("-----------------")
			end

			-- This Handles the sell action of the cup from the Shop
			w_item:GetParent():action_SellCup(w_item, pl, price)
			--This Closes the ShopUI on Purchase
			net.Start("zfs_ItemSellWindowClose_sv")
			net.Send(pl)
		end
	end
end)
