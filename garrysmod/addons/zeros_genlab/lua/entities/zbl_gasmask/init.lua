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
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

end


function ENT:AcceptInput(input, activator, caller, data)
	if string.lower(input) == "use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then

		if zbl.f.Player_GetProtectionChance(activator, nil, nil) >= 100 then
			zbl.f.Notify(activator, zbl.language.Gun["FullProtectionCheck"], 3)
			return
		end

		if activator:GetNWInt("zbl_RespiratorUses",0) >= zbl.config.Respirator.Uses then return end

		zbl.f.GasMask_Equipt(activator,true)
		SafeRemoveEntity(self)
	end
end
