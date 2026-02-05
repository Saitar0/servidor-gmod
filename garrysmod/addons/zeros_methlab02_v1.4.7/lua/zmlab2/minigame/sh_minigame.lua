/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

zmlab2 = zmlab2 or {}
zmlab2.MiniGame = zmlab2.MiniGame or {}
zmlab2.MiniGame.List = zmlab2.MiniGame.List or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

/*
	Registers a new minigame
*/
function zmlab2.MiniGame.Register(id,data)
	data.GameID = id
	zmlab2.MiniGame.List[id] = data
end

function zmlab2.MiniGame.GetPenalty(Machine)
    return math.Round(zmlab2.config.MiniGame.Quality_Penalty)
end

function zmlab2.MiniGame.GetReward(Machine)
    return math.Round(zmlab2.config.MiniGame.Quality_Reward)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

