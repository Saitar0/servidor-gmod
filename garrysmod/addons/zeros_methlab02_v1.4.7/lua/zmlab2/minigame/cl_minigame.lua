/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not CLIENT then return end
zmlab2 = zmlab2 or {}
zmlab2.MiniGame = zmlab2.MiniGame or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

/*
	Called from the SERVER to tell the Client about the minigame id
*/
net.Receive("zmlab2.MiniGame.GameID", function(len)
    zclib.Debug_Net("zmlab2.MiniGame.GameID",len)

	local MiniGame_Ent = net.ReadEntity()
	local GameID = net.ReadString()
	if MiniGame_Ent and IsValid(MiniGame_Ent) and MiniGame_Ent:IsValid() and GameID then
		MiniGame_Ent.GameID = GameID
	end
end)

/*
	Called from the SERVER to start a minigame
*/
net.Receive("zmlab2_MiniGame", function(len)
    zclib.Debug_Net("zmlab2_MiniGame",len)

	local GameID = net.ReadString()
    local MiniGame_Ent = net.ReadEntity()

	zmlab2.MiniGame.List[GameID]:OnStart(MiniGame_Ent,ply)

	zmlab2.MiniGame.List[GameID]:Interface(MiniGame_Ent,ply)
end)

/*
	Called from the MiniGame to send the game result to the SERVER
*/
function zmlab2.MiniGame.Finish(GameID,Machine,Result)

	zmlab2.MiniGame.List[ GameID ]:OnFinish(Machine, LocalPlayer(), Result)

	net.Start("zmlab2_MiniGame")
	net.WriteString(GameID)
	net.WriteEntity(Machine)
	net.WriteBool(Result)
	net.SendToServer()
end

