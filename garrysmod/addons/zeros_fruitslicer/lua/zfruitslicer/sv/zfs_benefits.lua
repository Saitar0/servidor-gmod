if not SERVER then return end
zfs = zfs or {}
zfs.Benefits = zfs.Benefits or {}

util.AddNetworkString("zfs_screeneffect")

local function safeNotify(ply, key)
    if not IsValid(ply) then return end
    local msg = (zfs.language and zfs.language.Benefit and zfs.language.Benefit[key]) or ""
    if msg ~= "" then zfs.f.Notify(ply, msg, 1) end
end

function zfs.Benefits.Health(ply, toppingID, apply)
    if not IsValid(ply) then return end
    local t = zfs.config.Toppings[toppingID]
    if not t then return end
    local amount = t.ToppingBenefits and t.ToppingBenefits["Health"]
    if not amount or amount == 0 then return end

    -- To avoid warnings when DarkRP 'Energy' DarkRPVar isn't registered,
    -- apply health change directly. If you want DarkRP hunger integration,
    -- enable it explicitly after ensuring the 'Energy' DarkRPVar exists.
    local newHealth = ply:Health() + amount

    if zfs.config.HealthCap and newHealth > zfs.config.MaxHealthCap then
        newHealth = zfs.config.MaxHealthCap
        safeNotify(ply, "CantAdd_ExtraHealth")
    end

    ply:SetHealth(newHealth)
end

function zfs.Benefits.ParticleEffect(ply, toppingID, apply)
    if not IsValid(ply) then return end
    local t = zfs.config.Toppings[toppingID]
    if not t then return end
    local effect = t.ToppingBenefits and t.ToppingBenefits["ParticleEffect"]
    if not effect then return end

    -- Attach the particle to the player so it follows them instead of spawning at their feet
    zfs.f.CreateEffectTable(effect, nil, ply, nil, nil, 0)

    local dur = t.ToppingBenefit_Duration or -1
    if dur and dur > 0 then
        timer.Simple(dur, function()
            if IsValid(ply) then zfs.f.RemoveEffectNamed(ply, effect, nil) end
        end)
    end
end

function zfs.Benefits.SpeedBoost(ply, toppingID, apply)
    if not IsValid(ply) then return end
    local t = zfs.config.Toppings[toppingID]
    if not t then return end
    local amount = t.ToppingBenefits and t.ToppingBenefits["SpeedBoost"]
    if not amount or amount == 0 then return end

    if ply:GetNWBool("zfs_SpeedBoost", false) then
        safeNotify(ply, "CantAdd_Speedboost")
        return
    end

    ply:SetNWBool("zfs_SpeedBoost", true)
    ply.zfs_oldWalk = ply:GetWalkSpeed() or 200
    ply.zfs_oldRun = (ply.GetRunSpeed and ply:GetRunSpeed()) or ply.zfs_oldWalk
    ply:SetWalkSpeed((ply.zfs_oldWalk or 200) + amount)
    if ply.SetRunSpeed then ply:SetRunSpeed((ply.zfs_oldRun or 200) + amount) end

    local dur = t.ToppingBenefit_Duration or 30
    timer.Simple(dur, function()
        if not IsValid(ply) then return end
        ply:SetWalkSpeed(ply.zfs_oldWalk or 200)
        if ply.SetRunSpeed then ply:SetRunSpeed(ply.zfs_oldRun or ply.zfs_oldWalk or 200) end
        ply:SetNWBool("zfs_SpeedBoost", false)
    end)
end

function zfs.Benefits.AntiGravity(ply, toppingID, apply)
    if not IsValid(ply) then return end
    local t = zfs.config.Toppings[toppingID]
    if not t then return end
    local amount = t.ToppingBenefits and t.ToppingBenefits["AntiGravity"]
    if not amount or amount == 0 then return end

    if ply:GetNWBool("zfs_AntiGravity", false) then
        safeNotify(ply, "CantAdd_AntiGravity")
        return
    end

    ply:SetNWBool("zfs_AntiGravity", true)
    ply.zfs_oldJump = ply:GetJumpPower() or 200
    ply:SetJumpPower(amount)

    local dur = t.ToppingBenefit_Duration or 30
    timer.Simple(dur, function()
        if not IsValid(ply) then return end
        ply:SetJumpPower(ply.zfs_oldJump or 200)
        ply:SetNWBool("zfs_AntiGravity", false)
    end)
end

function zfs.Benefits.Ghost(ply, toppingID, apply)
    if not IsValid(ply) then return end
    local t = zfs.config.Toppings[toppingID]
    if not t then return end
    local alpha = t.ToppingBenefits and t.ToppingBenefits["Ghost"]
    if not alpha then return end

    if ply:GetNWBool("zfs_Ghost", false) then
        safeNotify(ply, "CantAdd_Ghost")
        return
    end

    ply:SetNWBool("zfs_Ghost", true)
    local oldcol = ply:GetColor()
    ply.zfs_oldColor = oldcol
    ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    ply:SetColor(Color(oldcol.r, oldcol.g, oldcol.b, alpha))

    local dur = t.ToppingBenefit_Duration or 30
    timer.Simple(dur, function()
        if not IsValid(ply) then return end
        if ply.zfs_oldColor then ply:SetColor(ply.zfs_oldColor) end
        ply:SetNWBool("zfs_Ghost", false)
    end)
end

function zfs.Benefits.Drugs(ply, toppingID, apply)
    if not IsValid(ply) then return end
    local t = zfs.config.Toppings[toppingID]
    if not t then return end
    local drug = t.ToppingBenefits and t.ToppingBenefits["Drugs"]
    if not drug then return end

    if ply:GetNWBool("zfs_Drugs", false) then
        safeNotify(ply, "CantAdd_Drugs")
        return
    end

    ply:SetNWBool("zfs_Drugs", true)
    local dur = t.ToppingBenefit_Duration or 30
    net.Start("zfs_screeneffect")
    local info = { parent = ply, screeneffect = drug, duration = dur }
    net.WriteTable(info)
    net.Send(ply)

    timer.Simple(dur, function()
        if not IsValid(ply) then return end
        ply:SetNWBool("zfs_Drugs", false)
    end)
end
