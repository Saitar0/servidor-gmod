ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Model = "models/zerochain/props_crackermaker/zcm_fireworkpack.mdl"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.PrintName = "FireCracker Pack"
ENT.Category = "Zeros Crackermachine"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Ignited")

    if (SERVER) then
        self:SetIgnited(false)
    end
end

function ENT:OnIgniteButton(ply)
    local trace = ply:GetEyeTrace()
    //debugoverlay.Sphere(self:LocalToWorld(Vector(-3, 0, 6)), 1, 0.1, Color( 255, 255, 255 ), true )
    local lp = self:WorldToLocal(trace.HitPos)

    if lp.y > -7.4 and lp.y < 7.4 and lp.x < 4.7 and lp.x > -0.15 then
        return true
    else
        return false
    end
end
