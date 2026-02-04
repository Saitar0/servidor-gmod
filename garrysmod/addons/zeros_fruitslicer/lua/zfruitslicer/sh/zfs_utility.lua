zfs = zfs or {}
zfs.f = zfs.f or {}

if SERVER then
	function zfs.f.Notify(ply, msg, ntfType)
		if gmod.GetGamemode().Name == "DarkRP" then
			DarkRP.notify(ply, ntfType, 8, msg)
		else
			ply:ChatPrint(msg)
		end
	end

	-- This saves the owners SteamID
	function zfs.f.SetOwnerID(ent, ply)
		if (IsValid(ply)) then
			ent:SetNWString("zfs_Owner", ply:SteamID())

			if CPPI then
				ent:CPPISetOwner(ply)
			end
		else
			ent:SetNWString("zfs_Owner", "world")
		end
	end
end

-- This returns the entites owner SteamID
function zfs.f.GetOwnerID(ent)
	return ent:GetNWString("zfs_Owner", "nil")
end

-- This returns the owner
function zfs.f.GetOwner(ent)
	if (IsValid(ent)) then
		local id = ent:GetNWString("zfs_Owner", "nil")
		local ply = player.GetBySteamID(id)

		if (IsValid(ply)) then
			return ply
		else
			return false
		end
	else
		return false
	end
end

-- This returns true if the input is the owner
function zfs.f.IsOwner(ply, ent)
	if (IsValid(ent)) then
		if (zfs.config.SharedEquipment) then
			return true
		else
			local id = ent:GetNWString("zfs_Owner", "nil")
			local ply_id = ply:SteamID()

			if (IsValid(ply) and id == ply_id or id == "world") then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

-- This checks if the player is a admin
function zfs.f.IsAdmin(ply)
	local isAdmin = false

	if (table.HasValue(zfs.config.AllowedRanks, ply:GetUserGroup())) then
		isAdmin = true
	end

	return isAdmin
end

-- Does the player have the correct Job?
function zfs.f.HasAllowedJob(ply, AllowedJobs)
	local plyJob = team.GetName(ply:Team())
	local UserHasAllowedJob = false

	if (table.Count(AllowedJobs) > 0) then
		for a, b in pairs(AllowedJobs) do
			if (b == plyJob) then
				UserHasAllowedJob = true
				break
			end
		end
	else
		UserHasAllowedJob = true
	end

	return UserHasAllowedJob
end

function zfs.f.CreateAllowList(atable)
	local allowedGroups = {}

	for i, k in pairs(atable) do
		if (i ~= nil and k == true) then
			table.insert(allowedGroups, i)
		end
	end

	return allowedGroups
end

-- This Calculates our Fruit varation Boni
function zfs.f.CalculateFruitVarationBoni(item)
	local FruitVariationCount = -1

	for i, k in pairs(item.recipe) do
		if (k > 0) then
			FruitVariationCount = FruitVariationCount + 1
		end
	end

	local PriceBoni = (FruitVariationCount / 9)

	return PriceBoni
end
