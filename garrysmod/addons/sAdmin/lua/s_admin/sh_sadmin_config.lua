sAdmin = sAdmin or {}
sAdmin.config = sAdmin.config or {}

--  _______       _          _______              ___ _       
-- (_______)     (_)        (_______)            / __|_)      
--  _  _  _ _____ _ ____     _       ___  ____ _| |__ _  ____ 
-- | ||_|| (____ | |  _ \   | |     / _ \|  _ (_   __) |/ _  |
-- | |   | / ___ | | | | |  | |____| |_| | | | || |  | ( (_| |
-- |_|   |_\_____|_|_| |_|   \______)___/|_| |_||_|  |_|\___ |
--                                                     (_____|

sAdmin.config["language"] = "en"

sAdmin.config["prefix"] = "[sAdmin] "

sAdmin.config["chat_prefix"] = {Color(0,140,255), "[sAdmin] "}

sAdmin.config["chat_command"] = {
    ["!sadmin"] = true,
    ["!menu"] = true,
    ["/menu"] = true
}

sAdmin.config["disabled_modules"] = {
    ["Warns"] = false,
    ["Chat"] = false,
    ["DarkRP"] = false,
    ["Fun"] = false
}

sAdmin.config["chat_command_prefix"] = {
    ["!"] = true,
    ["/"] = true
}

sAdmin.config["silent_chat_command_prefix"] = {
    ["$"] = true
}

sAdmin.config["ignore_immunity_cmds"] = { -- You can specify which commands will ignore immunity.
    ["pm"] = true,
}

sAdmin.config["console_prints"] = {
    ["attempt_call"] = true, -- [sAdmin] Stromic | Hellstorm.io ran command noclip with args [N/A]
    ["fine_print"] = true -- [sAdmin] Stromic | Hellstorm.io toggled noclip for Stromic | Hellstorm.io.
}

sAdmin.config["super_users"] = { -- This is where you will add the sid's that will ALWAYS be able to change permissions, i recommend steamid.io to get their steamid64.
    ["76561198972098406"] = true,
}

sAdmin.config["sizing"] = { -- This is where you can define the sizing of the menus
    ["menu"] = {
        x = 780,
        y = 550
    },
}

sAdmin.config["hide_insufficient_perms_cmds"] = true -- This will hide the commands you cannot use instead of making them red in the menu.

sAdmin.config["ban_message"] = [[
--------------- You are banned ---------------

Admin: %s

Reason: %s

Time left: %s
]]

sAdmin.config["warns"] = { -- Warns settings.
    ["active_time"] = "1d",
    ["punishments"] = {
        [3] = {
            type = "kick"
        },
        [5] = {
            type = "ban",
            time = "1d"
        },
        [6] = {
            type = "ban",
            time = "2d"
        },
    }
}

sAdmin.config["adverts"] = {
    {
        msg = {Color(255,255,255), "Há ", Color(0,200,0), player.GetCount, Color(255,255,255), " jogadores no momento!"}, -- Message with multicolor support!
        time = "1800", -- Every 30 minutes
        offset = "200" -- Offset the time
    },
}

sAdmin.config["auto_cloak_on_noclip"] = true

sAdmin.config["auto_god_on_noclip"] = true
 
sAdmin.config["colors"] = {
    ["green_ply"] = Color(0,161,54),
    ["orange_ply"] = Color(245,179,37),
    ["red_ply"] = Color(185,43,43)
}

hook.Run("sA:ConfigReloaded")