-- Discord comando
hook.Add("PlayerSay", "SAdmin_DiscordCommand", function(ply, text, team)
    if not IsValid(ply) then return end

    local msg = string.Trim(string.lower(text))
    if msg == "!discord" or string.StartWith(msg, "!discord ") then
        ply:ChatPrint("Discord do servidor: https://discord.gg/eSp2KSYg")
        return "" -- evita que a mensagem apareça para os outros jogadores
    end
end)

-- Workshop comando
hook.Add("PlayerSay", "SAdmin_WorkshopCommand", function(ply, text, team)
    if not IsValid(ply) then return end

    local msg = string.Trim(string.lower(text))
    if msg == "!workshop" or string.StartWith(msg, "!workshop ") then
        ply:ChatPrint("Workshop do servidor: https://steamcommunity.com/sharedfiles/filedetails/?id=3655899845")
        return "" -- evita que a mensagem apareça para os outros jogadores
    end
end)

