ztm = ztm || {}
ztm.f = ztm.f || {}

function ztm.f.LoadAllFiles(fdir)
	local files, dirs = file.Find(fdir .. "*", "LUA")

	for _, afile in ipairs(files) do
		if string.match(afile, ".lua") then
			print("[    Zeros Trashman - Initialize:    ] " .. afile)

			if SERVER then
				AddCSLuaFile(fdir .. afile)
			end

			include(fdir .. afile)
		end
	end

	for _, dir in ipairs(dirs) do
		ztm.f.LoadAllFiles(fdir .. dir .. "/")
	end
end

ztm.f.LoadAllFiles("ztrashman/")

ztm.f.LoadAllFiles("ztm_languages/")
