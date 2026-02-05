if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}
ztm.trashbags = ztm.trashbags or {}

function ztm.f.SWEP_TrashCollector_Primary(swep)

    ztm.f.Effect_Exception( swep,swep.Owner)

    swep.Owner:EmitSound("ztm_airburst")

    local tr = swep.Owner:GetEyeTrace()

    if tr.Hit and ztm.f.InDistance(tr.HitPos, swep.Owner:GetPos(), 200) and IsValid(tr.Entity) then
        if tr.Entity:GetClass() == "ztm_leafpile"  then
            ztm.f.Leafpile_Explode(tr.Entity,swep.Owner)
        else
            if ztm.config.TrashSWEP.allow_physmanipulation == false then return end

            local phys = tr.Entity:GetPhysicsObject()


            if IsValid(phys) and phys:IsMoveable() and phys:GetMass() < 100 then

                local dir = tr.Entity:GetPos() - swep.Owner:GetPos()
                phys:ApplyForceCenter( (phys:GetMass() * (3 * swep.Owner.ztm_data.lvl)) * dir )
            end

        end
    end
end

function ztm.f.SWEP_TrashCollector_Secondary(swep)
    if swep:GetTrash() >= ztm.config.TrashSWEP.level[swep:GetPlayerLevel()].inv_cap then return end

    local tr = swep.Owner:GetEyeTrace()
    if tr.Hit and ztm.f.InDistance(tr.HitPos, swep.Owner:GetPos(), 200) then

        for k, v in pairs(ents.FindInSphere(tr.HitPos,25)) do
            if IsValid(v) then

                if v:GetClass() == "ztm_trash" and v:GetTrash() > 0  then

                    // Custom Hook
                    hook.Run("ztm_OnTrashCollect" ,swep.Owner, v:GetTrash())

                    ztm.f.SWEP_TrashCollector_XP(swep.Owner,v:GetTrash())
                    swep:SetTrash(swep:GetTrash() + v:GetTrash())
                    SafeRemoveEntity( v )
                    break
                elseif v:IsPlayer() == false and v:GetNWInt("ztm_trash",nil) and v:GetNWInt("ztm_trash",0) > 0  then

                    // Custom Hook
                    hook.Run("ztm_OnTrashCollect" ,swep.Owner, 1)

                    ztm.f.SWEP_TrashCollector_XP(swep.Owner,1)

                    swep:SetTrash(swep:GetTrash() + 1)
                    v:SetNWInt("ztm_trash", math.Clamp(v:GetNWInt("ztm_trash",0) - 1,0,9999))
                    break
                elseif v:GetClass() == "ztm_manhole" and v:GetTrash() > 0 and v:GetIsClosed() == false  then

                    // Custom Hook
                    hook.Run("ztm_OnTrashCollect" ,swep.Owner, 1)

                    ztm.f.SWEP_TrashCollector_XP(swep.Owner,1)

                    swep:SetTrash(swep:GetTrash() + 1)

                    v:SetTrash(v:GetTrash() - 1)

                    break
                elseif v:IsPlayer() and v:Alive() and v ~= swep.Owner and v:GetNWInt("ztm_trash",nil) ~= nil and v:GetNWInt("ztm_trash",0) > 0  then

                    // Custom Hook
                    hook.Run("ztm_OnTrashCollect" ,swep.Owner, 1)

                    ztm.f.SWEP_TrashCollector_XP(swep.Owner,1)

                    swep:SetTrash(swep:GetTrash() + 1)

                    v:SetNWInt("ztm_trash",math.Clamp(v:GetNWInt("ztm_trash",0) - 1,0,ztm.config.PlayerTrash.Limit))
                    break
                elseif v:GetClass() == "ztm_trashbag"  then

                    swep:SetTrash(swep:GetTrash() + 1)
                    v:SetTrash(v:GetTrash() - 1)

                    if v:GetTrash() <= 0 then
                        // Remove trashbag
                        SafeRemoveEntity( v )
                        ztm.f.Debug("Trashbag removed!")
                    end

                    break
                end
            end
    	end
    end
end

function ztm.f.SWEP_TrashCollector_XP(ply, trash)

    if ply.ztm_data.lvl >= table.Count(ztm.config.TrashSWEP.level) then return end

    local xp = trash * ztm.config.TrashSWEP.xp_per_kg
    xp = ztm.config.TrashSWEP.xp_modify(ply, xp)
    ztm.data.AddXP(ply, xp)
end



// Drop Trashbag
function ztm.f.SWEP_TrashCollector_DropTrashbag(ply,key)
    if key == MOUSE_MIDDLE and IsValid(ply) and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "ztm_trashcollector" then

        local swep = ply:GetActiveWeapon()
        local _trash = swep:GetTrash()

        if _trash > 0 then

            local tr = ply:GetEyeTrace()

            if tr.Hit and tr.HitSky == false and ztm.f.InDistance(ply:GetPos(), tr.HitPos, 500) then

                if IsValid(tr.Entity) and tr.Entity:GetClass() == "ztm_trashbag" and tr.Entity:GetTrash() < ztm.config.Trashbags.capacity then

                    local trashbag_trash = tr.Entity:GetTrash()

                    local _freespace = ztm.config.Trashbags.capacity - trashbag_trash

                    _trash = math.Clamp(_trash,0,_freespace)

                    tr.Entity:SetTrash(tr.Entity:GetTrash() + _trash)
                    swep:SetTrash(swep:GetTrash() - _trash)

                else
                    if ztm.f.Trashbag_GetCountByPlayer(ply) >= ztm.config.Trashbags.limit then
                        ztm.f.Notify(ply, ztm.language.General["TrashbagLimit"], 1)
                        return
                    end

                    if _trash > ztm.config.Trashbags.capacity then

                        ztm.f.Trashbag_Create(tr.HitPos + Vector(0,0,20),ztm.config.Trashbags.capacity,ply)
                        swep:SetTrash(_trash - ztm.config.Trashbags.capacity)
                    else

                        ztm.f.Trashbag_Create(tr.HitPos + Vector(0,0,20),_trash,ply)
                        swep:SetTrash(0)
                    end
                end

            end
        end
    end
end

hook.Add("PlayerButtonDown", "ztm_PlayerButtonDown_DropTrash", function(ply, key)
    ztm.f.SWEP_TrashCollector_DropTrashbag(ply,key)
end)

function ztm.f.Trashbag_GetCountByPlayer(ply)
    local count = 0

    for k, v in pairs(ztm.trashbags) do
        if IsValid(v) and ztm.f.IsOwner(ply, v) then
            count = count + 1
        end
    end

    return count
end

function ztm.f.Trashbag_Create(pos,trash,ply)
    local ent = ents.Create("ztm_trashbag")
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetTrash(trash)
    ztm.f.SetOwner(ent, ply)
    table.insert(ztm.trashbags ,ent)
end

hook.Add("canDropWeapon", "ztm_canDropWeapon", function(ply,swep)
    if IsValid(swep) and swep:GetClass() == "ztm_trashcollector" then
        return false
    end
end)
