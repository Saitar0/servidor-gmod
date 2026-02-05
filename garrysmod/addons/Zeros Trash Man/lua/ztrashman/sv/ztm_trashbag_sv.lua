if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

function ztm.f.Trashbag_Initialize(Trashbag)
    ztm.f.EntList_Add(Trashbag)
end

function ztm.f.Trashbag_Touch(Trashbag, other)
    if not IsValid(Trashbag) then return end
    if Trashbag:GetTrash() >= ztm.config.Trashbags.capacity then return end
    if not IsValid(other) then return end
    if other:GetClass() ~= "ztm_trash" then return end
    if ztm.f.CollisionCooldown(other) then return end
    if other:GetTrash() <= 0 then return end

    ztm.f.Trashbag_AddTrash(Trashbag, other)
end

function ztm.f.Trashbag_AddTrash(Trashbag, trash)

    Trashbag:SetTrash(Trashbag:GetTrash() + trash:GetTrash())
    SafeRemoveEntity(trash)
end
