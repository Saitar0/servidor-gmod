if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

// Shows/Hides the gasmask for the specified player
util.AddNetworkString("zbl_Gasmask_Equipt")
function zbl.f.GasMask_Equipt(ply, show)

    local maskID = 0
    if show == true then
        //ply.zbl_GasMaskUses = zbl.config.Respirator.Uses
        ply:SetNWInt("zbl_RespiratorUses",zbl.config.Respirator.Uses)

        if zbl.config.Respirator.random_style then
            maskID = math.random(#zbl.config.Respirator.styles)
        else
            maskID = zbl.config.Respirator.style
        end
    else
        //ply.zbl_GasMaskUses = 0
        ply:SetNWInt("zbl_RespiratorUses",0)
    end

    zbl.f.Debug("zbl_Gasmask_Equipt: " .. tostring(ply) .. " " .. tostring(show) .. " MaskID: " .. maskID .. " Uses: " .. ply:GetNWInt("zbl_RespiratorUses", 0))

    net.Start("zbl_Gasmask_Equipt")
    net.WriteEntity(ply)
    net.WriteBool(show)
    net.WriteInt(maskID,6)
    net.Broadcast()
end

function zbl.f.GasMask_Use(ply)
    local rsp_use = ply:GetNWInt("zbl_RespiratorUses",0)

    rsp_use = math.Clamp(rsp_use - 1, 0, zbl.config.Respirator.Uses)
    zbl.f.Debug("GasMask_Use: " .. rsp_use)

    if rsp_use <= 0 then

        ply:SetNWInt("zbl_RespiratorUses",0)

        zbl.f.Notify(ply, zbl.language.General["RespiratorUsedUp"], 3)

        zbl.f.GasMask_Equipt(ply, false)
    else

        ply:SetNWInt("zbl_RespiratorUses",rsp_use)
    end
end
