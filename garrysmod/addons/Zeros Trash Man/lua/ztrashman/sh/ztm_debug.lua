ztm = ztm or {}
ztm.f = ztm.f or {}

if SERVER then

	util.AddNetworkString("ztm_debug_drawsphere")
	function ztm.f.Debug_DrawSphere(ply,pos)

		net.Start("ztm_debug_drawsphere")
		net.WriteVector(pos)
		net.Send(ply)
	end


	util.AddNetworkString("ztm_debug_hideall")
	function ztm.f.Debug_HideAll(ply)

		net.Start("ztm_debug_hideall")
		net.Send(ply)
	end
end

if CLIENT then

	local wMod = ScrW() / 1920
	local hMod = ScrH() / 1080
	ztm_Debug_Hints = {}

	net.Receive("ztm_debug_drawsphere", function(len)

		local _pos = net.ReadVector()

		if _pos then
			table.insert(ztm_Debug_Hints,{pos = _pos,time = 30})
		end
	end)

	net.Receive("ztm_debug_hideall", function(len)

		ztm_Debug_Hints = {}
	end)

	function ztm.f.Debug_DrawHints()
		for k, v in pairs(ztm_Debug_Hints) do
			if (v.time + CurTime()) < CurTime() then
				local pos = v.pos:ToScreen()
				local size = 10
				surface.SetDrawColor(ztm.default_colors["red02"])
				surface.DrawRect(pos.x - (size * wMod) / 2, pos.y - (size * hMod) / 2, size * wMod, size * hMod)
			end
		end
	end

	hook.Add("HUDPaint", "ztm_HUDPaint_Debug", ztm.f.Debug_DrawHints)


end
