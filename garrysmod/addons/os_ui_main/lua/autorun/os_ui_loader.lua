    --[[
        There Loader for Mac OS UI.
    --]]

    OS_UI = OS_UI or {}

    local folder_client, folder_server, folder_root = "gui/", "core/", "os_ui/"

    OS_UI.Content = {
        { name = "os_ui_config", type = "shared" },
        { name = "os_ui_functions", type = "gui" },
        { name = "os_ui_avatar", type = "gui" },
        { name = "os_ui_hud_bar", type = "gui" },
        { name = "os_ui_hud", type = "gui" },
        { name = "os_ui_hud_components", type = "gui" },
        { name = "os_ui_core", type = "gui" },
        { name = "os_ui_scoreboard", type = "gui" },
        { name = "os_ui_clickable_panel", type = "gui" },
        { name = "os_ui_f4", type = "gui" },
        { name = "os_ui_server", type = "core" },
        { name = "os_ui_notifications", type = "gui" }
    }

    function OS_UI.Initialize()
        if SERVER then 
            resource.AddWorkshop( "1922363933" )
        end
        for k, v in pairs( OS_UI.Content ) do
            v.name = v.name .. ".lua"
            if v.type == "core" then
                if SERVER then include( folder_root .. folder_server .. v.name ) end
            elseif v.type == "gui" then
                if SERVER then AddCSLuaFile( folder_root .. folder_client .. v.name ) else include( folder_root .. folder_client .. v.name ) end
            else
                if SERVER then AddCSLuaFile( folder_root .. v.name ) include( folder_root .. v.name ) else include( folder_root .. v.name ) end
            end
        end
    end

    OS_UI.Initialize()