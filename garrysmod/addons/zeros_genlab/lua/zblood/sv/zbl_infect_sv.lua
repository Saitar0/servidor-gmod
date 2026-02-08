if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

// Infects all player in proximity
function zbl.f.Infect_Proximity(vac_id,vac_stage, pos, dist, chance)
    if vac_id == -1 then return end
    zbl.f.Debug("zbl.f.Infect_Proximity")
    for k, v in pairs(zbl_PlayerList) do
        if IsValid(v) and v:Alive() and zbl.f.InDistance(pos, v:GetPos(), dist) and zbl.f.RandomChance(chance) then
            zbl.f.Player_Infect(v, vac_id, vac_stage)
        end
    end
end

// Creates a vomit projectile
function zbl.f.Infect_VomitProjectile(ply,pos,dir)
    local ent = ents.Create("zbl_projectile_vomit")
    ent:SetPos(pos)
    ent.Owner = ply
    ent.FlyDir = dir

    ent:Spawn()
    ent:Activate()
end

// Create a diaria spot
function zbl.f.Infect_DiariaSpot(ply)

    local ent = ents.Create("zbl_diaria_spot")
    ent:SetPos(ply:GetPos())
    ent.VaccineID = ply:GetNWInt( "zbl_Vaccine", 1 )
    ent.VaccineStage = ply:GetNWInt( "zbl_VaccineStage", 1 )
    ent:Spawn()
    ent:Activate()
end
