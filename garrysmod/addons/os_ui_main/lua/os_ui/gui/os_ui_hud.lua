
    if string.lower( OS_UI.Settings.HUD_Type ) == "bar" or string.lower( OS_UI.Settings.HUD_Type ) == "none" then return end

    --> The function we use to create a Circle Avatar (on screen) <--
    local iconCreated = false
    function OS_UI.PrepareAvatar( ent )
        if ent == LocalPlayer() and not iconCreated then
            local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
            local icon_image = vgui.Create( "CircleAvatar" )
            icon_image:SetPos( 23, scr_h - 162 * 0.77 )
            icon_image:SetSize( 54, 54 )
            icon_image:SetPlayer( ply, 54 )
            iconCreated = true
        end
    end
    hook.Add( "OnEntityCreated", "OS_UI.PrepareAvatar", OS_UI.PrepareAvatar )


    local maxHealth = 100
    --> Create the base hud <--
    function OS_UI.DrawBaseHUD()
        local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
        local using_food = false
        local initial_width, initial_height = using_food and 330 or 265, 162
        local start_x, start_y = 7, scr_h - initial_height * 1.07
        local name, job_name, wallet, salary = ply:Nick(), team.GetName( ply:Team() ), ply:getDarkRPVar( "money" ) or 0, ply:getDarkRPVar( "salary" ) or 0
        
        local job_length = OS_UI.GetStringSize( "OS_UI.Font.22", job_name )
        local wallet_length = OS_UI.GetStringSize( "OS_UI.Font.22", wallet )
        local salary_length = OS_UI.GetStringSize( "OS_UI.Font.22", salary )

        local info_text_y, bar_display_y = 59.4, 90.24
        initial_width = initial_width + job_length + wallet_length

        local size = initial_width - 90
        local health_width, armor_width = size / 100 * ply:Health(), size / 100 * ply:Armor()
        local health_bar_color = OS_UI.Colors.RED
        if ply:Health() < 30 then
            health_bar_color = Color( 174 + math.abs( math.sin( CurTime() * 4 ) * 81 ), 30, 30, 250 )
        end
        maxHealth = Lerp( 4 * FrameTime(), maxHealth, ply:Health() )

        OS_UI.DrawRoundedBox( 6, start_x, start_y, initial_width, initial_height, OS_UI.Colors.BASE_BACKGROUND )
        OS_UI.DrawRoundedBox( 6, start_x, start_y, initial_width, 39.96, OS_UI.Colors.BASE_HEADER )
        
        OS_UI.DrawText( name, "OS_UI.Font.Bold.22", start_x + 14.56, start_y + 9.64, OS_UI.Colors.WHITE, TEXT_ALIGN_LEFT )
        OS_UI.DrawMacIcons( start_x + initial_width - 63.36, start_y + 15.12 )
        
            OS_UI.DrawIconText( OS_UI.Icons.JOB, job_name, start_x + 80.48, start_y + info_text_y, OS_UI.Colors.WHITE )
            OS_UI.DrawIconText( OS_UI.Icons.WALLET, "$" .. string.Comma( wallet ), start_x + job_length + 120.48, start_y + info_text_y, OS_UI.Colors.WHITE )
            OS_UI.DrawIconText( OS_UI.Icons.SALARY, "$" .. string.Comma( salary ), start_x + job_length + wallet_length + 174.08, start_y + info_text_y, OS_UI.Colors.WHITE )
        if using_food then
            OS_UI.DrawIconText( OS_UI.Icons.HUNGER, ( ply:getDarkRPVar( "Hunger" ) or 0 ) .. "%", start_x + job_length + wallet_length + 244.08, start_y + info_text_y, OS_UI.Colors.WHITE )
        end
        OS_UI.DrawIconBar( OS_UI.Icons.HEALTH, start_x + 28, start_y + 105.6, size, size / 100 * maxHealth + 1, 4, health_bar_color )
        OS_UI.DrawIconBar( OS_UI.Icons.ARMOR, start_x + 28, start_y + 132.48, size, armor_width, 4, OS_UI.Colors.BLUE )
        
        --> Generates all the other components, Agenda, Arrested, Lockdown etc <--
        OS_UI.GenerateGeneric( scr_w, scr_h, ply )

        if OS_UI.Settings.Enable_Overhead_HUD then OS_UI.DrawOverheadHUD() end
    end
    hook.Add( "HUDPaint", "OS_UI.DrawBaseHUD", OS_UI.DrawBaseHUD )
