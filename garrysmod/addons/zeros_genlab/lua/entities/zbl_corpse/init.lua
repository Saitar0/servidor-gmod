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

    self:SetModel( self.Model )
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
    self:UseClientSideAnimation()
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

    self.PhysgunDisabled = true
end

function ENT:OnRemove()
    zbl.f.Corpse_OnRemove(self)
end
