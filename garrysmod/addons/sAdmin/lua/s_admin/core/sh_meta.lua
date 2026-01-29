hook.Add("PostGamemodeLoaded", "sA:OverrideMeta", function()
    local meta = FindMetaTable("Player")

    meta.oldIsAdmin = meta.oldIsAdmin or meta.IsAdmin

    function meta:IsAdmin()
        local usergroup = self:GetUserGroup()
        if sAdmin.usergroups and sAdmin.usergroups["admin"] and sAdmin.usergroups[usergroup] and sAdmin.usergroups[usergroup].permissions then
            local admin_immunity, ug_immunity = sAdmin.usergroups["admin"].permissions and sAdmin.usergroups["admin"].permissions.immunity or 0, sAdmin.usergroups[usergroup].permissions and sAdmin.usergroups[usergroup].permissions.immunity or 0

            return tonumber(ug_immunity) >= tonumber(admin_immunity) or sAdmin.config["super_users"][self:SteamID64()]
        else
            return self:oldIsAdmin()
        end
    end

    meta.oldIsSuperAdmin = meta.oldIsSuperAdmin or meta.IsSuperAdmin

    function meta:IsSuperAdmin()
        local usergroup = self:GetUserGroup()
        if sAdmin.usergroups and sAdmin.usergroups["superadmin"] and sAdmin.usergroups[usergroup] and sAdmin.usergroups[usergroup].permissions then
            local sa_immunity, ug_immunity = sAdmin.usergroups["superadmin"].permissions and sAdmin.usergroups["superadmin"].permissions.immunity or 0, sAdmin.usergroups[usergroup].permissions and sAdmin.usergroups[usergroup].permissions.immunity or 0

            return tonumber(ug_immunity) >= tonumber(sa_immunity) or sAdmin.config["super_users"][self:SteamID64()]
        else
            return self:oldIsSuperAdmin()
        end
    end
end)