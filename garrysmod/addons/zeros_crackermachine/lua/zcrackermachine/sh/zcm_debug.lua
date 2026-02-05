zcm = zcm or {}
zcm.f = zcm.f or {}

if SERVER then
    concommand.Add("zcm_debug_addpaper", function(ply, cmd, args)
        if IsValid(ply) and zcm.f.IsAdmin(ply) then
            local tr = ply:GetEyeTrace()
            local trEntity = tr.Entity

            if IsValid(trEntity) and trEntity:GetClass() == "zcm_crackermachine" then
                trEntity:SetPaper(math.Clamp(trEntity:GetPaper() + 10, 0, 1000))
                print("Paper: " .. trEntity:GetPaper())
            end
        end
    end)

    concommand.Add("zcm_debug_addlevel", function(ply, cmd, args)
        if IsValid(ply) and zcm.f.IsAdmin(ply) then
            local tr = ply:GetEyeTrace()
            local trEntity = tr.Entity

            if IsValid(trEntity) and trEntity:GetClass() == "zcm_crackermachine" then
                zcm.f.Machine_LevelUp(trEntity)
            end
        end
    end)
end
