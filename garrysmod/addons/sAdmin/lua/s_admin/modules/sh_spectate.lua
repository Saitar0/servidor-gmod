sAdmin = sAdmin or {}

sAdmin.addCommand({
    name = "spectate",
    category = "Utility",
    inputs = {{"player", "player_name"}},
    func = function(ply, args, silent)
        if !IsValid(ply) then sAdmin.msg(silent and ply or nil, "cmd_cant_console", ply, targets) return end

        local targets = sAdmin.getTargets("spectate", ply, args[1], 1)
        for k,v in ipairs(targets) do
            if v == ply then sAdmin.msg(ply, "cant_target_self") return end

            local entIndex = v:EntIndex()

            sAdmin.networkData(ply, {"spectating"}, entIndex)

            ply.sASpectating = v

            ply:Spectate(OBS_MODE_CHASE)
            ply:SpectateEntity(v)

            ply.sAOGSpectatePos = ply:GetPos()
            ply.sAOGSpecWeapons = {}
            ply.sAOGSpectateHoldWep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or nil

            for k,v in ipairs(ply:GetWeapons()) do
                table.insert(ply.sAOGSpecWeapons, v:GetClass())
            end

            ply:StripWeapons()
        end

        sAdmin.msg(silent and ply or nil, "spectate_response", ply, targets)
    end
})

if SERVER then
    hook.Add("KeyPress", "sA:SpectateStop", function(ply, key)
        if ply.sASpectating and (key == 2 or key == 8192) then
            ply:SetPos(ply.sAOGSpectatePos)

            for k,v in ipairs(ply.sAOGSpecWeapons) do
                ply:Give(v, true)
            end
            
            timer.Simple(.1, function()
                if !IsValid(ply) or !ply.sAOGSpectateHoldWep then return end

                ply:SelectWeapon(ply.sAOGSpectateHoldWep)
                ply.sAOGSpectateHoldWep = nil
            end)

            sAdmin.networkData(ply, {"spectating"}, nil)

            ply:Spectate(OBS_MODE_NONE)
            ply:SpectateEntity(nil)

            ply.sASpectating = nil
            ply.sAOGSpectatePos = nil
            ply.sAOGSpecWeapons = nil

            if sAdmin.cloakedPeople[ply:SteamID64()] then
                sAdmin.cloakHandle(ply, true)
            end
        end
    end)

    hook.Add("PlayerCanHearPlayersVoice", "sA:SpectateHearFromPlayer", function(listener, talker)
        if listener.sASpectating then
            local canHear = GAMEMODE:PlayerCanHearPlayersVoice(listener.sASpectating, talker)

            return canHear or talker == listener.sASpectating
        end
    end)
else
    local isThirdperson = false

    local function getThirdPersonView(ply)
        local startPos = ply:EyePos()
        local endPos = startPos - LocalPlayer():GetAimVector() * 100

        local tr_data = {
            start = startPos,
            endpos = endPos,
            filter = ply
        }
    
        return util.TraceLine(tr_data).HitPos 
    end

    local beamMat, beamCol = Material("cable/cable2"), Color(40,90,255)
    local view = {}

    hook.Add("CalcView", "sA:Spectating", function()
        if !sAdmin.spectating then return end

        local specPly = Entity(sAdmin.spectating)

        if !IsValid(specPly) then return end

        view.origin = specPly:EyePos()
        view.angles = specPly:EyeAngles()

        if isThirdperson then
            view.origin = getThirdPersonView(specPly)
            view.angles = LocalPlayer():EyeAngles()
        end

        view.drawviewer = false

        specPly:SetNoDraw(!isThirdperson)

        return view
    end)

    hook.Add("RenderScreenspaceEffects", "sA:RenderSpectateLines", function()
        if !sAdmin.spectating or !isThirdperson then return end

        local specPly = Entity(sAdmin.spectating)

        if !IsValid(specPly) then return end

        cam.Start3D(view.origin, view.angles)
            render.SetMaterial(beamMat)
            render.DrawBeam(specPly:EyePos() + specPly:EyeAngles():Forward() * 5, specPly:GetEyeTrace().HitPos, 2, 0.01, 20, beamCol)
        cam.End3D()
    end)

    local acceptedBinds = {
        ["+jump"] = true,
        ["+reload"] = true
    }

    hook.Add("PlayerBindPress", "sA:CaptureButtons", function(ply, bind, pressed)
        if sAdmin.spectating then
            if bind == "+attack2" and pressed then
                isThirdperson = !isThirdperson
            end

            if bind == "+reload" and pressed then
                local specPly = Entity(sAdmin.spectating)

                if !IsValid(specPly) then return end

                RunConsoleCommand("sa", "goto", specPly:IsBot() and specPly:Nick() or specPly:SteamID64())
            end

            return !acceptedBinds[bind]
        end
    end)

    local maincolor, gap = table.Copy(slib.getTheme("maincolor")), slib.getTheme("margin")
    maincolor.a = 240

    local instructions = {slib.getLang("sadmin", sAdmin.config["language"], "spectating_thirdperson"), slib.getLang("sadmin", sAdmin.config["language"], "spectating_stop"), slib.getLang("sadmin", sAdmin.config["language"], "spectating_teleport")}
    local font, font2 = slib.createFont("Roboto", 15), slib.createFont("Roboto", 23)
    local scrh, scrw = ScrH(), ScrW()
    hook.Add("HUDPaint", "sA:SpectateInstructions", function()
        if !sAdmin.spectating then return end
        local x, y = gap, scrh * .5
        local w, h = 0, gap
        local def_h = 0

        surface.SetFont(font)
        for k,v in ipairs(instructions) do
            local txt_w, txt_h = surface.GetTextSize(v)
            h = h + txt_h + gap

            if txt_w > w then
                w = txt_w + gap * 4
            end

            def_h = txt_h + gap
        end
        
        surface.SetDrawColor(maincolor)
        surface.DrawRect(x, y - h * .5, w, h)

        for k,v in ipairs(instructions) do
            draw.SimpleText(v, font, gap * 3, y - h * .5 + gap + (def_h * (k - 1)), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        local specPly = Entity(sAdmin.spectating)

        if !IsValid(specPly) then return end
        draw.SimpleTextOutlined(slib.getLang("sadmin", sAdmin.config["language"], "spectating_ply", specPly:Nick()), font2, scrw * .5, gap * 3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
    end)
end