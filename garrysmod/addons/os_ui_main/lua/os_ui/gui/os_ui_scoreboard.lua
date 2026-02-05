if not OS_UI.Settings.Enable_Scoreboard then return end

OS_UI.Scoreboard = {}
local self = nil
function OS_UI.OnScoreboardShow()
    if not self or not IsValid( self ) then
        local openTime = CurTime()
        local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
        local low_res = scr_w < 1600

        self = vgui.Create( "DFrame" )
        self:SetSize( scr_w * ( low_res and 0.65 or 0.48 ), scr_h * ( low_res and 0.8 or 0.7 ) )
        if OS_UI.Settings.Enable_Scoreboard_Animation then
            self:SetPos( scr_w / 2 - self:GetWide() / 2, scr_h * 1 )
            self:MoveTo( scr_w / 2 - self:GetWide() / 2 , scr_h / 2 - self:GetTall() / 2, 0.3, 0, 1 )
        else
            self:Center()
        end
        self:SetTitle( "" )
        self:SetDraggable( false )
        self:ShowCloseButton( false )

        local icon_text_point = self:GetTall() * 0.069 
        self.Paint = function( me, w, h )
            Derma_DrawBackgroundBlur( me, openTime ) 
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND )
        end

        --> The header with the server name and Mac Icons <--
        self.Header = vgui.Create( "DPanel", self )
        self.Header:Dock( TOP )
        self.Header:SetTall( 40 )
        self.Header:DockMargin( -5, -30, -5, 0 )
        self.Header:InvalidateLayout( true )

        self.Header.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
            OS_UI.DrawText( OS_UI.Settings.Server_Name, "OS_UI.Font.22", w / 2, h / 2, OS_UI.Colors.GREY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            OS_UI.DrawMacIcons( w - 60, h / 2 - 4 )
        end

        self.Info_Header = vgui.Create( "DPanel", self )
        self.Info_Header:Dock( TOP )
        self.Info_Header:SetTall( self.Header:GetTall() )
        self.Info_Header:DockMargin( -5, 0, -5, 0 )

        self.Info_Header.Height_Point = self.Info_Header:GetTall() / 2 - 15
        self.Info_Header.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.DARK_BLACK )
            OS_UI.DrawIconText( OS_UI.Icons.NAME, "Nome", w * 0.02, self.Info_Header.Height_Point, OS_UI.Colors.WHITE, nil, true )
            OS_UI.DrawIconText( OS_UI.Icons.JOB, "Profissão", w * 0.31, self.Info_Header.Height_Point, OS_UI.Colors.WHITE, nil, true )
            OS_UI.DrawIconText( OS_UI.Icons.RANK, "Patente", w * 0.61, self.Info_Header.Height_Point, OS_UI.Colors.WHITE, nil, true )
            OS_UI.DrawIconText( OS_UI.Icons.PING, "Ping", w * 0.89, self.Info_Header.Height_Point, OS_UI.Colors.WHITE, nil, true )
        end

        self.Player_Panel = vgui.Create( "DPanelList", self )
        self.Player_Panel:Dock( FILL )
        self.Player_Panel:SetSpacing( 1 )
        self.Player_Panel:DockMargin( -5, 0, -5, -5 )

        local sorted_players = {}
        for k, v in pairs( player.GetAll() ) do
            table.insert( sorted_players, { v = v, name = team.GetName( v:Team() ) } )
        end
        table.sort( sorted_players, function( a, b ) return a.name < b.name end )

        for k, v in pairs( sorted_players ) do
            -- Get info while they're still valid.
            v = v.v
            if not IsValid( v ) then continue end  
            local name, job_name, rank, rank_color = v:Nick(), team.GetName( v:Team() ), v:GetUserGroup(), OS_UI.Colors.GREY
            local job_color = OS_UI.Colors.GREY
            local cmd_button_size = #OS_UI.Settings.Scoreboard_Commands

            if not OS_UI.Settings.Scoreboard_Ranks[ rank ] then
                rank = rank:gsub( "^%l", string.upper )
            else
                local data = OS_UI.Settings.Scoreboard_Ranks[ rank ]
                rank, rank_color = data.title or "Jogador", data.color or OS_UI.Colors.GREY
            end
            
            local button_size = math.floor( cmd_button_size ) / 7 > 1 and math.floor( cmd_button_size ) / 7 or 40
            self.Player_Row, self.Inner_Panel = OS_UI.CreateClickableRow( self.Player_Panel, 0, 45, button_size )
            self.Player_Row.Tall = 45 / 2
            self.Player_Row.Paint = function( me, w, h )
                OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
                OS_UI.DrawText( name, "OS_UI.Font.20", 50, self.Player_Row.Tall, OS_UI.Colors.GREY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                OS_UI.DrawText( job_name, "OS_UI.Font.20", w * 0.357, self.Player_Row.Tall, job_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                OS_UI.DrawText( rank, "OS_UI.Font.20", w * 0.663, self.Player_Row.Tall, rank_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                OS_UI.DrawText( IsValid( v ) and ( v:Ping() or 0 ) .. " ms", "OS_UI.Font.20", w * 0.96, self.Player_Row.Tall, OS_UI.Colors.GREY, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
            end

            self.Player_Icon = vgui.Create( "CircleAvatar", self.Player_Row )
            self.Player_Icon:SetPos( self:GetWide() * 0.018, self.Player_Row.Tall / 2 - 1 )
            self.Player_Icon:SetSize( 28, 28 )
            self.Player_Icon:SetPlayer( v, 28 )

            self.Buttons_Menu = vgui.Create( "DPanelList", self.Inner_Panel )
            self.Buttons_Menu:Dock( FILL )
            self.Buttons_Menu:DockMargin( 6, 6, 6, 6 )
            self.Buttons_Menu:SetTall( button_size )
            self.Buttons_Menu:EnableHorizontal( true )
            self.Buttons_Menu:SetSpacing( 5 )

            for key, value in pairs( OS_UI.Settings.Scoreboard_Commands ) do
                value.button_name = value.button_name or "Unknown"
                value.execution_message = value.execution_message or "Command attempted to execute."
                local command = OS_UI.CreateButton( button_panel, 0, 0, 100, 27, "OS_UI.Font.18", value.button_name )
                command.Paint = function( me, w, h )
                    OS_UI.DrawRect( 0, 0, w, h, me:IsHovered() and OS_UI.Colors.BASE_BACKGROUND or OS_UI.Colors.BASE_HEADER )
                end     
                command.DoClick = function( me )
                    if v == ply then OS_UI.SendMessage( "Você não pode usar comandos em si mesmo" ) return end
                    if not IsValid( v ) then OS_UI.SendMessage( "Jogador saiu do servidor" ) return end
                    local command_instance, message_instance = value.command, value.execution_message
                    command_instance = string.gsub( command_instance, "#target", v:Nick() )
                    message_instance = string.gsub( message_instance, "#target", v:Nick() )
                    ply:ConCommand( command_instance )
                end
                self.Buttons_Menu:AddItem( command )
            end

            self.Player_Panel:AddItem( self.Player_Row )
        end

        gui.EnableScreenClicker( true )
        return true
    end
end
hook.Add( "ScoreboardShow", "OS_UI.ShowScoreboard", OS_UI.OnScoreboardShow )

function OS_UI.OnScoreboardHide()
    if IsValid( self ) then
        self:Remove()
        self = nil
        gui.EnableScreenClicker( false )
        return true
    end
end
hook.Add( "ScoreboardHide", "OS_UI.HideScoreboard", OS_UI.OnScoreboardHide )	