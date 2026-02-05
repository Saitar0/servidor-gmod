
    if string.lower( OS_UI.Settings.HUD_Type ) == "normal" or string.lower( OS_UI.Settings.HUD_Type ) == "none" then return end
    

    --> The function we use to create a Circle Avatar (on screen) <--
    function OS_UI.PrepareAvatar( ent )
        if ent == LocalPlayer() then
            local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
            local icon_image = vgui.Create( "CircleAvatar" )
            icon_image:SetPos( scr_w * 0.005, scr_h * 0.006 )
            icon_image:SetSize( 32, 32 )
            icon_image:SetPlayer( ply, 32 )
        end
    end
    hook.Add( "OnEntityCreated", "OS_UI.PrepareAvatar", OS_UI.PrepareAvatar )
    
    --> Draws the actual bar hud, not much explaining needed here <--
    function OS_UI.DrawBarHUD()
        local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
        local bar_w, bar_h, text_y = scr_w, 43.2, 6

        local name, job_name, health, armor = OS_UI.CutStringLength( ply:Nick() or "Unknown", "OS_UI.Font.23", 128, 12 ), team.GetName( ply:Team() ), ply:Health(), ply:Armor() 

        local name_width = OS_UI.GetStringSize( "OS_UI.Font.25", name )
        local job_width = OS_UI.GetStringSize( "OS_UI.Font.21", job_name )
        local wallet_width = OS_UI.GetStringSize( "OS_UI.Font.21", ply:getDarkRPVar( "money" ) or 0 )
        local health_width = OS_UI.GetStringSize( "OS_UI.Font.21", health )
        local armor_width = OS_UI.GetStringSize( "OS_UI.Font.21", armor )

        local start_pos = 55.28 + name_width 
        
        OS_UI.DrawRect( 0, 0, bar_w, bar_h, OS_UI.Colors.BASE_BACKGROUND )
        OS_UI.DrawText( name, "OS_UI.Font.23", 48, 7.3, OS_UI.Colors.WHITE, TEXT_ALIGN_LEFT )

        OS_UI.DrawIconText( OS_UI.Icons.JOB, job_name, start_pos, text_y, OS_UI.Colors.WHITE )
        OS_UI.DrawIconText( OS_UI.Icons.WALLET, "$" .. string.Comma( ply:getDarkRPVar( "money" ) or 0 ), start_pos + job_width + 38.4, text_y, OS_UI.Colors.WHITE )
        OS_UI.DrawIconText( OS_UI.Icons.SALARY, "$" .. string.Comma( ply:getDarkRPVar( "salary" ) or 0 ), start_pos + job_width + wallet_width + 92.16, text_y, OS_UI.Colors.WHITE )
        OS_UI.DrawIconText( OS_UI.Icons.HEALTH, string.Comma( ply:Health() < 0 and 0 or ply:Health() or 0 ) .. "%", start_pos + job_width + wallet_width + 162.12, text_y, OS_UI.Colors.WHITE )
        OS_UI.DrawIconText( OS_UI.Icons.ARMOR, string.Comma( armor or 0 ) .. "%", start_pos + job_width + wallet_width + health_width + 213.84, text_y, OS_UI.Colors.WHITE )
        OS_UI.DrawIconText( OS_UI.Icons.CLOCK, os.date( "%A" ) .. ", " .. os.date( "%H:%M %p", os.time() ), scr_w - 109.44, text_y, OS_UI.Colors.WHITE, true )
    
        if OS_UI.Settings.Enable_Food then
            OS_UI.DrawIconText( OS_UI.Icons.HUNGER, ( ply:getDarkRPVar( "Energy" ) or 0 ) .. "%", start_pos + job_width + wallet_width +  health_width + armor_width + 267, text_y, OS_UI.Colors.WHITE )
        end

        OS_UI.DrawMacIcons( scr_w - 63.36, 15 )
        --> Generates all the other components, Agenda, Arrested, Lockdown etc <--
        OS_UI.GenerateGeneric( scr_w, scr_h, ply )
    end
    hook.Add( "HUDPaint", "OS_UI.DrawBarHUD", OS_UI.DrawBarHUD )