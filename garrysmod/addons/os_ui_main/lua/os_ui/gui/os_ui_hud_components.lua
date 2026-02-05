    --[[
        This file is in charge of all the external HUD visuals.
        This includes: Agenda, Wanted, Arrested, etc.
        Just to keep things nice and tidy.
    --]]

    local OS_UI_Meta = FindMetaTable( "Player" )

    --> Called when we want to replicate a blank box to store shit in <--
    function OS_UI.CreatePopup( icon, header, message, x, y, static, static_size )
        local scr_w, scr_h = ScrW(), ScrH()
        local width, height = surface.GetTextSize( message )
        local box_w, box_h = 390, not static and 64.8 + 0.040 * width or 110
        x = x - box_w / 2
        surface.SetFont( "OS_UI.Font.21" )
        message = message or "Ops, parece que nenhuma mensagem foi enviada."
        OS_UI.DrawRoundedBox( 6, x, y, box_w, box_h, OS_UI.Colors.BASE_BACKGROUND )
        OS_UI.DrawRect( x + 2, y, box_w - 2, 35, OS_UI.Colors.BASE_HEADER )
        OS_UI.DrawText( header, "OS_UI.Font.25", x + box_w / 2, y + 4, OS_UI.Colors.WHITE )
        message = DarkRP.textWrap( message, "OS_UI.Font.20", box_w - 5 )
        draw.DrawNonParsedText( message, "OS_UI.Font.20", x + 7, y + 37, OS_UI.Colors.GREY, 0 )
    end

    --> Easily creates two bars inside of eachother, for Health/Armor <--
    function OS_UI.DrawIconBar( icon, x, y, w, val, h, col )
        val = val or 100
        OS_UI.DrawTexture( icon, x, y, 24, 24, OS_UI.Colors.GREY )
        OS_UI.DrawRect( x + 32, y + 10, w, h, OS_UI.Colors.WHITE )
        OS_UI.DrawRect( x + 32, y + 10, val > w and w or val, h, col )
    end

    --> Draws the ammo counter down the bottom left <--
    function OS_UI.DrawAmmo( x, y )
        local scr_w, scr_h, self = ScrW(), ScrH(), LocalPlayer()
        if not self:Alive() or not self:GetActiveWeapon() then
            return
        end
        local weapon = self:GetActiveWeapon()
        if not IsValid( weapon ) then return end
        local weapon_name = string.lower( weapon:GetPrintName() )
        local clip, reserve = self:GetActiveWeapon():Clip1(), self:GetAmmoCount( self:GetActiveWeapon():GetPrimaryAmmoType() )
        if clip < 0 then return end
        local margin = 234.416
        OS_UI.DrawRoundedBox( 6, x - margin, y, 230, 86, OS_UI.Colors.BASE_BACKGROUND )
        OS_UI.DrawRoundedBox( 6, x - margin, y, 230, 32, OS_UI.Colors.BASE_HEADER )
        OS_UI.DrawTexture( OS_UI.Icons.WEAPONS, x - margin + 5, y + scr_h * 0.004, 24, 24, OS_UI.Colors.GREY )
        OS_UI.DrawText( weapon_name:gsub( "^%l", string.upper ), "OS_UI.Font.24", x - margin + 35, y + 3.16, OS_UI.Colors.WHITE, TEXT_ALIGN_LEFT )
        OS_UI.DrawText( clip .. " / " .. reserve, "OS_UI.Font.40", x - 115, y + 38, OS_UI.Colors.GREY )
    end

    --> Override both as we don't need them <--
    if OS_UI.Settings.Enable_Overhead_HUD then
        OS_UI_Meta.drawPlayerInfo = function( target )

        end

        OS_UI_Meta.drawWantedInfo = function( targ )

        end
    end

    local start_time, length = 0, 0
    function OS_UI.GetArrestTime()
        start_time = CurTime()
        length = net.ReadInt( 16 )
    end
    net.Receive( "OS_UI.Send.ArrestTime", OS_UI.GetArrestTime )

    --> Builds the foundation for essential DarkRP Popups <--
    function OS_UI.GenerateGeneric( scr_w, scr_h, ply )
        local agenda = ply:getAgendaTable()
        local wanted, reason = OS_UI.IsPlayerWanted( ply )
        local lockdown, arrested = OS_UI.IsLockdownActive(), ply:isArrested()
        local y_pos = 50
        if wanted and not arrested then
            OS_UI.CreatePopup( nil, "PROCURADO", "Você foi declarado procurado por: " .. reason, scr_w / 2, lockdown and 140 or y_pos )
        end
        if lockdown and not arrested then
            OS_UI.CreatePopup( nil, "TOQUE DE RECOLHER", DarkRP.getPhrase( "lockdown_started" ), scr_w / 2, y_pos )
        end
        if arrested then
            local time = math.Round( length - math.abs( start_time - CurTime() ) )
            OS_UI.CreatePopup( nil, "Preso", "Você foi preso! Tempo restante: " .. OS_UI.SecondsToClock( time ) .. " segundos até a libertação!", scr_w / 2, y_pos )
        end
        OS_UI.DrawAmmo( scr_w * 1, scr_h - 90 )
        if not agenda or not OS_UI.Settings.Enable_Agenda then return end
        if not ply:getDarkRPVar( "agenda" ) then return end
        local text = ply:getDarkRPVar( "agenda" ):gsub( "//", "\n" ):gsub( "\\n", "\n" )
        OS_UI.CreatePopup( nil, agenda.Title, text, 200, y_pos, true, 440 )
    end

