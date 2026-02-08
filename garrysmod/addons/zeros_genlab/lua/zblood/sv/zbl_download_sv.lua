if CLIENT then return end
zbl = zbl or {}
zbl.f = zbl.f or {}


if zbl.config.FastDl then
	zbl = zbl or {}
	zbl.force = zbl.force or {}

	function zbl.force.AddDir(path)

		local files, folders = file.Find(path .. "/*", "GAME")

		for k, v in pairs(files) do
			resource.AddFile(path .. "/" .. v)
		end

		for k, v in pairs(folders) do

			zbl.force.AddDir(path .. "/" .. v)
		end
	end

	zbl.force.AddDir("sound/zbl/")
	zbl.force.AddDir("models/zerochain/props_bloodlab/")
	zbl.force.AddDir("materials/zerochain/props_bloodlab/")
	zbl.force.AddDir("materials/zerochain/zblood/")


	resource.AddSingleFile("resource/fonts/OpenSans-Bold.ttf")
	resource.AddSingleFile("resource/fonts/OpenSans-Regular.ttf")

	resource.AddSingleFile("materials/entities/zbl_gasmask.png")
	resource.AddSingleFile("materials/entities/zbl_lab.png")
	resource.AddSingleFile("materials/entities/zbl_npc.png")

	resource.AddSingleFile("particles/zbl_effects.pcf")

	resource.AddSingleFile("materials/vgui/entities/zbl_gun.vmt")
	resource.AddSingleFile("materials/vgui/entities/zbl_gun.vtf")
	resource.AddSingleFile("materials/vgui/entities/zbl_spray.vmt")
	resource.AddSingleFile("materials/vgui/entities/zbl_spray.vtf")


	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_gun.vmt")
	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_gun.vtf")
	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_spray.vmt")
	resource.AddSingleFile("materials/zerochain/zblood/vgui/zbl_spray.vtf")

else
	resource.AddWorkshop( "2034684543" ) // Zeros GenLab
	//https://steamcommunity.com/sharedfiles/filedetails/?id=2034684543
end
