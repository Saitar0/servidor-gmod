properties.Add( "sadmin_options", {
	MenuLabel = sAdmin.config["prefix"].." "..slib.getLang("sadmin", sAdmin.config["language"], "commands"),
	Order = -100,
	MenuIcon = "icon16/fire.png",

	Filter = function( self, ent, ply )
        if !IsValid(ent) or !sAdmin.hasPermission(LocalPlayer(), "is_staff") or !ent:IsPlayer() then return false end

        return true
	end,
	MenuOpen = function( self, option, ent, tr )
		local submenu = option:AddSubMenu()
        local num = 0
        
        local categories = {}        
        
        for name,v in pairs(sAdmin.commands) do
            if !v.category then continue end
            categories[v.category] = categories[v.category] or {}
            v.name = name
            categories[v.category][v.index] = v
        end

        for name, v in pairs(categories) do
            submenu:AddSpacer()
            submenu:AddOption(name, function()end)
            submenu:AddSpacer()
            for name, v in SortedPairs(v) do
                local name = v.name
                if !sAdmin.hasPermission(LocalPlayer(), name) or !v.inputs or !v.inputs[1] or v.inputs[1][1] ~= "player" then continue end
                num = num + 1
                submenu:AddOption(name, function(self)
                    if v.inputs[2] then
                        local inpt = vgui.Create("SPopupBox")
                        :setTitle(slib.getLang("sadmin", sAdmin.config["language"], "input"))

                        local entries = {}

                        for i = 2, #v.inputs do
                            local entry = inpt:addInput("text", v.inputs[i][2] and slib.getLang("sadmin", sAdmin.config["language"], v.inputs[i][2]).." ("..slib.getLang("sadmin", sAdmin.config["language"], v.inputs[i][1])..")" or slib.getLang("sadmin", sAdmin.config["language"], v.inputs[i][1]))
                            table.insert(entries, entry)
                        end
                            
                        inpt:addChoise(slib.getLang("sadmin", sAdmin.config["language"], "execute"), function()
                            local values = ""
                            
                            for k,v in ipairs(entries) do
                                values = values.." "..v:GetValue()
                            end

                            LocalPlayer():ConCommand("sa "..name..' "'..(ent:IsBot() and ent:Nick() or ent:SteamID64())..'" '..values)
                        end)
                    else
                        LocalPlayer():ConCommand("sa "..name..' "'..(ent:IsBot() and ent:Nick() or ent:SteamID64())..'"')
                    end
                end)
            end
        end

        if num <= 0 then option:Remove() end
	end,
	Action = function( self, ent ) end,
})