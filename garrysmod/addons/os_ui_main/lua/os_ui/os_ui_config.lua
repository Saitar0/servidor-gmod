
    --[[
        OS UI - coded by ted.lua (https://steamcommunity.com/id/tedlua/)

        Credits to DanFMN (Danny) for his help on small parts of this script.
    --]]
    
    OS_UI.Settings = OS_UI.Settings or {} -- Don't touch

    OS_UI.Settings.HUD_Type = "normal" -- "bar" for bar hud or "normal" for normal hud or "none" to disable.
    OS_UI.Settings.Enable_Mac_Icons = true -- Enable Mac OS Icons?
    OS_UI.Settings.Enable_Food = false -- Enable DarkRP food?
    OS_UI.Settings.Enable_Agenda = false -- Enable the DarkRP Agenda?
    OS_UI.Settings.Enable_Overhead_HUD = true -- Enable the custom overhead?

    OS_UI.Settings.Server_Name = "McRP" -- The name to shown in F4/Scoreboard

    OS_UI.Settings.Enable_Scoreboard = true -- Is the scoreboard enabled?
    OS_UI.Settings.Enable_Scoreboard_Animation = true -- Enable opening animation?
    -- Configuração do Placar - Ranks
    OS_UI.Settings.Scoreboard_Ranks = {
        [ "superadmin" ] = { title = "Administrador", color = Color( 214, 48, 49 ) },
        [ "user" ] = { title = "Jogador", color = Color( 166, 166, 166 ) },
        [ 'VIP' ] = { title = 'VIP', color = Color( 255, 255, 0 ) },
        [ 'PREMIUM' ] = { title = 'Premium', color = Color( 255, 255, 0 ) },
    }

    -- Configure os comandos do Placar aqui: #target representa o jogador selecionado.
    OS_UI.Settings.Scoreboard_Commands = {
        { button_name = "Matar", execution_message = "", command = "ulx slay #target" },
        { button_name = "Puxar", execution_message = "", command = "ulx bring #target" },
        { button_name = "Teleportar para", execution_message = "", command = "ulx goto #target" },
        { button_name = "Silenciar", execution_message = "", command = "ulx mute #target" },
        { button_name = "Prisão", execution_message = "", command = "ulx jail #target" },
        { button_name = "Congelar", execution_message = "", command = "ulx freeze #target" }
    }

    OS_UI.Settings.Enable_F4 = true -- Is the F4 menu enabled?
    OS_UI.Settings.Enable_Vehicle_Tab = false -- Enable the Vehicle tab?
    OS_UI.Settings.Enable_Notifications = true -- Enable custom notifications?

    OS_UI.WebsiteLink = "https://discord.gg/snuSxq9cG7" -- Links shown in F4 Menu
    OS_UI.CollectionLink = "https://steamcommunity.com/sharedfiles/filedetails/?id=3655899845&savesuccess=1" -- Links shown in F4 Menu
    OS_UI.DonationLink = "https://www.google.co.uk" -- Links shown in F4 Menu


