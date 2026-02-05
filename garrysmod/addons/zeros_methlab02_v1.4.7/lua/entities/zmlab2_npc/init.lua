/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create(self.ClassName)
	if not IsValid(ent) then return end
	ent:SetPos(tr.HitPos + tr.HitNormal * 1)
	local angle = ply:GetAimVector():Angle()
	angle = Angle(0, angle.yaw, 0)
	angle:RotateAroundAxis(angle:Up(), 180)
	ent:SetAngles(angle)
	ent:Spawn()
	ent:Activate()
	return ent
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:Initialize()
	zmlab2.NPC.Initialize(self)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function ENT:AcceptInput(inputName, activator, caller, data)
	if inputName == "Use" and IsValid(activator) and activator:IsPlayer() and activator:Alive() then
		zmlab2.NPC.OnUse(self, activator)
	end
end

function ENT:OnTakeDamage(dmg)
	return 0
end

