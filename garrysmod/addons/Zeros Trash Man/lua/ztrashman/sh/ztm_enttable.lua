ztm = ztm or {}
ztm.f = ztm.f or {}


-- List of all the ztm Entities on the server
if ztm.EntList == nil then
	ztm.EntList = {}
end

function ztm.f.EntList_Add(ent)
	table.insert(ztm.EntList, ent)
end

if SERVER then


	concommand.Add("ztm_debug_EntList", function(ply, cmd, args)
		if IsValid(ply) and ztm.f.IsAdmin(ply) then
			PrintTable(ztm.EntList)
		end
	end)
end
