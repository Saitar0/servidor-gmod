// Version 1.0.5c
//Zeros FruitSlicer Job//

////////////////////////////////////////////////////////////////////////////////-
// Developed by ZeroChain:


// If you wish to contact me:
// clemensproduction@gmail.com
////////////////////////////////////////////////////////////////////////////////-
//////////////BEFORE YOU START BE SURE TO READ THE README.TXT////////////////////
////////////////////////////////////////////////////////////////////////////////-

zfs = zfs or {}
zfs.config = zfs.config or {}
zfs.utility = zfs.utility or {}

zfs.config.Debug = false

// This enables FastDownload
zfs.config.EnableResourceAddfile = false

// What Language should we use
// Currently we support: en = English, de = German, pl = Polish, fr = French
zfs.config.selectedLanguage = "pt"

// Can everyone use the fruitslicer?
zfs.config.SharedEquipment = true

// Players with these Ranks are allowed to use the save command !savezfs
zfs.config.AllowedRanks = {"superadmin"}

// These Jobs are allowed do interact with the fruitslicer
zfs.config.AllowedJobs = {"Cortador de Frutas"}

// These are the fruits which get loaded in the entity on spawn
zfs.config.StartStorage = {}
zfs.config.StartStorage["zfs_melon"] = 3
zfs.config.StartStorage["zfs_banana"] = 10
zfs.config.StartStorage["zfs_strawberry"] = 15

// What should the SmoothieShop look like,  1 = California, 2 = India
zfs.config.Theme = 1

// Do we allow the players do change the price of each Product
// *Note* If set to false then there will be a Fruit Variation Charge on the Base Price
// that uses the zfs.config.FruitMultiplicator too incourage the Production of more complex Smoothies
zfs.config.CustomPrice = true

// This is the minimum Custom Price the players can set it to
zfs.config.PriceMinimum = 25

// This is the maximum Custom Price the players can set it to
zfs.config.PriceMaximum = 1000

// The Currency we sell in
zfs.config.Currency = "$"

// This is the percentage of what the Smoothie will cost more when using multiple fruit types
// *Note Only works if zfs.config.CustomPrice is set to false
zfs.config.FruitMultiplicator = 0.5 // 0.5 = +50% extra cost

// This is the Max Health Boni a player gets when consuming a Smoothie that uses every single type of fruit
// *Note* This exists so Players get rewarded for buying Smoothies that have multiple fruit types
zfs.config.Max_HealthReward = 100

// This will turn the Health boni the players get too a Energy boni
zfs.config.UseHungermod = true

// Do we want do cap the Health to MaxHealth if we get over it
// *Examble* Player has 90 Health , MaxHealth = 100 , FruitCup gives Player 25 ExtraHealth , Players Health gets caped at 100
zfs.config.HealthCap = true

// This is the Max Health the player can get from the Smoothies
zfs.config.MaxHealthCap = 200

// This defines the Background Color of the Items
zfs.config.Item_BG = Color(87,122,136)

// This defines the Background Color of the Items if its ulx group exlusive
zfs.config.Restricted_Topping_BG = Color(229,167,48)

//Available Benefits
// ["Health"] = ExtraHealth - 100
// ["ParticleEffect"] = Effectname   // In Mod Effects: zfs_health_effect,zfs_money_effect,zfs_energetic,zfs_ghost_effect
// ["SpeedBoost"] = SpeedBoost - 200
// ["AntiGravity"] = JumpBoost - 300
// ["Ghost"] = Alpha  - 0/255
// ["Drugs"] = ScreenEffectName  // In Mod ScreenEffects: MDMA,CACTI

// The Smoothies we can make in the Shop
zfs.config.FruitCups = {
	[1] = {
		// The Name of our FruitCup
		Name = "Monster Melon",
		// The Base Price of the FruitCup, This value can change depending on the fruit varation if zfs.config.FruitPriceMultiplier is true
		Price = 150,
		// The Icon of the FruitCup
		Icon = "materials/zfruitslicer/ui/fs_ui_monstermelon.png",
		// The Info of the FruitCup
		Info = "A Tasty Melon Cup with Rainbows, Sparks and a fruity melon smell.",
		// The Color of the Fruitcup
		fruitColor = Color(255, 25, 0),
		// What Fruits are needed do make the Smoothie
		// Dont add more then 22 fruits max or it gets complicated
		recipe = {
			["zfs_melon"] = 3,
			["zfs_banana"] = 0,
			["zfs_coconut"] = 0,
			["zfs_pomegranate"] = 0,
			["zfs_strawberry"] = 0,
			["zfs_kiwi"] = 0,
			["zfs_lemon"] = 0,
			["zfs_orange"] = 0,
			["zfs_apple"] = 0
		}
	},
	[2] = {
		Name = "General Banana",
		Price = 120,
		Icon = "materials/zfruitslicer/ui/fs_ui_generalbanana.png",
		Info = "A tasty Bananas Smoothie full of Rainbows.",
		fruitColor = Color(255, 223, 126),
		recipe = {
			["zfs_melon"] = 0,
			["zfs_banana"] = 5,
			["zfs_coconut"] = 0,
			["zfs_pomegranate"] = 0,
			["zfs_strawberry"] = 0,
			["zfs_kiwi"] = 0,
			["zfs_lemon"] = 0,
			["zfs_orange"] = 0,
			["zfs_apple"] = 0
		}
	},
	[3] = {
		Name = "Chianka Cup",
		Price = 250,
		Icon = "materials/zfruitslicer/ui/fs_ui_chikichanga.png",
		Info = "A tropical yummi sweet Cup of Hawai.",
		fruitColor = Color(221, 112, 161),
		recipe = {
			["zfs_melon"] = 0,
			["zfs_banana"] = 1,
			["zfs_coconut"] = 3,
			["zfs_pomegranate"] = 2,
			["zfs_strawberry"] = 0,
			["zfs_kiwi"] = 0,
			["zfs_lemon"] = 0,
			["zfs_orange"] = 0,
			["zfs_apple"] = 0
		}
	},
	[4] = {
		Name = "Super Fruit Cup",
		Price = 500,
		Icon = "materials/zfruitslicer/ui/fs_ui_superfruit.png",
		Info = "The Ultimate Vitamin Bomb!",
		fruitColor = Color(140, 119, 219),
		recipe = {
			["zfs_melon"] = 1,
			["zfs_banana"] = 3,
			["zfs_coconut"] = 1,
			["zfs_pomegranate"] = 1,
			["zfs_strawberry"] = 1,
			["zfs_kiwi"] = 2,
			["zfs_lemon"] = 1,
			["zfs_orange"] = 2,
			["zfs_apple"] = 2
		}
	},
	[5] = {
		Name = "Strawberry Bomb",
		Price = 300,
		Icon = "materials/zfruitslicer/ui/fs_ui_strawberrybomb.png",
		Info = "Taste the blood of your Enemys!",
		fruitColor = Color(174, 36, 56),
		recipe = {
			["zfs_melon"] = 0,
			["zfs_banana"] = 0,
			["zfs_coconut"] = 0,
			["zfs_pomegranate"] = 0,
			["zfs_strawberry"] = 5,
			["zfs_kiwi"] = 0,
			["zfs_lemon"] = 0,
			["zfs_orange"] = 0,
			["zfs_apple"] = 0
		}
	},
	[6] = {
		Name = "Lava Burst Delight",
		Price = 300,
		Icon = "materials/zfruitslicer/ui/fs_ui_lavaburst.png",
		Info = "The Power of the Earth combined in a Fruity Delight!",
		fruitColor = Color(255, 119, 0),
		recipe = {
			["zfs_melon"] = 1,
			["zfs_banana"] = 2,
			["zfs_coconut"] = 0,
			["zfs_pomegranate"] = 0,
			["zfs_strawberry"] = 2,
			["zfs_kiwi"] = 0,
			["zfs_lemon"] = 0,
			["zfs_orange"] = 0,
			["zfs_apple"] = 4
		}
	},
	[7] = {
		Name = "Rouges Vortex",
		Price = 400,
		Icon = "materials/zfruitslicer/ui/fs_ui_fruitrougesvortex.png",
		Info = "A Vortex of tasty red fruits!",
		fruitColor = Color(199, 48, 62),
		recipe = {
			["zfs_melon"] = 1,
			["zfs_banana"] = 0,
			["zfs_coconut"] = 0,
			["zfs_pomegranate"] = 5,
			["zfs_strawberry"] = 2,
			["zfs_kiwi"] = 0,
			["zfs_lemon"] = 0,
			["zfs_orange"] = 0,
			["zfs_apple"] = 3
		}
	}
}

// The Toppings we can add on the FruitCup
zfs.config.Toppings = {
	// This is the item for NoTopping and should not be removed
	[1] = {
		Name = "No Topping",
		ExtraPrice = 0,
		Icon = "materials/zfruitslicer/ui/zfs_ui_nothing.png",
		Model = "models/props_c17/oildrum001.mdl",
		mScale = 1,
		Info = "At least its Free xD",
		ToppingBenefits = {},
		ToppingBenefit_Duration = -1,
		ConsumInfo = "Tasty!",
		UlxGroup_consume = {},
		UlxGroup_create = {},
		Job_consume = {}
	},
	//
	[2] = {
		// The Name of the Topping
		Name = "Baby",
		// The Extra price when adding this topping
		ExtraPrice = 100,
		// If specified we use a icon instead of the model itself
		Icon = nil,
		// The Topping Model that gets placed on the cup
		Model = "models/props_c17/doll01.mdl",
		// The Scale of the Topping Model
		mScale = 0.5,
		// The Info of the Topping
		Info = "Stem Cells can cure cancer, so \neating this gives you extra Health!",
		// The Benefits the player gets when consuming this topping
		ToppingBenefits = {
			["Health"] = 200 // This Gives the Player extra Health
		},
		// The Duration of the Benefits, this only applys to benefits that have a length. Wont to anything on Health since its Instant
		ToppingBenefit_Duration = 0,
		// The Info the Player gets when consuming the Fruicup
		ConsumInfo = "You feel very Healthy!",
		// This defines the ULX Groups who are allowed to consume the fruit cup if he has this topping, Leave empty to not Restrict it
		UlxGroup_consume = {},
		// This defines the ULX Groups who are allowed to add this topping to the fruit cup, Leave empty to not Restrict it
		UlxGroup_create = {
			["superadmin"] = false
		},
		// This defines the Jobs who are allowed to consume the fruit cup if he has this topping, Leave empty to not Restrict it
		Job_consume = {}
	},
	[3] = {
		Name = "Coffee",
		ExtraPrice = 100,
		Icon = nil,
		Model = "models/props_junk/garbage_metalcan002a.mdl",
		mScale = 0.5,
		Info = "Not good for the Health\nbut gives you an enery boost!",
		ToppingBenefits = {
			["ParticleEffect"] = "zfs_energetic",
			["SpeedBoost"] = 100
		},
		ToppingBenefit_Duration = 25,
		ConsumInfo = "You feel high on Energy!",
		UlxGroup_consume = {},
		UlxGroup_create = {},
		Job_consume = {}
	},
	[4] = {
		Name = "Floating Orb",
		ExtraPrice = 500,
		Icon = nil,
		Model = "models/Combine_Helicopter/helicopter_bomb01.mdl",
		mScale = 0.2,
		Info = "I found it in a crater so\ndo you want it?",
		ToppingBenefits = {
			["AntiGravity"] = 400
		},
		ToppingBenefit_Duration = 30,
		ConsumInfo = "You feel very light!",
		UlxGroup_consume = {},
		UlxGroup_create = {
			["superadmin"] = false
		},
		Job_consume = {}
	},
	[5] = {
		Name = "Old Skull",
		ExtraPrice = 300,
		Icon = nil,
		Model = "models/Gibs/HGIBS.mdl",
		mScale = 0.5,
		Info = "Some say you can enter the \nGhost Dimension by licking it.",
		ToppingBenefits = {
			["Ghost"] = 25,
			["ParticleEffect"] = "zfs_ghost_effect"
		},
		ToppingBenefit_Duration = 30,
		ConsumInfo = "You filled with Dark Energy!",
		UlxGroup_consume = {},
		UlxGroup_create = {},
		Job_consume = {}
	},
	[6] = {
		Name = "Mis Hulala",
		ExtraPrice = 600,
		Icon = nil,
		Model = "models/props_lab/huladoll.mdl",
		mScale = 0.8,
		Info = "It says Party on the Bottom.",
		ToppingBenefits = {
			["Drugs"] = "MDMA"
		},
		ToppingBenefit_Duration = 45,
		ConsumInfo = "You tripping Ballz!",
		UlxGroup_consume = {},
		UlxGroup_create = {
			["superadmin"] = false
		},
		Job_consume = {}
	},
	[7] = {
		Name = "Cactus juice",
		ExtraPrice = 600,
		Icon = nil,
		Model = "models/props_lab/cactus.mdl",
		mScale = 0.8,
		Info = "Drink cactus juice. It'll quench ya!\nIt's the quenchiest!",
		ToppingBenefits = {
			["Drugs"] = "CACTI"
		},
		ToppingBenefit_Duration = 45,
		ConsumInfo = "I feel quenchier!",
		UlxGroup_consume = {},
		UlxGroup_create = {},
		Job_consume = {}
	},
	[8] = {
		Name = "Energy Drink",
		ExtraPrice = 500,
		Icon = nil,
		Model = "models/props_junk/PopCan01a.mdl",
		mScale = 0.5,
		Info = "Not good for the Health\nbut gives you an enery boost!",
		ToppingBenefits = {
			["ParticleEffect"] = "zfs_energetic",
			["SpeedBoost"] = 500
		},
		ToppingBenefit_Duration = 25,
		ConsumInfo = "You feel high on Energy!",
		UlxGroup_consume = {},
		UlxGroup_create = {
			["superadmin"] = false
		},
		Job_consume = {}
	},
	[9] = {
		Name = "Helium",
		ExtraPrice = 50,
		Icon = nil,
		Model = "models/Items/combine_rifle_ammo01.mdl",
		mScale = 0.4,
		Info = "Makes you feel light headed.",
		ToppingBenefits = {
			["AntiGravity"] = 50
		},
		ToppingBenefit_Duration = 30,
		ConsumInfo = "You feel very light!",
		UlxGroup_consume = {},
		UlxGroup_create = {},
		Job_consume = {}
	},
	[10] = {
		Name = "Cough Syrup",
		ExtraPrice = 10,
		Icon = nil,
		Model = "models/Items/HealthKit.mdl",
		mScale = 0.2,
		Info = "Needs no prescription.",
		ToppingBenefits = {
			["Health"] = 25
		},
		ToppingBenefit_Duration = 0,
		ConsumInfo = "You feel very Healthy!",
		UlxGroup_consume = {},
		UlxGroup_create = {},
		Job_consume = {}
	},
	[11] = {
		Name = "CTD",
		ExtraPrice = 500,
		Icon = nil,
		Model = "models/Items/battery.mdl",
		mScale = 0.5,
		Info = "Thats one of these new Cell\nTarning Devices.",
		ToppingBenefits = {
			["Ghost"] = 25
		},
		ToppingBenefit_Duration = 30,
		ConsumInfo = "You feel almost invisible!",
		UlxGroup_consume = {},
		UlxGroup_create = {
			["superadmin"] = false
		},
		Job_consume = {
			["Gangster"] = true
		}
	}
}

zfs.utility.SortedToppingsTable = zfs.config.Toppings
table.sort(zfs.utility.SortedToppingsTable, function(a, b) return table.Count(a.UlxGroup_create) < table.Count(b.UlxGroup_create) end)
