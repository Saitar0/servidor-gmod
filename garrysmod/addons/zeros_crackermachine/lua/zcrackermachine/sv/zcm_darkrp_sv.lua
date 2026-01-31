if not SERVER then return end

local entTable = {
    ["zcm_box"] = true,
    ["zcm_blackpowder"] = true,
    ["zcm_paperroll"] = true,
    ["zcm_crackermachine"] = true,
}

hook.Add("playerBoughtCustomEntity", "zcm_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    if entTable[ent:GetClass()] then
        zcm.f.SetOwner(ent, ply)
    end
end)
