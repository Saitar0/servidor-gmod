if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}

// Tells us if we can drop another flask
function zbl.f.Flask_DropLimitReached(ply)
    if ply.zbl_FlaskList == nil then
        ply.zbl_FlaskList = {}
    end

    local capacity = zbl.config.InjectorGun.flask_capacity[zbl.f.GetPlayerRank(ply)]
    if capacity == nil then
        capacity = zbl.config.InjectorGun.flask_capacity["default"]
    end

    if #ply.zbl_FlaskList >= capacity then

        local str = string.Replace(zbl.language.Gun["FlaskDropLimit"],"$FlaskCount",capacity)
        zbl.f.Notify(ply, str, 1)

        return true
    else
        return false
    end
end

// Adds a flask to the players internal list to keep track
function zbl.f.Flask_Add(ply,flask)
    if ply.zbl_FlaskList == nil then
        ply.zbl_FlaskList = {}
    end

    table.insert(ply.zbl_FlaskList,flask)
end

function zbl.f.Flask_Remove(flask)
    if IsValid(flask.FlaskOwner) and flask.FlaskOwner.zbl_FlaskList then
        // Remove yourself from the flasklist of the owner so he can spawn more flask again
        table.RemoveByValue(flask.FlaskOwner.zbl_FlaskList,flask)
    end
end

function zbl.f.Flask_Spawn(_owner,_pos,_gentype,_genval,_genname,_genpoints,_genclass)
    local ent = ents.Create("zbl_flask")
    ent:SetPos(_pos)
    ent:Spawn()
    ent:Activate()

    ent:SetGenType(_gentype)
    ent:SetGenValue(_genval)
    ent:SetGenName(_genname)
    ent:SetGenPoints(_genpoints)
    ent:SetGenClass(_genclass)

    if IsValid(_owner) then
        zbl.f.SetOwner(ent, _owner)

        ent.FlaskOwner = _owner
    end

    return ent
end


function zbl.f.Flask_Initialize(flask)
    zbl.f.EntList_Add(flask)
    flask.zbl_Collided = false

    timer.Simple(0,function()
        if IsValid(flask) then
            zbl.f.Flask_UpdateVisuals(flask)
        end
    end)
end

function zbl.f.Flask_UpdateVisuals(flask)
    local _gentype = flask:GetGenType()
    local _genval = flask:GetGenValue()
    local _genclass = flask:GetGenClass()

    if _gentype ~= 0 then
        flask:SetBodygroup(0,1)
    end

    if _gentype == 1 then
        // Check if sample is from player and color the liquid red
        if _genclass and _genclass == "player" then
            flask:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_bloodsample")
        end
    elseif _gentype == 2 then
        local vaccine_data = zbl.config.Vaccines[_genval]

        if vaccine_data.isvirus == true then
            flask:SetSubMaterial(0, vaccine_data.mat)
        else
            flask:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_abillity_diff")
        end
    elseif _gentype == 3 then
        flask:SetSubMaterial(0, "zerochain/props_bloodlab/flask/zbl_flask_liquid_cure_diff")
    end
end

function zbl.f.Flask_OnPhysicsCollide(flask,data)
    if zbl.config.Flask.Breakable == false then return end
    if IsValid(data.HitEntity) and data.HitEntity:GetClass() == "zbl_lab" then return end

    if (data.Speed > zbl.config.Flask.Break_speed) then
        zbl.f.Flask_Explode(flask)
    end
end

function zbl.f.Flask_OnDamage(flask,dmginfo)
    if zbl.config.Flask.Breakable == false then return end
    if dmginfo:GetDamage() >= 5 then
        zbl.f.Flask_Explode(flask)
    end
end

function zbl.f.Flask_Explode(flask)
    zbl.f.Debug("zbl.f.Flask_Explode")

    if flask.zbl_Collided == true then return end

    local gen_type = flask:GetGenType()
    local gen_val = flask:GetGenValue()

    local pos = flask:GetPos()
    local ang = flask:GetAngles()
    if gen_type == 1 then

        // Check if sample is from player or not
        if flask:GetGenClass() == "player" then
            zbl.f.CreateNetEffect("jar_break_blood", pos)
        else
            zbl.f.CreateNetEffect("jar_break_sample", pos)
        end
    elseif gen_type == 2 then
        local vac_data = zbl.config.Vaccines[gen_val]

        if vac_data.isvirus then

            if zbl.config.Flask.InfectOnDestruction then
                zbl.f.Infect_Proximity(gen_val, 1, pos, zbl.config.Flask.Infect_Radius, 75)
            end

            // Creates a virus node somewhere near it
            if zbl.config.Flask.NodeOnDestruction then
                timer.Simple(0,function()
                    if pos and ang and gen_val then
                        zbl.f.VN_CreateNodeRandom(pos, Angle(0,0,0), gen_val, 1)
                    end
                end)
            end

            zbl.f.CreateNetEffect("jar_break_virus", pos)
        else

            if zbl.config.Flask.InfectOnDestruction then
                zbl.f.Infect_Proximity(gen_val, 1, pos, zbl.config.Flask.Infect_Radius, 99)
            end
            zbl.f.CreateNetEffect("jar_break_abillity", pos)
        end
    elseif gen_type == 3 then

        if zbl.config.Flask.InfectOnDestruction then
            zbl.f.Player_CureProximity(gen_val, pos, zbl.config.Flask.Infect_Radius)
        end

        zbl.f.CreateNetEffect("jar_break_cure", pos)

        // Kill any virus nodes in proximity of flask explosion which have the same vaccine id
        // This wont create any infection cloud on death
        for k,v in pairs(zbl.VirusNodes) do
            if IsValid(v) and v.Virus_ID == gen_val and zbl.f.InDistance(v:GetPos(), pos, zbl.config.Flask.Infect_Radius) then
                zbl.f.VN_ChangeHealth(v,0)
            end
        end
    end

    local deltime = FrameTime() * 2
    if not game.SinglePlayer() then deltime = FrameTime() * 6 end
    SafeRemoveEntityDelayed(flask,deltime)

    flask.zbl_Collided = true
end

function zbl.f.Flask_OnRemove(flask)
    zbl.f.Flask_Remove(flask)
end

// This makes sure that flask cant collide with each other
hook.Add("ShouldCollide", "zbl_flask_ShouldCollide", function(ent1, ent2)
    if IsValid(ent1) and IsValid(ent2) and ent1:GetClass() == "zbl_flask" and ent2:GetClass() == "zbl_flask" then return false end
end)
