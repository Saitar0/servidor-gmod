/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.PumpSystem = zmlab2.PumpSystem or {}

// Returns the Pump Duration
function zmlab2.PumpSystem.GetTime(From,To)
    return 4
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

// Returns if the From entity can give its liquid to the To Entity
function zmlab2.PumpSystem.AllowConnection(From_ent,To_ent)
    //zclib.Debug("zmlab2.PumpSystem.AllowConnection")

    if To_ent.AllowConnection then
        return To_ent:AllowConnection(From_ent)
    else
        return false
    end
end

