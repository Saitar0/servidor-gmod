include("zfruitslicer/sh/zfs_tableregi.lua")
AddCSLuaFile("zfruitslicer/sh/zfs_tableregi.lua")
print("[    Zero´s FruitSlicer - Initialize:    ] " .. "zfs_tableregi.lua")

include("zfruitslicer/sh/zfs_config.lua")
AddCSLuaFile("zfruitslicer/sh/zfs_config.lua")
print("[    Zero´s FruitSlicer - Initialize:    ] " .. "zfs_config.lua")

local IgnoreFileTable = {
	["zfs_config.lua"] = true,
	["zfs_tableregi.lua"] = true
}

local function zfs_LoadAllFiles(fdir)
	local files, dirs = file.Find(fdir .. "*", "LUA")

	for _, afile in ipairs(files) do
		if (string.match(afile, ".lua") and not IgnoreFileTable[afile]) then
			print("[    Zero´s FruitSlicer - Initialize:    ] " .. afile)

			if SERVER then
				AddCSLuaFile(fdir .. afile)
			end

			include(fdir .. afile)
		end
	end

	for _, dir in ipairs(dirs) do
		zfs_LoadAllFiles(fdir .. dir .. "/")
	end
end
zfs_LoadAllFiles( "languages/" )
zfs_LoadAllFiles("zfruitslicer/")