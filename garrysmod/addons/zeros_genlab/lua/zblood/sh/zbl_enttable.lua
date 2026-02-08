zbl = zbl or {}
zbl.f = zbl.f or {}


// List of all the zbl Entities on the server and Client
zbl.EntList = zbl.EntList or {}

function zbl.f.EntList_Add(ent)
	table.insert(zbl.EntList, ent)
end

function zbl.f.EntList_Remove(ent)
	table.RemoveByValue(zbl.EntList,ent)
end
