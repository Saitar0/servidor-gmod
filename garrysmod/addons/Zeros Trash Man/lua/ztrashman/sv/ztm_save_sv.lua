if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

hook.Add("PlayerSay", "ztm_PlayerSay_Save", function(ply, text)
    if string.sub(string.lower(text), 1, 8) == "!saveztm" then
        if ztm.f.IsAdmin(ply) then
            ztm.f.PublicEnt_SaveAll(ply)
            ztm.f.Notify(ply, "Trash entities´s have been saved for the map " .. game.GetMap() .. "!", 0)
        else
            ztm.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
        end
    end
end)

concommand.Add( "ztm_save_all", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.PublicEnt_SaveAll(ply)
    end
end )

concommand.Add( "ztm_remove_all", function( ply, cmd, args )

    if IsValid(ply) and ztm.f.IsAdmin(ply) then
        ztm.f.PublicEnt_RemoveAll(ply)
    end
end )

function ztm.f.PublicEnt_RemoveAll(ply)
    ztm.f.Leafpile_Remove()
    ztm.f.Manhole_Remove()
    ztm.f.Recycler_Remove()
    ztm.f.Trashburner_Remove()
    ztm.f.Trash_Remove()
    ztm.f.Buyermachine_Remove()

    ztm.f.Notify(ply, "All Trash entities have been removed for the map " .. game.GetMap() .. "!", 0)
end

function ztm.f.PublicEnt_SaveAll(ply)
    ztm.f.Leafpile_Save()
    ztm.f.Manhole_Save()
    ztm.f.Recycler_Save()
    ztm.f.Trashburner_Save()
    ztm.f.Trash_Save()
    ztm.f.Buyermachine_Save()

    ztm.f.Notify(ply, "All Trash entities have been saved for the map " .. game.GetMap() .. "!", 0)
end

function ztm.f.PublicEnt_Load()
    ztm.f.Leafpile_Load()
    ztm.f.Manhole_Load()
    ztm.f.Recycler_Load()
    ztm.f.Trashburner_Load()
    ztm.f.Trash_Load()
    ztm.f.Buyermachine_Load()
end


hook.Add("InitPostEntity", "ztm_SpawnPublicEnts", ztm.f.PublicEnt_Load)
hook.Add("PostCleanupMap", "ztm_SpawnPublicEntsPostCleanUp", ztm.f.PublicEnt_Load)
