
    local LINKS_CATEGORY = {
        { name = "Discord", icon = OS_UI.Icons.WEBSITE, callBack = function() gui.OpenURL( OS_UI.WebsiteLink ) end, link = true },
        { name = "Content", icon = OS_UI.Icons.WEBSITE, callBack = function() gui.OpenURL( OS_UI.CollectionLink  ) end, link = true },
        { name = "Doações", icon = OS_UI.Icons.DONATE, callBack = function() gui.OpenURL( OS_UI.DonationLink ) end, link = true },
    }

    local GENERAL_COMMANDS = {
        { name = "Jogar dinheiro", show_box = "Digite uma quantidade", command = "/dropmoney #number", data_type = "number"  },
        { name = "Alterar nick", show_box = "Digite um novo nome", command = "/name #string", data_type = "string"  },
        { name = "Descartar arma atual", show_box = false, command = "/drop", data_type = nil  },
        { name = "Vender todas as portas", show_box = false, command = "/sellalldoors", data_type = nil  }
    }

    local POLICE_COMMANDS = {
        { name = "Procurado", show_box = "Selecione um jogador", command = "/wanted #string", data_type = "string", selection = true, reason = true  },
        { name = "Remover procurado", show_box = "Selecione um jogador", command = "/dropmoney #string", data_type = "string", selection = true  },
        { name = "Emitir mandado de busca", show_box = "Selecione um jogador", command = "/wanted #string", data_type = "string", selection = true, reason = true  },
        { name = "Revogar mandado de busca", show_box = "Selecione um jogador", command = "/unwanted #string", data_type = "string", selection = true  },
        { name = "Declarar toque de recolher", show_box = false, command = "/lockdown", data_type = nil  },
        { name = "Encerrar toque de recolher", show_box = false, command = "/unlockdown", data_type = nil  },
        { name = "Sorteio", show_box = false, command = "/lottery", data_type = nil  }
    }

    --> Returns total visible objects within any category passed <--
    function OS_UI.GetCategoryObjects( data, name, id )
        local size, ply = 0, LocalPlayer()
        for k, v in pairs( data ) do
            if name == v.name then 
                local exit
                if v.canSee and not v.canSee( ply ) then continue end
                if not v.members or #v.members < 1 then continue end
                if id == "Singles" or id == "Shipments" then
                    local has_any_access = false
                    for x = 1, #v.members do
                        local ref = v.members[ x ]
                        if ( id == "Singles" and ref.separate ~= true or id == "Shipments" and ref.separate == true ) then
                            exit = true
                        end
                        if id == "Singles" and not GAMEMODE.Config.restrictbuypistol then
                            has_any_access = true
                        end
                        if ref.allowed and table.HasValue( ref.allowed, ply:Team() ) then
                            has_any_access = true
                        end
                    end
                    if exit or not has_any_access then continue end
                end
                size = size + 1 
            end
        end
        return size
    end

    --> Appends a comma to each weapon name, dependent on position <--
    function OS_UI.ReturnWeaponStr( data )
        local str = ""
        for k, v in pairs( data ) do
            str = str .. v .. ( k == #data and "" or ", " )
        end
        if #data < 1 then str = "Sem armamento." end
        return str
    end

    --> Returns all single weapons <--
    function OS_UI.GetSingles()
        local singles = {}
        for k, v in pairs( CustomShipments ) do
            if v.seperate == true then
                table.insert( singles, v )
            end
        end
        return singles
    end

    --> Returns a specific team id <--
    function OS_UI.GetTeamID( data_line )
        for k, v in pairs( RPExtraTeams ) do
            if data_line == v then
                return k
            end
        end
    end

    --> Returns all shipments <--
    function OS_UI.GetShipments()
        local shipments = {}
        for k, v in pairs( CustomShipments ) do
            if v.seperate == false then
                table.insert( shipments, v )
            end
        end
        return shipments
    end

    --> Forms all categories neatly, all follow the same layout <--
    function OS_UI.CreateCategoryFoundation( self, creating_job, category_table, main_table, id, on_click )
        local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
        --! if creating_job then create a panel on the right hand side !--

        self.Cur_Selection, self.Text_Objects, self.General_Objects, self.Tracker_Objects = nil, {}, {}, {}

        self.Main_Container = vgui.Create( "DPanel", self.Container )
        self.Main_Container:SetSize( creating_job and self.Container:GetWide() / 1.4 or self.Container:GetWide(), self.Container:GetTall() )
        self.Main_Container:Dock( LEFT )
        self.Main_Container.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND )
        end

        self.Object_Display_Scroll = vgui.Create( "DScrollPanel", self.Main_Container )
        self.Object_Display_Scroll:DockMargin( 0, -6, 0, 0 )
        self.Object_Display_Scroll:Dock( FILL )
        self.Object_Display_Scroll:SetSize( self.Main_Container:GetWide(), self.Main_Container:GetTall() )
        OS_UI.PaintBar( self.Object_Display_Scroll, nil, nil, OS_UI.Colors.BASE_HEADER )

        self.Object_Display = vgui.Create( "DIconLayout", self.Object_Display_Scroll )
        self.Object_Display:Dock( FILL )
        self.Object_Display:SetSize( self.Main_Container:GetWide(), self.Main_Container:GetTall() )
        self.Object_Display:SetSpaceY( 5 )
        self.Object_Display:SetSpaceX( 5 )

        self.Object_Display.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND )
        end

        local categories = category_table --> Sort categories based on their sortOrder
        table.sort( categories, function( a, b )
            if a.sortOrder and b.sortOrder then return a.sortOrder < b.sortOrder end
        end )

        for i = 1, #categories do
            local category = categories[ i ]
            local size = OS_UI.GetCategoryObjects( category_table, category.name, id ) -- Returns the size of valid jobs inside a category.

            if size < 1 then continue end --> We don't need to create a category that has nothing in it.
            if category.canSee and not category.canSee( ply ) then continue end --> They're not supposed to see it

            self.Category_Panel = vgui.Create( "DPanel", self.Object_Display )
            self.Category_Panel:SetSize( self.Object_Display:GetWide(), 30 )
            self.Category_Panel.Paint = nil

            self.Category_Header = vgui.Create( "DLabel", self.Category_Panel )
            self.Category_Header:Dock( TOP )
            self.Category_Header:DockMargin( 5, 6, 0, 15 )
            self.Category_Header:SetText( category.name or "Desconhecido" )
            self.Category_Header:SetFont( "OS_UI.Font.20" )
            self.Category_Header:SetTextColor( OS_UI.Colors.GREY )

            for k, v in pairs( main_table ) do
                
                if v.category == category.name or category.name == "Food" or category.name == "Vehicles" then 
                    if k == ply:Team() and creating_job then continue end --> No need to display their current job.
                    --> If the category is singles and there's a restriction on buying pistols verify their team <--
                    if id == "Singles" and v.allowed and GAMEMODE.Config.restrictbuypistol then
                        if not table.HasValue( v.allowed, ply:Team() ) then
                            continue
                        end
                    end
                    --> General checks here for Shipments (We don't hide normal entities) <--
                    if id == "Shipments" and v.allowed then 
                        if not table.HasValue( v.allowed, ply:Team() ) then
                            continue
                        end
                    end
                    --> Checks as per individual food <--
                    if category.name == "Food" then
                        if v.requiresCook == true and not ply:isCook() then continue end
                    end 
                    self.Display_Item = vgui.Create( "DPanel", self.Category_Panel )
                    self.Display_Item:SetSize( self.Category_Panel:GetWide() / ( creating_job and 2 or 2.974 ) - 10, 70 )
                    self.Display_Item.Paint = function( me, w, h )
                        OS_UI.DrawRoundedBox( 6, 0, 0, w, h, me:IsHovered() and OS_UI.ConvertColour( OS_UI.Colors.DARK_BLACK, 10 ) or OS_UI.Colors.DARK_BLACK )
                    end

                    self.Display_Item.OnMousePressed = function( me )
                        if creating_job then
                            self.Cur_Max, self.Cur_Pos, self.Ref = 0, 1, v
                            local model = type( v.model ) == "table" and v.model[ 1 ] or v.model
                            self.Cur_Selection = { v.name, "Armamento: ", OS_UI.ReturnWeaponStr( v.weapons ), "Descrição: ", v.description:gsub( "%s+", "-" ):gsub( "-", " " ) }
                            for x = 1, #self.Text_Objects do
                                local reference = self.Text_Objects[ x ]
                                if IsValid( reference ) then
                                    reference:SetText( self.Cur_Selection[ x ] )
                                    reference:SetVisible( true )
                                end
                            end
                            for k, v in pairs( self.General_Objects ) do
                                if IsValid( v ) then v:SetVisible( true ) end
                            end
                            if type( v.model ) == "table" and #v.model > 1 then
                                for k, v in pairs( self.Tracker_Objects ) do
                                    if IsValid( v ) then v:SetVisible( true ) end
                                end
                                self.Cur_Max = #v.model
                                self.Side_Container_Tracker:SetText( self.Cur_Pos .. "/" .. self.Cur_Max )
                            else
                                for k, v in pairs( self.Tracker_Objects ) do
                                    if IsValid( v ) then v:SetVisible( false ) end
                                end
                            end
                            self.Side_Container_Job_Model:SetModel( model )
                            DarkRP.setPreferredJobModel( k, model )
                        else
                            if on_click then on_click( v ) end
                            self:Close()
                        end
                    end

                    self.Display_Item_Name = vgui.Create( "DLabel", self.Display_Item )
                    self.Display_Item_Name:Dock( TOP )
                    self.Display_Item_Name:DockMargin( 80, 17, 0, 24 )
                    self.Display_Item_Name:SetText( v.name )
                    self.Display_Item_Name:SetFont( "OS_UI.Font.21" )
                    self.Display_Item_Name:SetTextColor( OS_UI.Colors.GREY )

                    self.Display_Item_Price = vgui.Create( "DLabel", self.Display_Item )
                    self.Display_Item_Price:Dock( TOP )
                    self.Display_Item_Price:DockMargin( 80, -22, 0, 8 )
                    self.Display_Item_Price:SetText( "$" .. string.Comma( creating_job and v.salary or v.price ) )
                    self.Display_Item_Price:SetFont( "OS_UI.Font.21" )
                    self.Display_Item_Price:SetTextColor( OS_UI.Colors.GREEN )

                    self.Display_Item_Model = vgui.Create( "DModelPanel", self.Display_Item )
                    self.Display_Item_Model:SetSize( 64, 70 )
                    self.Display_Item_Model.LayoutEntity = function() return end
                    if creating_job then
                        self.Display_Item_Model:SetPos( 0, 0 )
                        self.Display_Item_Model:SetFOV( 38 )
                        self.Display_Item_Model:SetCamPos( Vector( 25, 0, 65 ) )
                        self.Display_Item_Model:SetLookAt( Vector( 10, 0, 65 ) )
                        self.Display_Item_Model:SetModel( type( v.model ) == "table" and v.model[ 1 ] or v.model )
                    else
                        self.Display_Item_Model:SetModel( v.model )
                        local mn, mx = self.Display_Item_Model.Entity:GetRenderBounds()
                        local size = 0
                        size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                        size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                        size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
                        self.Display_Item_Model:SetFOV( ( id == "Shipments" or id == "Singles" or id == "Vehicles" ) and 35 or 45 )
                        self.Display_Item_Model:SetCamPos( Vector( size, size, size ) )
                        self.Display_Item_Model:SetLookAt( ( mn + mx ) * 0.5 )
                    end

                    if v.max or v.energy or id == "Shipments" then 
                        self.Display_Item_Team_Members = vgui.Create( "DLabel", self.Display_Item )
                        self.Display_Item_Team_Members:Dock( RIGHT )
                        self.Display_Item_Team_Members:SetWide( 50 )
                        self.Display_Item_Team_Members:DockMargin( 0, -34, 8, 15 )
                        self.Display_Item_Team_Members:SetText( creating_job and ( table.Count( team.GetPlayers( v.team ) ) .. "/" .. ( v.max == 0 and "∞" or v.max  ) ) or category.name == "Food" and "+" .. v.energy or id == "Shipments" and v.amount .. "x" or v.max .. " Max" )
                        self.Display_Item_Team_Members:SetFont( "OS_UI.Font.20" )
                        self.Display_Item_Team_Members:SetContentAlignment( 8 )
                        self.Display_Item_Team_Members:SetTextColor( OS_UI.Colors.GREY )
                        self.Display_Item_Team_Members.Paint = function( me, w, h )
                            OS_UI.DrawRoundedBox( 6, 0, 0, w, h, Color( 36, 36, 36 ) )
                        end
                    end

                    self.Object_Display:Add( self.Display_Item )
                end
            end
        end

        if not creating_job then return end

        --[[
            Below here is all the code for the side_display on the job's tab.
            If we are not creating_job; not on the job's tab then we exit.
            If we are, we create all the requried elements.
        --]]

        self.Side_Container = vgui.Create( "DPanel", self.Container )
        self.Side_Container:Dock( RIGHT )
        self.Side_Container:DockMargin( 0, 0, 0, 0 )
        self.Side_Container:SetWide( self.Container:GetWide() / 3.5 )
        self.Side_Container.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER ) 
        end

        self.Side_Container_Dock = vgui.Create( "DPanel", self.Side_Container )
        self.Side_Container_Dock:Dock( TOP )
        self.Side_Container_Dock:DockMargin( 10, 5, 10, 0 )
        self.Side_Container_Dock:SetTall( 30 )
        self.Side_Container_Dock.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.DARK_BLACK )
        end
        table.insert( self.General_Objects, self.Side_Container_Dock )

        self.Side_Container_Header = vgui.Create( "DLabel", self.Side_Container_Dock )
        self.Side_Container_Header:Dock( TOP )
        self.Side_Container_Header:DockMargin( 6, 4, 6, 0 )
        self.Side_Container_Header:SetContentAlignment( 8 )
        self.Side_Container_Header:SetFont( "OS_UI.Font.20" )
        self.Side_Container_Header:SetTextColor( OS_UI.Colors.WHITE )
        table.insert( self.Text_Objects, self.Side_Container_Header )

        self.Side_Container_Preview = vgui.Create( "DPanel", self.Side_Container )
        self.Side_Container_Preview:Dock( TOP )
        self.Side_Container_Preview:DockMargin( 10, 5, 10, 0 )
        self.Side_Container_Preview:SetTall( self.Container:GetTall() / 2.6 )
        self.Side_Container_Preview.Paint = function( me, w, h )
            OS_UI.DrawOutline( 0, 0, w, h, 4, OS_UI.Colors.DARK_BLACK )
        end
        table.insert( self.General_Objects, self.Side_Container_Preview )

        self.Side_Container_Job_Model = vgui.Create( "DModelPanel", self.Side_Container )
        self.Side_Container_Job_Model:SetSize( self.Side_Container:GetWide() / 1.2, self.Side_Container_Preview:GetTall() )
        self.Side_Container_Job_Model:SetPos( self.Side_Container:GetWide() / 2 - self.Side_Container_Job_Model:GetWide() / 2 + 1, self.Side_Container_Preview:GetTall() / 2 - self.Side_Container_Job_Model:GetTall() / 3 + 10 )
        self.Side_Container_Job_Model.LayoutEntity = function() return end
        self.Side_Container_Job_Model:SetMouseInputEnabled( false )
        self.Side_Container_Job_Model:SetCamPos( Vector( 50, 0, 60 ) )
        self.Side_Container_Job_Model:SetModel( ply:GetModel() )
        table.insert( self.General_Objects, self.Side_Container_Job_Model )

        self.Side_Container_Tracker = vgui.Create( "DLabel", self.Side_Container_Preview )
        self.Side_Container_Tracker:Dock( TOP )
        self.Side_Container_Tracker:SetTall( 30 )
        self.Side_Container_Tracker:SetContentAlignment( 8 )
        self.Side_Container_Tracker:SetFont( "OS_UI.Font.21" )
        self.Side_Container_Tracker:DockMargin( 0, 7, 0, 0 )
        table.insert( self.Tracker_Objects, self.Side_Container_Tracker )

        self.Side_Container_Right = vgui.Create( "DButton", self.Side_Container_Preview )
        self.Side_Container_Right:Dock( RIGHT )
        self.Side_Container_Right:SetSize( self.Side_Container_Preview:GetWide() / 2.8, self.Side_Container_Preview:GetTall() )
        self.Side_Container_Right:SetText( ">" )
        self.Side_Container_Right:SetFont( "OS_UI.Font.30" )
        self.Side_Container_Right:SetTextColor( OS_UI.Colors.WHITE )
        self.Side_Container_Right:DockMargin( 0, -18, 4, 0  )
        self.Side_Container_Right.Paint = nil
        table.insert( self.Tracker_Objects, self.Side_Container_Right )

        self.Side_Container_Right.OnMousePressed = function( me )
            if self.Cur_Pos == self.Cur_Max then
                self.Cur_Pos = 1
            else
                self.Cur_Pos = self.Cur_Pos + 1
            end
            self.Side_Container_Job_Model:SetModel( self.Ref.model[ self.Cur_Pos ] )
            self.Side_Container_Tracker:SetText( self.Cur_Pos .. "/" .. self.Cur_Max )
            DarkRP.setPreferredJobModel( OS_UI.GetTeamID( self.Ref ), self.Ref.model[ self.Cur_Pos ] )
        end

        self.Side_Container_Left = vgui.Create( "DButton", self.Side_Container_Preview )
        self.Side_Container_Left:Dock( LEFT )
        self.Side_Container_Left:SetSize( self.Side_Container_Preview:GetWide() / 2.8, self.Side_Container_Preview:GetTall() )
        self.Side_Container_Left:SetText( "<" )
        self.Side_Container_Left:SetFont( "OS_UI.Font.30" )
        self.Side_Container_Left:SetTextColor( OS_UI.Colors.WHITE )
        self.Side_Container_Left:DockMargin( 4, -18, 0, 0  )
        self.Side_Container_Left.Paint = nil
        table.insert( self.Tracker_Objects, self.Side_Container_Left )

        self.Side_Container_Left.OnMousePressed = function( me )
            if self.Cur_Pos <= 1 then
                self.Cur_Pos = 1
            else
                self.Cur_Pos = self.Cur_Pos - 1
            end
            self.Side_Container_Job_Model:SetModel( self.Ref.model[ self.Cur_Pos ] )
            self.Side_Container_Tracker:SetText( self.Cur_Pos .. "/" .. self.Cur_Max )
            DarkRP.setPreferredJobModel( OS_UI.GetTeamID( self.Ref ), self.Ref.model[ self.Cur_Pos ] )
        end

        self.Side_Container_Weapon_Header = vgui.Create( "DLabel", self.Side_Container )
        self.Side_Container_Weapon_Header:Dock( TOP )
        self.Side_Container_Weapon_Header:DockMargin( 10, 10, 10, 0 )
        self.Side_Container_Weapon_Header:SetFont( "OS_UI.Font.21" )
        self.Side_Container_Weapon_Header:SetTextColor( OS_UI.Colors.WHITE )
        table.insert( self.Text_Objects, self.Side_Container_Weapon_Header )

        self.Side_Container_Weapons = vgui.Create( "DLabel", self.Side_Container )
        self.Side_Container_Weapons:Dock( TOP )
        self.Side_Container_Weapons:DockMargin( 10, 10, 10, 0 )
        self.Side_Container_Weapons:SetTall( 35 )
        self.Side_Container_Weapons:SetWrap( true )
        self.Side_Container_Weapons:SetContentAlignment( 7 )
        self.Side_Container_Weapons:SetFont( "OS_UI.Font.18" )
        self.Side_Container_Weapons:SetTextColor( OS_UI.Colors.GREY )
        table.insert( self.Text_Objects, self.Side_Container_Weapons )

        self.Side_Container_Description_Header = vgui.Create( "DLabel", self.Side_Container )
        self.Side_Container_Description_Header:Dock( TOP )
        self.Side_Container_Description_Header:DockMargin( 10, 10, 0, 0 )
        self.Side_Container_Description_Header:SetFont( "OS_UI.Font.21" )
        self.Side_Container_Description_Header:SetTextColor( OS_UI.Colors.WHITE )
        table.insert( self.Text_Objects, self.Side_Container_Description_Header )

        self.Side_Container_Description = vgui.Create( "DLabel", self.Side_Container )
        self.Side_Container_Description:Dock( TOP )
        self.Side_Container_Description:DockMargin( 10, 10, 0, 0 )
        self.Side_Container_Description:SetWrap( true )
        self.Side_Container_Description:SetContentAlignment( 7 )
        self.Side_Container_Description:SetTall( self.Container:GetTall() / 3.3 )
        self.Side_Container_Description:SetFont( "OS_UI.Font.16" )
        self.Side_Container_Description:SetTextColor( OS_UI.Colors.GREY )
        table.insert( self.Text_Objects, self.Side_Container_Description )

        self.Side_Container_Select_Job = vgui.Create( "DButton", self.Side_Container )
        self.Side_Container_Select_Job:Dock( BOTTOM )
        self.Side_Container_Select_Job:DockMargin( 10, 0, 10, 10 )
        self.Side_Container_Select_Job:SetTall( 40 )
        self.Side_Container_Select_Job:SetFont( "OS_UI.Font.19" )
        self.Side_Container_Select_Job:SetText( "Selecionar" )
        self.Side_Container_Select_Job:SetTextColor( OS_UI.Colors.WHITE )
        self.Side_Container_Select_Job.DoClick = function( me )
            RunConsoleCommand( "darkrp", self.Ref.vote and "vote" .. self.Ref.command or self.Ref.command )
        end
        self.Side_Container_Select_Job.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, me:IsHovered() and OS_UI.ConvertColour( OS_UI.Colors.DARK_BLACK, 5 ) or OS_UI.Colors.DARK_BLACK )
        end
        table.insert( self.General_Objects, self.Side_Container_Select_Job )

        --[[
            So a quick run down here to explain what looks to be retarded:
            self.Text_Objects refers to those objects in which will be directly modified when OnMousePressed is called.
            self.General_Objects refers to those objects in which I just want to be visible when OnMousePressed is called.
            self.Tracker_Objects is a parent on top of "self.Side_Container_Preview" and only visible if
            the job has more than 1 model type to cycle between. (if previously selected, we MUST set in invisible) when
            selecting a new job;
            Meaning putting these in 1 table simply would not work.
        --]]

        for k, v in pairs( self.Text_Objects ) do 
            if IsValid( v ) then v:SetVisible( false ) end
        end

        for k, v in pairs( self.General_Objects ) do
            if IsValid( v ) then v:SetVisible( false ) end
        end

        for k, v in pairs( self.Tracker_Objects ) do
            if IsValid( v ) then v:SetVisible( false ) end
        end
    end

    --> Prepares F4 menu commands <--
    function OS_UI.PrepareCommands( self )
        local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
        local headers = { "Geral", "Polícia & Prefeito" }

        self.Container.Paint = function( me, w, h ) 
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND ) 
        end

        --> The panel that holds all of the components for the "General Commands" section <--
        self.General_Commands = vgui.Create( "DPanel", self.Container )
        self.General_Commands:DockMargin( 0, 6, 0, 0 )
        self.General_Commands:Dock( TOP )
        self.General_Commands:SetTall( 160 )
        self.General_Commands.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND ) 
        end

        self.General_Commands_Header = vgui.Create( "DLabel", self.General_Commands )
        self.General_Commands_Header:Dock( TOP )
        self.General_Commands_Header:DockMargin( 5, 0, 0, 15 )
        self.General_Commands_Header:SetText( "Comandos Gerais" )
        self.General_Commands_Header:SetFont( "OS_UI.Font.20" )
        self.General_Commands_Header:SetTextColor( OS_UI.Colors.GREY )

        self.General_Commands_Container = vgui.Create( "DPanelList", self.General_Commands )
        self.General_Commands_Container:DockMargin( 0, -5, 0, 0 )
        self.General_Commands_Container:Dock( FILL )
        self.General_Commands_Container:SetSpacing( 3 )
        --self.General_Commands_Container.Paint = function( me, w, h ) OS_UI.DrawRect( 0, 0, w, h, Color( 200, 0, 0 ) ) end

        for k, v in pairs( GENERAL_COMMANDS ) do
            local button = OS_UI.CreateButton( self.General_Commands_Container, 0, 0, self.General_Commands_Container:GetWide(), 30, "OS_UI.Font.18", v.name )
            button.DoClick = function( me )
                if v.show_box then self:Close() OS_UI.CreateDialogBox( v ) else ply:ConCommand( "say " .. v.command ) end
            end
            self.General_Commands_Container:AddItem( button )
        end

        --> The panel that holds all of the components for the "Police & Mayor" section <--
        self.Police_Commands = vgui.Create( "DPanel", self.Container )
        self.Police_Commands:DockMargin( 0, 10, 0, 0 )
        self.Police_Commands:Dock( TOP )
        self.Police_Commands:SetTall( 350 )
        self.Police_Commands.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND ) 
        end

        self.Police_Commands_Header = vgui.Create( "DLabel", self.Police_Commands )
        self.Police_Commands_Header:Dock( TOP )
        self.Police_Commands_Header:DockMargin( 5, 0, 0, 0 )
        self.Police_Commands_Header:SetText( "Polícia & Prefeito" )
        self.Police_Commands_Header:SetFont( "OS_UI.Font.20" )
        self.Police_Commands_Header:SetTextColor( OS_UI.Colors.GREY )

        self.Police_Commands_Container = vgui.Create( "DPanelList", self.Police_Commands )
        self.Police_Commands_Container:DockMargin( 0, 10, 0, 0 )
        self.Police_Commands_Container:Dock( FILL )
        self.Police_Commands_Container:SetSpacing( 3 )
        --self.Police_Commands_Container.Paint = function( me, w, h ) OS_UI.DrawRect( 0, 0, w, h, Color( 200, 0, 0 ) ) end

        for k, v in pairs( POLICE_COMMANDS ) do
            local button = OS_UI.CreateButton( self.General_Commands_Container, 0, 0, self.General_Commands_Container:GetWide(), 30, "OS_UI.Font.18", v.name )
            button.DoClick = function( me )
                if v.show_box then self:Close() OS_UI.CreateDialogBox( v ) else ply:ConCommand( "say " .. v.command ) end
            end
            self.Police_Commands_Container:AddItem( button )
        end
    end

    --> Creates a bunch of links, buttons etc on the Dashboard <--
    function OS_UI.ButtonListHeader( self, x, y, w, header_str, tbl, useSelection, link )
        useSelection = useSelection or false
        local scr_w, scr_h = ScrW(), ScrH()
        local selected, instances = 0, {}

        self.Button_Menu_Header = vgui.Create( "DLabel", self.Dashboard )
        self.Button_Menu_Header:SetPos( scr_w * 0.007, y )
        self.Button_Menu_Header:SetText( header_str )
        self.Button_Menu_Header:SetFont( "OS_UI.Font.20" )
        self.Button_Menu_Header:SetTextColor( OS_UI.Colors.GREY )

        self.Button_Menu_List = vgui.Create( "DPanelList", self.Dashboard )
        self.Button_Menu_List:SetSpacing( -6 )
        self.Button_Menu_List:SetSize( self.Dashboard:GetWide(), self.Dashboard:GetTall() )
        self.Button_Menu_List:SetPos( scr_w * 0.004, y + scr_h * 0.016 ) 

        for k, v in pairs( tbl ) do
            if v.enabled == false then continue end
            self.Button_Menu_Container = vgui.Create( "DPanel", self.Button_Menu_List )
            self.Button_Menu_Container:SetSize( w, 40 )
            self.Button_Menu_Container.Paint = function( me, w, h )
                if v.icon then
                    OS_UI.DrawTexture( v.icon, 5, 17, 22, 22, OS_UI.Colors.GREY )
                else
                    OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
                end
            end

            self.Button_Menu_Button = vgui.Create( "DLabel", self.Button_Menu_Container )
            self.Button_Menu_Button:SetPos( self.Dashboard:GetWide() / 4.8, 7 )
            self.Button_Menu_Button:SetSize( w, 40 )
            self.Button_Menu_Button:SetText( v.name )
            self.Button_Menu_Button:SetFont( "OS_UI.Font.18" )
            self.Button_Menu_Button:SetTextColor( ( useSelection and k == 1 and OS_UI.Colors.GREY or OS_UI.Colors.WHITE ) )
            self.Button_Menu_Button:SetMouseInputEnabled( true )
            self.Button_Menu_Button:SetCursor( "hand" )

            table.insert( instances, self.Button_Menu_Button )

            self.Button_Menu_Button.OnMousePressed = function( me )
                if link == false then 
                    if selected == k then return end
                    self.Container:Clear() 
                    selected = k
                    for k, v in pairs( instances ) do
                        if IsValid( v ) then 
                            if v == me then
                                v:SetTextColor( OS_UI.Colors.GREY )
                            else
                                v:SetTextColor( OS_UI.Colors.WHITE )
                            end
                        end 
                    end
                end
                if v.callBack then v.callBack( self ) end
            end
            self.Button_Menu_List:AddItem( self.Button_Menu_Container )
        end
        return self.Button_Menu_List
    end

    --> Creates the Jobs section in the F4 menu <--
    function OS_UI.PrepareJobs( self )
        OS_UI.CreateCategoryFoundation( self, true, DarkRP.getCategories()[ "jobs" ], RPExtraTeams, nil, function( v )
            RunConsoleCommand( "darkrp", v.vote and "vote" .. v.command or v.command )
        end )
    end

    --> Creates the Entities section in the F4 menu <--
    function OS_UI.PrepareEntities( self )
        OS_UI.CreateCategoryFoundation( self, false, DarkRP.getCategories()[ "entities" ], DarkRPEntities, nil, function( v )
            RunConsoleCommand( "darkrp", v.cmd )
        end )
    end

    --> Creates the Ammo section in the F4 menu <--
    function OS_UI.PrepareAmmo( self )
        OS_UI.CreateCategoryFoundation( self, false, DarkRP.getCategories()[ "ammo" ], GAMEMODE.AmmoTypes, nil, function( v ) 
            RunConsoleCommand( "darkrp", "buyammo", v.ammoType )
        end )
    end

    --> Creates the Singles section in the F4 menu <--
    function OS_UI.PrepareSingles( self )
        OS_UI.CreateCategoryFoundation( self, false, DarkRP.getCategories()[ "shipments" ], OS_UI.GetSingles(), "Singles", function( v ) 
            RunConsoleCommand( "darkrp", "buy", v.name )
        end )
    end

    --> Creates the Shipments section in the F4 menu <--
    function OS_UI.PrepareShipments( self )
        OS_UI.CreateCategoryFoundation( self, false, DarkRP.getCategories()[ "shipments" ], OS_UI.GetShipments(), "Shipments", function( v ) 
            RunConsoleCommand( "darkrp", "buyshipment", v.name )
        end )
    end

    --> Creates the Food section in the F4 menu <--
    --> We create a "fake" category here to force the F4 menu to create a category. <--
    function OS_UI.PrepareFood( self )
        local category = { name = "Food", sortOrder = 100, members = FoodItems }
        OS_UI.CreateCategoryFoundation( self, false, { category }, FoodItems, "Food", function( v ) 
            RunConsoleCommand( "darkrp", "buyfood", v.name )
        end )
    end

    --> Creates the Vehicle section in the F4 menu <--
    --> We create a "fake" category here to force the F4 menu to create a category. <--
    function OS_UI.PrepareVehicles( self )
        local category = { name = "Vehicles", sortOrder = 100, members = CustomVehicles }
        OS_UI.CreateCategoryFoundation( self, false, { category }, CustomVehicles, "Vehicles", function( v ) 
            RunConsoleCommand( "darkrp", "buyvehicle", v.name )
        end )
    end

    local OPTIONS_CATEGORY = {
        { name = "Comandos", icon = OS_UI.Icons.COMMANDS, callBack = OS_UI.PrepareCommands },
        { name = "Profissões", icon = OS_UI.Icons.JOB, callBack = OS_UI.PrepareJobs },
        { name = "Loja", icon = OS_UI.Icons.MISC, callBack = OS_UI.PrepareEntities },
        { name = "Munição", icon = OS_UI.Icons.AMMO, callBack = OS_UI.PrepareAmmo },
        { name = "Armas", icon = OS_UI.Icons.WEAPONS, callBack = OS_UI.PrepareSingles },
        { name = "Produtos", icon = OS_UI.Icons.SHIPMENTS, callBack = OS_UI.PrepareShipments },
        { name = "Comida", icon = OS_UI.Icons.HUNGER, callBack = OS_UI.PrepareFood, enabled = OS_UI.Settings.Enable_Food },
        { name = "Veículos", icon = OS_UI.Icons.VEHICLE, callBack = OS_UI.PrepareVehicles, enabled = OS_UI.Settings.Enable_Vehicle_Tab }
    }
    
    function OS_UI.OpenF4Menu()
        local scr_w, scr_h, ply = ScrW(), ScrH(), LocalPlayer()
        local low_res = scr_w < 1600
        local self = vgui.Create( "DFrame" )
        self:SetSize( scr_w * ( low_res and 0.9 or 0.57 ), scr_h * ( low_res and 0.95 or 0.67 ) )
        self:Center()
        self:SetTitle( "" )
        self:SetDraggable( false )
        self:MakePopup()
        self:ShowCloseButton( false )

        local openTime = CurTime()
        self.Paint = function( me, w, h )
            Derma_DrawBackgroundBlur( me, openTime ) 
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND )
        end

        --> Header with #Server_Name# and Close Button <--
        self.Header = vgui.Create( "DPanel", self )
        self.Header:Dock( TOP )
        self.Header:SetTall( 40 )
        self.Header:DockMargin( -5, -30, -5, 0 )
        self.Header:InvalidateLayout( true )

        self.Header.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
            OS_UI.DrawText( OS_UI.Settings.Server_Name, "OS_UI.Font.21", w / 2, h / 2, OS_UI.Colors.GREY, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        --> Close button icon <--
        OS_UI.CreateIconObject( self.Header, OS_UI.Icons.CIRCLE, self:GetWide() - 22, self.Header:GetTall() / 2 - 6, 12, 12, true, function()
            self:Close()
        end )

        self.Dashboard = vgui.Create( "DPanel", self )
        self.Dashboard:Dock( LEFT )
        self.Dashboard:SetTall( self:GetTall() )
        self.Dashboard:SetWide( self:GetWide() / 6 ) 
        self.Dashboard:DockMargin( -5, 1, 0, -5 )
        self.Dashboard.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_HEADER )
        end

        self.Container = vgui.Create( "DPanel", self )
        self.Container:Dock( FILL )
        self.Container:DockMargin( ( self:GetWide() / 6 - self.Dashboard:GetWide() ) + 7, 6, 2, 2 )
        self.Container.Paint = function( me, w, h )
            OS_UI.DrawRect( 0, 0, w, h, OS_UI.Colors.BASE_BACKGROUND )
        end

        OS_UI.ButtonListHeader( self, scr_w * 0.01, scr_h * 0.012, self.Dashboard:GetWide(), "Opções", OPTIONS_CATEGORY, true, false )
        OS_UI.ButtonListHeader( self, scr_w * 0.01, self:GetTall() / ( low_res and 2.3 or scr_w == 1600 and 1.95 or 2.26 ), self.Dashboard:GetWide(), "Links", LINKS_CATEGORY, false, true )

        OS_UI.PrepareCommands( self )
    end
    net.Receive( "OS_UI.Open.F4_Menu", OS_UI.OpenF4Menu )