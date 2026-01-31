if CLIENT then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

if zcm.config.EnableResourceAddfile then
	zcm = zcm or {}
	zcm.force = zcm.force or {}

	function zcm.force.AddDir(path)
		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do
			zcm.force.AddDir(path .. "/" .. v)
		end
	end

	zcm.force.AddDir("particles")
	zcm.force.AddDir("sound/")
	zcm.force.AddDir("models/")
	zcm.force.AddDir("materials/")
else
	resource.AddWorkshop( "1653699664" ) -- Zeros Crackermachine Contentpack
end
