timer.Simple(.1, function()
    for k,v in pairs(CAMI.GetPrivileges and CAMI.GetPrivileges() or {}) do
        sAdmin.registerPermission(v.Name or k, "CAMI", false, true)
    end
end)

hook.Add("CAMI.OnPrivilegeRegistered", "sA:RegisterPrivlege", function(priv)
    sAdmin.registerPermission(istable(priv) and priv.Name or priv, "CAMI", false, true)
end)

hook.Add("CAMI.PlayerHasAccess", "sA:HasAccess", function(ply, privname, cb)
    local result = sAdmin.hasPermission(ply, privname)
    
    if cb then
        cb(result)
    end

    return result, "N/A"
end)