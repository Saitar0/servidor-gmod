AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
    local SpawnPos = tr.HitPos + tr.HitNormal * 15
    local ent = ents.Create(self.ClassName)
    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()
    zbl.f.SetOwner(ent, ply)

    return ent
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    else
        self:Remove()

        return
    end

    self:DrawShadow(false)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:SetTrigger(true)
    self:SetCustomCollisionCheck(true)

    self:SetVHealth(zbl.config.VirusHotspots.node_health_default)
    self.NextTouch = CurTime()
    self.Virus_ID = 1
    self.Virus_Stage = 1
end

function ENT:StartTouch(other)
    if IsValid(other) and other:IsPlayer() and other:Alive() and self.Virus_ID and self.Virus_Stage and self.NextTouch < CurTime() then
        self.NextTouch = CurTime() + 2
        zbl.f.VN_ExplodeNode(self,zbl.config.VirusNodes.KillOnTouch)
    end
end

function ENT:OnRemove()
    zbl.f.VN_OnRemove(self)
end

function ENT:OnTakeDamage(dmginfo)
    if zbl.config.VirusHotspots.node_damage == false then return end

    if (not self.m_bApplyingDamage) then
        self.m_bApplyingDamage = true
        self:TakeDamageInfo(dmginfo)
        zbl.f.VN_ChangeHealth(self, math.Clamp(self:GetVHealth() - dmginfo:GetDamage(), 0, zbl.config.VirusHotspots.node_health_max))
        self.m_bApplyingDamage = false
    end
end
