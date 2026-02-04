TEAM_ZFRUITSLICER = DarkRP.createJob("Cortador de Frutas", {
	color = Color(0, 128, 255, 255),
    	model = {"models/player/group03/male_04.mdl"},
	description = [[Você vende smoothies!]],
    	weapons = {"zfs_knife"},
	command = "FruitSlicer",
	max = 2,
	salary = 50,
	admin = 0,
	vote = false,
	category = "Citizens",
	hasLicense = false
})

DarkRP.createCategory{
	name = "Loja de Frutas",
	categorises = "entities",
	startExpanded = true,
	color = Color(0, 107, 0, 255),
	canSee = fp{fn.Id, true},
	sortOrder = 255
}

DarkRP.createEntity("Loja de Frutas", {
	ent = "zfs_shop",
	model = "models/zerochain/fruitslicerjob/fs_shop.mdl",
	price = 400,
	max = 1,
	cmd = "buyzfs_shop",
	allowed = TEAM_ZFRUITSLICER,
	category = "Loja de Frutas",
	sortOrder = 0
})

local Fruits = {}
Fruits["zfs_fruitbox_melon"] = "Melões"
Fruits["zfs_fruitbox_banana"] = "Bananas"
Fruits["zfs_fruitbox_coconut"] = "Cocos"
Fruits["zfs_fruitbox_pomegranate"] = "Romãs"
Fruits["zfs_fruitbox_strawberry"] = "Morangos"
Fruits["zfs_fruitbox_kiwi"] = "Kiwis"
Fruits["zfs_fruitbox_lemon"] = "Limões"
Fruits["zfs_fruitbox_orange"] = "Laranjas"
Fruits["zfs_fruitbox_apple"] = "Maçãs"

for k, v in pairs(Fruits) do
		DarkRP.createEntity(v, {
		ent = k,
		model = "models/zerochain/fruitslicerjob/fs_cardboardbox.mdl",
		price = 100,
		max = 5,
		cmd = "buy" .. k,
		allowed = TEAM_ZFRUITSLICER,
			category = "Loja de Frutas"
	})
end
