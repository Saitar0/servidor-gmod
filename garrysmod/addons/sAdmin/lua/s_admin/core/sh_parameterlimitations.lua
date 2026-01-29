sAdmin = sAdmin or {}
sAdmin.ParameterLimitations = sAdmin.ParameterLimitations or {}
sAdmin.typeDefinitions = {
    --["amount"] = 1,
    --["classname"] = "",
    --["damage"] = 1,
    --["dropdown"] = "",
    --["gamemode"] = "",
    --["id"] = "",
    --["job"] = "",
    --["map"] = "",
    --["model"] = "",
    --["msg"] = "",
    --["name"] = "",
    ["numeric"] = 0,
    ["player"] = 0,
    --["player_name"] = "",
    --["rank"] = 1,
    --["reason"] = "",
    --["scale"] = true,
    --["sid64/sid"] = true,
    --["text"] = true,
    ["time"] = "",
}

if SERVER then
    util.AddNetworkString("sA:ParameterLimitations")

    net.Receive("sA:ParameterLimitations", function(_, ply) 
        if !sAdmin.hasPermission(ply, "manage_perms") and !sAdmin.config["super_users"][ply:SteamID64()] then return end

        local rank = net.ReadString()
        local name = net.ReadString()
        local action = net.ReadBool()

        if !rank or !name then return end

        if action then
            local data = net.ReadString()
            if !data then return end
            data = util.JSONToTable(data)

            sAdmin.saveParameterLimitations(rank, name, data)
        else
            net.Start("sA:ParameterLimitations")
            net.WriteString(rank)
            net.WriteString(name)
            net.WriteString(util.TableToJSON(sAdmin.ParameterLimitations[name] and sAdmin.ParameterLimitations[name][rank] or {}))
            net.Send(ply)
        end
    end)
else
    local margin = slib.getTheme("margin")
    local limit_h = slib.getScaledSize(50, "y")
    
    local header_font, input_font = slib.createFont("Roboto", 18), slib.createFont("Roboto", 15)
    local maincolor, maincolor_7, maincolor_10, maincolor_15, limit_col, textcolor, cleanaccentcolor = slib.getTheme("maincolor"), slib.getTheme("maincolor", 7), slib.getTheme("maincolor", 10), slib.getTheme("maincolor", 15), slib.getTheme("textcolor", -70), slib.getTheme("textcolor"), slib.getTheme("accentcolor")
    local header_h = limit_h * .5

    local function createLabel(txt, parent)
        local label = vgui.Create("EditablePanel", parent)
        label:Dock(LEFT)
        label:SetWide(select(1, surface.GetTextSize(txt)) + margin * 2)
        label.Paint = function(s,w,h)
            draw.SimpleText(txt, input_font, w * .5, h * .5, limit_col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local function createInputStatement(type, val, parent)
        local element

        if type == "time" then
            element = vgui.Create("DTextEntry", parent)
            element:SetWide(slib.getScaledSize(80, "x"))
            element:SetDrawLanguageID(false)
            element:SetFont(input_font)
            element.Paint = function(s,w,h)
                draw.RoundedBox(h * .3, 0, 0, w, h, maincolor)
    
                s:DrawTextEntryText(textcolor, cleanaccentcolor, cleanaccentcolor)
            end

            element.OnChange = function()
                local val = element:GetValue()

                if element.onValueChange then
                    element.onValueChange(sAdmin.getTime(val))
                end
            end
        else
            element = vgui.Create("DNumberWang", parent)
            element:SetWide(slib.getScaledSize(50, "x"))
            element:SetDrawLanguageID(false)
            element:SetFont(input_font)
            element:SetMin(0)
            element:SetMax(2000000)

            element.OnValueChanged = function(ignore)
                local oldValue = element.oldValue
                local newValue = element:GetValue()
    
                timer.Create(tostring(element), .3, 1, function()
                    if isfunction(element.onValueChange) then
                        local result = element.onValueChange(newValue)
                        if result == false then
                            element.oldValue = oldValue
                            element:SetText(oldValue)
                        return end
    
                        element.oldValue = newValue
                    end
                end)
            end
    
            element.Paint = function(s,w,h)
                draw.RoundedBox(h * .3, 0, 0, w, h, maincolor)
    
                s:DrawTextEntryText(textcolor, cleanaccentcolor, cleanaccentcolor)
            end
        end

        element:Dock(LEFT)
        element:DockMargin(margin, margin + 1, margin * 2, margin - 1)
        element:SetValue(val or 0)
        element.default = val

        return element
    end

    local function createLimitBar(type, name, parent, min_val, max_val)
        local main = vgui.Create("EditablePanel", parent)
        main:Dock(TOP)
        main:DockMargin(margin, margin, margin, 0)
        main:SetTall(limit_h)
        main.Paint = function(s,w,h)
            surface.SetDrawColor(maincolor_7)
            surface.DrawRect(0,0,w,h)

            surface.SetDrawColor(maincolor_15)
            surface.DrawRect(0,header_h, w, 2)

            draw.SimpleText(name, header_font, margin, header_h * .5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        parent:InvalidateLayout(true)

        local limit_bar = vgui.Create("EditablePanel", main)
        limit_bar:SetSize(main:GetWide(), limit_h - header_h)
        limit_bar:SetPos(0, header_h)
        
        surface.SetFont(input_font)
        
        createLabel("Min", limit_bar)
        local min = createInputStatement(type, min_val, limit_bar)
        createLabel("Max", limit_bar)
        local max = createInputStatement(type, max_val, limit_bar)

        main.min, main.max = min, max

        return min, max
    end

    sAdmin.openParametersLimiter = function(rank, name, data)
        local cmd = sAdmin.commands[name]

        if !cmd or !cmd.inputs then return end

        local gap = slib.getScaledSize(4, "x")
        local changed = false

        local setting_menu = vgui.Create("SFrame")
        setting_menu:SetSize(slib.getScaledSize(350, "x"), slib.getScaledSize(300, "y"))
        :setBlur(true)
        :SetBG(true, true, nil, true)
        :addCloseButton()
        :MakePopup()
        :Center()
        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "limit_parameters", name))

        for k,v in ipairs(cmd.inputs) do
            local sel_type = sAdmin.typeDefinitions[v[2] or ""] or sAdmin.typeDefinitions[v[1] or ""]

            if !sel_type then continue end
            local min, max = createLimitBar(v[1], slib.getLang("sadmin", sAdmin.config["language"], (v[2] or v[1]).."_limit"), setting_menu.frame, data[k] and data[k].min, data[k] and data[k].max)

            min.onValueChange = function(val)
                data[k] = data[k] or {}
                data[k].min = val
                changed = true
            end

            max.onValueChange = function(val)
                data[k] = data[k] or {}
                data[k].max = val
                changed = true
            end
        end

        local button_box = vgui.Create("EditablePanel", setting_menu.frame)
        button_box:SetSize(setting_menu:GetWide() - (gap * 2), slib.getScaledSize(25, "y"))
        button_box:SetPos(gap, setting_menu.frame:GetTall() - button_box:GetTall() - gap)
        button_box:DockMargin(gap, 0, gap, gap)

        local button_w = math.Round(button_box:GetWide() / 2)

        local revertvals_button = vgui.Create("SButton", button_box)
        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "restore_limits"))
        :SetSize(button_w - gap * .25, button_box:GetTall())

        revertvals_button.bg = maincolor_10
        revertvals_button.font = input_font

        revertvals_button.DoClick = function()
            setting_menu.frame:RequestFocus()
            timer.Simple(.1, function()
                if !IsValid(setting_menu.frame) then return end

                for k,v in ipairs(setting_menu.frame:GetChildren()) do
                    if IsValid(v.min) then
                        v.min:SetValue(v.min.default or 0)
                    end

                    if IsValid(v.max) then
                        v.max:SetValue(v.max.default or 0)
                    end
                end
            end)

            changed = false
        end

        local save_button = vgui.Create("SButton", button_box)
        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "save_limits"))
        :SetPos(button_w + gap * .5, 0)
        :SetSize(button_w - gap * .25, button_box:GetTall())

        save_button.bg = maincolor_10
        save_button.font = input_font

        save_button.DoClick = function()
            setting_menu:Remove()

            if !changed then return end

            net.Start("sA:ParameterLimitations")
            net.WriteString(rank)
            net.WriteString(cmd.name)
            net.WriteBool(true)
            net.WriteString(util.TableToJSON(data))
            net.SendToServer()

            changed = false
        end
    end

    net.Receive("sA:ParameterLimitations", function(_, ply)
        local rank = net.ReadString()
        local name = net.ReadString()
        local data = util.JSONToTable(net.ReadString())

        if !name or !data then return end

        sAdmin.openParametersLimiter(rank, name, data)
    end)
end