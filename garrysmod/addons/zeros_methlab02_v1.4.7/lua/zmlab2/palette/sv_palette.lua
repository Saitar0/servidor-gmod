/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Palette = zmlab2.Palette or {}

function zmlab2.Palette.Initialize(Palette)
    zclib.EntityTracker.Add(Palette)

    Palette:SetMaxHealth( zmlab2.config.Damageable[Palette:GetClass()] )
    Palette:SetHealth(Palette:GetMaxHealth())

    Palette.MethList = {}

    Palette.LastMethChange = CurTime()
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function zmlab2.Palette.OnRemove(Palette)
    zclib.EntityTracker.Remove(Palette)
end

function zmlab2.Palette.OnUse(Palette, ply)
    if zmlab2.Player.CanInteract(ply, Palette) == false then return end
    if Palette.LastMethChange and CurTime() < (Palette.LastMethChange + 0.5) then return end

    local valid_data,valid_key
    for k,v in pairs(Palette.MethList) do
        if v and k then
            valid_data = v
            valid_key = k
        end
    end
    table.remove(Palette.MethList,valid_key)

    if valid_data and valid_data.t and valid_data.a and valid_data.q then
        local ent = ents.Create("zmlab2_item_crate")
        if not IsValid(ent) then return end
        ent:SetPos(Palette:LocalToWorld(Vector(50,0,50)))
        ent:SetAngles(angle_zero)
        ent:Spawn()
        ent:Activate()
        ent:SetMethType(valid_data.t)
        ent:SetMethAmount(valid_data.a)
        ent:SetMethQuality(valid_data.q)
        zclib.Player.SetOwner(ent, ply)

        zmlab2.Palette.Update(Palette)

        Palette:EmitSound("zmlab2_crate_place")
    end
    Palette.LastMethChange = CurTime()
end

function zmlab2.Palette.OnStartTouch(Palette,other)
    if not IsValid(Palette) then return end
    if not IsValid(other) then return end
    if Palette.LastMethChange and CurTime() < (Palette.LastMethChange + 0.25) then return end
    if zclib.util.CollisionCooldown(other) then return end
    if table.Count(Palette.MethList) >= zmlab2.config.Palette.Limit then return end

    if other:GetClass() ~= "zmlab2_item_crate" then return end
    if other:GetMethAmount() <= 0 then return end
    if other:GetNoDraw() then return end

    zmlab2.Palette.AddMeth(Palette,other,other:GetMethType(),other:GetMethAmount(),other:GetMethQuality())
    Palette.LastMethChange = CurTime()
    Palette:EmitSound("zmlab2_crate_place")
end

util.AddNetworkString("zmlab2_Palette_Update")
function zmlab2.Palette.Update(Palette)
    local e_String = util.TableToJSON(Palette.MethList)
    local e_Compressed = util.Compress(e_String)
    net.Start("zmlab2_Palette_Update")
    net.WriteEntity(Palette)
    net.WriteUInt(#e_Compressed,16)
    net.WriteData(e_Compressed,#e_Compressed)
    net.Broadcast()
end

function zmlab2.Palette.AddMeth(Palette,Crate,MethType,MethAmount,MethQuality)
    zclib.Debug("zmlab2.Palette.AddMeth")

    // Stop moving if you have physics
    
    local phys = Crate:GetPhysicsObject()
    if IsValid(phys) then phys:EnableMotion(false) end

    -- if Crate.PhysicsDestroy then Crate:PhysicsDestroy() end

    // Hide entity
    if IsValid(Crate) then Crate:Remove() end

    // This got taken from a Physcollide function but maybe its needed to prevent a crash
    //local deltime = FrameTime() * 2
    //if not game.SinglePlayer() then deltime = FrameTime() * 6 end
    //SafeRemoveEntityDelayed(Crate, deltime)

	timer.Simple(0.1, function()
        table.insert(Palette.MethList, {
            t = MethType,
            a = MethAmount,
            q = MethQuality,
        })
        zmlab2.Palette.Update(Palette)
	end)
end


concommand.Add("zmlab2_debug_Palette_Test", function(ply, cmd, args)
    if zclib.Player.IsAdmin(ply) then
        local tr = ply:GetEyeTrace()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

        if tr.Hit then
            local ent = ents.Create("zmlab2_item_palette")
            if not IsValid(ent) then return end
            ent:SetPos(tr.HitPos)
            ent:Spawn()
            ent:Activate()

            timer.Simple(1,function()
                ent.MethList = {}
                for i = 1, 32 do
                    table.insert(ent.MethList, {
                        t = 2,
                        a = zmlab2.config.Crate.Capacity,
                        q = 100
                    })
                end
                ent.LastMethChange = CurTime()
                zclib.Player.SetOwner(ent, ply)
                zmlab2.Palette.Update(ent)
            end)
        end
    end
end)

