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
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	self:SetBodygroup(0,1)
	self:SetBodygroup(1,1)
end

function ENT:AcceptInput(key, ply)
	if ((self.lastUsed or CurTime()) <= CurTime()) and (key == "Use" and IsValid(ply) and ply:IsPlayer() and ply:Alive()) then
		self.lastUsed = CurTime() + 0.25
		if self:GetIgnited() then return end

		self:IgniteFirework()
	end
end

function ENT:IgniteFirework()

	// Ignite firework
	self:SetIgnited(true)

	self.PhysgunDisabled = true

	timer.Simple(1.9,function()
		if IsValid(self) then

			local phys = self:GetPhysicsObject()

			if (phys:IsValid()) then
				phys:Wake()
				phys:EnableMotion(false)
			end

		end
	end)

	timer.Simple(3,function()
		if IsValid(self) then

			self:Remove()
		end
	end)
end

// Damage Stuff
function ENT:OnTakeDamage(dmg)
	if self:GetIgnited() then return end

	self:TakePhysicsDamage(dmg)
	local damage = dmg:GetDamage()
	local entHealth = 5

	if (entHealth > 0) then
		self.CurrentHealth = (self.CurrentHealth or entHealth) - damage

		if (self.CurrentHealth <= 0) then
			self:IgniteFirework()
		end
	end
end
