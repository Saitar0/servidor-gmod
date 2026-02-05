if CLIENT then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

if ztm.config.FastDl then
	ztm = ztm or {}
	ztm.force = ztm.force or {}

	function ztm.force.AddDir(path)

		local files, folders = file.Find("addons/zeros_trashman/" .. path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile("addons/zeros_trashman/" .. path .. "/" .. v)
		end

		for k, v in pairs(folders) do

			ztm.force.AddDir("addons/zeros_trashman/" .. path .. "/" .. v)
		end
	end

	ztm.force.AddDir("particles")
	ztm.force.AddDir("sound/ztm/")
	ztm.force.AddDir("models/zerochain/props_trashman/")
	ztm.force.AddDir("materials/zerochain/props_trashman/")
	ztm.force.AddDir("materials/entities/")
	ztm.force.AddDir("materials/vgui/entities/")

else
	resource.AddWorkshop( "1795813904" ) // Zeros Trashman Contentpack
	//https://steamcommunity.com/sharedfiles/filedetails/?id=1795813904
end
