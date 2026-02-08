if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

////////////////////////////////////////////
//////////////// Virusnode  ////////////////
////////////////////////////////////////////
zbl.VirusNodes = zbl.VirusNodes or {}

// Performs a sphere trace with a random end point on a halfsphere
function zbl.f.VN_PerformSpawnTrace(pos,ang,length)
    local tr_ang = Angle(ang.p,ang.y,ang.r)

    // Rotation fix so the ang looks up
    tr_ang:RotateAroundAxis(ang:Right(),-180)

    // Random rotate to the right/left
    tr_ang:RotateAroundAxis(ang:Right(),math.random(-80,80))

    // Random rotate to Forward/backward
    tr_ang:RotateAroundAxis(ang:Forward(),math.random(-80,80))

    local tr_start = pos /*+ (ang:Up() * up)*/
    local tr_end = pos + (tr_ang:Up() * length)

    local tr = util.TraceLine( {
        start = tr_start,
        endpos = tr_end,
        mask = 81931, // Hit only the world + brushes please
    } )

    if tr.Hit and tr.HitWorld and tr.HitSky == false and tr.StartSolid == false and tr.HitPos and util.IsInWorld( tr.HitPos ) and zbl.f.VH_AreaFree(tr.HitPos) and zbl.f.AIZ_NearZone(tr.HitPos) == false then
        //debugoverlay.Sphere(tr.HitPos, 3, 1, Color(0, 255, 0), false)
        debugoverlay.Line(tr_start, tr.HitPos, 5, Color(0, 255, 0), false)
    else
        debugoverlay.Line(tr_start, tr_end, 5, Color( 255, 0, 0 ),false )
        tr = false
    end

    return tr
end

// Checks if there are any nodes near the specified position
function zbl.f.VH_AreaFree(pos)
    local free = true

    local dist = 75 + (15 * zbl.config.VirusNodes.max_scale)

    for k, v in pairs(zbl.VirusNodes) do
        if IsValid(v) and zbl.f.InDistance(pos, v:GetPos(), dist) then
            free = false
            break
        end
    end

    return free
end

// Removes the node , creates a spore effect and infects player arround it
function zbl.f.VN_ExplodeNode(node,destroy)
    if not IsValid(node) then return end
    zbl.f.Debug("zbl.f.VN_ExplodeNode")

    zbl.f.CreateNetEffect("node_explode",node:GetPos())

    local dist = 50 * zbl.config.VirusNodes.max_scale

    zbl.f.Infect_Proximity(node.Virus_ID,node.Virus_Stage, node:GetPos(), dist,90)

    zbl.f.Ctmn_ProximityContaminate(node:GetPos(), dist, node.Virus_ID)

    if destroy then
        // Destroy Virus
        local deltime = FrameTime() * 2
        if not game.SinglePlayer() then deltime = FrameTime() * 6 end
        SafeRemoveEntityDelayed(node,deltime)
    end
end

// Creates a virus node
function zbl.f.VN_CreateNode(pos, ang, virus_id, virus_stage)
    zbl.f.Debug("zbl.f.VN_CreateNode")

    local ent = ents.Create("zbl_virusnode")
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:Activate()

    ent:SetNWInt("zbl_Vaccine", virus_id)

    ent.Virus_ID = virus_id
    ent.Virus_Stage = 1

    local vac_data = zbl.config.Vaccines[virus_id]

    // Change material according to virus id
    if vac_data and vac_data.mat then
        ent:SetMaterial(vac_data.mat)
    end
    ent:SetVHealth(zbl.config.VirusHotspots.node_health_default)

    table.insert(zbl.VirusNodes,ent)

    zbl.f.Debug("Virus node created " .. tostring(ent))
    return ent
end

// Creates a virus node on a random space arround the provided pos
function zbl.f.VN_CreateNodeRandom(pos, ang, virus_id, virus_stage)
    local tr = zbl.f.VN_PerformSpawnTrace(pos,ang,400)
    if tr == false then return end

    if zbl.f.AIZ_NearZone(tr.HitPos) then return end

    local node_pos =  tr.HitPos
    local node_ang = tr.HitNormal:Angle()
    node_ang:RotateAroundAxis(node_ang:Right(),-90)

    local node = zbl.f.VN_CreateNode(node_pos, node_ang, virus_id, virus_stage)

    // This tells the created virus node to remove itself after certain amount of time
    SafeRemoveEntityDelayed(node,zbl.config.VirusNodes.life_time)
end

function zbl.f.VN_OnRemove(node)
    table.RemoveByValue(zbl.VirusNodes,node)
    zbl.f.VHS_RemoveNode(node)
end

function zbl.f.VN_TakeDamage(node,amount)
    if not IsValid(node) then return end
    zbl.f.VN_ChangeHealth(node,math.Clamp(node:GetVHealth() - amount,0,zbl.config.VirusHotspots.node_health_max))
end

function zbl.f.VN_Heal(node,amount)
    if not IsValid(node) then return end
    zbl.f.VN_ChangeHealth(node,math.Clamp(node:GetVHealth() + amount,0,zbl.config.VirusHotspots.node_health_max))
end

// Changes the Health of a Virus Node
function zbl.f.VN_ChangeHealth(node,new_health)
    //zbl.f.Debug("zbl.f.VN_ChangeHealth")

    local old_Health = node:GetVHealth()

    if new_health > old_Health then
        debugoverlay.Sphere(node:GetPos(), 50, 1, Color(0, 255, 255), true)
    elseif new_health < old_Health then
        debugoverlay.Sphere(node:GetPos(), 50, 1, Color(255, 0, 255), true)
    end

    node:SetVHealth(new_health)

    if new_health <= 0 then


        // Destroy Virus
        local deltime = FrameTime() * 2
        if not game.SinglePlayer() then deltime = FrameTime() * 6 end
        SafeRemoveEntityDelayed(node,deltime)

    elseif new_health >= zbl.config.VirusHotspots.node_health_spread then
        node:SetBodygroup(0,1)
    else
        node:SetBodygroup(0,0)
    end
end
////////////////////////////////////////////
////////////////////////////////////////////
