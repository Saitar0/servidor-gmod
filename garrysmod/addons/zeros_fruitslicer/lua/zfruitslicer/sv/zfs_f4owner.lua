if not SERVER then return end

local entTable = {
    ["zfs_fruit"] = true,
    ["zfs_fruitcup_base"] = true,
    ["zfs_shop"] = true
}

hook.Add("playerBoughtCustomEntity", "zfruitslicer_SetOwnerOnEntBuy", function(ply, enttbl, ent, price)
    --Check table of entities
    if entTable[ent:GetClass()] then
        zfs.f.SetOwnerID(ent, ply)
    end
end)
