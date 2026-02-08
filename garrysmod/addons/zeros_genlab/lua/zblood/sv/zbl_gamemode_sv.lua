if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

local entTable = {
    ["zbl_lab"] = true,
    ["zbl_gasmask"] = true,
}

hook.Add("playerBoughtCustomEntity", "zbl_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    if entTable[ent:GetClass()] then
        zbl.f.SetOwner(ent, ply)
    end
end)

hook.Add("BaseWars_PlayerBuyEntity", "zbl_basewars_SetOwnerOnEntBuy", function(ply, ent)
    if entTable[ent:GetClass()] then
        zbl.f.SetOwner(ent, ply)
    end
end)
