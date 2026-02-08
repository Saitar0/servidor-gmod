zbl = zbl or {}
zbl.f = zbl.f or {}

player_manager.AddValidModel("Hazmat", "models/zerochain/props_bloodlab/zbl_hazmat.mdl")
player_manager.AddValidHands("Hazmat", "models/zerochain/props_bloodlab/zbl_hazmat_arms.mdl", 0, "00000000")


function zbl.f.Player_GetID(ply)
    if ply:IsBot() then
        return ply:UserID()
    else
        return ply:SteamID()
    end
end

function zbl.f.Player_GetName(ply)
    if ply:IsBot() then
        return "Bot_" .. ply:UserID()
    else
        return ply:Nick()
    end
end

// Tells us if the player is male based on model or gives us a random result
function zbl.f.Player_IsMale(ply)
    local ply_model = ply:GetModel()
    if zbl.SoundByModel[ply_model] then
        if zbl.SoundByModel[ply_model] == "female" then
            return false
        else
            return true
        end
    else
        if zbl.f.RandomChance(50) then
            return true
        else
            return false
        end
    end
end

function zbl.f.Player_PlaySound_Ouch(ply)
    if not IsValid(ply) then return end

    if zbl.f.Player_IsMale(ply) then
        ply:EmitSound("zbl_ouch_male")
    else
        ply:EmitSound("zbl_ouch_female")
    end
end

function zbl.f.Player_PlaySound_Cough(ply)
    if not IsValid(ply) then return end

    if zbl.f.Player_IsMale(ply) then
        ply:EmitSound("zbl_cough_male")
    else
        ply:EmitSound("zbl_cough_female")
    end
end

function zbl.f.Player_PlaySound_Vomit(ply)
    if not IsValid(ply) then return end

    if zbl.f.Player_IsMale(ply) then
        ply:EmitSound("zbl_vomit_male")
    else
        ply:EmitSound("zbl_vomit_female")
    end
end

// Returns the position of the players head if found
function zbl.f.Player_GetHeadPos(ply)
    local pos = ply:GetPos() + ply:GetUp() * 25

    local attachID = ply:LookupAttachment("eyes")
    if attachID then
        local attach = ply:GetAttachment(attachID)

        if attach then
            pos =  attach.Pos
        end
    end
    return pos
end
