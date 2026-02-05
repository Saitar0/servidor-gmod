zcm = zcm or {}
zcm.f = zcm.f or {}
zcm.config = zcm.config or {}

/////////////////////////// Zeros Crackermaker /////////////////////////////

// Developed by ZeroChain:
// http://steamcommunity.com/id/zerochain/
// https://www.gmodstore.com/users/view/76561198013322242

// If you wish to contact me:
// clemensproduction@gmail.com

/////////////////////////////////////////////////////////////////////////////

// This enables the Debug Mode
zcm.config.Debug = false

// Switches between FastDl and Workshop
zcm.config.EnableResourceAddfile = false

// Currency
zcm.config.Currency = "R$"

// The language , en , de , fr , pl , ru , pt , es
zcm.config.SelectedLanguage = "pt"

// These Ranks are allowed to use the debug commands and the save command for the buyer npcs  !savezcm
zcm.config.AdminRanks = {"superadmin","owner"}

// This will add the Player as the Owner of the entities for Falcos Prop Protection System
zcm.config.CPPI = true

zcm.config.CrackerMachine = {
    Paper_Cap = 800, // How much paper can the machine hold
    BlackPowder_Cap = 400, // How much blackpowder can the machine hold
    PaperRoll_Cap = 25, // How many paperrolls can the machine hold
    Usage_BlackPowder = 25, // How much blackpowder gets used per firework
    Usage_Paper = 10, // How much paper gets used to create 4 PaperRolls

    // The upgrades influence the work speed of the machine
    Upgrades = {
        Ranks = {}, // These ranks are allowed to buy a upgrade, Leave empty to disable the rank restriction
        Count = 10, // How many levels can the machine have
        Cost = 2500, // How much does a upgrade cost
        Cooldown = 10, // How long till the player can buy another upgrade
        AutoUpgrade_Count = 16 // How much firework does the machine needs to produce before it gets a LevelUp by itself, Set to 0 to disable the auto upgrade
    },
}

zcm.config.BlackPowder = {
    Amount = 100, // How much BlackPowder does one bag contain
    Damage = 0, // How much damages does the BlackPowder inflict on players if it explodes
}

zcm.config.Paper = {
    Amount = 400, // How much Paper does one roll contain
}

zcm.config.FireCracker = {
    CrackerCount = 15, // How many cracker will it spawn on explosion, Note* The crackers entities are only created on client and
    // the spawn amount will also be reduced if necessary by the clients zcm_cl_vfx_effectcount setting to prevent a OverFlow
}

zcm.config.SellBox = {

    // These Jobs can sell the illegal firework, Leave empty to disable the Job restriction
    Jobs = {"Fabricante de Fogos de Artifício"},

    // A sell box can hold up to 8 firework products and can only be sold once its full, The Sell Price gets multiplied by 8
    SellPrice = {
        ["Default"] = 520, // Dont Remove this value, its used for every rank thats not specified!
        ["vip"] = 550,
        ["superadmin"] = 550,
    },

    DirectSell = false, // If set to false then this changes the sell button on the box to a collect button so it can be sold to the npc later
}

zcm.config.NPC = {
    Model = "models/odessa.mdl" , // The model of the npc
    Capabilities = true, // Setting this to false will improve network performance but disables the npc reactions for the player

    // The values below define the minimum and maximum buy rate of the npc in percentage.
    // The base money the player will recieve is still defined in the SellPrice var above but this modifies it to be diffrent from npc to npc.
    // If you dont want this then just set both to 100
    MaxBuyRate = 115,
    MinBuyRate = 75,

    RefreshRate = 600, // The interval at which the buy rate changes in seconds, set to -1 to disable the refreshing of the price modifier
}

zcm.config.Player = {
    ResetFirework_OnDeath = false, // Do we want to reset the players collected firework if he dies?
}

// Do we have VrondakisLevelSystem installed?
zcm.config.VrondakisLevelSystem = false
zcm.config.Vrondakis = {}
zcm.config.Vrondakis["Producing"] = {XP = 25} // XP per produced Firework
zcm.config.Vrondakis["Selling"] = {XP = 25}	// XP per Sold Firework
