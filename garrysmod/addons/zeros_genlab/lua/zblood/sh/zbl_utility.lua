zbl = zbl or {}
zbl.f = zbl.f or {}

////////////////////////////////////////////
/////////////// DEFAULT ////////////////////
////////////////////////////////////////////
if SERVER then

	// Basic notify function
	function zbl.f.Notify(ply, msg, ntfType)
		if not IsValid(ply) then return end
		if DarkRP and DarkRP.notify then
			DarkRP.notify(ply, ntfType, 8, msg)
		else
			ply:ChatPrint(msg)
		end
	end
end

if (CLIENT) then
	function zbl.f.LoopedSound(ent, soundfile, shouldplay)
		if shouldplay and zbl.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 500) then
			if ent.Sounds == nil then
				ent.Sounds = {}
			end

			if ent.Sounds[soundfile] == nil then
				ent.Sounds[soundfile] = CreateSound(ent, soundfile)
			end

			if ent.Sounds[soundfile]:IsPlaying() == false then
				ent.Sounds[soundfile]:Play()
				ent.Sounds[soundfile]:ChangeVolume(1, 0)
			end
		else
			if ent.Sounds == nil then
				ent.Sounds = {}
			end

			if ent.Sounds[soundfile] ~= nil and ent.Sounds[soundfile]:IsPlaying() == true then
				ent.Sounds[soundfile]:ChangeVolume(0, 0)
				ent.Sounds[soundfile]:Stop()
				ent.Sounds[soundfile] = nil
			end
		end
	end

	function zbl.f.LerpColor(t, c1, c2)
		local c3 = Color(0, 0, 0)
		c3.r = Lerp(t, c1.r, c2.r)
		c3.g = Lerp(t, c1.g, c2.g)
		c3.b = Lerp(t, c1.b, c2.b)
		c3.a = Lerp(t, c1.a, c2.a)

		return c3
	end

	function zbl.f.ColorToVector(col)
		return Vector((1 / 255) * col.r, (1 / 255) * col.g, (1 / 255) * col.b)
	end

	function zbl.f.GetFontFromTextSize(str,len,font01,font02)
		local size = string.len(str)
		if size <= len then
			return font01
		else
			return font02
		end
	end

	function zbl.f.GetTextSize(txt,font)
		surface.SetFont(font)
		return surface.GetTextSize(txt)
	end

	// Checks if the entity did not got drawn for certain amount of time and call update functions for visuals
	function zbl.f.UpdateEntityVisuals(ent)
		if zbl.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 600) then

			local curDraw = CurTime()

			if ent.LastDraw == nil then
				ent.LastDraw = CurTime()
			end

			if ent.LastDraw < (curDraw - 1) then
				ent:UpdateVisuals()
			end

			ent.LastDraw = curDraw
		end
	end

	function zbl.f.draw_Circle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end
end

//Used to fix the Duplication Glitch
function zbl.f.CollisionCooldown(ent)
	if ent.zbl_CollisionCooldown == nil then
		ent.zbl_CollisionCooldown = true

		timer.Simple(0.1,function()
			if IsValid(ent) then
				ent.zbl_CollisionCooldown = false
			end
		end)

		return false
	else
		if ent.zbl_CollisionCooldown then
			return true
		else
			ent.zbl_CollisionCooldown = true

			timer.Simple(0.1,function()
				if IsValid(ent) then
					ent.zbl_CollisionCooldown = false
				end
			end)
			return false
		end
	end
end

// Here we check if the string has invalid characts
function zbl.f.String_ValidCharacter(aString)
	local str = string.gsub( aString, " ", "" )
	local Valid = true

	if string.match(str, "%W", 1) then
		Valid = false
	end

	return Valid
end

function zbl.f.String_TooShort(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooShort = false

	if string.len(str) <= size then
		_TooShort = true
	end

	return _TooShort
end

function zbl.f.String_TooLong(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooLong = false

	if string.len(str) > size then
		_TooLong = true
	end

	return _TooLong
end

// Checks if the distance between pos01 and pos02 is smaller then dist
function zbl.f.InDistance(pos01, pos02, dist)
	return pos01:DistToSqr(pos02) < (dist * dist)
end

function zbl.f.GetRandomPos(pos, ang, radius)
	pos = pos + ang:Right() * math.Rand(-radius / 2, radius / 2)
	pos = pos + ang:Forward() * math.Rand(-radius / 2, radius / 2)

	return pos
end

function zbl.f.RandomChance(chance)
	if math.random(0, 100) < chance then
		return true
	else
		return false
	end
end

function zbl.f.table_randomize( t )
	local out = { }

	while #t > 0 do
		table.insert( out, table.remove( t, math.random( #t ) ) )
	end

	return out
end

// Creates a new clean table from the given table by removing all the nil entrys
function zbl.f.table_clean(tbl)
	local new_tbl = {}

	for k, v in pairs(tbl) do
		if v then
			new_tbl[k] = v
		end
	end

	return new_tbl
end

function zbl.f.Calculate_AmountCap(hAmount, cap)
	local sAmount

	if hAmount > cap then
		sAmount = cap
	else
		sAmount = hAmount
	end

	return sAmount
end

// Tells us if the function is valid
function zbl.f.FunctionValidater(func)
	if (type(func) == "function") then return true end
	// 270274409
	return false
end

function zbl.f.Lerp(fraction,start,target)
	local value = target / 1 * fraction
	return value
end

function zbl.f.SnapValue(snapval,val)
	val = val / snapval
	val = math.Round(val)
	val = val * snapval
	return val
end

// Returns a 7 digit unique number generated from a string
function zbl.f.StringToUniqueID(str)
	local _bytes = {string.byte(str, 1, string.len(str))}
	local _seed = table.concat( _bytes,"", 1, #_bytes )
	math.randomseed( _seed )
	return math.random(1,9999999)
end


function zbl.f.CurrencyPos(money, symbol)
	if zbl.config.CurrencyPosInvert then
		return symbol .. zbl.f.FormatMoney(money)
	else
		return zbl.f.FormatMoney(money) .. symbol
	end
end

// Returns the formated money as string
function zbl.f.FormatMoney(money)
	if not money then return "0" end
	money = tostring(math.abs(money))
	local sep = sep or ","
	local dp = string.find(money, "%.") or #money + 1

	for i = dp - 4, 1, -3 do
		money = money:sub(1, i) .. sep .. money:sub(i + 1)
	end

	return money
end

function zbl.f.FormatTime(time)
	local divid = time / 60
	local minutes = math.floor(time / 60)
	local seconds = math.Round(60 * (divid - minutes))
	if seconds > 0 and minutes > 0 then
		return minutes .. " " .. zbl.language.General["Minutes"] .. " | " .. seconds .. " " .. zbl.language.General["Seconds"]
	elseif seconds <= 0 and minutes > 0 then
		return minutes .. " " .. zbl.language.General["Minutes"]
	elseif seconds >= 0 and minutes <= 0 then
		return seconds .. " " .. zbl.language.General["Seconds"]
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
///////////////// OWNER ////////////////////
////////////////////////////////////////////
if SERVER then
	// This saves the owners SteamID
	function zbl.f.SetOwnerByID(ent, id)
		ent:SetNWString("zbl_Owner", id)
	end

	// This saves the owners SteamID
	function zbl.f.SetOwner(ent, ply)
		if (IsValid(ply)) then
			ent:SetNWString("zbl_Owner", zbl.f.Player_GetID(ply))
			if CPPI then
				ent:CPPISetOwner(ply)
			end
		else
			ent:SetNWString("zbl_Owner", "world")
		end
	end
end

// This returns the entites owner SteamID
function zbl.f.GetOwnerID(ent)
	return ent:GetNWString("zbl_Owner", "nil")
end

// Checks if both entities have the same owner
function zbl.f.OwnerID_Check(ent01,ent02)

	if IsValid(ent01) and IsValid(ent02) then

		if zbl.f.GetOwnerID(ent01) == zbl.f.GetOwnerID(ent02) then
			return true
		else
			return false
		end
	else
		return false
	end
end

// This returns the owner
function zbl.f.GetOwner(ent)
	if IsValid(ent) then
		local id = ent:GetNWString("zbl_Owner", "nil")
		local ply = player.GetBySteamID(id)

		if (IsValid(ply)) then
			return ply
		else
			return false
		end
	else
		return false
	end
end

// Checks if the player is the owner of the entitiy
function zbl.f.IsOwner(ply, ent)
	if IsValid(ent) and IsValid(ply) then
		local id = ent:GetNWString("zbl_Owner", "nil")
		local ply_id = zbl.f.Player_GetID(ply)

		if id == ply_id or id == "world" then
			return true
		else
			return false
		end
	else
		return false
	end
end

// This returns true if the player is a admin
function zbl.f.IsAdmin(ply)
	if IsValid(ply) then
		if xAdmin then
			//xAdmin Support
			return ply:IsAdmin()
		else
			if zbl.config.AdminRanks[zbl.f.GetPlayerRank(ply)] then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end
/////////////////////////////////////////////
/////////////////////////////////////////////



////////////////////////////////////////////
///////////////// Timer ////////////////////
////////////////////////////////////////////
concommand.Add("zbl_debug_Timer_PrintAll", function(ply, cmd, args)
	if IsValid(ply) and zbl.f.IsAdmin(ply) then
		zbl.f.Timer_PrintAll()
	end
end)

if zbl_TimerList == nil then
	zbl_TimerList = {}
end

function zbl.f.Timer_PrintAll()
	PrintTable(zbl_TimerList)
end

function zbl.f.Timer_Create(timerid, time, rep, func)
	if zbl.f.FunctionValidater(func) then
		timer.Create(timerid, time, rep, func)
		table.insert(zbl_TimerList, timerid)
		//zbl.f.Debug("Timer Created: " .. timerid)
	end
end

function zbl.f.Timer_Remove(timerid)
	if timer.Exists(timerid) then
		timer.Remove(timerid)
		table.RemoveByValue(zbl_TimerList, timerid)
		//zbl.f.Debug("Timer Removed: " .. timerid)
	end
end
////////////////////////////////////////////
////////////////////////////////////////////



////////////////////////////////////////////
////////////// Rank / Job //////////////////
////////////////////////////////////////////
// Returns the player rank / usergroup
function zbl.f.GetPlayerRank(ply)
	return ply:GetUserGroup()
end

// Returns the players job
function zbl.f.GetPlayerJobName(ply)
	return team.GetName( zbl.f.GetPlayerJob(ply) )
end

function zbl.f.GetPlayerJob(ply)
	return ply:Team()
end
////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
//////////////// CUSTOM ////////////////////
////////////////////////////////////////////
function zbl.f.IsResearcher(ply)
	if zbl.config.Jobs and table.Count(zbl.config.Jobs) > 0 and zbl.config.Jobs[zbl.f.GetPlayerJob(ply)] then
		return true
	elseif BaseWars then
		return true
	else
		return false
	end
end

// Returns true if a research is on the server
function zbl.f.ActiveResearcher()
	local result = false

	for k, v in pairs(zbl_PlayerList) do
		if IsValid(v) and zbl.f.IsResearcher(v) then
			result = true
			break
		end
	end

	return result
end

function zbl.f.RankTblToString(tbl)
	local str = ""

	for k, v in pairs(tbl) do
		str = str .. k
	end

	return str
end
////////////////////////////////////////////
////////////////////////////////////////////
