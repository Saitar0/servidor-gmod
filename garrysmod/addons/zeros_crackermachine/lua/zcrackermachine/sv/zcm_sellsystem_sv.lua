if not SERVER then return end
zcm = zcm or {}
zcm.f = zcm.f or {}

function zcm.f.Sell_CrackerPack(ply, npc ,ent)

	// This checks if the player has the correct job to sell firework
	if table.Count(zcm.config.SellBox.Jobs) > 0 and not table.HasValue(zcm.config.SellBox.Jobs, team.GetName(ply:Team())) then
		return
	end


	// This tells us how much firework we sell
	local fireworkCount = 0
	if IsValid(npc) then
		fireworkCount = ply:GetNWInt("zcm_firework", 0)
		ply:SetNWInt("zcm_firework", 0)
	elseif IsValid(ent) then
		fireworkCount = ent:GetFireworkCount()
	end

	if fireworkCount <= 0 then return end


	// This calculates the earning amount according to the player rank
	local earning = zcm.config.SellBox.SellPrice[ply:GetUserGroup()]
	if earning == nil then
		earning = zcm.config.SellBox.SellPrice["Default"]
	end
	earning = earning * fireworkCount

	// If the firework gets sold by a npc then we multiply the earning times the price modifier
	if IsValid(npc) then
		earning = earning * ((1 / 100) * npc:GetPriceModifier())
	end

	//Vrondakis
	if (zcm.config.VrondakisLevelSystem) then
		ply:addXP(zcm.config.Vrondakis["Selling"].XP * fireworkCount, " ", true)
	end

	// Here we give the player the money
	zcm.f.GiveMoney(ply, earning)

	// This creates the sell effect
	if IsValid(npc) then
		zcm.f.CreateEffectTable("zcm_sell", "zcm_sell", npc, npc:GetAngles(), npc:GetPos(), nil)
	elseif IsValid(ent) then
		zcm.f.CreateEffectTable("zcm_sell", "zcm_sell", ent, ent:GetAngles(), ent:GetPos(), nil)
		ent:Remove()
	end

	zcm.f.Notify(ply, "+" .. earning .. zcm.config.Currency, 0)
end
