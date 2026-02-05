AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 90)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	zcm.f.SetOwner(ent, ply)
	return ent
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end
end

function ENT:ExplodeBlackpowder()
	self:SetDestroyed(true)
	self.PhysgunDisabled = true
	self:SetNoDraw(true)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(false)
	end

	if zcm.config.BlackPowder.Damage > 0 then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 300)) do
			if IsValid(v) and v:IsPlayer() and v:Alive() then
				v:SetHealth(v:Health() - zcm.config.BlackPowder.Damage)
			end
		end
	end

	timer.Simple(0.3, function()
		if IsValid(self) then
			self:Remove()
		end
	end)
end

-- Damage Stuff
function ENT:OnTakeDamage(dmg)
	if self:GetDestroyed() then return end
	self:TakePhysicsDamage(dmg)
	local damage = dmg:GetDamage()
	local entHealth = 5

	if (entHealth > 0) then
		self.CurrentHealth = (self.CurrentHealth or entHealth) - damage

		if (self.CurrentHealth <= 0) then
			self:ExplodeBlackpowder()
		end
	end
end
