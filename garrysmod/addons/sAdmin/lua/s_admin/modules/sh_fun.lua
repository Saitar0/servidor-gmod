sAdmin.addCommand({
    name = "freeze",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("freeze", ply, args[1])

        for k,v in ipairs(targets) do
            v:Freeze(true)
            v:EmitSound("player/pl_drown2.wav")
        end

        sAdmin.msg(silent and ply or nil, "freeze_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "unfreeze",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("unfreeze", ply, args[1])

        for k,v in ipairs(targets) do
            v:Freeze(false)
            v:EmitSound("player/pl_drown1.wav")
        end

        sAdmin.msg(silent and ply or nil, "unfreeze_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "jail",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"time"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("jail", ply, args[1])
        local time = sAdmin.getTime(args, 2)

        for k,v in ipairs(targets) do
            local sid64 = v:SteamID64()
            if sid64 and sAdmin.jailData[sid64] then continue end

            if v == ply and args[1] == "*" then
                sAdmin.msg(ply, "cant_target_self")
                table.remove(targets, k)
            continue end
            
            sAdmin.jailPly(v, time)
        end

        sAdmin.msg(silent and ply or nil, "jail_response", ply, targets, time)
    end
})

sAdmin.addCommand({
    name = "unjail",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("unjail", ply, args[1])

        for k,v in ipairs(targets) do
            sAdmin.unjailPly(v)
        end

        sAdmin.msg(silent and ply or nil, "unjail_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "strip",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("strip", ply, args[1])

        for k,v in ipairs(targets) do
            v:StripWeapons()
        end

        sAdmin.msg(silent and ply or nil, "strip_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "slay",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("slay", ply, args[1])

        for k,v in ipairs(targets) do
            v:Kill()
        end

        sAdmin.msg(silent and ply or nil, "slay_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "exitvehicle",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("exitvehicle", ply, args[1])

        for k,v in ipairs(targets) do
            v:ExitVehicle()
        end

        sAdmin.msg(silent and ply or nil, "exitvehicle_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "respawn",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("respawn", ply, args[1])

        for k,v in ipairs(targets) do
            v:Spawn()
        end

        sAdmin.msg(silent and ply or nil, "respawn_response", ply, targets)
    end
})

local slap_sounds = {
    [1] = "physics/body/body_medium_impact_hard1.wav",
    [2] = "physics/body/body_medium_impact_hard2.wav",
    [3] = "physics/body/body_medium_impact_hard3.wav",
    [4] = "physics/body/body_medium_impact_hard4.wav",
    [5] = "physics/body/body_medium_impact_hard5.wav",
    [6] = "physics/body/body_medium_impact_hard6.wav"
}

sAdmin.addCommand({
    name = "slap",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"numeric", "damage"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("slap", ply, args[1])
        local dmg = tonumber(args[2] or 1)

        if !isnumber(dmg) then dmg = 1 end

        dmg = dmg < 1 and 1 or dmg

        for k,v in ipairs(targets) do
            local dir = Vector(math.random(-150, 150), math.random(-150, 150), math.random(150, 350))
            v:SetVelocity(dir)
            local snd = table.Random(slap_sounds)
            v:EmitSound(snd)
            v:TakeDamage(dmg, v, v)
        end

        sAdmin.msg(silent and ply or nil, "slap_response", ply, targets, dmg)
    end
})

sAdmin.addCommand({
    name = "giveammo",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"numeric", "amount"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("giveammo", ply, args[1])
        local amount = args[2] or 1

        for k,v in ipairs(targets) do
            local wep = v:GetActiveWeapon()
            if !IsValid(wep) then continue end
            local ammotype = wep:GetPrimaryAmmoType()
            if ammotype == -1 then continue end

            v:GiveAmmo(amount, ammotype)
        end

        sAdmin.msg(silent and ply or nil, "giveammo_response", ply, amount, targets)
    end
})

sAdmin.addCommand({
    name = "ignite",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"time"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("ignite", ply, args[1])
        local time = sAdmin.getTime(args, 2)

        if !isnumber(time) then time = 1 end

        time = time < 1 and 1 or time

        for k,v in ipairs(targets) do
            v:Ignite(time)
        end

        sAdmin.msg(silent and ply or nil, "ignite_response", ply, targets, time)
    end
})

sAdmin.addCommand({
    name = "extinguish",
    category = "Fun",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("extinguish", ply, args[1])

        for k,v in ipairs(targets) do
            v:Extinguish()
        end

        sAdmin.msg(silent and ply or nil, "extinguish_response", ply, targets)
    end
})

sAdmin.addCommand({
    name = "setmodel",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"text", "model"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("setmodel", ply, args[1])
        local mdl = args[2]

        if !mdl then return end

        for k,v in ipairs(targets) do
            v:SetModel(mdl)
        end

        sAdmin.msg(silent and ply or nil, "setmodel_response", ply, targets, mdl)
    end
})

sAdmin.addCommand({
    name = "scale",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"numeric", "scale"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("scale", ply, args[1])
        local size = args[2] or 1

        for k,v in ipairs(targets) do
            v:SetModelScale(size, 0)
        end

        sAdmin.msg(silent and ply or nil, "scale_response", ply, targets, size)
    end
})

sAdmin.addCommand({
    name = "speed",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"numeric", "amount"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("speed", ply, args[1])
        local speed = args[2] or 1

        for k,v in ipairs(targets) do
            v:SetWalkSpeed(speed)
            v:SetRunSpeed(speed)
        end

        sAdmin.msg(silent and ply or nil, "speed_response", ply, targets, speed)
    end
})

sAdmin.addCommand({
    name = "walkspeed",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"numeric", "amount"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("walkspeed", ply, args[1])
        local speed = args[2] or 1

        for k,v in ipairs(targets) do
            v:SetWalkSpeed(speed)
        end

        sAdmin.msg(silent and ply or nil, "walkspeed_response", ply, targets, speed)
    end
})

sAdmin.addCommand({
    name = "runspeed",
    category = "Fun",
    inputs = {{"player", "player_name"}, {"numeric", "amount"}},
    func = function(ply, args, silent)
        local targets = sAdmin.getTargets("runspeed", ply, args[1])
        local speed = args[2] or 1

        for k,v in ipairs(targets) do
            v:SetRunSpeed(speed)
        end

        sAdmin.msg(silent and ply or nil, "runspeed_response", ply, targets, speed)
    end
})


sAdmin.addCommand({
    name = "bot",
    category = "Fun",
    inputs = {},
    func = function(ply, args, silent)
        RunConsoleCommand("bot")

        sAdmin.msg(silent and ply or nil, "bot_response", ply, targets, speed)
    end
})