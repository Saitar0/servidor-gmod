if not SERVER then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

local zcm_buyer_npcs = {}

function zcm.f.Check_BuyerMarkt_TimerExist()
	if timer.Exists("zcm_buyermarkt_id") == false and zcm.config.NPC.RefreshRate ~= -1 then
		timer.Create("zcm_buyermarkt_id", zcm.config.NPC.RefreshRate, 0, zcm.f.ChangeMarkt)
	end
end

hook.Add("InitPostEntity", "zcm_buyermarkt_OnMapLoad", zcm.f.Check_BuyerMarkt_TimerExist)

function zcm.f.Add_BuyerNPC(npc)
	table.insert(zcm_buyer_npcs,npc)
end

function zcm.f.ChangeMarkt()
	for k, v in pairs(zcm_buyer_npcs) do
		if (IsValid(v)) then
			v:RefreshBuyRate()
		end
	end
	zcm.f.debug("Firework NPCs Updated!")
end


// The SAVE / LOAD Functions
function zcm.f.Save_BuyerNPC()
	local data = {}

	for u, j in pairs(ents.FindByClass("zcm_buyer_npc")) do
		table.insert(data, {
			pos = j:GetPos(),
			ang = j:GetAngles()
		})
	end

	if not file.Exists("zcm", "DATA") then
		file.CreateDir("zcm")
	end

	file.Write("zcm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt", util.TableToJSON(data))
end

function zcm.f.Load_BuyerNPC()
	if file.Exists("zcm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt", "DATA") then
		local data = file.Read("zcm/" .. string.lower(game.GetMap()) .. "_buyernpcs" .. ".txt", "DATA")
		data = util.JSONToTable(data)

		if data and table.Count(data) > 0 then
			for k, v in pairs(data) do
				local npc = ents.Create("zcm_buyer_npc")
				npc:SetPos(v.pos)
				npc:SetAngles(v.ang)
				npc:Spawn()
				npc:Activate()
			end

			print("[Zeros Crackermachine] Finished loading Buyer NPCs.")
		end
	else
		print("[Zeros Crackermachine] No map data found for BuyerNPCs entities. Please place some and do !savezcm to create the data.")
	end
end

hook.Add("InitPostEntity", "zcm_SpawnBuyerNPC", zcm.f.Load_BuyerNPC)
hook.Add("PostCleanupMap", "zcm_SpawnBuyerNPCPostCleanUp", zcm.f.Load_BuyerNPC)

hook.Add("PlayerSay", "zcm_SaveBuyerNPC", function(ply, text)
	if string.sub(string.lower(text), 1, 8) == "!savezcm" then
		if zcm.f.IsAdmin(ply) then
			zcm.f.Save_BuyerNPC()
			zcm.f.Notify(ply, "Firework Buyer NPC´s have been saved for the map " .. game.GetMap() .. "!", 0)
		else
			zcm.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
		end
	end
end)
