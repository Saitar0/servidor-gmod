if CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

function zcm.f.TransportBox_Use(ply, box)
    if box:GetIsOpen() == false and box:OnSellButton(ply) then
        if zcm.config.SellBox.DirectSell then
            zcm.f.Sell_CrackerPack(ply,nil, box)
        else
            zcm.f.TransportBox_PickUp(ply, box)
        end
    end
end

function zcm.f.TransportBox_PickUp(ply, box)
    local fireworkCount = box:GetFireworkCount()
    ply:SetNWInt("zcm_firework", ply:GetNWInt("zcm_firework", 0) + fireworkCount)
    box:Remove()
    zcm.f.Notify(ply, "+" .. fireworkCount .. " " .. zcm.language.General["Firework"], 0)
end
