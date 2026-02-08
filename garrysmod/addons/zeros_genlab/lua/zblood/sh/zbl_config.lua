zbl = zbl or {}
zbl.f = zbl.f or {}
zbl.config = zbl.config or {}

/////////////////////////////////////////////////////////////////////////////

// Bought by 76561198321283401
// Version 1.5.2


///////////////////////////// Zeros GenLab //////////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242
// https://www.artstation.com/zerochain

/////////////////////////////////////////////////////////////////////////////


/*

    Tool Gun:
        HotSpot Spawner - Spawns / Removes / Saves Virus Hotspots

    Console Commands:
        zbl_debug_VHS_AddPos - Adds a new position for a VirusHotSpot to grow at where you looking
        zbl_debug_VHS_SavePos - Saves all the HotSpot positions for the current map
        zbl_debug_VHS_RemovePos - Removes all the HotSpot positions for the current map

    For more debug console commands look at zeros_bloodlab\lua\zblood\sh\zbl_debug.lua

    Chat Commands:
        !zbl_save - Saves all the NPCs and VirusHotSpots for the Map (Admin Only)
        !dropmask - Drops the current Respirator if the player has any equipt

    Functions:
        zbl.f.Lab_Data_AddPoints(ply,points) - Gives the specified Player the specified amount of DNA Points
        zbl.f.Lab_Data_RemovePoints(ply,points) - Removes the specified Player the specified amount of DNA Points
*/


// Switches between FastDl and Workshop
zbl.config.FastDl = false

// This enables the Debug Mode
zbl.config.Debug = false

// The language , en , de , fr , cn , ru , pl
zbl.config.SelectedLanguage = "en"

// These Ranks are admins, if one of the following scripts is installed then you can ignore this table
// If xAdmin is installed then this table can be ignored
zbl.config.AdminRanks = {
    ["superadmin"] = true,
    ["owner"] = true,
}

// The Currency symbol
zbl.config.Currency = "$"

// If true then the Currency symbol will be on the left side of the number
zbl.config.CurrencyPosInvert = true

// Those Jobs can use the Lab entities and sell to the npcs
zbl.config.Jobs = {
    [TEAM_ZBL_RESEARCHER] = true,
}



// Requires McPhone https://www.gmodstore.com/market/view/mcphone-advanced-phone-system-1
// The McPhone App can be used to tell the player if there are infected player or objects near by
// It also shows him if he currently is wearing a respirator
zbl.config.McPhone = {
    scan_radius = 750,

    scan_duration = 1,
}



// Corpses get created when a player dies while being infected
zbl.config.Corpse = {

    // Do we want corpses to get created when a player dies while being infected
    enabled = true,

    // How long till the corpse gets removed
    life_time = 60,

    // Should the virus material be visible on the corpse?
    infection_visible = true,

    // Should the corpse explode when it despawns, this will infect anyone near it
    ExplodeOnDespawn = true,

    // One of those animations will be used for the corpse
    anim = {"zombie_slump_idle_01"}
}



// Here you can add custom protection checks against viruses
// Return a value between 0 - 100 , 0 = Not protected at all, 100 = Fully Protected
// This check goes both ways so if a player is infected but is protected by a respirator then the chance of him infecting other people low aswell.
zbl.config.ProtectionCheck = function(ply,vac_id,vac_stage)

    local chance = 0

    // If the Protection chance is higher or equal 100 then it prevents the player from picking up respirators

    // A Hazmat Suit, nothing goes in or out
    if ply:GetModel() == "models/zerochain/props_bloodlab/zbl_hazmat.mdl" then
        chance = 100

    // Technicly this model is wearing a respirator so he is fully protected from virus spores
    elseif ply:GetModel() == "models/player/police.mdl" then
        chance = 100

    // Does the player wear a respirator
    elseif ply:GetNWInt("zbl_RespiratorUses",0) > 0 then

        // This should NEVER be higher then 99
        chance = 80
    end

    return chance
end



// Protects the player with style :D
zbl.config.Respirator = {
    // How often can the respirator be used before it gets used up and removed
    // The Repsirator gets used when protecting against viruses
    Uses = 15,

    // Should the player get a random respirator style assigned when opening a respirator box
    random_style = true,

    // If random_style = false then we can define which respirator style people gonna wear
    style = -1,

    // Here we define the styles
    styles = {
        // n95 Mask
        [1] = {
            model = "models/zerochain/props_bloodlab/zbl_n95mask.mdl",
            skin = 0
        },

        // Blank Mask
        [2] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 0
        },

        // Beard01
        [3] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 1
        },

        // Beard02
        [4] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 2
        },

        // Blushsmile
        [5] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 3
        },

        // Cat
        [6] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 4
        },

        // Kawai
        [7] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 5
        },

        // Kiss
        [8] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 6
        },

        // Panda
        [9] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 7
        },

        // Smile
        [10] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 8
        },

        // Vampire
        [11] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 9
        },

        // Zipper
        [12] = {
            model = "models/zerochain/props_bloodlab/zbl_mask.mdl",
            skin = 10
        },
    }
}



// Disinfectant Spray is used to decontaminate objects/players and fight virus nodes
zbl.config.DisinfectantSpray = {
    // How much liquid does the spray have?
    Amount = 70,

    // How much liquid get used per click
    UsagePerClick = 1,

    // How much damage gets inflicted on the virus node if you spray on him
    VirusNode_Damage = 10
}



// The Injector gun is used to inject/extract liquid from players and entities
zbl.config.InjectorGun = {

    //https://wiki.facepunch.com/gmod/Enums/KEY
    Keys = {
        // Open Help menu
        Help = KEY_H,

        // Injects the selected vaccine in to yourself
        SelfInject = KEY_B,

        // Emptys the gun of any substance
        EmptyFlask = KEY_X,

        // Switches to the next flask
        SwitchFlask = KEY_R,

        // Extracts the substance of the gun in to a flask and drops it
        ExtractFlask = MOUSE_MIDDLE,

        // Scan the area arround you
        ScanArea = KEY_T,
    },

    // This defines how many chambers the gun has
    // Should not be smaller then 3 or bigger then 12
    // This also defines how many flasks the player can drop on the floor
    flask_capacity = {
        ["default"] = 6,
        ["vip"] = 8,
        ["superadmin"] = 12,
    },

    // The scan can be used to detect infected objects/players
    Scan = {

        // How long will the scanned objects show their infection status
        duration = 3,

        // The scan radius arround the player
        radius = 500,

        // How long does the player need to wait before he can scan again
        interval = {
            ["default"] = 3,
            ["vip"] = 2,
            ["superadmin"] = 0.1,
        },

        // Should we display what virus has infected the scanned object/player and at whichs tage it is
        show_info = true
    }
}



// The flask entity is a storage container for DNA Samples, Viruses, Cures and Abillity Boosts
zbl.config.Flask = {
    // Can it be destroyed?
    Breakable = true,

    // How fast does the flask have to be on colliion in order to break?
    Break_speed = 400,

    // Should the flask infect/cure players in proximity with the vaccine it holds?
    InfectOnDestruction = true,

    // How close does a player needs to be in order to get infected?
    Infect_Radius = 200,

    // Should the flask create virus nodes on destruction if the liquid is a virus
    // It will only create virus nodes if it finds a valid position
    NodeOnDestruction = true,
}



// Here we can define which entities can be used to get DNA samples from
zbl.config.SampleTypes = {
    // Entity Class
    ["player"] = {

        // How many DNA points do we get when analyzing this sample
        dna_points = 5,

        // This defines the name of the sample
        name = function(ent)

            if zbl.f.Player_IsInfected(ent) then
                return zbl.f.Player_GetName(ent) .. " (Infected)"
            else
                return zbl.f.Player_GetName(ent)
            end
        end,

        // This can be used to modify DNA points generated from this sample
        // ply = Swep Owner , ent = Target , points = dna_points
        points_modify = function(ply,ent,points)

            // If the (blood) sample is from a infected player then we get double the DNA points
            if zbl.f.Player_IsInfected(ent) then
                points = points * 2
            end
            return points
        end,

        // How do samples of this type differentiate? (Needs to be a int)
        identifier = function(ent)
            return ent:AccountID()
        end,

        // This will be called on the entity we are harvesting the sample from
        OnCollect = function(ply,ent)

            // Damage the Player we are collecting the sample from
            local d = DamageInfo()
            d:SetDamage( 5 )
            d:SetAttacker( ply )
            d:SetDamageType( DMG_SLASH )
            ent:TakeDamageInfo( d )

            zbl.f.Player_PlaySound_Ouch(ent)
        end,
    },
    ["zbl_virusnode"] = {
        dna_points = 3,
        name = function(ent)
            return zbl.config.Vaccines[ent.Virus_ID].name
        end,
        points_modify = function(ply,ent,points)
            return points
        end,
        identifier = function(ent)
            return ent.Virus_ID
        end,
        OnCollect = function(ply,ent)
            zbl.f.VN_TakeDamage(ent,50)
        end,
    },
    ["npc_headcrab"] = {
        dna_points = 10,
        name = function(ent)
            return ent:GetClass()
        end,
        points_modify = function(ply,ent,points)
            return points
        end,
        identifier = function(ent)
            // Creates a unique id using the entities model path
            return zbl.f.StringToUniqueID(ent:GetModel())
        end,
        OnCollect = function(ply,ent)
            ent:TakeDamage( ent:Health(), ply, ply:GetActiveWeapon() )
        end,
    },
    ["zbl_corpse"] = {
        dna_points = 10,
        name = function(ent)

            return ent:GetPlayerName()
        end,
        points_modify = function(ply,ent,points)
            return points
        end,

        // How do samples of this type differentiate? (Needs to be a int)
        identifier = function(ent)
            return ent:GetPlayerID()
        end,

        // This will be called on the entity we are harvesting the sample from
        OnCollect = function(ply,ent)

            SafeRemoveEntity(ent)
        end,
    },
}


// The GenLab is used to create DNA Points from Samples and create Vaccines/Viruses from DNA Points
zbl.config.GenLab = {

    // How long does it take to analyze one sample
    time_per_sample = 25, // seconds

    // Once a sample got used on the lab , how long does the player need to wait til the same sample gives full points again
    sample_cooldown = 300, // seconds

    // How much value does a sample has which was previous researched in this lab, aka a sample with a cooldown
    cooldown_penalty = 0.1, // 0 - 1

    // How much value does a sample has which is multiple times in the lab
    duplicate_penalty = 0, // 0 - 1

    // Changes the analyze/create speed according to what rank the player has
    // 1 = NoChange, 2 = Double duration , 0.5 = Half duration
    time_modify = {
        // Dont remove the default value
        ["default"] = 1,
        ["vip"] = 0.9,
        ["superadmin"] = 0.5,
    },

    Data = {
        // Should the DNA Points be saved on the server?
        Save = true,

        // How often should we auto save the data of players. Set to -1 to disable the autosave.
        // The data will also get saved when the player disconnects from the Server so the autosave is just a safety measure.
        Save_Interval = 600,

        // If specified then only data for Players with these Ranks get saved. Leave empty to save the data for every player.
        Whitelist = {
            ["superadmin"] = true,
            ["vip"] = true
        }
    }
}



// Here you can define perception effects for the player which changes how the player sees and hears.
zbl.config.PerceptionEffects = {
    ["visual_distortion_weak"] = {

        // What audio filter should be applied? (Changes how the player hears ingame)
        //https://developer.valvesoftware.com/wiki/Dsp_presets
        //audio_filter = 15,

        // A diffuse material which get layered over the players screen
        //mat = "zerochain/zblood/screeneffects/zbl_scfx_braincells",

        // A refract material which get layered over the players screen
        //warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_braincells_warp",

        // The Bloom Color
        bloom = {0, 0, 0.1},

        // The blur effect
        m_blur = 0.5,

        // The DrawColorModify data
        colormodify = {

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0.05,

            ["pp_colour_brightness"] = 0,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.5
        }
    },
    ["visual_distortion_strong"] = {

        // What audio filter should be applied? (Changes how the player hears ingame)
        //https://developer.valvesoftware.com/wiki/Dsp_presets
        audio_filter = 15,

        // A diffuse material which get layered over the players screen
        mat = "zerochain/zblood/screeneffects/zbl_scfx_zombiemeat",

        // A refract material which get layered over the players screen
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_zombiemeat_warp",

        // The Bloom Color
        bloom = {0.125, 0.125, 1},

        // The blur effect
        m_blur = 1,

        // The DrawColorModify data
        colormodify = {

            ["pp_colour_addr"] = 0.5,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,

            ["pp_colour_brightness"] = -0.4,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_distortion_mutant"] = {
        audio_filter = 15,
        mat = "zerochain/zblood/screeneffects/zbl_scfx_mutant",
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_mutant_warp",
        bloom = {1, 0.125, 1},
        m_blur = 1,
        colormodify = {

            ["pp_colour_addr"] = 0.2,
            ["pp_colour_addg"] = 0.5,
            ["pp_colour_addb"] = 0.2,

            ["pp_colour_brightness"] = -0.6,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_blindness_weak"] = {
        m_blur = 0.5,
        b_blur = 50,
        colormodify = {

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0,

            ["pp_colour_brightness"] = 0.1,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0
        }
    },
    ["visual_blindness_medium"] = {
        m_blur = 1,
        b_blur = 200,
        colormodify = {

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0,

            ["pp_colour_brightness"] = 0.5,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0
        }
    },
    ["visual_blindness_strong"] = {
        m_blur = 1.2,
        b_blur = 500,
        colormodify = {

            ["pp_colour_addr"] = 0,
            ["pp_colour_addg"] = 0,
            ["pp_colour_addb"] = 0,

            ["pp_colour_brightness"] = 0.5,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.8,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0
        }
    },
    ["visual_headache_weak"] = {
        m_blur = 0.5,
        b_blur = 55,
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_headache_warp",
        colormodify = {

            ["pp_colour_addr"] = 0.3,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,

            ["pp_colour_brightness"] = -0.1,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_headache_strong"] = {
        m_blur = 1,
        b_blur = 75,
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_headache_warp",
        colormodify = {

            ["pp_colour_addr"] = 0.4,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,

            ["pp_colour_brightness"] = -0.1,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
    ["visual_sars_strong"] = {
        m_blur = 1,
        b_blur = 15,
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_sars_warp",
        colormodify = {

            ["pp_colour_addr"] = 0.2,
            ["pp_colour_addg"] = 0.2,
            ["pp_colour_addb"] = 0.2,

            ["pp_colour_brightness"] = -0.3,
            ["pp_colour_contrast"] = 1,
            ["pp_colour_colour"] = 0.1,

            ["pp_colour_mulr"] = 0,
            ["pp_colour_mulg"] = 1,
            ["pp_colour_mulb"] = 1
        }
    },
    ["visual_covid_strong"] = {
        audio_filter = 15,
        mat = "zerochain/zblood/screeneffects/zbl_scfx_covid",
        warp_mat = "zerochain/zblood/screeneffects/zbl_scfx_braincells_warp",
        bloom = {1, 0.125, 0},
        m_blur = 1,
        colormodify = {

            ["pp_colour_addr"] = 0.3,
            ["pp_colour_addg"] = 0.1,
            ["pp_colour_addb"] = 0.1,

            ["pp_colour_brightness"] = -0.5,
            ["pp_colour_contrast"] = 0.9,
            ["pp_colour_colour"] = 0.1,

            ["pp_colour_mulr"] = 2,
            ["pp_colour_mulg"] = 0,
            ["pp_colour_mulb"] = 0.0
        }
    },
}



// Here you can define diffrent appearances for the player
zbl.config.AppearanceEffects = {
    ["appearance_rhizome"] = {

        // What wound material should be applied to the infected player?
        /*
            "zerochain/zblood/wounds/zbl_wound_braincells_diff",
            "zerochain/zblood/wounds/zbl_wound_flesh_diff",
            "zerochain/zblood/wounds/zbl_wound_mutant_diff",
            "zerochain/zblood/wounds/zbl_wound_rhizome_diff",
            "zerochain/zblood/wounds/zbl_wound_zombiemeat_diff",
        */
        MaterialOverlay = "zerochain/zblood/wounds/zbl_wound_rhizome_diff",

        // What wound color should be applied to the infected player?
        //ColorOverlay = Color(178,48,32),

        // What player model should be applied to the infected player?
        //PlayerModel = "models/player/charple.mdl"
    },
    ["appearance_braincells"] = {
        MaterialOverlay = "zerochain/zblood/wounds/zbl_wound_braincells_diff",
        ColorOverlay = Color(178,48,32),
        PlayerModel = "models/player/charple.mdl"
    },
    ["appearance_armor"] = {
        MaterialOverlay = "zerochain/zblood/misc/zbl_armored_diff",
    },
}



// Here you can define what objects can be contaminated with a virus
zbl.config.Contamination = {

    // Should objects get contaminated when used by a infected player?
    enabled = true,

    // If set to true then the contaminated objects will have the virus material applied which makes it easier to identify them
    // Setting this to false means only the scan function of the injector gun will show if entities/players are infected
    visible = false,

    // Those entities can be contaminated with a virus
    // Only entities which can be interacted via USE can be used
    ents = {
        ["func_door"] = true,
        ["func_door_rotating"] = true,
        ["prop_door_rotating"] = true,
        ["prop_vehicle_jeep"] = true,
        ["money_printer"] = true,
        ["func_button"] = true,
        ["prop_vehicle_prisoner_pod"] = true,
        ["darkrp_tip_jar"] = true,
        ["spawned_shipment"] = true,
        ["spawned_weapon"] = true,
        ["spawned_money"] = true,
        ["spawned_food"] = true,
        ["spawned_ammo"] = true,
        ["gunlab"] = true,
        ["gmod_button"] = true,
        ["keypad"] = true,
        ["keypad_wire"] = true,
    },

    // This system automaticly contaminates a object on the server which matches the entity class above
    AutoContaminate = {

        enabled = true,

        // How often should we try to contaminate a object
        interval = 1200, // seconds

        // Should Objects which gets used a lot be prioritised when choosing what entity to contaminate?
        // Setting this to true will reduce the list of possible contaminated entities from all to only those which got touched since the last interval.
        HeavyUsePriority = true,

        // Defines which virus should be used
        virus_chance = {
            // [virus_id] = chance
            // Cold
            [1] = 50, // %

            // SARS
            [2] = 25,

            //COVID19
            [3] = 25,
        },
    }
}



// This system creates a virus outbreak on predefind locations and grows over time.
// There can only be one active virus hotspot at a time, if the master node dies then the system will search for a new area to setup a new hotspot but any virusnode still alive will stay
zbl.config.VirusHotspots = {

    // Should we create virus outbreaks on predefind locations?
    enabled = true,

    // Should the virus hotspots grow only if one of the players has one of those jobs zbl.config.Jobs
    GrowOnJobOnly = true,

    // The growth interval in seconds
    // Keep in mind that finding grow positions for the nodes according to the world geometry is a expensive progress, short interval = more expensive
    growth_interval = 60,

    // Here you can define spawn chances for diffrent virus ids
    // The higher the percentage, the higher the chance of this virus getting used for the virus hotspot
    virus_chance = {
        // [virus_id] = chance
        // Cold
        [1] = 50, // %

        // SARS
        [2] = 25,

        //COVID19
        [3] = 25,
    },

    // How many virus nodes (entities) is the system allowed to create?
    node_limit = 15,

    // Can virus nodes be damaged with normal weapons?
    node_damage = true,

    // Default health of a node
    node_health_default = 100,

    // How much health can a virus node have total
    node_health_max = 200,

    // How much health does a virus node gain over time.
    node_health_increment = 10,

    // If a node has more then this amount of health then it can spread to a new location
    node_health_spread = 50,
}



// Virus nodes can spawn randomly arround the map or get created when a infected player dies
// A virus node stores the virus data in it and can be harvested to generate new DNA points in the lab.
// It also explodes and infects everyone near it if you touch it!
zbl.config.VirusNodes = {

    // How long does a virus node exist before it gets removed
    // This is the default value but can be overriden in the Vaccine Config
    // This only affects virus nodes created on player death or by exploding flasks and doesent affect virus nodes created by virus hotspots
    life_time = 5000,

    // Defines the maximal model scale of a virus node if it reaches max health
    max_scale = 3,

    // Should the virus node explode on touch?
    KillOnTouch = false
}



// Here we create all the viruses and the abillity boosts
zbl.config.Vaccines = {}

// For easier vaccine creation
function zbl.f.Vaccine_CreateConfig(vaccine)
    return table.insert(zbl.config.Vaccines, vaccine)
end

// Cold
zbl.f.Vaccine_CreateConfig({
    // Name of the Vaccine
    name = "Cold",

    // Description of the vaccine
    desc = "A regular cold.",

    // How much money is this vaccine worth?
    price = 1000,

    // Just to tell the script if this vaccine is a abillity boost or a virus
    isvirus = true,

    // Duration of the Vaccine / Virus per mutation stage
    duration = 60,

    cure = {

        // If the player gets cured by the cure , how long will he be immun against this virus?
        immunity_time = 1200,

        // Should this vaccine/virus remove itself when the player dies?
        // Setting this to false will keep the player infected even after he respawns.
        ondeath = true,

        // How much money is the vaccine cure worth?
        price = 2000,
    },

    // This material gets applied on virus nodes and contaminated objects
    // If this vaccine is not a virus then just remove this part
    // The materials bellow come with the script but you can also use your own
    /*
        "zerochain/zblood/wounds/zbl_wound_braincells_diff"
        "zerochain/zblood/wounds/zbl_wound_flesh_diff"
        "zerochain/zblood/wounds/zbl_wound_inflorescence_diff"
        "zerochain/zblood/wounds/zbl_wound_mold_diff"
        "zerochain/zblood/wounds/zbl_wound_moss_diff"
        "zerochain/zblood/wounds/zbl_wound_mutant_diff"
        "zerochain/zblood/wounds/zbl_wound_rhizome_diff"
        "zerochain/zblood/wounds/zbl_wound_zombiemeat_diff"
    */
    mat = "zerochain/zblood/wounds/zbl_wound_moss_diff",

    // The research info for the Lab
    research = {
        // How much DNA points are needed to create this Vaccine
        ["vaccine_points"] = 15,

        // How long does it take to create this vaccine
        ["vaccine_time"] = 120,

        // How much DNA points are needed to create a cure for this vaccine?
        ["cure_points"] = 20,

        // How long does it take to create a cure this vaccine?
        ["cure_time"] = 200,

        // Those ranks are allowed to create this vaccine / cure
        ["ranks"] = {
            //["superadmin"] = true,
        }
    },

    // Before the virus starts to develop any symptomes its gonna be in its occopation stage were it secretly infects other players arround the infected player every 10 seconds
    // Simple remove this block if you dont want it
    occopation = {
      // How long does the occopation stage last?
      time = 50,

      // How high is the chance for players near the infected player getting infected
      infection_chance = 50,

      // How close does a player need to be to the infected player in order to get infected
      infection_radius = 200,
    },

    // Should objects get contaminated with the virus if the player interacts with them
    // Simple remove this block if you dont want it
    contamination = {

        // How long will the object be contaminated?
        time = 100,

        // How high is the chance that players infected with this virus contaminate objects they interact with.
        chance = 50,
    },

    // Mutation Chance
    // After the duration ended this value defines if the vaccine stops or mutates which switches the mutation_stages to the next stage and restarts the vaccine timer
    // -1 Disables the mutation
    mutation_chance = 50,

    // Here you can define the diffrent stages of the vaccine/virus, effects,symptomes,perception and appearance
    mutation_stages = {
        [1] = {
            // How the vaccine affects the player
            // Here is a list of all effects
            /*
                ["movement_speed"] = 0.8, // (0.1 - 2)
                ["movement_distortion"] = 1, // (1 - 5)
                ["movement_invert"] = true, // true

                ["damage_modify"] = 1.1, // (0.1 - 2)
                ["damage_fall_modify"] = 1.1, // (0.1 - 2)
                ["damage_fire_modify"] = 1.1, // (0.1 - 2)
                ["damage_bullet_modify"] = 1.1, // (0.1 - 2)

                ["jump_modify"] = 180, // Default is 200
            */
            effects = {
                ["movement_speed"] = 0.8, // (0.1 - 2)
                ["damage_modify"] = 1.1, // (0.1 - 2)
                ["jump_modify"] = 180, // Default is 200
            },

            // Symptomes which can cause the vaccine to spread or to modify the player in some way (Usally just used for viruses)
            // Here is a list of all Symptomes
            /*
                ["coughing"] = {interval = 1, infect_distance = 100, infect_chance = 50, damage = 0},
                ["projectile_vomit"] = {interval = 5, damage = 0},
                ["explosive_diarrhea"] = {interval = 5, damage = 0},
                ["head_swelling"] = {scale = 2, damage = 0},
                ["legs_swelling"] = {scale = 1.75, damage = 0},
                ["explosive_head"] = {infect_distance = 300, infect_chance = 60},
            */
            symptomes = {
                // Coughing can infect other players in close proximity
                ["coughing"] = {interval = 4, infect_distance = 100, infect_chance = 50, damage = 0},
            },
        },
        [2] = {
            effects = {
                ["movement_speed"] = 0.5,
                ["damage_modify"] = 1.5,
                ["jump_modify"] = 100,
            },
            symptomes = {
                ["coughing"] = {interval = 2, infect_distance = 100, infect_chance = 90, damage = 15},
            },
            perception = "visual_distortion_strong",
        },
    },
})

// SARS
zbl.f.Vaccine_CreateConfig({
    name = "SARS",
    desc = "A deadly virus which causes projectile vomit on its host.",
    price = 1000,
    isvirus = true,
    duration = 300,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_inflorescence_diff",
    research = {
        ["vaccine_points"] = 15,
        ["vaccine_time"] = 200,
        ["cure_points"] = 20,
        ["cure_time"] = 250,
        ["ranks"] = {
            ["superadmin"] = true,
            ["vip"] = true,
        }
    },
    occopation = {
      time = 60,
      infection_chance = 60,
      infection_radius = 200,
    },
    contamination = {
        time = 35,
        chance = 75,
    },
    mutation_chance = 90,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 0.8,
                ["damage_modify"] = 1.1,
                ["jump_modify"] = 180,
            },
            symptomes = {
                ["projectile_vomit"] = {interval = 5, damage = 0},
            },
            perception = "visual_distortion_weak",
        },
        [2] = {
            effects = {
                ["movement_speed"] = 0.5,
                ["damage_modify"] = 1.5,
                ["jump_modify"] = 100,
            },
            symptomes = {
                ["projectile_vomit"] = {interval = 1, damage = 5},
                ["explosive_diarrhea"] = {interval = 5, damage = 0},
            },
            perception = "visual_sars_strong",
            appearance = "appearance_rhizome",
        },
    },
})

// COVID19
zbl.f.Vaccine_CreateConfig({
    name = "COVID-19",
    desc = "Highly infectious virus which causes heavy coughing followed by death.",
    price = 1000,
    isvirus = true,
    duration = 500,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_braincells_diff",
    research = {
        ["vaccine_points"] = 30,
        ["vaccine_time"] = 250,
        ["cure_points"] = 40,
        ["cure_time"] = 300,
        ["ranks"] = {
            ["superadmin"] = true,
            ["vip"] = true,
        }
    },
    occopation = {
      time = 100,
      infection_chance = 80,
      infection_radius = 200,
    },
    contamination = {
        time = 500,
        chance = 75,
    },
    mutation_chance = 90,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 1.2,
                ["damage_modify"] = 1.1,
            },
            symptomes = {
                ["coughing"] = {interval = 2, infect_distance = 200, infect_chance = 75, damage = 0},
            },
            perception = "visual_distortion_weak",
        },
        [2] = {
            effects = {
                ["movement_speed"] = 2,
                ["damage_modify"] = 1.5,
            },
            symptomes = {
                ["coughing"] = {interval = 1, infect_distance = 300, infect_chance = 90, damage = 15},
            },
            perception = "visual_covid_strong",
            appearance = "appearance_braincells",
        },
    },
})

// Eye Cancer
zbl.f.Vaccine_CreateConfig({
    name = "Eye Cancer",
    desc = "Causes the host to gradully lose their eye sight.",
    price = 1000,
    isvirus = true,
    duration = 60,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_rhizome_diff",
    research = {
        ["vaccine_points"] = 25,
        ["vaccine_time"] = 150,
        ["cure_points"] = 25,
        ["cure_time"] = 200,
        ["ranks"] = {
            ["superadmin"] = true,
            ["vip"] = true,
        }
    },
    occopation = {
      time = 60,
      infection_chance = 50,
      infection_radius = 200,
    },
    contamination = {
        time = 60,
        chance = 60,
    },
    mutation_chance = 35,
    mutation_stages = {
        [1] = {
            perception = "visual_blindness_weak",
        },
        [2] = {
            perception = "visual_blindness_medium",
        },
        [3] = {
            perception = "visual_blindness_strong",
        },
    },
})

// Ebola
zbl.f.Vaccine_CreateConfig({
    name = "Ebola",
    desc = "Causes explosive diarrhea on its host which creates contaminated areas!",
    price = 1000,
    isvirus = true,
    duration = 60,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_mold_diff",
    research = {
        ["vaccine_points"] = 30,
        ["vaccine_time"] = 200,
        ["cure_points"] = 25,
        ["cure_time"] = 250,
        ["ranks"] = {
            ["superadmin"] = true,
            ["vip"] = true,
        }
    },
    occopation = {
      time = 100,
      infection_chance = 80,
      infection_radius = 200,
    },
    contamination = {
        time = 500,
        chance = 75,
    },
    mutation_chance = 90,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 1.2,
                ["damage_modify"] = 1.1,
            },
            symptomes = {
                ["explosive_diarrhea"] = {interval = 5, damage = 0},
            },
            perception = "visual_distortion_weak",
        },
        [2] = {
            effects = {
                ["movement_speed"] = 2,
                ["damage_modify"] = 1.5,
            },
            symptomes = {
                ["explosive_diarrhea"] = {interval = 2, damage = 10},
            },
            perception = "visual_distortion_mutant",
            appearance = "appearance_braincells",
        },
    },
})

// Explosive Headache
zbl.f.Vaccine_CreateConfig({
    name = "Explosive Headache",
    desc = "Causes a strong Headache which untreated can cause the patients head to explode.",
    price = 1000,
    isvirus = true,
    duration = 60,
    cure = {
        immunity_time = 1200,
        ondeath = true,
        price = 2000,
    },
    mat = "zerochain/zblood/wounds/zbl_wound_zombiemeat_diff",
    research = {
        ["vaccine_points"] = 40,
        ["vaccine_time"] = 215,
        ["cure_points"] = 25,
        ["cure_time"] = 250,
        ["ranks"] = {
            ["superadmin"] = true,
            ["vip"] = true,
        }
    },
    occopation = {
      time = 60,
      infection_chance = 50,
      infection_radius = 200,
    },
    contamination = {
        time = 300,
        chance = 60,
    },
    mutation_chance = 110,
    mutation_stages = {
        [1] = {
            effects = {
                ["jump_modify"] = 300,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 1.5, damage = 0},
            },
            perception = "visual_headache_weak"
        },
        [2] = {
            effects = {
                ["jump_modify"] = 400,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 2, damage = 0},
            },
            perception = "visual_headache_weak"
        },
        [3] = {
            effects = {
                ["jump_modify"] = 500,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 2.5, damage = 0},
            },
            perception = "visual_headache_strong"
        },
        [4] = {
            effects = {
                ["jump_modify"] = 600,
                ["damage_fall_modify"] = 0
            },
            symptomes = {
                ["head_swelling"] = {scale = 3, damage = 0},
            },
            perception = "visual_headache_strong"
        },
        [5] = {
            symptomes = {
                ["explosive_head"] = {infect_distance = 300, infect_chance = 60},
            },
        },
    },
})

// Fire Resistance
zbl.f.Vaccine_CreateConfig({
    name = "Fire Resitance",
    desc = "Makes the patient Immune against fire.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        ["vaccine_points"] = 10,
        ["vaccine_time"] = 100,
        ["cure_points"] = 20,
        ["cure_time"] = 100,
        ["ranks"] = {
            //["superadmin"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["damage_fire_modify"] = 0,
            },
        },
    },
})

// Mobility Boost
zbl.f.Vaccine_CreateConfig({
    name = "Mobility Boost",
    desc = "Increases the patients move speed.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        ["vaccine_points"] = 10,
        ["vaccine_time"] = 35,
        ["cure_points"] = 20,
        ["cure_time"] = 50,
        ["ranks"] = {
            //["superadmin"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["movement_speed"] = 2,
            },
        },
    },
})

// Super Legs
zbl.f.Vaccine_CreateConfig({
    name = "Super Legs",
    desc = "Increases the patients jump height.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        ["vaccine_points"] = 10,
        ["vaccine_time"] = 35,
        ["cure_points"] = 20,
        ["cure_time"] = 40,
        ["ranks"] = {
            //["superadmin"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["damage_fall_modify"] = 0,
                ["jump_modify"] = 500,
            },

            symptomes = {
                ["legs_swelling"] = {scale = 1.75, damage = 0},
            },
        },
    },
})

// Invinsibility
zbl.f.Vaccine_CreateConfig({
    name = "Invinsibility",
    desc = "Makes the player Immune against any damage.",
    price = 1000,
    isvirus = false,
    duration = 60,
    cure = {
        immunity_time = 200,
        ondeath = true,
        price = 2000,
    },
    research = {
        ["vaccine_points"] = 75,
        ["vaccine_time"] = 60,
        ["cure_points"] = 25,
        ["cure_time"] = 60,
        ["ranks"] = {
            ["superadmin"] = true,
            ["vip"] = true,
        }
    },
    mutation_chance = -1,
    mutation_stages = {
        [1] = {
            effects = {
                ["damage_modify"] = 0.05,
            },
            appearance = "appearance_armor",
        },
    },
})




// The NPC buys your Viruses/Cures/Abillity Boosts and also has quests for you
zbl.config.NPC = {

    // Name of the npc
    name = "Kane - Genetic Engineer",

    // Color of the NPC/Interface
    SkinColor = Color(190,58,64,255),

    // How long till the player can do another quest / a new quest gets offered
    quest_cooldown = 300,

    // This will be filled with the quest configs bellow
    quests = {}
}

// Bring 3  unique blood samples (collected from 3 diffrent players) to the npc
zbl.f.Quest_CreateConfig({
    // The Type of Quest
    q_type = ZBL_SUPPLY_UNIQUE_PLAYER_SAMPLES,

    // The Name of the Quest
    name = "Blood Thief",

    // The Description of the Quest
    desc = "I need you to get me 3 unique blood samples.",

    // Count of items
    count = 3,

    // Money Reward
    money_reward = 5000,

    // DNA Points Reward (Remove this if you dont want to give the player DNA Points)
    dna_reward = 20,

    // Quest Time
    time = 600,
})

// Bring 3 samples of the specified virus (which were harvested from a virus node) to the npc
zbl.f.Quest_CreateConfig({
    q_type = ZBL_SUPPLY_VIRUS_SAMPLES,
    name = "Virus Sample Delivery",
    desc = "I need you to get me 3 samples from the Cold virus.",
    virus_id = 1,
    sample_class = "zbl_virusnode",
    count = 3,
    money_reward = 4000,
    dna_reward = 10,
    time = 600,
})

// Bring 1 fire resistance vaccine to the npc
zbl.f.Quest_CreateConfig({
    q_type = ZBL_SUPPLY_VACCINE,
    name = "Vaccine Delivery",
    desc = "I need you to get me 1 Fire Resistance vaccine.",
    virus_id = 7,
    count = 1,
    money_reward = 3000,
    dna_reward = 10,
    time = 600
})

// Bring 3 Cold Cures to the npc
zbl.f.Quest_CreateConfig({
    q_type = ZBL_SUPPLY_CURE,
    name = "Cure Delivery",
    desc = "I need you to get me 3 Cold cures.",
    virus_id = 1,
    count = 3,
    money_reward = 8000,
    time = 600
})

/*
This only is usefull if you have headcrabs on the server
// Bring 3 samples from a headcrab to the npc
zbl.f.Quest_CreateConfig({
    q_type = ZBL_SUPPLY_SAMPLES,
    name = "Sample Delivery",
    desc = "I need you to get me 3 samples from a Headcrab.",
    virus_id = nil,
    sample_class = "npc_headcrab",
    count = 3,
    money_reward = 5000,
    time = 600
})
*/

// Bring 2 Sars Cures to the npc
zbl.f.Quest_CreateConfig({
    q_type = ZBL_SUPPLY_CURE,
    name = "Cure Delivery",
    desc = "I need you to get me 2 SARS cures.",
    virus_id = 2,
    count = 2,
    money_reward = 8000,
    dna_reward = 10,
    time = 600
})





// Here you can specify if the model is male or female, so the script knows what sound to play
// For none specified models it will just play male/female sounds at random
zbl.SoundByModel = {}


zbl.SoundByModel["models/player/alyx.mdl"] = "female"
zbl.SoundByModel["models/player/p2_chell.mdl"] = "female"
zbl.SoundByModel["models/player/mossman.mdl"] = "female"

zbl.SoundByModel["models/player/kleiner.mdl"] = "male"
zbl.SoundByModel["models/player/monk.mdl"] = "male"
zbl.SoundByModel["models/player/corpse1.mdl"] = "male"
zbl.SoundByModel["models/player/police.mdl"] = "male"
zbl.SoundByModel["models/player/breen.mdl"] = "male"
zbl.SoundByModel["models/player/barney.mdl"] = "male"
zbl.SoundByModel["models/player/gman_high.mdl"] = "male"
zbl.SoundByModel["models/player/odessa.mdl"] = "male"
zbl.SoundByModel["models/player/eli.mdl"] = "male"
zbl.SoundByModel["models/player/charple.mdl"] = "male"
zbl.SoundByModel["models/player/soldier_stripped.mdl"] = "male"

zbl.SoundByModel["models/player/group02/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group02/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group02/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group02/male_08.mdl"] = "male"


zbl.SoundByModel["models/player/group01/male_01.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_03.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_05.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_07.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_08.mdl"] = "male"
zbl.SoundByModel["models/player/group01/male_09.mdl"] = "male"


zbl.SoundByModel["models/player/group03/male_01.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_03.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_05.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_07.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_08.mdl"] = "male"
zbl.SoundByModel["models/player/group03/male_09.mdl"] = "male"

zbl.SoundByModel["models/player/group03/female_01.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_02.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_03.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_04.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_05.mdl"] = "female"
zbl.SoundByModel["models/player/group03/female_06.mdl"] = "female"


zbl.SoundByModel["models/player/group03m/male_01.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_02.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_03.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_04.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_05.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_06.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_07.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_08.mdl"] = "male"
zbl.SoundByModel["models/player/group03m/male_09.mdl"] = "male"

zbl.SoundByModel["models/player/group03m/female_01.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_02.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_03.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_04.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_05.mdl"] = "female"
zbl.SoundByModel["models/player/group03m/female_06.mdl"] = "female"


zbl.SoundByModel["models/player/group01/female_01.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_02.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_03.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_04.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_05.mdl"] = "female"
zbl.SoundByModel["models/player/group01/female_06.mdl"] = "female"


zbl.SoundByModel["models/player/hostage/hostage_01.mdl"] = "male"
zbl.SoundByModel["models/player/hostage/hostage_02.mdl"] = "male"
zbl.SoundByModel["models/player/hostage/hostage_03.mdl"] = "male"
zbl.SoundByModel["models/player/hostage/hostage_04.mdl"] = "male"



// This defines a offsets for diffrent models so the gasmask allways fits perfect
zbl.ModelOffsets = {}
zbl.ModelOffsets["Default"] = {pos = Vector(2.9, 0, 0.6),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/kleiner.mdl"] = {pos = Vector(3.1, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/monk.mdl"] = {pos = Vector(3.6, 0, 0.85),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/corpse1.mdl"] = {pos = Vector(3.6, 0, 0),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/police.mdl"] = {pos = Vector(6, 0, 0),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/breen.mdl"] = {pos = Vector(3.3, 0, 0),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/alyx.mdl"] = {pos = Vector(2.6, 0, 0.6),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/p2_chell.mdl"] = {pos = Vector(2.8, 0, 0.8),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/barney.mdl"] = {pos = Vector(3.6, 0, 0.9),ang = Angle(-5, 0, 0)}
zbl.ModelOffsets["models/player/gman_high.mdl"] = {pos = Vector(3, 0, 1.9),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/odessa.mdl"] = {pos = Vector(3.7, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/mossman.mdl"] = {pos = Vector(3, 0.1, 0.7),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/eli.mdl"] = {pos = Vector(3, 0.1, 0.7),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/charple.mdl"] = {pos = Vector(1, 0, 0),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/soldier_stripped.mdl"] = {pos = Vector(2, 0, 0),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/group02/male_02.mdl"] = {pos = Vector(3.5, 0, 0.6),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group02/male_04.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group02/male_06.mdl"] = {pos = Vector(4, 0, 0.9),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group02/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}


zbl.ModelOffsets["models/player/group01/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group01/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}


zbl.ModelOffsets["models/player/group03/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}

zbl.ModelOffsets["models/player/group03/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/group03m/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zbl.ModelOffsets["models/player/group03m/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}

zbl.ModelOffsets["models/player/group03m/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group03m/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/group01/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/group01/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zbl.ModelOffsets["models/player/hostage/hostage_01.mdl"] = {pos = Vector(3, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/hostage/hostage_02.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zbl.ModelOffsets["models/player/hostage/hostage_03.mdl"] = {pos = Vector(3, 0, 0.2),ang = Angle(10, 0, 0)}
zbl.ModelOffsets["models/player/hostage/hostage_04.mdl"] = {pos = Vector(3, 0, 1),ang = Angle(0, 0, 0)}
