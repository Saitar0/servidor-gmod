ztm = ztm or {}
ztm.f = ztm.f or {}

if SERVER then

	// Basic notify function
	function ztm.f.Notify(ply, msg, ntfType)
		if DarkRP and DarkRP.notify then
			DarkRP.notify(ply, ntfType, 8, msg)
		else
			ply:ChatPrint(msg)
		end
	end

	// This saves the owners SteamID
	function ztm.f.SetOwnerByID(ent, id)
		ent:SetNWString("ztm_Owner", id)
	end

	// This saves the owners SteamID
	function ztm.f.SetOwner(ent, ply)
		if (IsValid(ply)) then
			ent:SetNWString("ztm_Owner", ply:SteamID())
			ent:CPPISetOwner(ply)
		else
			ent:SetNWString("ztm_Owner", "world")
		end
	end
end

if (CLIENT) then

	function ztm.f.LoopedSound(ent, soundfile, shouldplay)
		if shouldplay and ztm.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 500) then
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

	function ztm.f.LerpColor(t, c1, c2)
		local c3 = Color(0, 0, 0)
		c3.r = Lerp(t, c1.r, c2.r)
		c3.g = Lerp(t, c1.g, c2.g)
		c3.b = Lerp(t, c1.b, c2.b)
		c3.a = Lerp(t, c1.a, c2.a)

		return c3
	end

	function ztm.f.GetFontFromTextSize(str,len,font01,font02)
		local size = string.len(str)
		if size < len then
			return font01
		else
			return font02
		end
	end

	// Checks if the entity did not got drawn for certain amount of time and call update functions for visuals
	function ztm.f.UpdateEntityVisuals(ent)
		if ztm.f.InDistance(LocalPlayer():GetPos(), ent:GetPos(), 1000) then

			local curDraw = CurTime()

			if ent.LastDraw == nil then
				ent.LastDraw = CurTime()
			end

			if ent.LastDraw < (curDraw - 1) then
				//print("Entity: " .. ent:EntIndex() .. " , Call UpdateVisuals() at " .. math.Round(CurTime()))

				ent:UpdateVisuals()
			end

			ent.LastDraw = curDraw
		end
	end


	function ztm.f.draw_Circle( x, y, radius, seg )
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
function ztm.f.CollisionCooldown(ent)
	if ent.ztm_CollisionCooldown == nil then
		ent.ztm_CollisionCooldown = true

		timer.Simple(0.1,function()
			if IsValid(ent) then
				ent.ztm_CollisionCooldown = false
			end
		end)

		return false
	else
		if ent.ztm_CollisionCooldown then
			return true
		else
			ent.ztm_CollisionCooldown = true

			timer.Simple(0.1,function()
				if IsValid(ent) then
					ent.ztm_CollisionCooldown = false
				end
			end)
			return false
		end
	end
end


// Returns the player rank / usergroup
function ztm.f.GetPlayerRank(ply)
	return ply:GetUserGroup()
end

// Returns the players job
function ztm.f.GetPlayerJob(ply)
	return team.GetName( ply:Team() )
end

// Here we check if the string has invalid characts
function ztm.f.String_ValidCharacter(aString)
	local str = string.gsub( aString, " ", "" )
	local Valid = true

	if string.match(str, "%W", 1) then
		Valid = false
	end

	return Valid
end

function ztm.f.String_TooShort(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooShort = false

	if string.len(str) <= size then
		_TooShort = true
	end

	return _TooShort
end

function ztm.f.String_TooLong(aString,size)
	local str = string.gsub( aString, " ", "" )
	local _TooLong = false

	if string.len(str) > size then
		_TooLong = true
	end

	return _TooLong
end


//////////// OWNER CHECKS ///////////////////

// This returns the entites owner SteamID
function ztm.f.GetOwnerID(ent)
	return ent:GetNWString("ztm_Owner", "nil")
end

// Checks if both entities have the same owner
function ztm.f.OwnerID_Check(ent01,ent02)

	if IsValid(ent01) and IsValid(ent02) then

		if ztm.f.GetOwnerID(ent01) == ztm.f.GetOwnerID(ent02) then
			return true
		else
			return false
		end
	else
		return false
	end
end

// This returns the owner
function ztm.f.GetOwner(ent)
	if (IsValid(ent)) then
		local id = ent:GetNWString("ztm_Owner", "nil")
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
function ztm.f.IsOwner(ply, ent)
	if IsValid(ent) and IsValid(ply) then
		local id = ent:GetNWString("ztm_Owner", "nil")
		local ply_id = ply:SteamID()

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
function ztm.f.IsAdmin(ply)
	if IsValid(ply) then

		//xAdmin Support
		if xAdmin then
			return ply:IsAdmin()
		else
			if table.HasValue(ztm.config.AdminRanks,ztm.f.GetPlayerRank(ply)) then
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function ztm.f.IsTrashman(ply)
	if ply:Team() == TEAM_ZTM_TRASHMAN then
		return true
	else
		return false
	end
end


// Used for Debug
function ztm.f.Debug(mgs)
	if (ztm.config.Debug) then
		if istable(mgs) then
			print("[    DEBUG    ] Table Start >")
			PrintTable(mgs)
			print("[    DEBUG    ] Table End <")
		else
			print("[    DEBUG    ] " .. mgs)
		end
	end
end

function ztm.f.Debug_Sphere(pos,size,lifetime,color,ignorez)
	if ztm.config.Debug then
		debugoverlay.Sphere( pos, size, lifetime, color, ignorez )
	end
end

// Checks if the distance between pos01 and pos02 is smaller then dist
function ztm.f.InDistance(pos01, pos02, dist)
	local inDistance = pos01:DistToSqr(pos02) < (dist * dist)
	return  inDistance
end

function ztm.f.RandomChance(chance)
	if math.random(0, 100) < math.Clamp(chance,0,100) then
		return true
	else
		return false
	end
end

function ztm.f.table_randomize( t )
	local out = { }

	while #t > 0 do
		table.insert( out, table.remove( t, math.random( #t ) ) )
	end

	return out
end

function ztm.f.Calculate_AmountCap(hAmount, cap)
	local sAmount

	if hAmount > cap then
		sAmount = cap
	else
		sAmount = hAmount
	end

	return sAmount
end

// Tells us if the function is valid
function ztm.f.FunctionValidater(func)
	if (type(func) == "function") then return true end

	return false
end


function ztm.f.Timer_Create(timerid,time,rep,func)
	if ztm.f.FunctionValidater(func) then
		timer.Create(timerid, time, rep,func)
	end
end

function ztm.f.Timer_Remove(timerid)
	if timer.Exists(timerid) then
		timer.Remove(timerid)
	end
end
