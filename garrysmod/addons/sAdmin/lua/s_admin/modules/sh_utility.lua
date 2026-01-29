sAdmin = sAdmin or {}
sAdmin.godded, sAdmin.demigodded = sAdmin.godded or {}, sAdmin.demigodded or {}
sAdmin.cloakedPeople = sAdmin.cloakedPeople or {}

sAdmin.cloakHandle = function(ply, action)
    local sid64 = ply:SteamID64()
    sAdmin.cloakedPeople[sid64] = action
    sAdmin.networkData(nil, {"cloakedPeople", sid64}, action or nil)

    ply:SetRenderMode(action and RENDERMODE_NONE or RENDERMODE_NORMAL)
    ply:DrawShadow(!action)
    ply:SetNoTarget(action)

    for k,v in ipairs(ply:GetWeapons()) do
        v:SetRenderMode(action and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL)
        v:Fire("alpha", action and 0 or 255, 0)
        v:DrawShadow(!action)
    end
end

hook.Add("DrawPhysgunBeam", "sA:NoRenderBeam", function(ply)
    local sid64 = ply:SteamID64()
    if !sid64 then return end

    if sAdmin.cloakedPeople[sid64] and !sAdmin.cloakedPeople[LocalPlayer():SteamID64()] and LocalPlayer() != ply then return false end
end)

sAdmin.addCommand({
    name = "noclip",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("noclip", ply, args[1], 1, true)
        for k,v in ipairs(targets) do
            local sid64 = v:SteamID64()

            if sAdmin.jailData[sid64] then if #targets == 1 then return else continue end end

            local isNoclipped = ply:GetMoveType() == MOVETYPE_NOCLIP

            if sAdmin.config["auto_cloak_on_noclip"] then
                sAdmin.cloakHandle(v, !isNoclipped and true)
            end

            v:SetMoveType(!isNoclipped and MOVETYPE_NOCLIP or MOVETYPE_WALK)
        end

        sAdmin.msg(silent and ply or nil, "noclip_response", ply, targets)
    end
})


sAdmin.addCommand({
    name = "hp",
    category = "Utility",
    inputs = {{"player", "player_name"}, {"numeric", "amount"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("hp", ply, args[1])
        local amount = tonumber(args[2] or 100)

        if !isnumber(amount) then amount = 100 end

        for k,v in ipairs(targets) do
            v:SetHealth(amount)
        end

        sAdmin.msg(silent and ply or nil, "hp_response", ply, targets, amount)
    end
})

sAdmin.addCommand({
    name = "armor",
    category = "Utility",
    inputs = {{"player", "player_name"}, {"numeric", "amount"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("armor", ply, args[1], 1)
        local amount = tonumber(args[2] or 100)

        if !isnumber(amount) then amount = 100 end

        for k,v in ipairs(targets) do
            v:SetArmor(amount)
        end

        sAdmin.msg(silent and ply or nil, "armor_response", ply, targets, amount)
    end
})

sAdmin.addCommand({
    name = "god",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("god", ply, args[1], 1, true)
        for k,v in ipairs(targets) do
            local sid64 = v:SteamID64()
            sAdmin.godded[sid64] = true
        end

        sAdmin.msg(silent and ply or nil, "god_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "ungod",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("ungod", ply, args[1], 1, true)
        for k,v in ipairs(targets) do
            local sid64 = v:SteamID64()
            sAdmin.godded[sid64] = nil
        end

        sAdmin.msg(silent and ply or nil, "ungod_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "demigod",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("demigod", ply, args[1], 1, true)
        for k,v in ipairs(targets) do
            local sid64 = v:SteamID64()
            sAdmin.demigodded[sid64] = true
        end

        sAdmin.msg(silent and ply or nil, "demigod_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "undemigod",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("undemigod", ply, args[1], 1, true)
        for k,v in ipairs(targets) do
            local sid64 = v:SteamID64()
            sAdmin.demigodded[sid64] = nil
        end

        sAdmin.msg(silent and ply or nil, "undemigod_response", ply, targets)
    end
})

if CLIENT then
    sAdmin.overriddenCloaks = sAdmin.overriddenCloaks or {}
    local transparent = Color(255,255,255,0)

    local function handleRendering(ply, hide)
        if hide then
            ply.RenderOverride = function(self)
                self:DrawShadow(false)
    
                local wep = self:GetActiveWeapon()
                if IsValid(wep) then
                    wep.sATreated = true
                    wep.sAOldRenderMode = wep:GetRenderMode()
                    wep.sAOldColor = wep:GetColor()
                    wep.RenderOverride = function(self) wep:SetRenderMode(RENDERMODE_TRANSALPHA) wep:SetColor(transparent) self:DrawShadow(false) return end 
                end
            end
        else
            ply.RenderOverride = nil
            ply:DrawShadow(true)
    
            for k,v in ipairs(ply:GetWeapons()) do
                v.RenderOverride = nil
                v.sATreated = nil
    
                v:SetRenderMode(v.sAOldRenderMode or RENDERMODE_NORMAL)
                v:SetColor(v.sAOldColor or color_white)
    
                v.sAOldRenderMode = nil
                v.sAOldColor = nil
            end
        end
    end

    hook.Add("sA:NetworkReceived", "sA:HandleCloaking", function(args, data)
        if args[1] == "cloakedPeople" then
            if #args == 2 then
                local ply = slib.sid64ToPly[args[2]]
                if IsValid(ply) then
                    handleRendering(ply, data)
                end
            else
                if data and istable(data) then
                    for sid64,v in pairs(data) do
                        local ply = slib.sid64ToPly[sid64]
                        if IsValid(ply) then
                            handleRendering(ply, true)
                        end
                    end
                end
            end
        end
    end)
end

sAdmin.addCommand({
    name = "cloak",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("cloak", ply, args[1])

        for k,v in ipairs(targets) do
            sAdmin.cloakHandle(v, true)
        end

        sAdmin.msg(silent and ply or nil, "cloak_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "uncloak",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("uncloak", ply, args[1])

        for k,v in ipairs(targets) do
            sAdmin.cloakHandle(v)
        end

        sAdmin.msg(silent and ply or nil, "uncloak_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "stopsound",
    category = "Utility",
    func = function(ply, args, silent)
        for k,v in ipairs(player.GetAll()) do
            v:ConCommand("stopsound")
        end

        sAdmin.msg(silent and ply or nil, "stopsound_response", ply)
    end
})

sAdmin.addCommand({
    name = "cleardecals",
    category = "Utility",
    func = function(ply, args, silent)
        for k,v in ipairs(player.GetAll()) do
            v:ConCommand("r_cleardecals")
        end

        sAdmin.msg(silent and ply or nil, "cleardecals_response", ply)
    end
})

local prop_classes = {
    ["prop_physics"] = true,
    ["prop_physics_multiplayer"] = true
}

sAdmin.addCommand({
    name = "freezeprops",
    category = "Utility",
    func = function(ply, args, silent)
        for k,v in ipairs(ents.GetAll()) do
            if prop_classes[v:GetClass()] then
                local phys = v:GetPhysicsObject()

                if IsValid(phys) then
                    phys:EnableMotion(false)
                end
            end
        end

        sAdmin.msg(silent and ply or nil, "freezeprops_response", ply)
    end
})

if CLIENT then
    sAdmin.playURL = function(url, volume)
        if IsValid(sAdmin.playURLStation) then
            sAdmin.playURLStation:Stop()
        end

        sound.PlayURL(url, "", function(ch, _, err)
            if IsValid(ch) then
                ch:Play()
                ch:SetVolume(tonumber(volume) or 1)

                sAdmin.playURLStation = ch
            end
        end)
    end
end

sAdmin.addCommand({
    name = "playurl",
    category = "Utility",
    inputs = {{"player", "player_name"}, {"text", "url"}, {"numeric", "volume"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("playurl", ply, args[1])
        local url, volume = args[2] or "", args[3] or 1

        for k,v in ipairs(targets) do
            v:SendLua([[sAdmin.playURL("]]..url..[[",]]..volume..[[)]])
        end

        sAdmin.msg(silent and ply or nil, "playurl_response", ply, url, targets)
    end
})

sAdmin.addCommand({
    name = "playsound",
    category = "Utility",
    inputs = {{"player", "player_name"},  {"text", "path"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("playsound", ply, args[1])
        local dir = args[2] or ""

        for k,v in ipairs(targets) do
            v:SendLua([[surface.PlaySound("]]..dir..[[")]])
        end

        sAdmin.msg(silent and ply or nil, "playsound_response", ply, dir, targets)
    end
})

sAdmin.addCommand({
    name = "cleanup",
    category = "Utility",
    func = function(ply, args, silent)
        game.CleanUpMap( false, { "env_fire", "entityflame", "_firesmoke" } )

        sAdmin.msg(silent and ply or nil, "cleanup_response", ply)
    end
})

sAdmin.addCommand({
    name = "map",
    category = "Utility",
    inputs = {{"dropdown", "map", sAdmin.GetMaps}, {"dropdown", "gamemode", sAdmin.GetGamemodes}},
    func = function(ply, args, silent)
        local map = args[1] or game.GetMap()
        local gm = args[2] or engine.ActiveGamemode()

        if map == sAdmin.commands["map"].inputs[1][2] then
            map = game.GetMap()
        end

        if gm == sAdmin.commands["map"].inputs[2][2] then
            gm = engine.ActiveGamemode()
        end

        if gm and gm ~= "" then
            game.ConsoleCommand("gamemode "..gm.."\n")
        end

        game.ConsoleCommand("changelevel "..map.."\n")

        sAdmin.msg(silent and ply or nil, "map_response", ply, map, gm)
    end
})

sAdmin.addCommand({
    name = "maprestart",
    category = "Utility",
    func = function(ply, args, silent)
        game.ConsoleCommand("changelevel "..game.GetMap().."\n")

        sAdmin.msg(silent and ply or nil, "maprestart_response", ply)
    end
})

sAdmin.addCommand({
    name = "mapreset",
    category = "Utility",
    func = function(ply, args, silent)
        game.CleanUpMap(true)

        sAdmin.msg(silent and ply or nil, "mapreset_response", ply)
    end
})

sAdmin.addCommand({
    name = "give",
    abbreviation = {"giveweapon"},
    category = "Utility",
    inputs = {{"player", "player_name"}, {"text", "classname"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("give", ply, args[1])
        local classname = args[2]

        if !classname then sAdmin.msg(ply, "invalid_arguments") return end

        for k,v in ipairs(targets) do
            v:Give(classname)
        end

        sAdmin.msg(silent and ply or nil, "give_response", ply, targets, classname)
    end
})

sAdmin.addCommand({
    name = "time",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("time", ply, args[1], 1)

        local target

        for k,v in ipairs(targets) do
            target = v
            
            break
        end

        if !target then return end

        sAdmin.msg(ply, "time_session_response", target:Nick(), sAdmin.formatTime(target:GetUTimeSessionTime(), true))
    end
})

sAdmin.addCommand({
    name = "totaltime",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("time", ply, args[1], 1)

        local target

        for k,v in ipairs(targets) do
            target = v
            
            break
        end

        if !target then return end

        sAdmin.msg(ply, "total_time_response", target:Nick(), sAdmin.formatTime(target:GetUTimeTotalTime(), true))
    end
})

sAdmin.addCommand({
    name = "notarget",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("notarget", ply, args[1])

        for k,v in ipairs(targets) do
            v:SetNoTarget(true)
        end

        sAdmin.msg(silent and ply or nil, "notarget_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "unnotarget",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("unnotarget", ply, args[1])

        for k,v in ipairs(targets) do
            v:SetNoTarget(false)
        end

        sAdmin.msg(silent and ply or nil, "unnotarget_response", ply, targets)
    end
})

hook.Add("EntityTakeDamage", "sA:HandleGodmode", function( ply, dmginfo )
	if ply:IsPlayer() then
        local sid64 = ply:SteamID64()

        if sAdmin.godded[sid64] or (ply:GetMoveType() == MOVETYPE_NOCLIP and sAdmin.config["auto_god_on_noclip"]) then return true end
        if sAdmin.demigodded[sid64] then
            local take_dmg = dmginfo:GetDamage()

            dmginfo:SetDamage(math.min(ply:Health() - 1, take_dmg))
        end
	end
end )

hook.Add("PlayerDisconnected", "sA:HandleDisconnectedGod", function(ply)
    local sid64 = ply:SteamID64()
    sAdmin.godded[sid64] = nil
end)