sAdmin = sAdmin or {}
sAdmin.usergroups = sAdmin.usergroups or {}
sAdmin.playerData = sAdmin.playerData or {}
sAdmin.warnsData = sAdmin.warnsData or {
    warnsThisWeek = 0,
    warnsChart = {},
    totalWarns = 0, 
    punishmentsThisWeek = 0,
    totalPunishments = 0
}
sAdmin.stats = sAdmin.stats or {totalPlaytime = 0, totalPlayers = 0, totalStaffOnline = 0, staff_playtimeLeaderboard = {}}

sAdmin.offlinePlayers = sAdmin.offlinePlayers or {refresh = true}
sAdmin.onlineWarns = sAdmin.onlineWarns or {refresh = true}
sAdmin.offlineWarns = sAdmin.offlineWarns or {refresh = true}

local categorySorting = {
    ["Fun"] = 1,
    ["Chat"] = 2,
    ["Management"] = 3,
    ["Teleport"] = 4,
    ["Utility"] = 5,
    ["Warns"] = 6,
    ["DarkRP"] = 7,
    ["CAMI"] = 8
}

local isConsole = {
    ["0"] = true,
    ["[NULL Entity]"] = true
}

local margin, neutralcolor, maincolor, failcolor, maincolor_3, maincolor_5, maincolor_7, maincolor_10, maincolor_min5, maincolor_min35, textcol_min40, hovercolor, linecol = slib.getTheme("margin"), slib.getTheme("neutralcolor"), slib.getTheme("maincolor"), slib.getTheme("failcolor"), slib.getTheme("maincolor", 3), slib.getTheme("maincolor", 5), slib.getTheme("maincolor", 7), slib.getTheme("maincolor", 10), slib.getTheme("maincolor", -5), slib.getTheme("maincolor", -35), slib.getTheme("textcolor", -40), slib.getTheme("hovercolor"), Color(24,24,24,160)
local accent_col = slib.getTheme("accentcolor")
local disablecolor = table.Copy(failcolor)
disablecolor.a = 40

local permissionNameToBox, usergroupNameToBox, offlineSid64ToPanel, bansSid64ToPanel = {}, {}, {}, {}

local delete_ico, edit_ico, arrow_ico, loading_ico, settings_ico = Material("sadmin/delete.png", "smooth noclamp"), Material("sadmin/edit.png", "smooth noclamp"), Material("slib/down-arrow.png", "smooth noclamp"), Material("slib/load.png", "smooth noclamp"), Material("sadmin/levels.png", "smooth noclamp")
local toph = slib.getScaledSize(25, "y")

local function networkRank(rank, create, copy_from)
    net.Start("sA:Networking")
    net.WriteUInt(1, 3)
    net.WriteString(rank)
    net.WriteBool(create)
    
    if create then
        net.WriteString(copy_from or "")
    end

    net.SendToServer()
end

local curBox

local createStatBox = function(parent, title, stat)
    if !IsValid(curBox) or #curBox:GetChildren() >= 2 then
        curBox = vgui.Create("EditablePanel", parent)
        curBox:SetTall(slib.getScaledSize(70, "y"))
        curBox:Dock(TOP)
        curBox:DockMargin(0,margin,0,0)
    end

    local wide = (parent:GetWide() * .5) - (margin * 1.5)
    local box = vgui.Create("EditablePanel", curBox)
    box:Dock(LEFT)
    box:DockMargin(margin,0,0,0)
    box:SetWide(wide)

    local font = slib.createFont("Roboto", 18)
    local font_2 = slib.createFont("Roboto", 25)

    box.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor_10)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(maincolor_5)
        surface.DrawRect(0,math.ceil(h * .6),w,math.ceil(h * .4))

        draw.SimpleText(isfunction(stat) and stat() or stat, font_2, w * .5, h * .3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(title, font, w * .5, h * .8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local createSummaryBox = function(parent, title, txt, noline)
    local box = vgui.Create("EditablePanel", parent)
    box:Dock(TOP)
    box:DockMargin(0,margin,0,0)
    local baseh = slib.getScaledSize(txt and 40 or 20, "y")
    box:SetTall(baseh)
    
    local parsed
    
    local font = slib.createFont("Roboto", 16)
    surface.SetFont(font)
    local firstH = select(2, surface.GetTextSize("XYZABC"))

    box.Paint = function(s,w,h)
        draw.SimpleText(title, slib.createFont("Roboto", 14), w * .5, margin, textcol_min40, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        if txt then
            draw.SimpleText(txt() or "N/A", font, w * .5, firstH + margin, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        if !noline then
            surface.SetDrawColor(maincolor_5)
            surface.DrawRect(w * .15,h - 1,w * .7,1)
        end
    end

    return box
end

local function addIconButton(selcol, icon, func, parent)
    local bttn = vgui.Create("SButton", parent)
    bttn:SetWide(bttn:GetTall())
    bttn.DoClick = function()
        func()
    end

    local hovcol = table.Copy(selcol or color_white)

    bttn.Paint = function(s,w,h)
        hovcol.a = bttn.hovopacity or hovercolor.a
        
        local icosize = h * .7
        local shadowsize = h * .71

        local wantedCol = s:IsHovered() and (selcol or color_white) or hovcol

        surface.SetDrawColor(slib.lerpColor(s, wantedCol))
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(w * .5 - icosize * .5, h * .5 - icosize * .5, icosize, icosize)

        if s.shadow then
            surface.SetDrawColor(shadow_col)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(w * .5 - shadowsize * .5, h * .5 - shadowsize * .5, shadowsize, shadowsize)
        end
    end

    return bttn
end

local createToggleButton = function(parent, data)
    local button = vgui.Create("SButton", parent)
    :Dock(TOP)
    :DockMargin(margin,margin,margin,0)
    :DockPadding(margin,0,0,0)
    :SetZPos(data.index or 0)
    :SetTall(slib.getScaledSize(25, "y"))
    :setTitle(data.name)
    :setToggleable(true)

    button.font = slib.createFont("Roboto", 15)

    button.Paint = function(s,w,h)
        local wantedcolor = neutralcolor

        if !s:IsHovered() and s.toggleCheck() then
            wantedcolor = table.Copy(wantedcolor)
            wantedcolor.a = 0
        end
        
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(s.disabled and disablecolor or slib.lerpColor(s, wantedcolor))
        surface.DrawRect(0, 0, w, h)

        draw.SimpleText(s.title, s.font, margin, h * .5, textcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    return button
end

local createPaginator = function(parent)
    local font = slib.createFont("Roboto", 16)
    local paginator_tall = slib.getScaledSize(25, "y")
    local paginator = vgui.Create("EditablePanel", parent)
    paginator:Dock(BOTTOM)
    paginator:DockPadding(margin,margin,margin,margin)
    paginator:SetTall(paginator_tall)
    paginator.page = 1
    paginator.maxpage = 5

    paginator.Paint = function(s,w,h)
        surface.SetDrawColor(linecol)
        surface.DrawRect(0,0,w,1)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "page_of_page", s.page, s.maxpage), font, w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    surface.SetFont(font)
    local prev_w = select(1, surface.GetTextSize(slib.getLang("sadmin", sAdmin.config["language"], "previous")))
    local next_w = select(1, surface.GetTextSize(slib.getLang("sadmin", sAdmin.config["language"], "next")))

    local left = vgui.Create("SButton", paginator)
    :Dock(LEFT)
    :SetWide(paginator_tall + prev_w)

    local ico_size = paginator:GetTall() * .5

    left.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(0,0,w,h)

        local hover = s:IsHovered()
        local curCol = slib.lerpColor(s, hover and hovercolor or color_white)

        s.move = s.move or 1
        s.move = math.Clamp(hover and s.move + .05 or s.move - .05, 0, 2)

        surface.SetDrawColor(curCol)
        surface.SetMaterial(arrow_ico)
        surface.DrawTexturedRectRotated(h * .5 - s.move, h * .5,ico_size ,ico_size, -90)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "previous"), font, w - margin, h * .5, curCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    left.DoClick = function()
        if paginator.page <= 1 then return end
        local nextpage = paginator.page - 1

        paginator.onPageChanged(nextpage)
    end

    local right = vgui.Create("SButton", paginator)
    :Dock(RIGHT)
    :SetWide(paginator_tall + next_w)

    right.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(0,0,w,h)

        local hover = s:IsHovered()
        local curCol = slib.lerpColor(s, hover and hovercolor or color_white)

        s.move = s.move or 1
        s.move = math.Clamp(hover and s.move + .05 or s.move - .05, 0, 2)

        surface.SetDrawColor(curCol)
        surface.SetMaterial(arrow_ico)
        surface.DrawTexturedRectRotated(w - (h * .5 - s.move), h * .5,ico_size ,ico_size, 90)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "next"), font, margin, h * .5, curCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    right.DoClick = function()
        if paginator.page >= paginator.maxpage then return end
        local nextpage = paginator.page + 1

        paginator.onPageChanged(nextpage)
    end

    return paginator
end

local function getUsergroupsSorted()
    local result = {}

    local tbl = {}

    for k,v in pairs(sAdmin.usergroups) do
        tbl[k] = v.permissions and tonumber(v.permissions.immunity) or 0    
    end

    for k,v in SortedPairsByValue(tbl, true) do
        table.insert(result, k)
    end

    return result
end

local requestPage = function(type, page, search_str)
    net.Start("sA:Networking")
    net.WriteUInt(5, 3)
    net.WriteUInt(type, 3)
    net.WriteUInt(page, 15)
    net.WriteString(search_str or "")
    net.SendToServer()
end

local networkPermission = function(rankcanvas, name, val)
    if !rankcanvas.selected then return end
    local var_type = slib.getStatement(val)

    net.Start("sA:Networking")
    net.WriteUInt(0, 3)
    net.WriteString(rankcanvas.selected)
    net.WriteString(name)
    
    if var_type == "int" then
        net.WriteInt(val, 13)
    else
        net.WriteBool(val)
    end
    
    net.SendToServer()
end

local createPermission = function(parent, name, statement, rankcanvas, base, nosettings)
    local permData = sAdmin.getPermissiondata(name)

    local input_font = slib.createFont("Roboto", 15)
    local permission = vgui.Create("SStatement", parent)
    local permission, elem = permission:addStatement((base or permData.translate) and slib.getLang("sadmin", sAdmin.config["language"], name) or name, statement)
    permission:DockMargin(margin,margin,margin,0)
    permission.bg = maincolor_7
    permission.elemBg = maincolor_min5

    elem.PaintOver = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(w-1,0,1,h)
        surface.DrawRect(0,0,1,h)
    end

    elem.perm = name
    elem.base = base
    elem.default_val = statement
    elem:SetEnabled(false)

    elem.onValueChange = function(val)
        networkPermission(rankcanvas, name, val)
    end

    elem.DoClick = function()
        local cur = elem.enabled
        networkPermission(rankcanvas, name, !cur)
    end

    if parent.IsPermissionTab and !nosettings then
        local right_gap = slib.getScaledSize(4, "x")
        local height = permission:GetTall() * .55
        local size_gap = (permission:GetTall() - height) / 2

        local setting = vgui.Create("SButton", permission)
        setting:SetWide(height)
        setting:Dock(RIGHT)
        setting:DockMargin(0,size_gap,right_gap,size_gap)
        setting.Paint = function(s, w, h)
            surface.SetDrawColor(s:IsHovered() and accent_col or color_white)
            surface.SetMaterial(settings_ico)
            surface.DrawTexturedRect(0,0,w,h)
        end

        setting.DoClick = function()
            local cmd = sAdmin.commands[name]
            
            if !cmd or !cmd.inputs or !rankcanvas.selected or !name then return end

            net.Start("sA:ParameterLimitations")
            net.WriteString(rankcanvas.selected)
            net.WriteString(name)
            net.WriteBool(false)
            net.SendToServer()
        end
    end

    table.insert(rankcanvas.perms, elem)

    permissionNameToBox[name] = elem

    return elem
end

local createUsergroup = function(parent, data)
    local usergroup = createToggleButton(parent, data)
    usergroup.toggleCheck = function() return parent.selected ~= data.name end
    usergroup.name = data.name

    local immunity = sAdmin.usergroups and sAdmin.usergroups[data.name] and sAdmin.usergroups[data.name].permissions and sAdmin.usergroups[data.name].permissions["immunity"]

    if immunity then
        usergroup:SetZPos(-immunity)
    end

    usergroup.DoClick = function()
        local pnl = vgui.GetKeyboardFocus()

        if IsValid(pnl) then
            pnl:SetKeyboardInputEnabled(false)
            pnl:SetKeyboardInputEnabled(true)

        end

        timer.Simple(0, function()
            if !IsValid(parent) then return end
            
            parent.selected = (parent.selected ~= data.name) and data.name or nil
            parent.refreshValues()
        end)
    end

    local delete = addIconButton(failcolor, delete_ico, function()
        local popup = vgui.Create("SPopupBox")
        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "are_you_sure"))
        :setBlur(true)
        :addChoise(slib.getLang("sadmin", sAdmin.config["language"], "no"))
        :addChoise(slib.getLang("sadmin", sAdmin.config["language"], "yes"), function()
            networkRank(data.name, false)
        end)
        :setText(slib.getLang("sadmin", sAdmin.config["language"], "this_delete", data.name))

        popup:Center()
    end, usergroup)

    delete:Dock(RIGHT)
    delete:DockMargin(margin,margin * .5,margin,margin * .5)

    usergroupNameToBox[data.name] = usergroup

    return usergroup
end

local overlineFont, underlineFont = slib.createFont("Roboto", 13), slib.createFont("Roboto", 15)

local addMultibox = function(parent, data)
    local refbttn_width = 0

    local panel = vgui.Create("EditablePanel", parent)
    panel:DockMargin(margin,margin,margin,0)
    panel:SetTall(slib.getScaledSize(33, "y"))
    panel:Dock(TOP)
    panel.name = isfunction(data[1].val) and data[1].val() or data[1].val
    
    local dataCount = #data

    panel.Paint = function(s,w,h)
        local icosize = h * .6
        surface.SetDrawColor(maincolor_10)
        surface.DrawRect(0,0,w,h)

        local xoffset = s.avatar and h - 2 + margin or margin

        for k,v in ipairs(data) do
            panel.name = isfunction(v.val) and v.val() or v.val
            draw.SimpleText(v.title, overlineFont, xoffset + (w * v.offset), margin, textcolor_min50, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(panel.name, underlineFont, xoffset + (w * v.offset), h - margin, textcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end
    end

    return panel
end

local netMenuState = function(state)
    net.Start("sA:Networking")
    net.WriteUInt(2, 3)
    net.WriteBool(state)
    net.SendToServer()
end

local requestCD = {}

local requestData = function(id)
    if requestCD[id] and requestCD[id] > CurTime() then return end
    requestCD[id] = CurTime() + 1

    net.Start("sA:Networking")
    net.WriteUInt(3,3)
    net.WriteUInt(id,2)
    net.SendToServer()
end

local sadmin_menu

local banHandle = function(sid64, action)
    net.Start("sA:Networking")
    net.WriteUInt(4, 3)
    net.WriteString(sid64)
    net.WriteBool(action)

    if action then
        local timeLeft = sAdmin.bans and sAdmin.bans[sid64] and (sAdmin.bans[sid64].expiration - os.time()) or 0
        net.WriteUInt(tonumber(timeLeft),32)
        net.WriteString(sAdmin.bans and sAdmin.bans[sid64] and sAdmin.bans[sid64].reason or 0)
    end

    net.SendToServer()
end

local editBan = function(sid64)
    local oldData = table.Copy(sAdmin.bans[sid64])
    local savebttnh = slib.getScaledSize(30, "y")
    local noRevert = false

    local popup = vgui.Create("SFrame")
    :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "edit_ban_title", slib.findName(sid64)))
    :SetSize(slib.getScaledSize(270, "x"), slib.getScaledSize(290, "y"))
    :addCloseButton()
    :Center()
    :MakePopup()
    :setBlur(true)
    :SetBG(true, true)

    local oldRemove = popup.OnRemove
    popup.OnRemove = function()
        oldRemove(popup)
        if !noRevert then
            sAdmin.bans[sid64] = oldData
        end
    end

    local font = slib.createFont("Roboto", 17)
    surface.SetFont(font)
    local txt_w, txt_h = surface.GetTextSize("ABCXYZ")

    popup.PaintOver = function(s,w,h)
        local timeLeft = (sAdmin.bans and sAdmin.bans[sid64] and tonumber(sAdmin.bans[sid64].expiration) or 0)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "sid64"), font, w * .5, s.topbarheight + margin, textcol_min40, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(sid64, font, w * .5, s.topbarheight + margin + txt_h, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "time_left"), font, w * .5, s.topbarheight + (margin * 2) + (txt_h * 2), textcol_min40, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(timeLeft > 0 and sAdmin.formatTime(timeLeft - os.time(), true) or slib.getLang("sadmin", sAdmin.config["language"], "eternity"), font, w * .5, s.topbarheight + (margin * 2) + (txt_h * 3), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "reason"), font, w * .5, s.topbarheight + (margin * 3) + (txt_h * 4), textcol_min40, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local time_left_w = surface.GetTextSize(slib.getLang("sadmin", sAdmin.config["language"], "time_left"))

    local ico_size = slib.getScaledSize(12, "y")
    local left_margin = (popup:GetWide() * .5) + (time_left_w * .5) + (margin * 2)
    local right_margin = popup:GetWide() - left_margin - ico_size

    local edit_time = vgui.Create("SButton", popup)
    edit_time:SetSize(ico_size, ico_size)
    edit_time:Dock(TOP)
    edit_time:DockMargin(left_margin, popup.topbarheight + (margin * 3) + (txt_h * 2), right_margin, 0)
    edit_time.Paint = function(s,w,h)
        surface.SetDrawColor(s:IsHovered() and hovercolor or color_white)
        surface.SetMaterial(edit_ico)
        surface.DrawTexturedRect(0,0,w,h)
    end

    edit_time.DoClick = function()
        local time_selector = vgui.Create("SFrame")
        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "select_time", slib.findName(sid64)))
        :SetSize(slib.getScaledSize(210, "x"), slib.getScaledSize(75, "y") + (margin * 3))
        :addCloseButton()
        :Center()
        :MakePopup()
        :setBlur(true)
        :SetBG(true, true)

        local number = vgui.Create("STextEntry", time_selector.frame)
        :SetPlaceholder(slib.getLang("sadmin", sAdmin.config["language"], "time"))
        :Dock(TOP)
        :DockMargin(margin,margin,margin,margin)
        :SetTall(slib.getScaledSize(25, "y"))

        number.bg = maincolor_5

        local save = vgui.Create("SButton", time_selector.frame)
        :Dock(TOP)
        :DockMargin(margin,0,margin,margin)
        :SetTall(slib.getScaledSize(20, "y"))
        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "save"))

        save.DoClick = function()
            local args = string.Explode(" ", number:GetValue())
            local time = sAdmin.getTime(args, 1)

            sAdmin.bans[sid64].expiration = os.time() + time

            time_selector:Remove()
        end

        save.bg = maincolor_5
    end

    local text_bg = vgui.Create("EditablePanel", popup)
    text_bg:Dock(FILL)
    text_bg:DockMargin(margin, (txt_h * 3) - ico_size, margin, margin)
    text_bg.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor_5)
        surface.DrawRect(0,0,w,h)
    end

    local reason_text = vgui.Create("STextEntry", text_bg)
    reason_text:Dock(FILL)
    reason_text:DockMargin(margin,margin,margin,margin)
    reason_text:SetMultiline(true)
    reason_text:SetPlaceholder("")
    reason_text:SetValue(sAdmin.bans and sAdmin.bans[sid64] and sAdmin.bans[sid64].reason or slib.getLang("sadmin", sAdmin.config["language"], "no_reason_provided"))
    reason_text.sideline = true
    reason_text.bg = Color(0,0,0,0)

    reason_text.onValueChange = function(val)
        if !sAdmin.bans or !sAdmin.bans[sid64] then return end
        sAdmin.bans[sid64].reason = val
    end

    local button_box = vgui.Create("EditablePanel", popup)
    button_box:Dock(BOTTOM)
    button_box:DockMargin(margin,0,margin,margin)
    button_box:SetTall(slib.getScaledSize(20, "y"))

    local unban = vgui.Create("SButton", button_box)
    :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "unban"))
    :Dock(LEFT)
    :SetWide(popup:GetWide() * .5 - (margin * 1.5))
    :SetTall(slib.getScaledSize(25, "y"))

    unban.DoClick = function()
        popup:Remove()
        noRevert = true

        banHandle(sid64, false)
    end

    local update = vgui.Create("SButton", button_box)
    :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "update"))
    :Dock(LEFT)
    :DockMargin(margin,0,0,0)
    :SetWide(popup:GetWide() * .5 - (margin * 1.5))
    :SetTall(slib.getScaledSize(25, "y"))

    update.DoClick = function()
        popup:Remove()
        noRevert = true

        banHandle(sid64, true)
    end

    update.bg = maincolor_5
    unban.bg = maincolor_5
end



local function titleBox(txt, parent)
    local title_font = slib.createFont("Roboto", 18)
    local title = vgui.Create("EditablePanel", parent)
    title:Dock(TOP)
    title:DockMargin(margin,margin,margin,0)
    title:SetTall(toph)

    title.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor_5)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText(txt, title_font, w * .5, h * .5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return title
end

local function openMenu()
    if IsValid(sadmin_menu) then local todo = !sadmin_menu:IsVisible() sadmin_menu:SetVisible(todo) netMenuState(todo) return end

    sAdmin.stats.totalStaffOnline = 0
    for k, v in ipairs(player.GetAll()) do
        if sAdmin.hasPermission(v, "is_staff") then
            sAdmin.stats.totalStaffOnline = sAdmin.stats.totalStaffOnline + 1
        end
    end
    
    netMenuState(true)

    requestData(0)
    requestData(1)

    sadmin_menu = vgui.Create("SFrame")
    sadmin_menu:SetSize(slib.getScaledSize(sAdmin.config["sizing"]["menu"].x, "x"),slib.getScaledSize(sAdmin.config["sizing"]["menu"].y, "y"))
    :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "title"))
    :addCloseButton()
    :Center()
    :MakePopup()
    :addTab(slib.getLang("sadmin", sAdmin.config["language"], "dashboard"), "sadmin/tabs/dashboard.png")
    :addTab(slib.getLang("sadmin", sAdmin.config["language"], "commands"), "sadmin/tabs/commands.png")
    :addTab(slib.getLang("sadmin", sAdmin.config["language"], "players"), "sadmin/tabs/players.png")

    if !sAdmin.config["disabled_modules"]["Warns"] then
        sadmin_menu:addTab(slib.getLang("sadmin", sAdmin.config["language"], "warns"), "sadmin/tabs/warning.png")
    end

    sadmin_menu:addTab(slib.getLang("sadmin", sAdmin.config["language"], "offline_players"), "sadmin/tabs/ply_off.png")
    :addTab(slib.getLang("sadmin", sAdmin.config["language"], "ranks"), "sadmin/tabs/ranks.png")
    :addTab(slib.getLang("sadmin", sAdmin.config["language"], "bans"),"sadmin/tabs/bans.png")
    :setActiveTab(slib.getLang("sadmin", sAdmin.config["language"], "dashboard"))

    sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "ranks")].perm = "manage_perms"
    sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "players")].perm = "is_staff"
    sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "bans")].perm = "is_staff"
    sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "offline_players")].perm = "is_staff"

    sadmin_menu.onlyHide = true

    sadmin_menu.onClose = function()
        netMenuState(false)
    end

    sadmin_menu.changedTab = function(name)
        if name == slib.getLang("sadmin", sAdmin.config["language"], "bans") then
            requestData(2)
        end

        if name == slib.getLang("sadmin", sAdmin.config["language"], "warns") then
            requestData(3)
        end
    end

    sadmin_menu.nameToPanel = {}

    -- Dashboard Tab
    createStatBox(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "dashboard")], slib.getLang("sadmin", sAdmin.config["language"], "players_online"), function() return player.GetCount().."/"..game.MaxPlayers() end)
    createStatBox(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "dashboard")], slib.getLang("sadmin", sAdmin.config["language"], "staff_online"), function() return sAdmin.stats.totalStaffOnline end)
    createStatBox(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "dashboard")], slib.getLang("sadmin", sAdmin.config["language"], "total_players"), function() return string.Comma(sAdmin.stats.totalPlayers) end)
    createStatBox(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "dashboard")], slib.getLang("sadmin", sAdmin.config["language"], "total_playtime"), function() return sAdmin.formatTime(sAdmin.stats.totalPlaytime) end)

    local ico_size = slib.getScaledSize(64, "y")

    sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "dashboard")].PaintOver = function(s,w,h)
        if sadmin_menu.statsLoaded then return end
        surface.SetDrawColor(maincolor.r, maincolor.r, maincolor.b, 235)
        surface.DrawRect(0,0,w,h)

        slib.DrawBlur(s, 2)

        s.rotation = s.rotation or 0
        s.rotation = s.rotation + .8

        surface.SetDrawColor(color_white)
        surface.SetMaterial(loading_ico)
        surface.DrawTexturedRectRotated(w * .5, h * .5, ico_size, ico_size, -s.rotation)
    end

    local leaderboard_title = titleBox(slib.getLang("sadmin", sAdmin.config["language"], "staff_playtime_leaderboard"), sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "dashboard")])

    local topcolors = {
        [1] = Color(212, 175, 55),
        [2] = Color(211, 211, 211),
        [3] = Color(205, 127, 50)
    }

    local timeBoxes = vgui.Create("SScrollPanel", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "dashboard")])
    timeBoxes:Dock(FILL)
    timeBoxes:DockMargin(margin,0,margin,margin)
    timeBoxes.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor_3)
        surface.DrawRect(0,0,w,h)
    end

    timeBoxes.rebuildScore = function()
        for k,v in ipairs(timeBoxes:GetCanvas():GetChildren()) do
            v:Remove()
        end

        for k,v in ipairs(sAdmin.stats.staff_playtimeLeaderboard) do
            local ply = addMultibox(timeBoxes, {
                [1] = {
                    title = slib.getLang("sadmin", sAdmin.config["language"], "name"),
                    val = v.name or function() return slib.findName(v.sid64) end,
                    offset = 0
                },
                [2] = {
                    title = slib.getLang("sadmin", sAdmin.config["language"], "playtime"),
                    val = sAdmin.formatTime(v.playtime, true),
                    offset = 0.4
                }
            })

            ply.PaintOver = function(s,w,h)
                draw.SimpleText("#"..k, slib.createFont("Roboto", 18), w - margin, h * .5, topcolors[k] or textcolor_min50, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    timeBoxes.rebuildScore()

    sadmin_menu.timeBoxes = timeBoxes

    -- Commands Tab
    local commands_frame = vgui.Create("EditablePanel", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "commands")])
    commands_frame:Dock(LEFT)
    commands_frame:DockMargin(0,0,2,0)
    commands_frame:SetWide(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "commands")]:GetWide() * .33)

    local commands_canvas = vgui.Create("SScrollPanel", commands_frame)
    :Dock(FILL)

    commands_canvas.cats = {}

    commands_canvas.bg = maincolor_5

    local commands_search = vgui.Create("SSearchBar", commands_frame)
    :Dock(TOP)
    :DockMargin(0,0,0,2)
    :addIcon()

    commands_search.bg = maincolor_10

    commands_search.entry.onValueChange = function(val)
        for k, parent in ipairs(commands_canvas:GetCanvas():GetChildren()) do
            local collapse = false
            for child, pnl in ipairs(parent:GetChildren()) do
                if !pnl.name then continue end
                local open = string.find(string.lower(pnl.name), string.lower(string.PatternSafe(val))) and (!sAdmin.config["hide_insufficient_perms_cmds"] or sAdmin.hasPermission(LocalPlayer(), pnl.name))
                if open then collapse = true end
                pnl:SetVisible(open)
            end

            parent.collapsed = collapse
            parent:ForceSize()
        end

        commands_canvas:InvalidateLayout()
    end

    local input_summary
    for name, data in pairs(sAdmin.commands) do
        if !data.category then continue end
        if !commands_canvas.cats[data.category] then
            local category = vgui.Create("SCollapsiblePanel", commands_canvas)
            :Dock(TOP)
            :setTitle(data.category)

            if sAdmin.config["hide_insufficient_perms_cmds"] then
                category.Think = function()
                    if category.nextThink and CurTime() - category.nextThink < 3 then return end
                    category.nextThink = CurTime()
                    category.updatedGroup()
                end

                category.updatedGroup = function()
                    local search_val, changed = commands_search.entry:GetValue()
                    
                    for k,v in ipairs(category:GetChildren()) do
                        if !v.name then continue end

                        local search_allow = (search_val == "" or search_val == commands_search.entry.placeholder) or string.find(string.lower(v.name), string.lower(string.PatternSafe(search_val)))
                        local nextVis = sAdmin.hasPermission(LocalPlayer(), v.name) and search_allow

                        changed = changed or nextVis != v:IsVisible()

                        v:SetVisible(nextVis)
                    end

                    if changed then
                        category:ForceSize((category:getChildCount() < 1 and category.collapsed) and slib.getScaledSize(25, "y") or 0)
                    end
                end

                category.onClicked = function()
                    category:ForceSize((category:getChildCount() < 1 and category.collapsed) and slib.getScaledSize(25, "y") or 0)

                    return true
                end

                category.emptyMsg = slib.getLang("sadmin", sAdmin.config["language"], "no_entries")
            end

            category.bg = maincolor

            if categorySorting[data.category] ~= nil then
                category:SetZPos(categorySorting[data.category])
            end

            commands_canvas.cats[data.category] = category
        end

        data.name = name
        local command = createToggleButton(commands_canvas.cats[data.category], data)
        command.toggleCheck = function() return commands_canvas.selected ~= data.name end
        command.name = name

        local tooltip = slib.createTooltip(slib.getLang("sadmin", sAdmin.config["language"], name.."_help"), command)
        tooltip.clickable = true
        tooltip.bg = maincolor

        command.DoClick = function()
            commands_canvas.selected = (commands_canvas.selected ~= name) and name or nil

            for k,v in ipairs(input_summary:GetChildren()) do
                v:Remove()
            end

            input_summary.curInputs = {}

            if !commands_canvas.selected then return end

            if !sAdmin.commands[commands_canvas.selected].inputs then return end
            for k,v in ipairs(sAdmin.commands[commands_canvas.selected].inputs) do
                if v[1] == "player" and k == 1 then continue end
                input_summary.addInput(v[1], slib.getLang("sadmin", sAdmin.config["language"], v[2] and v[2] or v[1]), v[3])
            end
        end

        command.PaintOver = function(s,w,h)
            local ply = LocalPlayer()
            s.disabled = !sAdmin.hasPermission(ply, data.name)
        end
    end

    for name, panel in pairs(commands_canvas.cats) do
        panel:forceCollapse()
    end

    local players_frame = vgui.Create("EditablePanel", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "commands")])
    players_frame:Dock(LEFT)
    players_frame:SetWide(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "commands")]:GetWide() * .33)

    players_frame.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor)
        surface.DrawRect(0, 0, w, h)
    end
    

    local players_canvas = vgui.Create("SScrollPanel", players_frame)
    players_canvas:Dock(FILL)
    players_canvas.pnls = {}

    players_canvas.PaintOver = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(w-1,0,1,h)
        surface.DrawRect(0,0,1,h)
    end

    local players_search = vgui.Create("SSearchBar", players_frame)
    :Dock(TOP)
    :DockMargin(0,0,0,0)
    :addIcon()

    players_search.bg = maincolor_10

    players_search.entry.onValueChange = function(val)
        for k,v in ipairs(players_canvas:GetCanvas():GetChildren()) do
            if v == players_search or !v.title then continue end
            v:SetVisible(string.find(string.lower(v.title), string.lower(string.PatternSafe(val))))
        end

        players_canvas:GetCanvas():InvalidateLayout()
    end

    local summary_model

    players_canvas.addPlayer = function(v)
        if !IsValid(v) then return end

        if players_canvas.pnls[v] and IsValid(players_canvas.pnls[v]) then return end
        local h = slib.getScaledSize(25, "y")
        local ply = vgui.Create("SButton", players_canvas)
        :Dock(TOP)
        :DockMargin(margin,margin,margin,0)
        :SetTall(h)
        :setToggleable(true)

        ply.font = slib.createFont("Roboto", 15)
        ply.title = v:Nick()
        
        ply.Paint = function(s,w,h)
            if !IsValid(v) then s:Remove() players_canvas:GetCanvas():InvalidateLayout() return end
            local wantedcolor = neutralcolor

            if !s:IsHovered() and players_canvas.selected ~= v then
                wantedcolor = table.Copy(wantedcolor)
                wantedcolor.a = 0
            end
            
            surface.SetDrawColor(maincolor_7)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(slib.lerpColor(s, wantedcolor))
            surface.DrawRect(0, 0, w, h)

            draw.SimpleText(v:Nick(), s.font, h, h * .5, textcolor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        ply.avatar = vgui.Create("AvatarImage", ply)
        ply.avatar:SetPlayer(v, 64)
        ply.avatar:SetPos(margin, margin)
        ply.avatar:SetSize(h - (margin * 2), h - (margin * 2))

        ply.DoClick = function()
            players_canvas.selected = (players_canvas.selected ~= v) and v or nil

        end

        players_canvas.pnls[v] = ply 
    end

    sadmin_menu.players_canvas = players_canvas

    for k,v in ipairs(player.GetAll()) do
        players_canvas.addPlayer(v)
    end

    local command_summary = vgui.Create("EditablePanel", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "commands")])
    command_summary:Dock(FILL)
    command_summary:DockMargin(2,0,0,0)
    command_summary:DockPadding(0,toph,0,0)

    command_summary.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(maincolor_10)
        surface.DrawRect(0,0,w,toph)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "summary"), slib.createFont("Roboto", 18), w * .5, margin, textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local sel_ply = createSummaryBox(command_summary, slib.getLang("sadmin", sAdmin.config["language"], "selected_player"), function() return IsValid(players_canvas.selected) and players_canvas.selected:Nick() or slib.getLang("sadmin", sAdmin.config["language"], "none_selected") end)
    local sel_cmd = createSummaryBox(command_summary, slib.getLang("sadmin", sAdmin.config["language"], "selected_command"), function() return commands_canvas.selected or slib.getLang("sadmin", sAdmin.config["language"], "none_selected") end)
    local inputs = createSummaryBox(command_summary, slib.getLang("sadmin", sAdmin.config["language"], "parameters"), nil, true)

    input_summary = vgui.Create("EditablePanel", command_summary)
    input_summary:Dock(FILL)
    input_summary:DockPadding(margin * 3,margin,margin * 3,0)
    input_summary.curInputs = {}

    input_summary.Paint = function(s,w,h)
        if table.Count(input_summary:GetChildren()) > 0 then return end
        
        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "no_parameters"), slib.createFont("Roboto", 16), w * .5, margin, textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    input_summary.addInput = function(type, title, tblfunc)
        local inpt = vgui.Create(type == "dropdown" and "SDropDown" or "STextEntry", input_summary)
        inpt:Dock(TOP)
        inpt:DockMargin(0,0,0,margin)
        inpt:SetPlaceholder(title)
        inpt:SetTall(slib.getScaledSize(25, "y"))
        inpt.font = slib.createFont("Roboto", 15)
        inpt.buttonh = inpt:GetTall()
        inpt.buttonfont = inpt.font
        inpt.bg = maincolor_7
        inpt.buttonbg = inpt.bg
        if type == "numeric" then
            inpt:SetNumeric(true)
        end

        if type == "dropdown" and tblfunc then
            local tbl = tblfunc()

            inpt.maxHeightChilds = 6

            for k,v in ipairs(tbl) do
                inpt:addOption(v)
            end
        end

        table.insert(input_summary.curInputs, inpt)
    end

    input_summary.getInputs = function()
        local inputs = ""

        for k,v in ipairs(input_summary.curInputs) do
            local val = v:GetValue()

            if val == "" then
                val = v.title or val
            end

            if val == v.placeholder then
                if v:GetNumeric() then
                    val = 0
                end
            end

            inputs = inputs..' "'..val..'"'
        end

        return inputs
    end

    local silent_checkbox, silent_elem

    local execute = vgui.Create("SButton", command_summary)
    :Dock(BOTTOM)
    :DockMargin(margin,margin,margin,margin)
    :SetTall(slib.getScaledSize(25, "y"))
    :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "execute"))

    execute.bg = maincolor_7

    execute.DoClick = function()
        local cmd = commands_canvas.selected
        local inputs = cmd
        
        if !cmd then return end
        local plyRequired = sAdmin.commands[cmd].inputs and sAdmin.commands[cmd].inputs[1] and sAdmin.commands[cmd].inputs[1][1] == "player"
        if plyRequired then
            if IsValid(players_canvas.selected) then
                inputs = inputs..' "'..(players_canvas.selected:SteamID64() or players_canvas.selected:Nick())..'"'
            else return end
        end

        inputs = inputs..input_summary.getInputs()
        LocalPlayer():ConCommand((silent_elem.enabled and "sa_silent" or "sa").." "..inputs)
    end

    silent_checkbox = vgui.Create("SStatement", command_summary)
    silent_checkbox, silent_elem = silent_checkbox:addStatement("Silent?", false)
    silent_checkbox:setCenter()

    silent_checkbox.bg, silent_checkbox.elemBg, silent_checkbox.font = maincolor, maincolor_7, slib.createFont("Roboto", 16)
    silent_checkbox:Dock(BOTTOM)

    -- Players Tab    ​​         0 
    local search_player = vgui.Create("SSearchBar", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "players")])
    search_player:DockMargin(0,0,0,2)
    :addIcon()

    search_player.bg = maincolor_10

    local players_listview = vgui.Create("SListView", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "players")])
    :addColumns(slib.getLang("sadmin", sAdmin.config["language"], "player"), slib.getLang("sadmin", sAdmin.config["language"], "usergroup"), slib.getLang("sadmin", sAdmin.config["language"], "playtime"))
    :Dock(FILL)

    players_listview.pnls = {}

    search_player.entry.onValueChange = function(newval)
        for k,v in pairs(players_listview:GetCanvas():GetChildren()) do
            if !v.name or !IsValid(v.ply) then continue end

            if !string.find(string.lower(v.name), string.lower(string.PatternSafe(newval))) and !string.find(string.lower(v.ply:GetUserGroup()), string.lower(string.PatternSafe(newval))) then
                v:SetVisible(false)
            else
                v:SetVisible(true)
            end

            players_listview:GetCanvas():InvalidateLayout(true)
        end
    end

    players_listview.addPlayer = function(v)
        if !IsValid(v) or v:IsBot() then return end
        local sid64 = v:SteamID64()

        if IsValid(players_listview.pnls[v]) or !sid64 then return end

        local _, line = players_listview:addLine(function() return (IsValid(v) and v:Nick() or sid64) end, 
        function()
            if !IsValid(v) then return end

            local data = sAdmin.playerData[sid64] 
            local timeLeft = (data and tonumber(data.rank_expire) or 0) - os.time() 
            return v:GetUserGroup()..(timeLeft > 0 and " ( "..sAdmin.formatTime(timeLeft).." ) " or "")
        end, function() return IsValid(v) and sAdmin.formatTime(sAdmin.getTotalPlaytime(v)) or "" end)
        
        line.ply = v

        line.PaintOver = function(s)
            if !IsValid(v) then
                s:Remove()

                players_listview:GetCanvas():InvalidateLayout(true)
            end
        end

        line.DoClick = function()
            local dropdown = vgui.Create("SDropDown")
            dropdown.buttonh = slib.getScaledSize(20, "y")
            dropdown.buttonfont = slib.createFont("Roboto", 15)
            dropdown.buttonbg = maincolor_10
            dropdown.buttoncol = maincolor_min35
            dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "open_profile"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_name"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_rank"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_playtime"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "set_rank"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "remove_rank"))

            dropdown.onValueChange = function(val)
                if val == slib.getLang("sadmin", sAdmin.config["language"], "open_profile") then
                    gui.OpenURL("https://steamcommunity.com/profiles/"..sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_name") then
                    SetClipboardText(v:Nick())
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid") then
                    SetClipboardText(v:SteamID())
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64") then
                    SetClipboardText(sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_rank") then
                    SetClipboardText(v:GetUserGroup())
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_playtime") then
                    SetClipboardText(sAdmin.formatTime(sAdmin.getTotalPlaytime(v)))
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "set_rank") then
                    local popup = vgui.Create("SPopupBox")
                    :setBlur(true)
                    :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "set_rank"))
                    
                    local rank = popup:addInput("dropdown", slib.getLang("sadmin", sAdmin.config["language"], "rank_name"))
                    local time = popup:addInput("text", slib.getLang("sadmin", sAdmin.config["language"], "time"))

                    rank.font = time.font
                    rank.buttonfont = rank.font
                    rank.buttonbg = time.bg
                    rank.buttonh = slib.getScaledSize(22, "y")

                    for k,v in ipairs(getUsergroupsSorted()) do
                        rank:addOption(v)
                    end

                    popup:addChoise(slib.getLang("sadmin", sAdmin.config["language"], "set_rank"), function()
                        local rank_name = rank.title
                        local time = time:GetValue()
                        RunConsoleCommand("sa", "setrank", v:Nick(), rank_name, time)
                    end)
            
                    popup:Center()

                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "remove_rank") then
                    RunConsoleCommand("sa", "removeuser", v:Nick())
                end
            end

            dropdown:popupAlone()
        end

        players_listview.pnls[v] = line
    end

    sadmin_menu.players_listview = players_listview

    for k,v in ipairs(player.GetAll()) do
        players_listview.addPlayer(v)
    end

    -- Warns tab experimental statistics inner-tab
    if IsValid(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "warns")]) then
        local statsz = sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "warns")].addTab(slib.getLang("sadmin", sAdmin.config["language"], "statistics"))

        createStatBox(statsz, slib.getLang("sadmin", sAdmin.config["language"], "total_warns"), function() return string.Comma(sAdmin.warnsData.totalWarns) end)
        createStatBox(statsz, slib.getLang("sadmin", sAdmin.config["language"], "total_punishments"), function() return string.Comma(sAdmin.warnsData.totalPunishments) end)
        createStatBox(statsz, slib.getLang("sadmin", sAdmin.config["language"], "warns_this_week"), function() return string.Comma(sAdmin.warnsData.warnsThisWeek) end)
        createStatBox(statsz, slib.getLang("sadmin", sAdmin.config["language"], "punishments_this_week"), function() return string.Comma(sAdmin.warnsData.punishmentsThisWeek) end)

        titleBox(slib.getLang("sadmin", sAdmin.config["language"], "warns_this_week"), statsz)
        local lines = 5

        local number_todays = {
            [1] = slib.getLang("sadmin", sAdmin.config["language"], "monday"),
            [2] = slib.getLang("sadmin", sAdmin.config["language"], "tuesday"),
            [3] = slib.getLang("sadmin", sAdmin.config["language"], "wednesday"),
            [4] = slib.getLang("sadmin", sAdmin.config["language"], "thursday"),
            [5] = slib.getLang("sadmin", sAdmin.config["language"], "friday"),
            [6] = slib.getLang("sadmin", sAdmin.config["language"], "saturday"),
            [7] = slib.getLang("sadmin", sAdmin.config["language"], "sunday")
        }

        local chart_container = vgui.Create("EditablePanel", statsz)
        chart_container:Dock(FILL)
        chart_container:DockMargin(margin,0,margin,margin)
        chart_container.Paint = function(s,w,h)
            surface.SetDrawColor(maincolor_10)
            surface.DrawRect(0,0,w,h)

            local dot_size = 8
            local gap_w, gap_h = (w * .9) / 6, h / (lines + 1)
            local left = -dot_size * .5 + w * .05
            local max_h = h * .85

            for i = 1, lines do
                surface.SetDrawColor(maincolor_3)
                surface.DrawRect(0,gap_h * i,w,1)
            end

            local highest = 0

            for i = 1, 7 do
                local num = (sAdmin.warnsData.warnsChart[i] and sAdmin.warnsData.warnsChart[i].amount or 0)
                if num > highest then
                    highest = num
                end
            end

            for i = 0, 6 do
                local value = sAdmin.warnsData.warnsChart[i + 1] and sAdmin.warnsData.warnsChart[i + 1].amount or 0
                local y_offset = max_h * (value / highest or 0)
                y_offset = tostring(y_offset) == "nan" and 0 or y_offset
                
                local x, y = left + gap_w * i, h - dot_size - y_offset

                if i < 6 then
                    local next_y_offset = max_h  * ((sAdmin.warnsData.warnsChart[i + 2] and sAdmin.warnsData.warnsChart[i + 2].amount or 0) / highest)
                    next_y_offset = tostring(next_y_offset) == "nan" and 0 or next_y_offset

                    surface.SetDrawColor(accent_col)
                    surface.DrawLine(x + dot_size * .5, y + dot_size * .5, left + gap_w * (i + 1) + dot_size * .5, h + dot_size - next_y_offset - dot_size * 1.5)
                end

                draw.RoundedBox(dot_size, x, y, dot_size, dot_size, color_white)

                draw.SimpleTextOutlined(value, slib.createFont("Roboto", 16), x + (dot_size * .5), y - margin - slib.getScaledSize(13, "y"), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, maincolor_3)
                draw.SimpleTextOutlined(number_todays[i + 1], slib.createFont("Roboto", 13), x + (dot_size * .5), y - margin, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, maincolor_3)
            end
        end

        -- Punishment logs
        local logs = sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "warns")].addTab(slib.getLang("sadmin", sAdmin.config["language"], "punishment_logs"))
        
        local search_punishments = vgui.Create("SSearchBar", logs)
        search_punishments:DockMargin(0,0,0,2)
        :addIcon()

        search_punishments.bg = maincolor_10

        local punishment_logs_listview = vgui.Create("SListView", logs)
        :addColumns(slib.getLang("sadmin", sAdmin.config["language"], "player"), slib.getLang("sadmin", sAdmin.config["language"], "active_warns"), slib.getLang("sadmin", sAdmin.config["language"], "date"), slib.getLang("sadmin", sAdmin.config["language"], "action"))
        :Dock(FILL)

        search_punishments.entry.onValueChange = function(newval)
            requestPage(1, 1, newval)
        end

        local pl_paginator = createPaginator(logs)
        pl_paginator.onPageChanged = function(page)
            requestPage(1, page, val == search_punishments.entry.placeholder and "" or val)
        end

        pl_paginator.onPageChanged(1)

        punishment_logs_listview.paginator = pl_paginator

        punishment_logs_listview.clearChilds = function()
            for k,v in ipairs(punishment_logs_listview:GetCanvas():GetChildren()) do
                if !v.isLine then continue end
                v:Remove()
            end

            punishment_logs_listview:GetCanvas():SetTall(punishment_logs_listview:GetTall())
        end

        local actionToLang = {
            [1] = "kick",
            [2] = "ban"
        }

        punishment_logs_listview.addLne = function(v)
            local _, line = punishment_logs_listview:addLine({function() return slib.findName(v.sid64, true) end, v.sid64}, v.active_warns, os.date("%H:%M:%S - %d/%m/%Y", v.date_given), slib.getLang("sadmin", sAdmin.config["language"], actionToLang[tonumber(v.action)]))
            line.isLine = true
            line.DoClick = function()
                local dropdown = vgui.Create("SDropDown")
                dropdown.buttonh = slib.getScaledSize(20, "y")
                dropdown.buttonfont = slib.createFont("Roboto", 15)
                dropdown.buttonbg = maincolor_10
                dropdown.buttoncol = maincolor_min35
                dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "open_profile"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64"))

                dropdown.onValueChange = function(val)
                    if val == slib.getLang("sadmin", sAdmin.config["language"], "open_profile") then
                        gui.OpenURL("https://steamcommunity.com/profiles/"..v.sid64)
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid") then
                        SetClipboardText(util.SteamIDFrom64(v.sid64))
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64") then
                        SetClipboardText(v.sid64)
                    end
                end

                dropdown:popupAlone()
            end

            line.DoRightClick = line.DoClick
        end

        sadmin_menu.punishmentLogs = punishment_logs_listview

        -- Online Players
        local online_players = sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "warns")].addTab(slib.getLang("sadmin", sAdmin.config["language"], "online_players"))

        sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "warns")].PaintOver = function()
            if IsValid(sadmin_menu.onlineWarns) and sadmin_menu.onlineWarns:IsVisible() and sAdmin.onlineWarns.refresh then
                sadmin_menu.onlineWarns.refreshPage()
                sAdmin.onlineWarns.refresh = nil
            end

            if IsValid(sadmin_menu.offlineWarns) and sadmin_menu.offlineWarns:IsVisible() and sAdmin.offlineWarns.refresh then
                sadmin_menu.offlineWarns.refreshPage()
                sAdmin.offlineWarns.refresh = nil
            end
        end

        local search_players = vgui.Create("SSearchBar", online_players)
        search_players:DockMargin(0,0,0,2)
        :addIcon()

        search_players.bg = maincolor_10

        local players_online_warns_listview = vgui.Create("SListView", online_players)
        :addColumns(slib.getLang("sadmin", sAdmin.config["language"], "player"), slib.getLang("sadmin", sAdmin.config["language"], "total_warns"))
        :Dock(FILL)

        search_players.entry.onValueChange = function(newval)
            requestPage(3, 1, newval)
        end

        local pow_paginator = createPaginator(online_players)
        pow_paginator.onPageChanged = function(page)
            requestPage(3, page, val == search_players.entry.placeholder and "" or val)
        end

        pow_paginator.onPageChanged(1)

        players_online_warns_listview.refreshPage = function()
            local search_str, page = search_players.entry:GetText(), pow_paginator.page
            search_str = search_str == search_players.entry.placeholder and "" or search_str

            requestPage(3, page, search_str)
        end

        players_online_warns_listview.paginator = pow_paginator

        players_online_warns_listview.clearChilds = function()
            for k,v in ipairs(players_online_warns_listview:GetCanvas():GetChildren()) do
                if !v.isLine then continue end
                v:Remove()
            end

            players_online_warns_listview:GetCanvas():SetTall(players_online_warns_listview:GetTall())
        end

        players_online_warns_listview.addLne = function(v)
            local _, line = players_online_warns_listview:addLine({function() return v.name or slib.findName(v.sid64, true) end, v.sid64}, v.total_warns or 0)
            line.isLine = true
            line.DoClick = function()
                local dropdown = vgui.Create("SDropDown")
                dropdown.buttonh = slib.getScaledSize(20, "y")
                dropdown.buttonfont = slib.createFont("Roboto", 15)
                dropdown.buttonbg = maincolor_10
                dropdown.buttoncol = maincolor_min35
                dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "check_warns"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "open_profile"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_name"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_rank"))

                dropdown.onValueChange = function(val)
                    if val == slib.getLang("sadmin", sAdmin.config["language"], "check_warns") then
                        requestPage(4, 0, v.sid64)
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "open_profile") then
                        gui.OpenURL("https://steamcommunity.com/profiles/"..v.sid64)
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_name") then
                        SetClipboardText(v.name or slib.findName(v.sid64, true))
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid") then
                        SetClipboardText(util.SteamIDFrom64(v.sid64))
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64") then
                        SetClipboardText(v.sid64)
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_rank") then
                        SetClipboardText(v.rank_name)
                    end
                end

                dropdown:popupAlone()
            end

            line.DoRightClick = line.DoClick
        end

        sadmin_menu.onlineWarns = players_online_warns_listview

        -- Offline Players
        local offline_players = sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "warns")].addTab(slib.getLang("sadmin", sAdmin.config["language"], "offline_players"))

        local search_players = vgui.Create("SSearchBar", offline_players)
        search_players:DockMargin(0,0,0,2)
        :addIcon()

        search_players.bg = maincolor_10

        local players_offline_warns_listview = vgui.Create("SListView", offline_players)
        :addColumns(slib.getLang("sadmin", sAdmin.config["language"], "player"), slib.getLang("sadmin", sAdmin.config["language"], "total_warns"))
        :Dock(FILL)

        search_players.entry.onValueChange = function(newval)
            requestPage(2, 1, newval)
        end

        local poffw_paginator = createPaginator(offline_players)
        poffw_paginator.onPageChanged = function(page)
            requestPage(2, page, val == search_players.entry.placeholder and "" or val)
        end

        poffw_paginator.onPageChanged(1)

        players_offline_warns_listview.refreshPage = function()
            local search_str, page = search_players.entry:GetText(), poffw_paginator.page
            search_str = search_str == search_players.entry.placeholder and "" or search_str

            requestPage(2, page, search_str)
        end

        players_offline_warns_listview.paginator = poffw_paginator

        players_offline_warns_listview.clearChilds = function()
            for k,v in ipairs(players_offline_warns_listview:GetCanvas():GetChildren()) do
                if !v.isLine then continue end
                v:Remove()
            end

            players_offline_warns_listview:GetCanvas():SetTall(players_offline_warns_listview:GetTall())
        end

        players_offline_warns_listview.addLne = function(v)
            local _, line = players_offline_warns_listview:addLine({function() return v.name or slib.findName(v.sid64, true) end, v.sid64}, v.total_warns or 0)
            line.isLine = true
            line.DoClick = function()
                local dropdown = vgui.Create("SDropDown")
                dropdown.buttonh = slib.getScaledSize(20, "y")
                dropdown.buttonfont = slib.createFont("Roboto", 15)
                dropdown.buttonbg = maincolor_10
                dropdown.buttoncol = maincolor_min35
                dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "check_warns"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "open_profile"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_name"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64"))
                :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_rank"))

                dropdown.onValueChange = function(val)
                    if val == slib.getLang("sadmin", sAdmin.config["language"], "check_warns") then
                        requestPage(4, 0, v.sid64)
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "open_profile") then
                        gui.OpenURL("https://steamcommunity.com/profiles/"..v.sid64)
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_name") then
                        SetClipboardText(v.name or slib.findName(v.sid64, true))
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid") then
                        SetClipboardText(util.SteamIDFrom64(v.sid64))
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64") then
                        SetClipboardText(v.sid64)
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_rank") then
                        SetClipboardText(v.rank_name)
                    end
                end

                dropdown:popupAlone()
            end

            line.DoRightClick = line.DoClick
        end

        sadmin_menu.offlineWarns = players_offline_warns_listview
    end
    
    -- Offline Players Tab
    local search_player = vgui.Create("SSearchBar", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "offline_players")])
    search_player:DockMargin(0,0,0,2)
    :addIcon()

    search_player.bg = maincolor_10

    local off_players_listview = vgui.Create("SListView", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "offline_players")])
    :addColumns(slib.getLang("sadmin", sAdmin.config["language"], "player"), slib.getLang("sadmin", sAdmin.config["language"], "usergroup"), slib.getLang("sadmin", sAdmin.config["language"], "playtime"))
    :Dock(FILL)

    sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "offline_players")].PaintOver = function()
        if IsValid(sadmin_menu.offlinePlayers) and sadmin_menu.offlinePlayers:IsVisible() and sAdmin.offlinePlayers.refresh then
            sadmin_menu.offlinePlayers.refreshPage()
            sAdmin.offlinePlayers.refresh = nil
        end
    end

    search_player.entry.onValueChange = function(newval)
        requestPage(0, 1, newval)
    end

    local op_paginator = createPaginator(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "offline_players")])
    op_paginator.onPageChanged = function(page)
        requestPage(0, page, val == search_player.entry.placeholder and "" or val)
    end

    op_paginator.onPageChanged(1)

    off_players_listview.refreshPage = function()
        local search_str, page = search_player.entry:GetText(), op_paginator.page
        search_str = search_str == search_player.entry.placeholder and "" or search_str

        requestPage(0, page, search_str)
    end

    off_players_listview.paginator = op_paginator

    local sid64toPly = {}

    for k,v in ipairs(player.GetAll()) do
        local sid = sid64toPly
        if v:IsBot() or !sid then continue end
        sid64toPly[sid] = v
    end

    off_players_listview.clearChilds = function()
        for k,v in ipairs(off_players_listview:GetCanvas():GetChildren()) do
            if !v.isLine then continue end
            v:Remove()
        end

        off_players_listview:GetCanvas():SetTall(off_players_listview:GetTall())
    end

    off_players_listview.addLne = function(v)
        local _, line = off_players_listview:addLine({function() return v.name or slib.findName(v.sid64, true) end, v.sid64}, function() local timeLeft = math.max((tonumber(v.rank_expire) or 0) - os.time(), 0) return v.rank_name..(timeLeft > 0 and " ( "..sAdmin.formatTime(v.rank_expire - os.time()).." ) " or (tonumber(v.rank_expire) or 0) > 0 and " ( "..slib.getLang("sadmin", sAdmin.config["language"], "expired").." ) " or "") end, {function() return sAdmin.formatTime(v.playtime, true) end, v.playtime})
        line.isLine = true
        line.DoClick = function()
            local dropdown = vgui.Create("SDropDown")
            dropdown.buttonh = slib.getScaledSize(20, "y")
            dropdown.buttonfont = slib.createFont("Roboto", 15)
            dropdown.buttonbg = maincolor_10
            dropdown.buttoncol = maincolor_min35
            dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "open_profile"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_name"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_rank"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_playtime"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "set_rank"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "remove_rank"))

            dropdown.onValueChange = function(val)
                if val == slib.getLang("sadmin", sAdmin.config["language"], "open_profile") then
                    gui.OpenURL("https://steamcommunity.com/profiles/"..v.sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_name") then
                    SetClipboardText(slib.findName(v.sid64))
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid") then
                    SetClipboardText(util.SteamIDFrom64(v.sid64))
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64") then
                    SetClipboardText(v.sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_rank") then
                    SetClipboardText(v.rank_name)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_playtime") then
                    SetClipboardText(sAdmin.formatTime(v.playtime))
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "set_rank") then
                    local popup = vgui.Create("SPopupBox")
                    :setBlur(true)
                    :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "set_rank"))

                    local rank = popup:addInput("dropdown", slib.getLang("sadmin", sAdmin.config["language"], "rank_name"))
                    local time = popup:addInput("text", slib.getLang("sadmin", sAdmin.config["language"], "time"))

                    rank.font = time.font
                    rank.buttonfont = rank.font
                    rank.buttonbg = time.bg
                    rank.buttonh = slib.getScaledSize(22, "y")

                    for k,v in ipairs(getUsergroupsSorted()) do
                        rank:addOption(v)
                    end

                    popup:addChoise(slib.getLang("sadmin", sAdmin.config["language"], "set_rank"), function()
                        local rank_name = rank.title
                        local time = time:GetValue()
                        RunConsoleCommand("sa", "setrankid", v.sid64, rank_name, time)

                        timer.Simple(1, off_players_listview.refreshPage)
                    end)
            
                    popup:Center()
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "remove_rank") then
                    RunConsoleCommand("sa", "setrankid", v.sid64, "user")

                    timer.Simple(1, off_players_listview.refreshPage)
                end
            end

            dropdown:popupAlone()
        end

        line.DoRightClick = line.DoClick

        offlineSid64ToPanel[v.sid64] = line
    end

    sadmin_menu.offlinePlayers = off_players_listview

    -- Ranks Tab
    local ranks_frame = vgui.Create("EditablePanel", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "ranks")])
    ranks_frame:Dock(LEFT)
    ranks_frame:DockMargin(0,0,2,0)
    ranks_frame:SetWide(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "ranks")]:GetWide() * .33)

    local ranks_canvas = vgui.Create("SScrollPanel", ranks_frame)
    :Dock(FILL)

    ranks_canvas.PaintOver = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(w-1,0,1,h)
        surface.DrawRect(0,0,1,h)
    end

    sadmin_menu.nameToPanel["ranks_canvas"] = ranks_canvas

    ranks_canvas.perms = {}

    ranks_canvas.refreshValues = function()
        local rank = ranks_canvas.selected

        for k,v in ipairs(ranks_canvas.perms) do
            v:SetEnabled(!!rank)
            local val = rank and istable(sAdmin.usergroups[rank]) and istable(sAdmin.usergroups[rank].permissions) and (sAdmin.usergroups[rank].permissions[v.perm] or (!v.base and sAdmin.usergroups[rank].permissions["all_perms"])) or v.default_val
            v.enabled = selected and false or val

            if isfunction(v.SetValue) then
                v:SetValue(val)

                timer.Remove(tostring(v))
            end
        end
    end

    ranks_canvas.bg = maincolor

    local ranks_search = vgui.Create("SSearchBar", ranks_frame)
    :Dock(TOP)
    :DockMargin(0,0,0,0)
    :addIcon()

    ranks_search.bg = maincolor_10

    ranks_search.entry.onValueChange = function(val)
        for k, v in ipairs(ranks_canvas:GetCanvas():GetChildren()) do
            v:SetVisible(string.find(string.lower(v.name), string.lower(string.PatternSafe(val))))
        end

        ranks_canvas:InvalidateLayout()
    end

    local add_rank = vgui.Create("SButton", ranks_search)
    :Dock(RIGHT)
    :DockMargin(margin * 2,margin * 2,margin * 2,margin * 2)
    :SetWide(ranks_search:GetTall() - (margin * 4))

    add_rank.Paint = function(s,w,h)
        local icosize, width = h * .7, 2
        local centerPos = h * .15
        local wantedCol = s:IsHovered() and color_white or hovercolor

        surface.SetDrawColor(slib.lerpColor(s, wantedCol))
        surface.DrawRect(w * .5 - width * .5, 0, width, h)
        surface.DrawRect(0, h * .5 - width * .5, w, width)
    end

    add_rank.DoClick = function()
        local popup = vgui.Create("SPopupBox")
        :setBlur(true)
        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "create_rank"))
        
        local entry = popup:addInput("text", slib.getLang("sadmin", sAdmin.config["language"], "rank_name"))
        local permsToCopy

        if sAdmin.usergroups and table.Count(sAdmin.usergroups) > 0 then
            local copy_perms = popup:addInput("dropdown", slib.getLang("sadmin", sAdmin.config["language"], "copy_perms_from"))
            copy_perms.iteration = 1
            copy_perms.oldTextcolor = copy_perms.textcolor
            copy_perms.textcolor = slib.getTheme("textcolor", -30)
            copy_perms.font = slib.createFont("Roboto", 15)
            copy_perms.onValueChange = function(val)
                copy_perms.textcolor = copy_perms.oldTextcolor
                permsToCopy = val
            end

            local usergroupsImmunity = {}

            for k,v in pairs(sAdmin.usergroups) do
                table.insert(usergroupsImmunity, {k, v.permissions and tonumber(v.permissions.immunity) or 0})
            end

            table.sort(usergroupsImmunity, function(a, b) return a[2] > b[2] end)

            for k, v in ipairs(usergroupsImmunity) do
                copy_perms:addOption(v[1])
            end
        end

        popup:addChoise("Create", function()
            local val = entry:GetValue()
            networkRank(val, true, permsToCopy)
        end)

        popup:Center()
    end

    for name, v in pairs(sAdmin.usergroups) do
        local data = {name = name}
        createUsergroup(ranks_canvas, data)
    end

    local rankInfo_frame = vgui.Create("EditablePanel", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "ranks")])
    rankInfo_frame:Dock(LEFT)
    rankInfo_frame:DockMargin(0,0,2,0)
    rankInfo_frame:DockPadding(0,toph,0,0)
    rankInfo_frame:SetWide(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "ranks")]:GetWide() * .33)

    rankInfo_frame.Paint = function(s,w,h)
        surface.SetDrawColor(maincolor)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(maincolor_10)
        surface.DrawRect(0,0,w,toph)

        draw.SimpleText(slib.getLang("sadmin", sAdmin.config["language"], "settings"), slib.createFont("Roboto", 18), w * .5, margin, textcolor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    rankInfo_frame.PaintOver = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(w-1,0,1,h)
        surface.DrawRect(0,0,1,h)
    end
    
    local sel_rank = createSummaryBox(rankInfo_frame, slib.getLang("sadmin", sAdmin.config["language"], "selected_rank"), function() return ranks_canvas.selected or slib.getLang("sadmin", sAdmin.config["language"], "none_selected") end)
    local perms = createSummaryBox(rankInfo_frame, slib.getLang("sadmin", sAdmin.config["language"], "permissions"), nil, true)

    local basePerms_canvas = vgui.Create("SScrollPanel", rankInfo_frame)
    :Dock(TOP)
    :SetTall(sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "ranks")]:GetTall() * .38)

    basePerms_canvas.bg = maincolor

    local vbar = basePerms_canvas:GetVBar()

    vbar.PaintOver = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(0,0,w,1)
    end

    basePerms_canvas:GetCanvas().PaintOver = function(s,w,h)
        surface.SetDrawColor(maincolor_7)
        surface.DrawRect(w-1,0,1,h)
        surface.DrawRect(0,0,1,h)
    end

    if sAdmin.limits and !table.IsEmpty(sAdmin.limits) then
        createSummaryBox(rankInfo_frame, slib.getLang("sadmin", sAdmin.config["language"], "limits"), nil)
        local limits_canvas = vgui.Create("SScrollPanel", rankInfo_frame)
        :Dock(FILL)
        :DockMargin(0,margin,0,0)

        limits_canvas.bg = maincolor
        
        local vbar = limits_canvas:GetVBar()

        vbar.PaintOver = function(s,w,h)
            surface.SetDrawColor(maincolor_7)
            surface.DrawRect(0,0,w,1)
        end

        limits_canvas:GetCanvas().PaintOver = function(s,w,h)
            surface.SetDrawColor(maincolor_7)
            surface.DrawRect(w-1,0,1,h)
            surface.DrawRect(0,0,1,h)
        end

        for k,v in ipairs(sAdmin.limits) do
            createPermission(limits_canvas, v, -1, ranks_canvas, true):SetMin(-1)
        end
    end

    for k,v in ipairs(sAdmin.base_Perms) do
        createPermission(basePerms_canvas, v.name, v.type or false, ranks_canvas, true)
    end

    local permission_frame = vgui.Create("EditablePanel", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "ranks")])
    permission_frame:Dock(FILL)

    local permission_canvas = vgui.Create("SScrollPanel", permission_frame)
    :Dock(FILL)

    permission_canvas.bg = maincolor_5
    permission_canvas.cats = {}

    local permission_search = vgui.Create("SSearchBar", permission_frame)
    :Dock(TOP)
    :DockMargin(0,0,0,2)
    :addIcon()

    permission_search.bg = maincolor_10

    permission_search.entry.onValueChange = function(val)
        for k, parent in ipairs(permission_canvas:GetCanvas():GetChildren()) do
            local collapse = false
            for child, pnl in ipairs(parent:GetChildren()) do
                if !pnl.name then continue end
                local open = string.find(string.lower(pnl.name), string.lower(string.PatternSafe(val)))
                if open then collapse = true end
                pnl:SetVisible(open)
            end

            parent.collapsed = collapse
            parent:ForceSize()
        end

        permission_canvas:InvalidateLayout()
    end

    local function getFilteredInputs(tbl)
        local inputs = {}

        if tbl and istable(tbl.inputs) then
            for k,v in ipairs(tbl.inputs) do
                local sel_type = sAdmin.typeDefinitions[v[2] or ""] or sAdmin.typeDefinitions[v[1] or ""]
                if !sel_type then continue end
                
                table.insert(inputs, v)
            end
        end

        return inputs
    end

    for k,v in ipairs(sAdmin.permissions) do
        if !permission_canvas.cats[v.category] then
            permission_canvas.cats[v.category] = vgui.Create("SCollapsiblePanel", permission_canvas)
            :Dock(TOP)
            :setTitle(v.category)

            permission_canvas.cats[v.category].IsPermissionTab = true

            permission_canvas.cats[v.category].bg = maincolor

            if categorySorting[v.category] ~= nil then
                permission_canvas.cats[v.category]:SetZPos(categorySorting[v.category])
            end
        end

        local inputs = getFilteredInputs(sAdmin.commands[v.name])

        createPermission(permission_canvas.cats[v.category], v.name, false, ranks_canvas, nil, !inputs or table.IsEmpty(inputs))
    end

    for name, panel in pairs(permission_canvas.cats) do
        panel:forceCollapse()
    end

    -- Bans Tab
    local search_player = vgui.Create("SSearchBar", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "bans")])
    search_player:DockMargin(0,0,0,2)
    :addIcon()

    search_player.bg = maincolor_10

    local bans_listview = vgui.Create("SListView", sadmin_menu.tab[slib.getLang("sadmin", sAdmin.config["language"], "bans")])
    :addColumns(slib.getLang("sadmin", sAdmin.config["language"], "player"), slib.getLang("sadmin", sAdmin.config["language"], "reason"), slib.getLang("sadmin", sAdmin.config["language"], "time_left"), slib.getLang("sadmin", sAdmin.config["language"], "admin"))
    :Dock(FILL)

    bans_listview.Columns[2].maxTxtLen = 24

    search_player.entry.onValueChange = function(newval)
        for k,v in pairs(bans_listview:GetCanvas():GetChildren()) do
            if !v.name then continue end
            if !string.find(string.lower(v.name), string.lower(string.PatternSafe(newval))) then
                v:SetVisible(false)
            else
                v:SetVisible(true)
            end

            bans_listview:GetCanvas():InvalidateLayout()
        end
    end

    bans_listview.addLne = function(v)
        if !istable(v) or !v.sid64 or v.sid64 == "NULL" or IsValid(bansSid64ToPanel[v.sid64]) then return end
        local _, line = bans_listview:addLine({function() return v and slib.findName(v.sid64, true) end, v.sid64}, function() local reason = sAdmin.bans and sAdmin.bans[v.sid64] and sAdmin.bans[v.sid64].reason or "N/A" return reason end, {function() local timeLeft = (sAdmin.bans and sAdmin.bans[v.sid64] and tonumber(sAdmin.bans[v.sid64].expiration) or 0) - os.time() return timeLeft == 0 and slib.getLang("sadmin", sAdmin.config["language"], "eternity") or timeLeft > 0 and sAdmin.formatTime(math.max(timeLeft, 0)) or slib.getLang("sadmin", sAdmin.config["language"], "eternity") end, v.expiration}, {function() return v and isConsole[v.admin_sid64] and slib.getLang("sadmin", sAdmin.config["language"], "console") or slib.findName(v.admin_sid64, true) end, v.admin_sid64})
        line.DoClick = function()
            local dropdown = vgui.Create("SDropDown")
            dropdown.buttonh = slib.getScaledSize(20, "y")
            dropdown.buttonfont = slib.createFont("Roboto", 15)
            dropdown.buttonbg = maincolor_10
            dropdown.buttoncol = maincolor_min35
            dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "edit_ban"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "open_profile"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_name"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "open_admin_profile"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_admin_steamid"))
            :addOption(slib.getLang("sadmin", sAdmin.config["language"], "copy_admin_steamid64"))
            
            dropdown.onValueChange = function(val)
                if val == slib.getLang("sadmin", sAdmin.config["language"], "edit_ban") then
                    editBan(v.sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "open_profile") then
                    gui.OpenURL("https://steamcommunity.com/profiles/"..v.sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_name") then
                    SetClipboardText(slib.findName(v.sid64))
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid") then
                    SetClipboardText(util.SteamIDFrom64(v.sid64))
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_steamid64") then
                    SetClipboardText(v.sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_admin_steamid") then
                    SetClipboardText(util.SteamIDFrom64(v.admin_sid64))
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "copy_admin_steamid64") then
                    SetClipboardText(v.admin_sid64)
                elseif val == slib.getLang("sadmin", sAdmin.config["language"], "open_admin_profile") then
                    gui.OpenURL("https://steamcommunity.com/profiles/"..v.admin_sid64)
                end
            end

            dropdown:popupAlone()
        end

        line.DoRightClick = line.DoClick

        bansSid64ToPanel[v.sid64] = line
    end

    sadmin_menu.bannedPlayers = bans_listview

    for k,v in pairs(sAdmin.bans or {}) do
        bans_listview.addLne(v)
    end
end

concommand.Add("sadmin_menu", function() local _, command = table.Random(sAdmin.config["chat_command"]) RunConsoleCommand("say", command) end)

hook.Add("sA:NetworkReceived", "sA:UpdateData", function(args, data)
    if IsValid(sadmin_menu) then
        sAdmin.stats.totalStaffOnline = 0
        for k, v in ipairs(player.GetAll()) do
            if sAdmin.hasPermission(v, "is_staff") then
                sAdmin.stats.totalStaffOnline = sAdmin.stats.totalStaffOnline + 1
            end
        end

        local ply = LocalPlayer()

        if !sAdmin.hasPermission(ply, "menu") then sadmin_menu:SetVisible(false) sadmin_menu:setActiveTab(slib.getLang("sadmin", sAdmin.config["language"], "dashboard")) return end

        for name, pnl in pairs(sadmin_menu.tab) do
            if pnl.perm then
                local hasPerm = sAdmin.hasPermission(ply, pnl.perm)
                pnl.tabbttn:SetVisible(hasPerm)
                if sadmin_menu.seltab == name and !hasPerm then
                    sadmin_menu:setActiveTab(slib.getLang("sadmin", sAdmin.config["language"], "dashboard"))
                end
            end
        end
        
        sadmin_menu.tabmenu:InvalidateChildren(true)
    end

    if args[1] == "usergroups" and args[3] == "permissions" and args[4] then
        local checkbox = permissionNameToBox[args[4]]
        if !IsValid(checkbox) then return end
        local usergroup = args[2]
        local newval = sAdmin.usergroups[usergroup] and sAdmin.usergroups[usergroup].permissions and sAdmin.usergroups[usergroup].permissions[args[4]] or false
        checkbox.enabled = !isbool(newval) and newval ~= nil or newval

        if args[4] == "all_perms" then
            for name, panel in pairs(permissionNameToBox) do
                if panel.base then continue end
                panel.enabled = newval or sAdmin.usergroups[usergroup] and sAdmin.usergroups[usergroup].permissions and sAdmin.usergroups[usergroup].permissions[name]
            end
        end

        if args[4] == "immunity" then
            local pnl = usergroupNameToBox[args[2]]
            if IsValid(pnl) then
                pnl:SetZPos(-(tonumber(data) or 0))
            end

            
            if CAMI and CAMI.UnregisterUsergroup then
                CAMI.UnregisterUsergroup(args[2])
                sAdmin.registerCAMIGroup(args[2])
            end
        end
    end

    if args[1] == "stats" then
        if !IsValid(sadmin_menu) then return end
        sadmin_menu.timeBoxes.rebuildScore()
        sadmin_menu.statsLoaded = true
    end

    if args[1] == "usergroups" then
        if #args == 1 and data then
            for k,v in pairs(data) do
                sAdmin.registerCAMIGroup(k)
            end
        elseif #args == 2 then
            if data then
                if !IsValid(sadmin_menu) or IsValid(usergroupNameToBox[args[2]]) then return end
                local ranks_canvas = sadmin_menu.nameToPanel["ranks_canvas"]
                createUsergroup(ranks_canvas, {name = args[2]})

                sAdmin.registerCAMIGroup(args[2])
            else
                local pnl = usergroupNameToBox[args[2]]
                if IsValid(pnl) then
                    pnl:Remove()
                end

                if CAMI and CAMI.UnregisterUsergroup then
                    CAMI.UnregisterUsergroup(args[2])
                end
            end
        end
    end

    if args[1] == "playerData" and #args == 1 then
        for k,v in pairs(sAdmin.playerData) do
            if !v.sid64 then continue end
            sAdmin.playerData[v.sid64] = v
            sAdmin.playerData[v.sid64].sid64 = nil

            sAdmin.playerData[k] = nil
        end
    end

    if args[1] == "playerWarns" then
        local warns = vgui.Create("SFrame")
        :MakePopup()
        :setTitle("Warns - "..(data.name))
        :SetSize(slib.getScaledSize(660, "x"), slib.getScaledSize(460, "y"))
        :addCloseButton()
        :setBlur(true)
        :SetBG(true, true, nil, true)
        :Center()

        local listview = vgui.Create("SListView", warns.frame)
        :addColumns(slib.getLang("sadmin", sAdmin.config["language"], "admin"), slib.getLang("sadmin", sAdmin.config["language"], "reason"), slib.getLang("sadmin", sAdmin.config["language"], "active"), slib.getLang("sadmin", sAdmin.config["language"], "date"))
        :Dock(FILL)

        listview.Columns[2].maxTxtLen = 32

        for k,v in ipairs(data) do
            local _, line = listview:addLine({function() return isConsole[v.admin_sid64] and slib.getLang("sadmin", sAdmin.config["language"], "console") or slib.findName(v.admin_sid64, true) end, v.admin_sid64}, v.reason, function() if (os.time() - (v.date_given or 0)) >= sAdmin.getTime(sAdmin.config["warns"]["active_time"]) then v.active = "0" end return v.active == "1" and slib.getLang("sadmin", sAdmin.config["language"], "true") or slib.getLang("sadmin", sAdmin.config["language"], "false") end, os.date("%H:%M:%S - %d/%m/%Y", v.date_given))
        
            line.DoClick = function()
                local lp = LocalPlayer()

                if !sAdmin.hasPermission(lp, "warn_remove") and !sAdmin.hasPermission(lp, "warn_setinactive") then return end

                local dropdown = vgui.Create("SDropDown")
                dropdown.buttonh = slib.getScaledSize(20, "y")
                dropdown.buttonfont = slib.createFont("Roboto", 15)
                dropdown.buttonbg = maincolor_10
                dropdown.buttoncol = maincolor_min35
                
                if sAdmin.hasPermission(lp, "warn_remove") then
                    dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "warn_remove"))
                end

                if sAdmin.hasPermission(lp, "warn_setinactive") and v.active == "1" then
                    dropdown:addOption(slib.getLang("sadmin", sAdmin.config["language"], "warn_setinactive"))
                end

                dropdown.onValueChange = function(val)
                    if val == slib.getLang("sadmin", sAdmin.config["language"], "warn_remove") then
                        RunConsoleCommand("sa", "warn_remove", v.id)
                        line:Remove()
                    elseif val == slib.getLang("sadmin", sAdmin.config["language"], "warn_setinactive") then
                        RunConsoleCommand("sa", "warn_setinactive", v.id)
                        v.active = "0"
                    end
                end
    
                dropdown:popupAlone()
            end
        end
    end

    if args[1] == "offlinePlayers" and #args == 1 then
        if !IsValid(sadmin_menu) or !IsValid(sadmin_menu.offlinePlayers) then return end
        sadmin_menu.offlinePlayers.paginator.maxpage, sadmin_menu.offlinePlayers.paginator.page = math.max(data.total_pages or 0, 1), data.cur_page
        
        if sadmin_menu.offlinePlayers.paginator.maxpage < sadmin_menu.offlinePlayers.paginator.page then
            sadmin_menu.offlinePlayers.paginator.page = 1
        end

        sadmin_menu.offlinePlayers.clearChilds()

        for k,v in ipairs(data) do
            sadmin_menu.offlinePlayers.addLne(v)
        end
    end

    if args[1] == "offlineWarns" and istable(data) then
        if !IsValid(sadmin_menu) or !IsValid(sadmin_menu.offlineWarns) then return end
        sadmin_menu.offlineWarns.paginator.maxpage, sadmin_menu.offlineWarns.paginator.page = math.max(data.total_pages or 0, 1), data.cur_page
        
        if sadmin_menu.offlineWarns.paginator.maxpage < sadmin_menu.offlineWarns.paginator.page then
            sadmin_menu.offlineWarns.paginator.page = 1
        end

        sadmin_menu.offlineWarns.clearChilds()

        for k,v in ipairs(data) do
            sadmin_menu.offlineWarns.addLne(v)
        end
    end
    
    if args[1] == "onlineWarns" and istable(data) then
        if !IsValid(sadmin_menu) or !IsValid(sadmin_menu.onlineWarns) then return end
        sadmin_menu.onlineWarns.paginator.maxpage, sadmin_menu.onlineWarns.paginator.page = math.max(data.total_pages or 0, 1), data.cur_page
        
        if sadmin_menu.onlineWarns.paginator.maxpage < sadmin_menu.onlineWarns.paginator.page then
            sadmin_menu.onlineWarns.paginator.page = 1
        end

        sadmin_menu.onlineWarns.clearChilds()

        for k,v in ipairs(data) do
            sadmin_menu.onlineWarns.addLne(v)
        end
    end
    
    if args[1] == "punishmentLogs" then
        if !IsValid(sadmin_menu) or !IsValid(sadmin_menu.punishmentLogs) then return end
        sadmin_menu.punishmentLogs.paginator.maxpage, sadmin_menu.punishmentLogs.paginator.page = math.max(data.total_pages or 0, 1), data.cur_page

        if sadmin_menu.punishmentLogs.paginator.maxpage < sadmin_menu.offlinePlayers.paginator.page then
            sadmin_menu.punishmentLogs.paginator.cur_page = 1
        end

        sadmin_menu.punishmentLogs.clearChilds()

        for k,v in ipairs(data) do
            sadmin_menu.punishmentLogs.addLne(v)
        end
    end

    if args[1] == "playersWarns" then
        if !IsValid(sadmin_menu) or !IsValid(sadmin_menu.playersWarns) then return end
        sadmin_menu.playersWarns.paginator.maxpage, sadmin_menu.playersWarns.paginator.page = math.max(data.total_pages or 0, 1), data.cur_page

        if sadmin_menu.playersWarns.paginator.maxpage < sadmin_menu.offlinePlayers.paginator.page then
            sadmin_menu.playersWarns.paginator.cur_page = 1
        end

        sadmin_menu.playersWarns.clearChilds()

        for k,v in ipairs(data) do
            sadmin_menu.playersWarns.addLne(v)
        end
    end

    if args[1] == "bans" then
        if #args > 1 then
            if !data then
                local pnl = bansSid64ToPanel[args[2]]
                if IsValid(pnl) then pnl:Remove() end
            elseif IsValid(sadmin_menu) and IsValid(sadmin_menu.bannedPlayers) then
                sadmin_menu.bannedPlayers.addLne(sAdmin.bans[args[2]])
            end
        else
            local converted = {}

            for k,v in pairs(sAdmin.bans) do
                if !v.sid64 then continue end

                converted[v.sid64] = v

                if IsValid(sadmin_menu) and IsValid(sadmin_menu.bannedPlayers) then
                    sadmin_menu.bannedPlayers.addLne(v)
                end
            end

            sAdmin.bans = converted
        end
    end
end)

hook.Add("OnEntityCreated", "sA:DetectConnect", function(ent)
    if ent:IsPlayer() then
        local sid64 = ent:SteamID64()
        local panel = offlineSid64ToPanel[sid64]
        if IsValid(panel) then panel:SetVisible(false) end

        if IsValid(sadmin_menu) and IsValid(sadmin_menu.players_listview) then
            sadmin_menu.players_listview.addPlayer(ent)
        end

        if IsValid(sadmin_menu) and IsValid(sadmin_menu.onlineWarns) then
            sAdmin.onlineWarns.refresh = true
        end

        if IsValid(sadmin_menu) and IsValid(sadmin_menu.offlineWarns) then
            sAdmin.offlineWarns.refresh = true
        end

        if IsValid(sadmin_menu) and IsValid(sadmin_menu.offlinePlayers) then
            sAdmin.offlinePlayers.refresh = true
        end

        if IsValid(sadmin_menu) and IsValid(sadmin_menu.players_canvas) then
            sadmin_menu.players_canvas.addPlayer(ent)
        end
    end
end)

hook.Add("OnRemove", "sA:DetectDisconnect", function(ent)
    if ent:IsPlayer() then
        local sid64 = ent:SteamID64()
        local panel = offlineSid64ToPanel[sid64]
        if IsValid(panel) then panel:SetVisible(true) end
    end
end)

hook.Add("PlayerNoClip", "sA:FixVisualBug", function() return false end) -- We check it only on serverside.

net.Receive("sA:Networking", function()
    local action = net.ReadUInt(3)

    if action == 0 then
        local var = net.ReadString()
        local info = util.JSONToTable(net.ReadString())

        local final = sAdmin.niceDisplayText(var, info)

        chat.AddText(sAdmin.config["chat_prefix"][1], sAdmin.config["chat_prefix"][2], unpack(final))
    elseif action == 1 then
        local compressed = net.ReadBool()

        local json

        if compressed then
            local len = net.ReadUInt(32)
            json = util.Decompress(net.ReadData(len))
        else
            json = net.ReadString()
        end

        local data = util.JSONToTable(json)
        local args = data.args

        local destination = sAdmin
        for k,v in ipairs(args) do
            destination[v] = #args > k and (destination[v] or {}) or data.data
            destination = destination[v]
        end

        hook.Run("sA:NetworkReceived", args, data.data)
    elseif action == 2 then
        openMenu()
    end
end)