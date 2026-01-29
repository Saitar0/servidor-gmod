timer.Simple(3, function()
    if GAS and GAS.Logging then
        local command = GAS.Logging:MODULE()

        command.Category = "sAdmin"
        command.Name = slib.getLang("sadmin", sAdmin.config["language"], "command_calls")
        command.Colour = sAdmin.config["chat_prefix"][1]

        command:Setup(function()
            command:Hook("sA:RanCommand", "sA:bLogSupport", function(ply, name, args, argstr)
                command:Log((IsValid(ply) and GAS.Logging:FormatPlayer(ply) or slib.getLang("sadmin", sAdmin.config["language"], "console")).." "..slib.getLang("sadmin", sAdmin.config["language"], "ran_command").." '"..name.."' "..slib.getLang("sadmin", sAdmin.config["language"], "with_args").." ["..argstr.."]")
            end)
        end)

        GAS.Logging:AddModule(command)

        local edited_ban = GAS.Logging:MODULE()

        edited_ban.Category = "sAdmin"
        edited_ban.Name = slib.getLang("sadmin", sAdmin.config["language"], "ban_edits")
        edited_ban.Colour = sAdmin.config["chat_prefix"][1]

        edited_ban:Setup(function()
            edited_ban:Hook("sA:EdittedBan", "sA:bLogSupport", function(ply, sid64, new_time, new_reason)
                local target = slib.sid64ToPly[sid64]
                target = IsValid(target) and GAS.Logging:FormatPlayer(target) or target

                edited_ban:Log(string.format(slib.getLang("sadmin", sAdmin.config["language"], "edited_ban"), IsValid(ply) and GAS.Logging:FormatPlayer(ply) or slib.getLang("sadmin", sAdmin.config["language"], "console"), target, new_time, new_reason))
            end)
        end)

        GAS.Logging:AddModule(edited_ban)
    end
end)