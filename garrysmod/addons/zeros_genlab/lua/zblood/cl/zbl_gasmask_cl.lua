if SERVER then return end
zbl = zbl or {}
zbl.f = zbl.f or {}


local _localplayer = LocalPlayer()


net.Receive("zbl_Gasmask_Equipt", function()
    local ply = net.ReadEntity()
    local show = net.ReadBool()
    local maskID = net.ReadInt(6)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    zbl.f.Debug("zbl_Gasmask_Equipt: " .. tostring(ply) .. " " .. tostring(show))
    zbl.f.GasMask_Equipt(ply, show,maskID)
end)

function zbl.f.GasMask_Equipt(ply, show,maskID)
    if show then
        local cs = ents.CreateClientProp()

        if IsValid(cs) then

            local maskData = zbl.config.Respirator.styles[maskID]

            cs.zbl_OwnerID = zbl.f.GetOwnerID(ply)
            cs.zbl_Owner = ply
            cs:SetModel(maskData.model)
            cs:SetSkin(maskData.skin)
            cs:SetNoDraw(true)
            cs:SetPredictable(false)
            cs:DrawShadow(false)
            cs:DestroyShadow()
            cs:SetMoveType(MOVETYPE_NONE)
            cs:Spawn()
            ply.zbl_GasMask_model = cs
            zbl.f.Debug("ClientModel created")

            ply:EmitSound("zbl_mask_on")
        end
    else
        if IsValid(ply.zbl_GasMask_model) then

            // Spawn Client GasMask model falling of player
            zbl.f.GasMask_PhysicsHandler_Create(ply:GetPos() + Vector(0,0,60))

            SafeRemoveEntity(ply.zbl_GasMask_model)
            zbl.f.Debug("ClientModel removed")

            ply:EmitSound("zbl_mask_off")
        end
    end
end

function zbl.f.GasMask_Draw(ply)
    if not IsValid(ply.zbl_GasMask_model) then return end
    local pos, ang

    local boneid = ply:LookupBone("ValveBiped.Bip01_Head1")
    local offset = zbl.ModelOffsets[ply:GetModel()]

    if boneid then
        local mat = ply:GetBoneMatrix(boneid)
        if not mat then return end
        pos, ang = mat:GetTranslation(), mat:GetAngles()
        local start_ang = ang
        ang:RotateAroundAxis(start_ang:Forward(), -90)
        ang:RotateAroundAxis(start_ang:Right(), -90)

        if offset == nil then
            offset = zbl.ModelOffsets["Default"]
        end

        ang:RotateAroundAxis(start_ang:Up(), offset.ang.y)
        ang:RotateAroundAxis(start_ang:Right(), offset.ang.p)
        ang:RotateAroundAxis(start_ang:Forward(), offset.ang.r)
        pos:Set(pos + ang:Forward() * offset.pos.x + ang:Right() * offset.pos.y + ang:Up() * offset.pos.z)
    else
        pos = ply:GetPos()
        ang = Angle(0, 0, 0)
    end


    ply.zbl_GasMask_model:SetPos(pos)
    ply.zbl_GasMask_model:SetAngles(ang)
    ply.zbl_GasMask_model:SetRenderOrigin(pos)
    ply.zbl_GasMask_model:SetRenderAngles(ang)
    ply.zbl_GasMask_model:SetupBones()
    ply.zbl_GasMask_model:DrawModel()
end

hook.Add("PostPlayerDraw", "zbl_GasMask_PostPlayerDraw", function(ply)
    if not IsValid(_localplayer) then
        _localplayer = LocalPlayer()
    else
        if IsValid(ply) and ply:Alive() and zbl.f.InDistance(_localplayer:GetPos(), ply:GetPos(), 1000) then
            zbl.f.GasMask_Draw(ply)
        end
    end
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "zbl_GasMask_player_disconnect", function(data)
    for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and v.zbl_OwnerID and v.zbl_OwnerID == data.networkid then
            SafeRemoveEntity(v)
        end
    end
end)



local zbl_GasmaskObjects = {}
function zbl.f.GasMask_PhysicsHandler_Create(pos)
    zbl.f.Debug("zbl.f.GasMask_PhysicsHandler_Create " .. tostring(pos))

    local ent = ents.CreateClientProp()
    ent:SetModel("models/zerochain/props_bloodlab/zbl_n95mask_worn.mdl")
    ent:SetPos(pos)
    ent:SetAngles(Angle(0, 0, 0))
    ent:Spawn()
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetSolid(SOLID_NONE)
    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetRenderMode(RENDERMODE_NORMAL)

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetMass(25)
        phys:Wake()
        phys:EnableMotion(true)
        phys:SetDragCoefficient(100)

        local tickrate = 66.6 * engine.TickInterval()
        tickrate = tickrate * 64
        tickrate = math.Clamp(tickrate, 15, 64)


        local f_force = tickrate * 2
        local f_dir = Vector(math.Rand(-1,1), math.Rand(-1,1), 1) * f_force
        phys:ApplyForceCenter(phys:GetMass() * f_dir)

        local val = 0.9
        local angVel = (Vector(0, 0, 1) * math.Rand(-val, val)) * phys:GetMass() * tickrate
        phys:AddAngleVelocity(angVel)
    else
        SafeRemoveEntity(ent)
    end

    table.insert(zbl_GasmaskObjects, {
        ent = ent,
        remove_time = CurTime() + 5,
    })
end

function zbl.f.GasMask_PhysicsHandler()
    if #zbl_GasmaskObjects > 0 then

        local ply = LocalPlayer()
        local distance = 1000

        for k, v in pairs(zbl_GasmaskObjects) do
            if IsValid(v.ent) and not zbl.f.InDistance(ply:GetPos(), v.ent:GetPos(), distance) or CurTime() >= v.remove_time then
                SafeRemoveEntity(v.ent)
                table.remove(zbl_GasmaskObjects, k)
            end
        end
    end
end
hook.Add("Think", "zbl_think_GasMask_PhysicsHandler_cl", zbl.f.GasMask_PhysicsHandler)


local wMod = ScrW() / 1920
local hMod = ScrH() / 1080

local function DrawHUD()
    local pos_x = (1920 / 100) * GetConVar("zbl_cl_mask_pos_x"):GetInt()
    local pos_y = (1080 / 100) * GetConVar("zbl_cl_mask_pos_y"):GetInt()

    local scale = GetConVar("zbl_cl_mask_scale"):GetFloat()

    local width,height = 150 * scale, 150 * scale

    pos_x = pos_x - (width / 2)
    pos_y = pos_y - (height / 2)

    draw.RoundedBox(100 * scale, pos_x * wMod, pos_y * hMod, width * wMod, height * hMod, zbl.default_colors["black02"])

    surface.SetDrawColor(zbl.default_colors["white04"])
    surface.SetMaterial(zbl.default_materials["zbl_mask_off"])
    surface.DrawTexturedRect(pos_x * wMod, pos_y * hMod, width * wMod, height * hMod)

    surface.SetDrawColor(zbl.default_colors["cure_green"])
    surface.SetMaterial(zbl.default_materials["zbl_mask_on"])
    surface.DrawTexturedRect(pos_x * wMod, pos_y * hMod, width * wMod, height * hMod)

    draw.SimpleText(math.Round((100 / zbl.config.Respirator.Uses) * LocalPlayer():GetNWInt("zbl_RespiratorUses", 0)) .. "%", "zbl_gasmaskhud_font01", (pos_x + (width / 2)) * wMod, (pos_y + (height / 1.6)) * hMod, zbl.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "zbl_Gasmask_HUDPaint", function()
    if GetConVar("zbl_cl_mask_enabled"):GetInt() == 1 and IsValid(LocalPlayer().zbl_GasMask_model) then
        DrawHUD()
    end
end)
