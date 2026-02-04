AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Effects
util.AddNetworkString("zfs_fruit_FX")

function ENT:CreateEffect_Table(effect, sound, parent, angle, position)
	net.Start("zfs_fruit_FX")
	local effectInfo = {}
	effectInfo.effect = effect
	effectInfo.sound = sound
	effectInfo.pos = position
	effectInfo.ang = angle
	effectInfo.parent = parent
	net.WriteTable(effectInfo)
	net.SendPVS(self:GetPos())
end

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create(self.ClassName)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Right(), -90)
	ent:SetAngles(angle)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()

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
		phys:EnableMotion(false)
	end

	-- State Stuff
	self.currentState = "UNPEELED"

	self.fStates = {
		["PEELED"] = function()
			self:state_PEELED()
		end,
		["SLICED"] = function()
			self:state_SLICED()
		end
	}

	self.fHealth = self.PrepareAmount
	self.WorkStation = nil
end

function ENT:Interact(caller)
	if (IsValid(caller) and caller:IsPlayer() and caller:Alive() and zfs.f.IsOwner(caller, self) and zfs.f.IsOwner(caller, self.WorkStation)) then
		self:PrepareFruit()
	end
end

function ENT:PrepareFruit()
	if (self.fHealth > 0) then
		self.fHealth = self.fHealth - 1
		self:UpdateVisuals()
		self:CheckState()
		self:Interact_VFX_SFX()
	else
		self.WorkStation:action_FillMixer(self)
		self:Finish_VFX_SFX()
	end
end

function ENT:Finish_VFX_SFX()
end

function ENT:Interact_VFX_SFX()
end

-- States
function ENT:CheckState()
	if (self.fHealth <= 0) then
		self:ChangeState("SLICED")
	elseif (self.fHealth <= self.PrepareAmount * 0.7) then
		self:ChangeState("PEELED")
	end
end

function ENT:ChangeState(state)
	if (self.currentState == state) then return end
	self.fStates[state]()
	self.currentState = state
end

function ENT:state_PEELED()
	self:SetSkin(self:SkinCount() - 1)
end

function ENT:state_SLICED()
	self:SetBodygroup(0, self:GetBodygroupCount(0))
end

--Actions
function ENT:action_PEEL()
	local SkinStep = (self.PrepareAmount * 0.3) / (self:SkinCount() - 1)
	local nextStep = math.Round(self.PrepareAmount - (SkinStep * (self:GetSkin() + 1)))

	if (self.fHealth == nextStep) then
		self:SetSkin(self:GetSkin() + 1)
	end
end

function ENT:action_SLICE()
	local BodygroupStep = (self.PrepareAmount * 0.7) / (self:GetBodygroupCount(0) - 2)
	local nextStep = self.PrepareAmount - (BodygroupStep * (self:GetBodygroup(0) + 1))
	nextStep = math.Round(nextStep)
	nextStep = math.Clamp(nextStep, 0, 100)

	if (self.fHealth <= nextStep) then
		self:SetBodygroup(0, self:GetBodygroup(0) + 1)
	end

	if (zfs.config.Debug) then
		print("Goal: " .. self:GetBodygroupCount(0) - 1)
		print("Current: " .. self:GetBodygroup(0))
	end

	-- Here we can change the Color when we reached a certain Bodygroup
	if (self.LastBodygroup_Color and self:GetBodygroup(0) >= self.ChangeColorAtBodygroup) then
		self:SetColor(Color(255, 255, 255, 255))
	end
end

function ENT:UpdateVisuals()
	if (self.fHealth < self.PrepareAmount * 0.7) then
		self:action_SLICE()
	elseif (self.fHealth > self.PrepareAmount * 0.7) then
		self:action_PEEL()
	end
end
