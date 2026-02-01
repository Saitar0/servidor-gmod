if CLIENT then return end
zfs = zfs or {}
zfs.force = zfs.force or {}

if zfs.config.EnableResourceAddfile then
	function zfs.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zfs.force.AddDir(path .. "/" .. v)
		end
	end

	zfs.force.AddDir("materials/zfruitslicer/ui")
	zfs.force.AddDir("materials/zfruitslicer/ui/ingrediens")
	zfs.force.AddDir("materials/particles/fruitslicer")
	zfs.force.AddDir("materials/zerochain/fruitslicerjob")
	zfs.force.AddDir("materials/zerochain/fruitslicerjob/fruitcup")
	zfs.force.AddDir("materials/zerochain/fruitslicerjob/knife")
	zfs.force.AddDir("materials/zerochain/fruitslicerjob/shakestand")
	zfs.force.AddDir("materials/zerochain/fruitslicerjob/sweetener")
	zfs.force.AddDir("models/zerochain/fruitslicerjob")
	zfs.force.AddDir("models/zerochain/fruitslicerjob/weapons")
	zfs.force.AddDir("particles")
	zfs.force.AddDir("resource/fonts")
	zfs.force.AddDir("sound/zfs")
else
	resource.AddWorkshop("1272277353") -- ZerosFruitSlicer Contentpack
end
