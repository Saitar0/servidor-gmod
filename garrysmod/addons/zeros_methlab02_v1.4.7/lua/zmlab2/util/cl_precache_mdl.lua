/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if SERVER then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643

timer.Simple(2,function()
    for k,v in pairs(zmlab2.config.Equipment.List) do zclib.CacheModel(v.model) end
    for k,v in pairs(zmlab2.config.Tent) do zclib.CacheModel(v.model) end
    zclib.CacheModel("models/zerochain/props_methlab/zmlab2_pipe_vent.mdl")
    zclib.CacheModel("models/zerochain/props_methlab/zmlab2_crate.mdl")
    zclib.CacheModel("models/hunter/misc/sphere025x025.mdl")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

