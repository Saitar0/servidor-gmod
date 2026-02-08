if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}




// Creates a short screeneffect to visualize the cough for the player
util.AddNetworkString("zbl_scfx_cough")
function zbl.f.ScreenEffect_Cough(ply)
    net.Start("zbl_scfx_cough")
    net.Send(ply)
end

// Creates a short screeneffect to visualize the vomit for the player
util.AddNetworkString("zbl_scfx_vomit")
function zbl.f.ScreenEffect_Vomit(ply)
    net.Start("zbl_scfx_vomit")
    net.Send(ply)
end

// Creates a short screeneffect to visualize the vomit for the player
util.AddNetworkString("zbl_scfx_headache")
function zbl.f.ScreenEffect_Headache(ply)
    net.Start("zbl_scfx_headache")
    net.Send(ply)
end

// Scales the players bone
util.AddNetworkString("zbl_scalebone")
function zbl.f.BoneScale(ply,boneid,scale,speed)
    net.Start("zbl_scalebone")
    net.WriteEntity(ply)
    net.WriteInt(scale * 10, 16)
    net.WriteInt(boneid,16)
    net.WriteInt(speed,16)
    net.Broadcast()
end

zbl.Symptomes = zbl.Symptomes or {}

zbl.Symptomes["coughing"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        local timerid = "zbl_coughing_" .. zbl.f.Player_GetID(ply)
        zbl.f.Timer_Remove(timerid)

        zbl.f.Timer_Create(timerid,data.interval,0,function()

            if IsValid(ply) and zbl.f.RandomChance(75) then

                // Screen Effect
                zbl.f.ScreenEffect_Cough(ply)

                // Cough
                zbl.f.Player_PlaySound_Cough(ply)

                if data.damage and data.damage > 0 then
                    // Damage Player
                    local d = DamageInfo()
                	d:SetDamage( data.damage )
                	d:SetAttacker( ply )
                	d:SetDamageType( DMG_POISON )
                	ply:TakeDamageInfo( d )
                end

                local vac_id = ply:GetNWInt("zbl_Vaccine",-1)
                local vac_stage = ply:GetNWInt("zbl_VaccineStage",1)

                // If the player himself has some protection then we reduce the infection impact on other player too
                local chance , immun = zbl.f.Player_ProtectionTest(ply, vac_id, vac_stage)
                chance = (1 / 100) * chance
                chance = math.Clamp(1 - chance,0,1)

                if chance > 0 then
                    //Create Effect
                    local effect_pos = zbl.f.Player_GetHeadPos(ply)
                    zbl.f.CreateNetEffect("infect_cough",effect_pos)
                end

                // Infect new Players in proximity
                zbl.f.Infect_Proximity(vac_id,vac_stage, ply:GetPos(),  data.infect_distance,data.infect_chance * chance)
            end
        end)
    end,

    OnEnd = function(ply)

        local timerid = "zbl_coughing_" .. zbl.f.Player_GetID(ply)
        zbl.f.Timer_Remove(timerid)
    end,
}

zbl.Symptomes["projectile_vomit"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        local timerid = "zbl_projectile_vomit_" .. zbl.f.Player_GetID(ply)
        zbl.f.Timer_Remove(timerid)

        zbl.f.Timer_Create(timerid,data.interval,0,function()

            if IsValid(ply) and zbl.f.RandomChance(50) then

                // Screeneffect
                zbl.f.ScreenEffect_Vomit(ply)

                // Vomit sound
                zbl.f.Player_PlaySound_Vomit(ply)

                local vac_id = ply:GetNWInt("zbl_Vaccine",-1)
                local vac_stage = ply:GetNWInt("zbl_VaccineStage",1)

                // If the player himself has some protection then we reduce the infection impact on other player too
                local chance , immun = zbl.f.Player_ProtectionTest(ply, vac_id, vac_stage)
                chance = (1 / 100) * chance
                chance = math.Clamp(1 - chance,0,1)

                if chance > 0 then
                    //Create Vomit Projectile
                    local vomit_pos = zbl.f.Player_GetHeadPos(ply) + (ply:EyeAngles():Forward() * 15)
                    zbl.f.Infect_VomitProjectile(ply,vomit_pos,ply:EyeAngles():Forward())
                end

                if data.damage and data.damage > 0 then
                    // Damage Player
                    local d = DamageInfo()
                	d:SetDamage( data.damage )
                	d:SetAttacker( ply )
                	d:SetDamageType( DMG_POISON )
                	ply:TakeDamageInfo( d )
                end
            end
        end)
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local timerid = "zbl_projectile_vomit_" .. zbl.f.Player_GetID(ply)
        zbl.f.Timer_Remove(timerid)
    end,
}

zbl.Symptomes["explosive_diarrhea"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        local timerid = "zbl_explosive_diarrhea_" .. zbl.f.Player_GetID(ply)
        zbl.f.Timer_Remove(timerid)

        zbl.f.Timer_Create(timerid,data.interval,0,function()

            if IsValid(ply) and zbl.f.RandomChance(50) then

                if data.damage and data.damage > 0 then
                    // Damage Player
                    local d = DamageInfo()
                	d:SetDamage( data.damage )
                	d:SetAttacker( ply )
                	d:SetDamageType( DMG_POISON )
                	ply:TakeDamageInfo( d )
                end


                local vac_id = ply:GetNWInt("zbl_Vaccine",-1)
                local vac_stage = ply:GetNWInt("zbl_VaccineStage",1)

                // If the player himself has some protection then we reduce the infection impact on other player too
                local chance , immun = zbl.f.Player_ProtectionTest(ply, vac_id, vac_stage)
                chance = (1 / 100) * chance
                chance = math.Clamp(1 - chance,0,1)

                if chance > 0 then
                    //Create Diaraia Spot
                    zbl.f.Infect_DiariaSpot(ply)

                    // Create Diaria effect and decals
                    zbl.f.CreateNetEffect("infect_diaria",ply)
                end

                // Infect new Players in proximity
                zbl.f.Infect_Proximity(vac_id,vac_stage, ply:GetPos(),  200,50 * chance)
            end
        end)
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local timerid = "zbl_explosive_diarrhea_" .. zbl.f.Player_GetID(ply)
        zbl.f.Timer_Remove(timerid)
    end,
}

zbl.Symptomes["head_swelling"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        zbl.f.Player_PlaySound_Ouch(ply)

        // Create net msg to increase player head on client
        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        zbl.f.BoneScale(ply,bone,data.scale,1)

        if data.damage and data.damage > 0 then
            // Damage Player
            local d = DamageInfo()
            d:SetDamage( data.damage )
            d:SetAttacker( ply )
            d:SetDamageType( DMG_GENERIC )
            ply:TakeDamageInfo( d )
        end
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        zbl.f.BoneScale(ply,bone,1,1)
    end,
}

zbl.Symptomes["legs_swelling"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        zbl.f.Player_PlaySound_Ouch(ply)

        local bone01 = ply:LookupBone("ValveBiped.Bip01_R_Thigh")
        zbl.f.BoneScale(ply,bone01,data.scale,1)

        local bone02 = ply:LookupBone("ValveBiped.Bip01_L_Thigh")
        zbl.f.BoneScale(ply,bone02,data.scale,1)


        local bone03 = ply:LookupBone("ValveBiped.Bip01_R_Foot")
        zbl.f.BoneScale(ply,bone03,data.scale,1)

        local bone04 = ply:LookupBone("ValveBiped.Bip01_L_Foot")
        zbl.f.BoneScale(ply,bone04,data.scale,1)


        local bone05 = ply:LookupBone("ValveBiped.Bip01_R_Calf")
        zbl.f.BoneScale(ply,bone05,data.scale,1)

        local bone06 = ply:LookupBone("ValveBiped.Bip01_L_Calf")
        zbl.f.BoneScale(ply,bone06,data.scale,1)


        if data.damage and data.damage > 0 then
            // Damage Player
            local d = DamageInfo()
            d:SetDamage( data.damage )
            d:SetAttacker( ply )
            d:SetDamageType( DMG_GENERIC )
            ply:TakeDamageInfo( d )
        end
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end

        local bone01 = ply:LookupBone("ValveBiped.Bip01_R_Thigh")
        zbl.f.BoneScale(ply,bone01,1,1)

        local bone02 = ply:LookupBone("ValveBiped.Bip01_L_Thigh")
        zbl.f.BoneScale(ply,bone02,1,1)

        local bone03 = ply:LookupBone("ValveBiped.Bip01_R_Foot")
        zbl.f.BoneScale(ply,bone03,1,1)

        local bone04 = ply:LookupBone("ValveBiped.Bip01_L_Foot")
        zbl.f.BoneScale(ply,bone04,1,1)

        local bone05 = ply:LookupBone("ValveBiped.Bip01_R_Calf")
        zbl.f.BoneScale(ply,bone05,1,1)

        local bone06 = ply:LookupBone("ValveBiped.Bip01_L_Calf")
        zbl.f.BoneScale(ply,bone06,1,1)

    end,
}

zbl.Symptomes["explosive_head"] = {

    OnStart = function(ply,data)
        if not IsValid(ply) then return end

        zbl.f.Player_PlaySound_Ouch(ply)

        //Create Effect
        local effect_pos = zbl.f.Player_GetHeadPos(ply)
        zbl.f.CreateNetEffect("explode_head",effect_pos)

        local vac_id = ply:GetNWInt("zbl_Vaccine",-1)
        local vac_stage = ply:GetNWInt("zbl_VaccineStage",1)

        // If the player himself has some protection then we reduce the infection impact on other player too
        local chance , immun = zbl.f.Player_ProtectionTest(ply, vac_id, vac_stage)
        chance = (1 / 100) * chance
        chance = math.Clamp(1 - chance,0,1)


        // Infect new Players in proximity
        zbl.f.Infect_Proximity(vac_id,1, ply:GetPos(), data.infect_distance,data.infect_chance * chance)

        ply:Kill()
    end,

    OnEnd = function(ply)

        if not IsValid(ply) then return end
    end,
}

// Creates the Symptomes of the Vaccine
function zbl.f.Symptome_OnStart(ply,vaccineID,vaccineStage)
    zbl.f.Debug("zbl.f.Symptomes_OnStart")

    local vaccineData = zbl.config.Vaccines[vaccineID]

    if vaccineData == nil then return end

    local mutation_stage = vaccineData.mutation_stages[vaccineStage]

    if mutation_stage == nil then return end

    // Create Symptomes
    if mutation_stage.symptomes and table.Count(mutation_stage.symptomes) > 0 then

        for k,v in pairs(mutation_stage.symptomes) do

            if zbl.Symptomes[k] then
                zbl.f.Debug("zbl.Symptomes[" .. k .. "] Start")

                // Calls the spread symptome
                zbl.Symptomes[k].OnStart(ply,mutation_stage.symptomes[k])
            end
        end
    end

    // Modify Jump Modifier
    if mutation_stage.effects and mutation_stage.effects["jump_modify"] then
        ply:SetJumpPower(mutation_stage.effects["jump_modify"])
    end
end

// Removes the Symptomes of the Vaccine
function zbl.f.Symptome_OnEnd(ply)
    zbl.f.Debug("zbl.f.Symptomes_OnEnd")

    if not IsValid(ply) then return end

    local vaccineID = ply:GetNWInt("zbl_Vaccine", -1)
    local vaccineData = zbl.config.Vaccines[vaccineID]

    if vaccineData == nil then return end

    local vaccineStage = ply:GetNWInt("zbl_VaccineStage", 1)
    local mutation_stage = vaccineData.mutation_stages[vaccineStage]

    if mutation_stage == nil then return end


    if mutation_stage.symptomes and table.Count(mutation_stage.symptomes) > 0 then

        for k,v in pairs(mutation_stage.symptomes) do

            if zbl.Symptomes[k] then

                zbl.f.Debug("zbl.Symptomes[" .. k .. "] End")

                // Stops the symthome
                zbl.Symptomes[k].OnEnd(ply)
            end
        end
    end

    // Reset Jump Power
    if mutation_stage.effects and mutation_stage.effects["jump_modify"] then
        ply:SetJumpPower(200)
    end
end




hook.Add("EntityTakeDamage", "zbl_DamageModifier", function(target, dmginfo)
    if IsValid(target) and target:IsPlayer() and target:Alive() then
        local vaccineID = target:GetNWInt("zbl_Vaccine", -1)
        local vaccineData = zbl.config.Vaccines[vaccineID]

        if vaccineID ~= -1 and vaccineData then
            local vaccineStage = target:GetNWInt("zbl_VaccineStage", -1)
            local mutation_stage = vaccineData.mutation_stages[vaccineStage]

            if mutation_stage and mutation_stage.effects then

                if mutation_stage.effects["damage_modify"] then
                    dmginfo:ScaleDamage(mutation_stage.effects["damage_modify"])
                elseif mutation_stage.effects["damage_fire_modify"] and dmginfo:GetDamageType() == DMG_BURN then
                    dmginfo:ScaleDamage(mutation_stage.effects["damage_fire_modify"])
                elseif mutation_stage.effects["damage_fall_modify"] and dmginfo:GetDamageType() == DMG_FALL then
                    dmginfo:ScaleDamage(mutation_stage.effects["damage_fall_modify"])
                elseif mutation_stage.effects["damage_bullet_modify"] and dmginfo:GetDamageType() == DMG_BULLET then
                    dmginfo:ScaleDamage(mutation_stage.effects["damage_bullet_modify"])
                end
            end
        end
    end
end)

hook.Add( "Move", "zbl_MoveModifier", function( ply, mv, usrcmd )
    if ply:GetNWInt("zbl_Vaccine", -1) ~= -1 then
        local vaccineData = zbl.config.Vaccines[ply:GetNWInt("zbl_Vaccine", -1)]

        if vaccineData then
            local vaccineStage = ply:GetNWInt("zbl_VaccineStage", -1)
            local mutation_stage = vaccineData.mutation_stages[vaccineStage]

            if mutation_stage and mutation_stage.effects and mutation_stage.effects["movement_speed"] then
                local speed = mv:GetMaxSpeed() * mutation_stage.effects["movement_speed"]
                mv:SetMaxSpeed( speed )
                mv:SetMaxClientSpeed( speed )
            end
        end
    end
end )
