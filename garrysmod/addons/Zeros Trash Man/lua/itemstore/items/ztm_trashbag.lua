ITEM.Name = "Trashbag"
ITEM.Description = "A bag of trash."
ITEM.Model = "models/zerochain/props_trashman/ztm_trashbag.mdl"
ITEM.Base = "base_darkrp"
ITEM.Stackable = false
ITEM.DropStack = false

function ITEM:GetName()
	local name = "Trashbag " .. "[ " .. self:GetData("Trash") .. ztm.config.UoW .. " ]"

	return self:GetData("Name", name)
end

function ITEM:SaveData(ent)
	self:SetData("Trash", ent:GetTrash())
end

function ITEM:LoadData(ent)
	ent:SetTrash(self:GetData("Trash"))
end

/*
function ITEM:CanPickup(ply, ent)
	if ztm.f.Trashbag_GetCountByPlayer(ply) >= ztm.config.Trashbags.limit then
		ztm.f.Notify(ply, ztm.language.General["TrashbagLimit"], 1)
		return false
	else
		return true
	end
end
*/

function ITEM:Drop(ply, container,slot,ent)
	if ztm.f.Trashbag_GetCountByPlayer(ply) >= ztm.config.Trashbags.limit then
		ply:PickupItem( ent )
		ztm.f.Notify(ply, ztm.language.General["TrashbagLimit"], 1)
	else
		ztm.f.SetOwner(ent, ply)
		table.insert(ztm.trashbags ,ent)
		ent:SetPos(ent:GetPos() + Vector(0,0,20))
	end
end
