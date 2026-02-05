    
    if not OS_UI.Settings.Enable_Notifications then return end

    local active = {}

    local icon_types = {}
    icon_types[ 0 ] = { icon = OS_UI.Icons.HINT, color = nil }
    icon_types[ 1 ] = { icon = OS_UI.Icons.ERROR, color = OS_UI.Colors.RED }
    icon_types[ 2 ] = { icon = OS_UI.Icons.UNDO, color = nil }
    icon_types[ 3 ] = { icon = OS_UI.Icons.GENERIC, color = nil }
    icon_types[ 4 ] = { icon = OS_UI.Icons.CLEANUP, color = nil }

    function notification.AddLegacy( text, type, time )
        OS_UI.PrepareNotification( text, type, time )
    end

    function OS_UI.PrepareNotification( text, type, time )
        local scr_w, scr_h = ScrW(), ScrH()
        surface.SetFont( "OS_UI.Font.22" )
        local width, height = surface.GetTextSize( text )

        local panel_width, panel_height = 13.44 + width + 32, 37.8
        local notification = vgui.Create( "DPanel" )
        notification:SetSize( panel_width, panel_height )
        local start = scr_w - notification:GetWide() - 3
        notification:SetPos( scr_w * 1 + panel_width, scr_h * 0.8 - ( #active - 1 ) * 50 )
        notification:MoveTo( start, scr_h * 0.8 - ( #active - 1 ) * 50, 0.1, 0, 1 )

        
        -- Match remove time to animation --
        timer.Simple( time, function()
            local anim_dur = 2
            local me = notification
            local x, y = me:GetPos()
            table.RemoveByValue( active, me )
            me:MoveTo( scr_w + ( panel_width * 2 ), y, 0.1, 0, anim_dur )
            for k, v in pairs( active ) do
                if IsValid( v ) then
                    local x, y = v:GetPos()
                    v:MoveTo( x, scr_h * 0.8 - ( 50 * ( k - 1 ) ), 0.1, 0, anim_dur )
                end
            end
            timer.Simple( anim_dur, function() me:Remove() end )
        end )

        notification.Time = CurTime() + time
        notification.Lerp = notification:GetWide() - 32
        notification.Paint = function( me, w, h )
            local icon = icon_types[ type ] or icon_types[ 1 ]
            icon.color = icon.color or OS_UI.Colors.WHITE
            local bar_size = ( w - 32 ) / time * math.Round( notification.Time - CurTime() )
            notification.Lerp = Lerp( 10 * FrameTime(), notification.Lerp, bar_size )
            OS_UI.DrawRoundedBox( 6, 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND )
            OS_UI.DrawRoundedBox( 6, 0, 0, 32, h, OS_UI.Colors.BASE_HEADER )
            OS_UI.DrawText( text, "OS_UI.Font.22", scr_w * 0.02, h / 2 - height / 2 - 2, OS_UI.Colors.WHITE, TEXT_ALIGN_LEFT )
            OS_UI.DrawTexture( icon.icon, 32 / 2 - 24 / 2 + 1, h / 2 - 24 / 2, 24, 24, icon.color )
            OS_UI.DrawRect( 0 + 32, h - scr_h * 0.003, me.Lerp, scr_h * 0.003, OS_UI.Colors.WHITE )
        end

        notification:SetVisible( true )

        table.insert( active, notification )
    end



