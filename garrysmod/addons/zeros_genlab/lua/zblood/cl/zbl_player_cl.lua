if SERVER then return end

zbl = zbl or {}
zbl.f = zbl.f or {}

function zbl.f.Player_Initialize()
	zbl.f.Debug("zbl.f.Player_Initialize")

	net.Start("zbl_Player_Initialize")
	net.SendToServer()
end

// Sends a net msg to the server that the player has fully initialized and removes itself
hook.Add("HUDPaint", "zbl_PlayerInit_HUDPaint", function()
	zbl.f.Debug("zbl_PlayerInit_HUDPaint")

	zbl.f.Player_Initialize()

	hook.Remove("HUDPaint", "zbl_PlayerInit_HUDPaint")
end)
