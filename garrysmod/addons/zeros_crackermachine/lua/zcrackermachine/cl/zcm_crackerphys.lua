if SERVER then return end
zcm = zcm or {}
zcm.f = zcm.f or {}
local zcm_CRACKEROBJECTS = {}

local sound_Explode = {"zcm/zcm_explode01.wav", "zcm/zcm_explode02.wav"}

function zcm.f.CrackerPackExplode(ent)

    local entPos = ent:GetPos()
    local entAng = ent:GetAngles()
    local delay = 0

    if zcm.config.FireCracker.CrackerCount > 0 then
        for i = 1, zcm.config.FireCracker.CrackerCount do
            timer.Simple(delay, function()
                if zcm.f.InDistance(LocalPlayer():GetPos(), entPos, GetConVar("zcm_cl_vfx_updatedistance"):GetFloat() or 2000) then
                    EmitSound(sound_Explode[math.random(#sound_Explode)], entPos, ent:EntIndex(), CHAN_STATIC, GetConVar("zcm_cl_sfx_volume"):GetFloat() or 1, SNDLVL_75dB, 0, 100)
                    ParticleEffect("crackerpack_explosion", entPos, entAng, NULL)
                    if zcm.f.ParticleOverFlow_Check() then
                        zcm.f.CrackerPhysicsHandler_CreateCracker(entPos, entAng, i)
                    end
                end
            end)

            delay = delay + 0.05
        end

        timer.Simple((0.05 * zcm.config.FireCracker.CrackerCount) + 0.05, function()
            if IsValid(ent) then
                ent:SetNoDraw(true)
            end
        end)
    else
        ent:SetNoDraw(true)
        EmitSound(sound_Explode[math.random(#sound_Explode)], entPos, ent:EntIndex(), CHAN_STATIC, GetConVar("zcm_cl_sfx_volume"):GetFloat() or 1, SNDLVL_75dB, 0, 100)
        ParticleEffect("crackerpack_explosion", entPos, entAng, NULL)
    end

    ParticleEffect("zcm_crackermain", entPos, entAng, NULL)
end

function zcm.f.CrackerPhysicsHandler_CreateCracker(pos, ang, numId)
    local ent = ents.CreateClientProp()
    ent:SetModel("models/zerochain/props_crackermaker/zcm_cracker.mdl")
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetSolid(SOLID_NONE)
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetRenderMode(RENDERMODE_NORMAL)
    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then

        local rnd_ang = Angle(math.Rand(0, 360), math.Rand(0, 360), math.Rand(0, 360))
        phys:SetMass(25)
        phys:Wake()
        phys:EnableMotion(true)

        local tickrate = 66.6 * engine.TickInterval()
        tickrate = tickrate * 64
        tickrate = math.Clamp(tickrate, 15, 64)

        local f_force = tickrate * 4
        local f_look = ang
        f_look:RotateAroundAxis(ang:Up(), (360 / zcm.config.FireCracker.CrackerCount) * numId)

        local f_dir = ang:Up() * f_force + f_look:Right() * f_force / 3

        phys:ApplyForceCenter(phys:GetMass() * f_dir)

        local val = 2
        local angVel = (rnd_ang:Up() * math.Rand(-val, val)) * phys:GetMass() * tickrate
        phys:AddAngleVelocity(angVel)
    end

    ParticleEffectAttach("zcm_crackerfuse", PATTACH_POINT_FOLLOW, ent, 1)

    table.insert(zcm_CRACKEROBJECTS, {
        cracker = ent,
        explodetime = CurTime() + math.Rand(0.5,1.1),
        exploded = false
    })
end


local sound_crackerExplode = {"zcm/zcm_cracker01.wav", "zcm/zcm_cracker02.wav", "zcm/zcm_cracker03.wav", "zcm/zcm_cracker04.wav", "zcm/zcm_cracker05.wav"}

function zcm.f.CrackerPhysicsHandler()
    if table.Count(zcm_CRACKEROBJECTS) > 0 then
        local ply = LocalPlayer()

        for k, v in pairs(zcm_CRACKEROBJECTS) do
            if IsValid(v.cracker) then
                if not zcm.f.InDistance(ply:GetPos(), v.cracker:GetPos(), 	GetConVar("zcm_cl_vfx_updatedistance"):GetFloat() or 2000 ) or v.exploded then
                    if IsValid(v.cracker) then
                        v.cracker:StopSound("zcm_fuse")
                        v.cracker:Remove()
                    end

                    table.remove(zcm_CRACKEROBJECTS, k)
                elseif (CurTime() >= v.explodetime and v.exploded == false) then
                    ParticleEffect("cracker_explosion01", v.cracker:GetPos(), v.cracker:GetAngles(), NULL)
                    EmitSound(sound_crackerExplode[math.random(#sound_crackerExplode)], v.cracker:GetPos(), v.cracker:EntIndex(), CHAN_STATIC, GetConVar("zcm_cl_sfx_volume"):GetFloat() or 1, SNDLVL_75dB, 0, 100)
                    v.exploded = true
                end
            end
        end
    end
end

hook.Add("Think", "zcm_think_CrackerPhysicsHandler", zcm.f.CrackerPhysicsHandler)
