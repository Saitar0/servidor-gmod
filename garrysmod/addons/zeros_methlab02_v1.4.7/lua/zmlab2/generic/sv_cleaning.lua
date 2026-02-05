/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.7 (stable)
*/

if not SERVER then return end
zmlab2 = zmlab2 or {}
zmlab2.Cleaning = zmlab2.Cleaning or {}

function zmlab2.Cleaning.Setup(ent)
	ent.Cleaning_Goal = math.random(3,10)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

function zmlab2.Cleaning.Inflict(ent,ply,OnFinished)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675618

	if ent.Cleaning_Goal == nil then zmlab2.Cleaning.Setup(ent) end
	ent.Cleaning_Goal = math.Clamp(ent.Cleaning_Goal - 1,0,10)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 76561198260675643

	if ent.Cleaning_Goal <= 0 then
		ent.Cleaning_Goal = nil
		ent:RemoveAllDecals()
		pcall(OnFinished)
	end

	local tr = ply:GetEyeTrace()
	if tr and tr.Hit and tr.HitPos then
		zclib.NetEvent.Create("clean",{[1] = tr.HitPos})
	end
end

