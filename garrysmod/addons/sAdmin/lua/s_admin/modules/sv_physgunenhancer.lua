hook.Add("PhysgunPickup", "sA:AdminPhysgunLogic", function(ply, ent)
    if ent:IsPlayer() then
        return sAdmin.hasPermission(ply, "phys_players") and (tonumber(sAdmin.hasPermission(ply, "immunity")) or 0) >= (tonumber(sAdmin.hasPermission(ent, "immunity")) or 0)
    end
end)

hook.Add("OnPhysgunPickup", "sA:AdminPhysgunPickup", function(ply, ent)
    if ent:IsPlayer() and sAdmin.hasPermission(ply, "phys_players") then
        ent.adminPickedUp = true
        ent:Lock()
    end
end)

hook.Add("PhysgunDrop", "sA:AdminPhysgunDrop", function(ply, ent)
    if IsValid(ent) and ent.adminPickedUp and sAdmin.hasPermission(ply, "phys_players") then
        ent.adminPickedUp = nil
        
        if ply:KeyPressed(IN_ATTACK2) then
            if !ent.physFrozen then ent:EmitSound("player/pl_drown2.wav") end
        
            ent:Lock()
            ent.physFrozen = true

            timer.Simple(0, function() ent:SetMoveType(MOVETYPE_NONE) end)
        return end

        if ent.physFrozen then
            ent.physFrozen = nil
            ent:EmitSound("player/pl_drown1.wav")
        end

        ent.physDropped = true

        ent:UnLock()
    end
end)

hook.Add("OnPlayerHitGround", "sA:PreventDamageHitFloor", function(ent, inwater, onfloater, speed)
    if ent.physDropped then
        ent.physDropped = nil
        if inwater or speed <= 450 then return end
        ent:EmitSound("garrysmod/balloon_pop_cute.wav")
        return true
    end
end)