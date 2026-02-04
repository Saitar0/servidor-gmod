if (not CLIENT) then return end

hook.Add("PreDrawHalos", "zfs_AddHalos", function()
	local zfs_Halotable = {}
	local trace = LocalPlayer():GetEyeTrace()
	local traceEnt = trace.Entity

	-- Adds Sweetener Halo
	if (IsValid(traceEnt) and traceEnt:GetClass() == "zfs_sweetener_base" and traceEnt:GetNoDraw() == false) then
		table.insert(zfs_Halotable, traceEnt)
	end

	-- Adds Fruitcup Halo
	if (IsValid(traceEnt) and traceEnt:GetClass() == "zfs_fruitcup_base" and traceEnt:GetReadydoSell()) then
		table.insert(zfs_Halotable, traceEnt)
	end

	-- Adds Mixer Halo
	if (IsValid(traceEnt) and traceEnt:GetClass() == "zfs_mixer" and traceEnt:GetParent():GetCurrentState() ~= "DISABLED" and traceEnt:GetParent():GetCurrentState() ~= "MIXING") then
		table.insert(zfs_Halotable, traceEnt)
	end

	-- Adds Knife Halo for fruits
	if (not LocalPlayer():Alive()) then return false end
	if (LocalPlayer() == nil) then return false end
	if (not LocalPlayer():IsValid()) then return false end
	if (LocalPlayer():GetActiveWeapon() == nil) then return false end
	if (not LocalPlayer():GetActiveWeapon():IsValid()) then return false end
	if (LocalPlayer():GetActiveWeapon():GetClass() == nil) then return false end

	if (LocalPlayer():GetActiveWeapon():GetClass() == "zfs_knife" and LocalPlayer():GetPos():Distance(trace.HitPos) < 70) then
		for i, k in pairs(ents.FindInSphere(trace.HitPos, 7)) do
			if (IsValid(k) and zfs_ents[k:GetClass()] and k:GetBodygroup(0) < (k:GetBodygroupCount(0) - 1)) then
				table.insert(zfs_Halotable, k)
				break
			end
		end
	end

	halo.Add(zfs_Halotable, HSVToColor(math.abs(math.sin(CurTime()) * 180), 1, 1), 3, 3, 2, true, true)
end)
