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
	local r = 1
	self.PhysObjRadius = r
	self:PhysicsInitSphere(r, "default")
	self:SetCollisionBounds(Vector(-r, -r, -r), Vector(r, r, r))
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:DrawShadow(false)
	self.PhysgunDisabled = true
	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass(1)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:Wake()
	else
		self:Remove()

		return
	end

	self:StartMotionController()
	self:SetCustomCollisionCheck(true)

	-- This gets set by other system to tell it where to fly
	-- but if it doesent then we just fly up
	if self.FlyDir == nil then
		self.FlyDir = self:GetAngles():Up()
	end

	self.HitPlayer = false
	SafeRemoveEntityDelayed(self, 0.5)
end

function ENT:GravGunPickupAllowed(ply)
	return false
end

local maxForce = 2 ^ 32

function ENT:PhysicsSimulate(phys, dt)
	if self.zbl_Collided then return end

	if not self.zbl_Increase then
		self.zbl_Increase = 1
	end

	self.zbl_Increase = math.Approach(self.zbl_Increase, maxForce, dt * maxForce * 0.01)
	local force = Vector(0, 0, 0)
	local angForce = Vector(0, 0, 0)
	force = force + self.FlyDir * self.zbl_Increase
	force = force * dt
	angForce = angForce * dt

	return angForce, force, SIM_GLOBAL_ACCELERATION
end

function ENT:PhysicsCollide(data, physobj)
	local ent = data.HitEntity

	if IsValid(data.HitObject) and IsValid(ent) and ent:IsPlayer() and ent:Alive() then
		self.HitPlayer = true
		-- Give the player some damage
		local d = DamageInfo()
		d:SetDamage(5)
		d:SetAttacker(self)
		d:SetDamageType(DMG_ACID)
		ent:TakeDamageInfo(d)
	end

	if not self.zbl_Collided then
		local velPlus = data.OurOldVelocity and data.OurOldVelocity:GetNormal() * 60 or Vector(0, 0, 0)
		-- Disable all physics to be save
		self:StopMotionController()
		self:PhysicsDestroy()

		timer.Simple(FrameTime(), function()
			if not self:IsValid() then return end
			local pos = data.HitPos - data.HitNormal * self.PhysObjRadius
			self:SetPos(pos + velPlus)
		end)

		local deltime = FrameTime() * 2

		if not game.SinglePlayer() then
			deltime = FrameTime() * 6
		end

		SafeRemoveEntityDelayed(self, deltime)

		if IsValid(self.Owner) then
			zbl.f.Infect_Proximity(self.Owner:GetNWInt("zbl_Vaccine", -1), self.Owner:GetNWInt("zbl_VaccineStage", 1), self:GetPos(), 200, 75)
		end

		self.zbl_Collided = true
	end
end
