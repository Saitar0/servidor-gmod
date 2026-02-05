    
    OS_UI.Colors = {
        BASE_BACKGROUND = Color( 30, 30, 30 ),
        BASE_HEADER = Color( 43, 43, 43 ),
        DARK_BLACK = Color( 52, 52, 52 ),
        WHITE = Color( 255, 255, 255 ),
        GREY = Color( 166, 166, 166 ),
        RED = Color( 214, 48, 49 ),
        ORANGE = Color( 253, 193, 47 ),
        GREEN = Color( 54, 205, 66, 175 ),
        BLUE = Color( 0, 168, 255 )
    }

    --> The materials we want to render as ENUMS. <--
    OS_UI.Icons = {
        JOB = Material( "os_ui_jobs.png" ),
        WALLET = Material( "os_ui_wallet.png" ),
        SALARY = Material( "os_ui_salary.png" ),
        HEALTH = Material( "os_ui_health.png" ),
        ARMOR = Material( "os_ui_armor.png" ),
        CLOCK = Material( "os_ui_clock.png" ),
        HUNGER = Material( "os_ui_hunger.png" ),
        CIRCLE = Material( "os_ui_circle.png" ),
        COMMANDS = Material( "os_ui_commands.png" ),
        MISC = Material( "os_ui_misc.png" ),
        AMMO = Material( "os_ui_ammo.png" ),
        WEAPONS = Material( "os_ui_gun.png" ),
        SHIPMENTS = Material( "os_ui_shipments.png" ),
        WEBSITE = Material( "os_ui_forums.png" ),
        DONATE = Material( "os_ui_donate.png" ),
        VEHICLE = Material( "os_ui_vehicle.png" ),
        --> Scoreboard <--
        NAME = Material( "os_ui_commands.png" ),
        RANK = Material( "os_ui_rank.png" ),
        PING = Material( "os_ui_ping.png" ),
        GENERIC = Material( "os_ui_generic.png" ),
        ERROR = Material( "os_ui_error.png" ),
        UNDO = Material( "os_ui_undo.png" ),
        HINT = Material( "os_ui_hint.png" ),
        CLEANUP = Material( "os_ui_cleanup.png" )
    }

    --> The specific HUD components we don't want <--
    local block_list = {
        [ 'DarkRP_HUD' ] = true,
        [ 'CHudBattery' ] = true,
        [ 'CHudHealth' ] = true,
        [ 'CHudAmmo' ] = true,
        [ 'DarkRP_Hungermod' ] = true,
    }

    --> The function to block said components. <--
    function OS_UI.BlockHUDComponents( name )
        if block_list[ name ] then return false end
    end
    hook.Add( 'HUDShouldDraw', 'OS_UI.Block.HUD_Components', OS_UI.BlockHUDComponents )

    --> Draws text and an icon at a specified point on the screen <--
    function OS_UI.DrawIconText( icon, str, x, y, col, align_right, bold )
        local font = "OS_UI.Font.21"
        surface.SetFont( font )
        local scr_w, scr_h = ScrW(), ScrH()
        local day_length = surface.GetTextSize( str )
        OS_UI.DrawTexture( icon, x - ( align_right and day_length or 0 ), y + 3, 22, 22, OS_UI.Colors.GREY )
        OS_UI.DrawText( str, font, x + ( bold and 30 or 27 ), y + 3, col, align_right and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT )
    end

    --> Cuts a string based on size, adds '..' onto the end of it <--
    function OS_UI.CutStringLength( str, font, maxSize, endIndex )
        surface.SetFont( font )
        local width, height = surface.GetTextSize( str )
        if width > maxSize then
            str = string.sub( str, 1, endIndex ) .. ".."
        end
        return str
    end

    --> Returns if the player is wanted. <--
    function OS_UI.IsPlayerWanted( self )
        if self:isWanted() then
            return true, self:getWantedReason() or "Você foi um jogador desobediente."
        end
        return false
    end

    --> Returns if Lockdown is active <--
    function OS_UI.IsLockdownActive()
        return GetGlobalBool( "DarkRP_LockDown" ) or false
    end

    --> Draws 3 Mac OS Icons on the screen <--
    function OS_UI.DrawMacIcons( x, y )
        if not OS_UI.Settings.Enable_Mac_Icons then return end
        OS_UI.DrawTexture( OS_UI.Icons.CIRCLE, x, y, 12, 12, OS_UI.Colors.RED )
        OS_UI.DrawTexture( OS_UI.Icons.CIRCLE, x + 19, y, 12, 12, OS_UI.Colors.ORANGE )
        OS_UI.DrawTexture( OS_UI.Icons.CIRCLE, x + 38, y, 12, 12, OS_UI.Colors.GREEN )
    end

    --> Sends a client-side message to the LocalPlayer <--
    function OS_UI.SendMessage( message )
        chat.AddText( OS_UI.Colors.RED, "[OS UI]: ", OS_UI.Colors.WHITE, message )
    end 

    --> Sets the font, gets the length and height. <--
    function OS_UI.GetStringSize( font, str )
        surface.SetFont( font )
        return surface.GetTextSize( str )
    end

    --> Popup interface when clicking on a F4 menu command (if applicable)
    function OS_UI.CreateDialogBox( v )
        local scr_w, scr_h, ply, startTime = ScrW(), ScrH(), LocalPlayer(), CurTime()

        local self = vgui.Create( "DFrame" )
        self:SetSize( 384, v.reason and 216 or 146.88 )
        self:Center()
        self:SetTitle( "" )
        self:SetDraggable( false ) 
        self:ShowCloseButton( true )
        self:MakePopup()

        self.Paint = function( me, w, h )
            Derma_DrawBackgroundBlur( me, openTime ) 
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND )
        end

        self.Header = vgui.Create( "DPanel", self )
        self.Header:Dock( TOP )
        self.Header:SetTall( 35 )
        self.Header:DockMargin( -5, -30, -5, 0 )

        self.Header.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
            OS_UI.DrawText( v.name, "OS_UI.Font.22", 10, h / 2, OS_UI.Colors.GREY, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        end

        self.Description_Text = vgui.Create( "DLabel", self )
        self.Description_Text:Dock( TOP )
        self.Description_Text:DockMargin( 0, 5, 0, 5 )
        self.Description_Text:SetText( v.show_box )
        self.Description_Text:SetContentAlignment( 8 )
        self.Description_Text:SetFont( "OS_UI.Font.22" )
        self.Description_Text:SetTextColor( OS_UI.Colors.GREY )

        self.Info_Field = vgui.Create( v.selection and "DComboBox" or "DTextEntry", self )
        self.Info_Field:Dock( TOP )
        self.Info_Field:DockMargin( 30, 5, 30, 5 )
        self.Info_Field:SetTall( 30 )
        self.Info_Field:SetText( v.selection and "Selecione um jogador.." or "" )
        self.Info_Field:SetFont( "OS_UI.Font.20" )

        self.Info_Field.Paint = function( me, w, h )
            OS_UI.DrawRoundedBox( 6, 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
            me:DrawTextEntryText( OS_UI.Colors.WHITE, OS_UI.Colors.RED, OS_UI.Colors.WHITE )
        end

        if v.selection then
            --> If there's a selction to make, load all the players into the list <--
            for k, v in pairs( player.GetAll() ) do
                if v == ply then continue end
                self.Info_Field:AddChoice( v:Nick() )
            end

            --> If there's a selection, create another text-field to store said reason <--

            self.Description_Text = vgui.Create( "DLabel", self )
            self.Description_Text:Dock( TOP )
            self.Description_Text:DockMargin( 0, 0, 0, 5 )
            self.Description_Text:SetText( "Digite a razão" )
            self.Description_Text:SetContentAlignment( 8 )
            self.Description_Text:SetFont( "OS_UI.Font.22" )
            self.Description_Text:SetTextColor( OS_UI.Colors.GREY )

            self.Reason_Field = vgui.Create( "DTextEntry", self )
            self.Reason_Field:Dock( TOP )
            self.Reason_Field:DockMargin( 30, 5, 30, 5 )
            self.Reason_Field:SetTall( 30 )
            self.Reason_Field:SetFont( "OS_UI.Font.20" )

            self.Reason_Field.Paint = function( me, w, h )
                OS_UI.DrawRoundedBox( 6, 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
                me:DrawTextEntryText( OS_UI.Colors.WHITE, OS_UI.Colors.RED, OS_UI.Colors.WHITE )
            end
        end

        local confirm_width = v.reason and 164 or 105
        self.Confirm = vgui.Create( "DButton", self )
        self.Confirm:Dock( TOP )
        self.Confirm:DockMargin( 120, 5, 120, 5 )
        self.Confirm:SetTall( 30 )
        self.Confirm:SetText( "Confirmar" )
        self.Confirm:SetFont( "OS_UI.Font.20" )
        self.Confirm:SetTextColor( OS_UI.Colors.WHITE )

        self.Confirm.Paint = function( me, w, h )
            OS_UI.DrawRoundedBox( 6, 0, 0, w, h, OS_UI.Colors.GREEN )
        end

        self.Confirm.DoClick = function( me )
            local str_reason = "Razão não especificada."
            if v.selection then
                if self.Reason_Field:GetValue() == "" then
                    OS_UI.SendMessage( "Erro: Razão não especificada." )
                    return
                end
                if self.Info_Field:GetValue() == "Selecione um jogador.." then
                    OS_UI.SendMessage( "Erro: Jogador não selecionado." )
                    return
                end
                str_reason = self.Reason_Field:GetValue()
            else
                if self.Info_Field:GetValue() == "" then
                    OS_UI.SendMessage( "Erro: Razão não especificada." )
                    return
                end
                str_reason = self.Info_Field:GetValue()
            end
            local command = v.command
            command = string.gsub( command, "#string", v.selection and self.Info_Field:GetSelected() or str_reason )
            command = string.gsub( command, "#number", tonumber( str_reason ) or "" ) --> Number N/A if nil
            if v.selection then --> If selection, we must append the reason.
                 command = command .. " " .. str_reason
            end
            ply:ConCommand( "say " .. command )
        end

        OS_UI.CreateIconObject( self, OS_UI.Icons.CIRCLE, self:GetWide() - 22, self.Header:GetTall() / 2 - 6, 12, 12, true, function()
            self:Close()
        end )

    end 

    --> Full credits to Danny (https://www.gmodstore.com/users/dan) for making this for me <--
    --> P.S: Sorry this doesn't match my other syntax, if this is an issue I can change it <--
    local drawDist = 80
	local drawDistSqr = drawDist^2
    local maxHealth = 100
    local avatarSize = 40
    local barW,barH = 200, 105
    local mat = Matrix()
    function OS_UI.DrawOverheadHUD()
    	local ply = LocalPlayer()
    	for k,targ in pairs(player.GetAll()) do
            if targ == ply then continue end
            if targ:InVehicle() then continue end
		    local dist = ply:GetPos():DistToSqr(targ:GetPos())
		    targ.nextDistCheck = targ.nextDistCheck or CurTime() - .4
		    if targ.nextDistCheck < CurTime() then
		        if dist > drawDistSqr then if IsValid(targ.overheadPanel) then targ.overheadPanel:Remove() targ.overheadPanel = nil end continue end
		        targ.nextDistCheck = CurTime() + .4
		    end
		    mat:Identity()
		    local bone = targ:LookupBone("ValveBiped.Bip01_Head1")
		    local bonePos
		    if bone then
		        bonePos = targ:GetBonePosition(bone) + Vector(0,0,20)
		    end
		    local drawPos = bonePos or targ:EyePos()
		    if not ply:IsLineOfSightClear(drawPos) then return end

		    drawPos = drawPos:ToScreen()
		    local vec = ( 1 - (drawDist / 600))
		    local hasRank = OS_UI.Settings.Scoreboard_Ranks[targ:GetUserGroup()]
		    local showJob = team.GetName(targ:Team())
            local teamColor = team.GetColor(targ:Team())
		    if not IsValid(targ.overheadPanel) then
		    	targ.overheadPanel = targ.overheadPanel or vgui.Create("DPanel")
		    	local name = targ:getDarkRPVar("rpname") or targ:Name()
		    	local offset = 0
                targ.overheadPanel.Paint = function(me,w,h)
                    local isWanted = targ:isWanted()
		    		surface.SetDrawColor(OS_UI.Colors.BASE_BACKGROUND)
		    		surface.DrawRect(0,0,w,h)
		    		surface.SetDrawColor(OS_UI.Colors.BASE_HEADER)
		    		surface.DrawRect(0,0,w,h * .17)
		            draw.SimpleText(name, "OS_UI.Font.23", w * .5, barH * .72, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		            draw.SimpleText(showJob, "OS_UI.Font.23", w * .5, barH * .92, teamColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		            if hasRank then
		            	draw.SimpleText(hasRank.title or "User", "OS_UI.Font.23", w * .5, barH * 1.12, hasRank.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    if isWanted then
                        draw.SimpleText("PROCURADO", "OS_UI.Font.23", 8, 10, OS_UI.Colors.RED, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
		            if OS_UI.Settings.Enable_OverheadHealth then
		            	local r = (math.Clamp(targ:Health(), 0, targ:GetMaxHealth()) / targ:GetMaxHealth())
		            	local curWidth = w * r
		            	local dif = w - curWidth
		            	surface.SetDrawColor(174,30,30)
		            	surface.DrawRect(dif / 2, h - barH * .06, curWidth, barH * .06)
		            end
		        end
		        targ.overheadPanel:SetPaintedManually(true)
		        targ.overheadPanel:SetSize(barW, barH)
		        local img = targ.overheadPanel.img or targ.overheadPanel:Add("CircleAvatar")
	            targ.overheadPanel.img = img
	            img:SetSize(avatarSize, avatarSize)
	            img:SetPlayer(targ, avatarSize)
	            img:SetPos(barW / 2 - avatarSize / 2, barH * .26)
		        if hasRank then
		        	targ.overheadPanel:SetTall(targ.overheadPanel:GetTall() + barH * .25)
		        end
		        if OS_UI.Settings.Enable_OverheadHealth then
		        	targ.overheadPanel:SetTall(targ.overheadPanel:GetTall() + barH * .06)
		        end
	        end
		    mat:Translate(Vector(drawPos.x - targ.overheadPanel:GetWide() * .5, drawPos.y))
		    mat:Translate(Vector( targ.overheadPanel:GetWide() * .5 * (1 - vec), 0))
		    mat:Scale(vec * Vector(1,1,1))
		    cam.PushModelMatrix(mat)
		    targ.overheadPanel:PaintManual()
		    cam.PopModelMatrix()
    	end
    end

    function CanCoOwnDoor( door )
        -- Returns if the door can actually be co-owned.
        local can_co_own = door:getKeysAllowedToOwn()
        return can_co_own and not fn.Null( can_co_own )
    end

    function IsDoorBlocked( door )
        local is_blocked, self = door:getKeysNonOwnable(), LocalPlayer()
        -- If the door is blocked and they're a superadmin let them have access to the door.
        return is_blocked and self:GetUserGroup() == "superadmin"
    end

    function GetDoorOwner( door )
        return door:getDoorOwner()
    end

    function SetupDoorDesign( door, flip )
        local angle = door:GetAngles()
        local center = door:OBBCenter()
        local size = door:OBBMins() - door:OBBMaxs()

        -- General DarkRP vars --
        local doorTeams = door:getKeysDoorTeams()
        local doorGroup = door:getKeysDoorGroup()
        local playerOwned = door:isKeysOwned() or table.GetFirstValue(door:getKeysCoOwners() or {}) ~= nil
        local door_residents = door:getKeysCoOwners() or 1

        local text_x = 200
        local owned = playerOwned or doorGroup or doorTeams

        local door_data = door:getDoorData()
        local title = "" -- Main Door title
        local sub_header = "" -- Door Sub header
        local footer = "" -- Door footer

        if door:getKeysTitle() then
            title = door:getKeysTitle()
        else
            title = "Собственность"
        end

        if not owned then
            -- If the door ownership is allowed
            if not IsDoorBlocked( door ) then 
                sub_header = "Продаётся"
                footer = "Нажмите F2 чтобы купить"
            end
        else
            local owner = GetDoorOwner( door ) -- Attempt to get user who owns door.
            sub_header = IsValid( owner ) and owner:Nick() or "Неизвестно"
            footer = door_residents .. ( door_residents == 1 and " Владелец" or " Владельцы" )
        end

        if IsDoorBlocked( door ) then
            -- If door ownership is not allowed.
            title = "Дверь недоступна"
            sub_header = "Не продаётся"
        end

        size = Vector( math.abs( size.x ), math.abs( size.y ), math.abs( size.z ) )
        local door_first_3d_pos, door_second_3d_pos = nil, nil

        if door:GetClass() == "prop_door_rotating" then 
            angle:RotateAroundAxis( angle:Right(), 90 )
            angle:RotateAroundAxis( angle:Up(), -90 )
            door_first_3d_pos = door:LocalToWorld( center ) - door:GetRight() * ( size.y / 2 ) + Vector( 0, 0, 35 )
            door_second_3d_pos = door:LocalToWorld( center ) + door:GetRight() * ( size.y / 2 ) + Vector( 0, 0, 35 )
        end

        local start = size.x / 0.2
        cam.Start3D2D( door_first_3d_pos, angle, 0.12 )
            OS_UI.DrawText( title, "OS_UI.Font.50", text_x, 10, OS_UI.Colors.BLUE )
            OS_UI.DrawText( sub_header, "OS_UI.Font.41", text_x, 60, OS_UI.Colors.WHITE )
            OS_UI.DrawText( footer, "OS_UI.Font.41", text_x, 100, OS_UI.Colors.WHITE )
        cam.End3D2D()

        angle:RotateAroundAxis( angle:Right(), 180 )

        cam.Start3D2D( door_second_3d_pos, angle, 0.12 )
            OS_UI.DrawText( title, "OS_UI.Font.50", text_x, 10, OS_UI.Colors.BLUE )
            OS_UI.DrawText( sub_header, "OS_UI.Font.41", text_x, 60, OS_UI.Colors.WHITE )
            OS_UI.DrawText( footer, "OS_UI.Font.41", text_x, 100, OS_UI.Colors.WHITE )
        cam.End3D2D()

    end

    function SetupDoorRender( door )
        local angle = door:GetAngles()
        -- Setup both sides of 3D2D text for doors.
        cam.Start3D()
            SetupDoorDesign( door ) 
        cam.End3D()
        cam.Start3D()
            SetupDoorDesign( door ) 
        cam.End3D()
    end

    function DrawDoorData( door )
        if door then
            if door:GetClass() == "prop_door_rotating" then
                SetupDoorRender( door )
                return true -- Override DarkRP.
            end
        end
    end
    hook.Add( "HUDDrawDoorData", "OS_UI.DrawDoorData", DrawDoorData )

