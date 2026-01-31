zcm = zcm || {}
zcm.f = zcm.f || {}

function zcm.f.LoadAllFiles(fdir)
	local files, dirs = file.Find(fdir .. "*", "LUA")

	for _, afile in ipairs(files) do
		if (string.match(afile, ".lua")) then
			print("[    Zeros Crackermachine - Initialize:    ] " .. afile)

			if SERVER then
				AddCSLuaFile(fdir .. afile)
			end

			include(fdir .. afile)
		end
	end
	for _, dir in ipairs(dirs) do
		zcm.f.LoadAllFiles(fdir .. dir .. "/")
	end
end

zcm.f.LoadAllFiles("zcrackermachine/")
zcm.f.LoadAllFiles("zcm_languages/")
