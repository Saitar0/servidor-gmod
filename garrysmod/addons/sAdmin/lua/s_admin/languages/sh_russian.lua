if CLIENT then
    slib.setLang("sadmin", "ru", "title", "sAdmin - Админ мод")
    slib.setLang("sadmin", "ru", "edit_ban_title", "Изменить бан - %s")

    slib.setLang("sadmin", "ru", "dashboard", "Главная Панель")
    slib.setLang("sadmin", "ru", "commands", "Команды")
    slib.setLang("sadmin", "ru", "players", "Игроки")
    slib.setLang("sadmin", "ru", "offline_players", "Офлайн Игроки")
    slib.setLang("sadmin", "ru", "ranks", "Ранги")
    slib.setLang("sadmin", "ru", "bans", "Баны")

    slib.setLang("sadmin", "ru", "save", "Сохранить")
    slib.setLang("sadmin", "ru", "update", "Обновить")
    slib.setLang("sadmin", "ru", "unban", "Разбанить")

    slib.setLang("sadmin", "ru", "ulib_required", "Чтобы это работало, вам потребуется установить ULib на вашем сервере!")

    --Chat Module
    slib.setLang("sadmin", "ru", "asay_help", "Это отправит сообщение всем администраторам!")
    slib.setLang("sadmin", "ru", "pm_help", "Это отправит сообщение определенному игроку!")
    slib.setLang("sadmin", "ru", "mute_help", "Это замутит игрока в чате! ")
    slib.setLang("sadmin", "ru", "unmute_help", "Это размутит игрока в чате!")
    slib.setLang("sadmin", "ru", "gag_help", "Это загагает игрока в голосовом чате!")
    slib.setLang("sadmin", "ru", "ungag_help", "Это разгагает игрока от голосовом чате! ")

    --DarkRP Module
    slib.setLang("sadmin", "ru", "arrest_help", "Это арестует игрока на указанное время!")
    slib.setLang("sadmin", "ru", "unarrest_help", "Это освободит игрока от ареста!")
    slib.setLang("sadmin", "ru", "setmoney_help", "Это установит деньги игрока!")
    slib.setLang("sadmin", "ru", "addmoney_help", "Это добавит денег в кошелек игрока!")
    slib.setLang("sadmin", "ru", "selldoor_help", "Это продаст дверь на которую вы сейчас смотрите!")
    slib.setLang("sadmin", "ru", "sellall_help", "Это продаст все двери указанного игрока!")
    slib.setLang("sadmin", "ru", "setjailpos_help", "Это установит джайл позицию!")
    slib.setLang("sadmin", "ru", "addjailpos_help", "Это добавит джайл позицию!")
    slib.setLang("sadmin", "ru", "setjob_help", "Это установит профессию указанному игроку!")
    slib.setLang("sadmin", "ru", "shipment_help", "Это заспавнит перед вами товар!")

    --Fun Module
    slib.setLang("sadmin", "ru", "freeze_help", "Это заморозит указанного игрока!")
    slib.setLang("sadmin", "ru", "unfreeze_help", "Это разморозит указанного игрока!")
    slib.setLang("sadmin", "ru", "jail_help", "Это отправит указанного игрока в джайл на некоторое время!")
    slib.setLang("sadmin", "ru", "unjail_help", "Это разджайлит указанного игрока! ")
    slib.setLang("sadmin", "ru", "strip_help", "Это заберёт все оружие у указанного игрока! ")
    slib.setLang("sadmin", "ru", "slay_help", "Это убьет указанного игрока!")
    slib.setLang("sadmin", "ru", "exitvehicle_help", "Это приведет к выходу из машины для указанного игрока!")
    slib.setLang("sadmin", "ru", "respawn_help", "Это зареспавнит указанного игрока! ")
    slib.setLang("sadmin", "ru", "slap_help", "Это нанесет указанному игроку определенное количество урона!")
    slib.setLang("sadmin", "ru", "giveammo_help", "Это даст указанному игроку боеприпасы для его активного оружия!")
    slib.setLang("sadmin", "ru", "ignite_help", "Это зажжет указанного игрока на некоторое время!")
    slib.setLang("sadmin", "ru", "extinguish_help", "Это погасит указанного игрока!")
    slib.setLang("sadmin", "ru", "setmodel_help", "Это установит игроку указанную модель!")
    slib.setLang("sadmin", "ru", "scale_help", "Это устанавит масштаб модели указанному игроку в указанный масштаб!")

    -- Management Module
    slib.setLang("sadmin", "ru", "ban_help", "Это приведет к бану указанного игрока по указанной причине на указанное время!")
    slib.setLang("sadmin", "ru", "unban_help", "Это разблокирует указанного игрока!")
    slib.setLang("sadmin", "ru", "banid_help", "Это заблокирует указанный steamid64 по указанной причине на указанное время!")
    slib.setLang("sadmin", "ru", "unbanid_help", "Это разблокирует указанного игрока! ")
    slib.setLang("sadmin", "ru", "kick_help", "Это приведет к удалению указанного игрока по указанной причине!")
    slib.setLang("sadmin", "ru", "setrank_help", "Это установит ранг указанного игрока!")
    slib.setLang("sadmin", "ru", "setrankid_help", "Это установит ранг указанного steamid64!")
    slib.setLang("sadmin", "ru", "removeuser_help", "Это сбросит ранг указанного игрока!")

    -- Teleport Module
    slib.setLang("sadmin", "ru", "goto_help", "Это телепортирует вас к указанному игроку!")
    slib.setLang("sadmin", "ru", "bring_help", "Это телепортирует к вам указанного игрока!")
    slib.setLang("sadmin", "ru", "tp_help", "Это переведет указанного игрока A к игроку B!")
    slib.setLang("sadmin", "ru", "return_help", "Это вернет указанного игрока на предыдущую позицию!")

    -- Utility Module
    slib.setLang("sadmin", "ru", "noclip_help", "Это ноуклипнет указанного игрока!")
    slib.setLang("sadmin", "ru", "hp_help", "Это установит здоровье указанного игрока на указанную сумму!")
    slib.setLang("sadmin", "ru", "armor_help", "Это установит броню указанного игрока на указанную сумму!")
    slib.setLang("sadmin", "ru", "god_help", "Это приведет к включению бессмертия указанного игрока!")
    slib.setLang("sadmin", "ru", "ungod_help", "Это приведет к выключению бессмертия указанного игрока!")
    slib.setLang("sadmin", "ru", "cloak_help", "Это включит невидимость указанного игрока!")
    slib.setLang("sadmin", "ru", "uncloak_help", "Это приведет к выключению невидимости указанного игрока!")
    slib.setLang("sadmin", "ru", "stopsound_help", "Это остановит звук для всех игроков!")
    slib.setLang("sadmin", "ru", "cleardecals_help", "Это очистит декали для всех игроков!")
    slib.setLang("sadmin", "ru", "map_help", "Это изменит карту или режим игры!")
    slib.setLang("sadmin", "ru", "maprestart_help", "Это перезапустит карту, своего рода мягкая перезагрузка.")
    slib.setLang("sadmin", "ru", "mapreset_help", "Это сбросит карту до значений по умолчанию! NB: будут удалены пропы игрока и т.д.")
    slib.setLang("sadmin", "ru", "give_help", "Это даст указанному игроку указанное оружие!")

    -- Miscs
    slib.setLang("sadmin", "ru", "and_others", " и %s другим")
    slib.setLang("sadmin", "ru", "unavailable_plys", "%s недоступен.")

    slib.setLang("sadmin", "ru", "immunity", "Иммунитет")
    slib.setLang("sadmin", "ru", "all_perms", "Все разрешения")
    slib.setLang("sadmin", "ru", "manage_perms", "Управлять разрешениями")
    slib.setLang("sadmin", "ru", "permissions", "Разрешения")
    slib.setLang("sadmin", "ru", "limits", "Лимиты")
    slib.setLang("sadmin", "ru", "phys_players", "Физган игрока")
    slib.setLang("sadmin", "ru", "password_protected", "Паролем защищён")
    slib.setLang("sadmin", "ru", "is_staff", "Персонал")
    slib.setLang("sadmin", "ru", "menu", "Открыть меню")

    slib.setLang("sadmin", "ru", "player", "Игрок")
    slib.setLang("sadmin", "ru", "usergroup", "Группа пользователей")
    slib.setLang("sadmin", "ru", "playtime", "Время игры")
    slib.setLang("sadmin", "ru", "reason", "Причина")
    slib.setLang("sadmin", "ru", "time_left", "Оставшееся время")
    slib.setLang("sadmin", "ru", "admin", "Админ")

    slib.setLang("sadmin", "ru", "are_you_sure", "Вы Уверены?")
    slib.setLang("sadmin", "ru", "no", "Нет")
    slib.setLang("sadmin", "ru", "yes", "Да")
    slib.setLang("sadmin", "ru", "this_delete", "Это удалит '%s'")

    slib.setLang("sadmin", "ru", "eternity", "Вечность")

    slib.setLang("sadmin", "ru", "selected_player", "Выбранный игрок")
    slib.setLang("sadmin", "ru", "selected_rank", "Выбранный ранг")
    slib.setLang("sadmin", "ru", "selected_command", "Выбранная команда")
    slib.setLang("sadmin", "ru", "none_selected", "ничего не выбрано")

    slib.setLang("sadmin", "ru", "settings", "Настройки")
    slib.setLang("sadmin", "ru", "summary", "Резюме")

    slib.setLang("sadmin", "ru", "expired", "Истек")

    slib.setLang("sadmin", "ru", "parameters", "Параметры")
    slib.setLang("sadmin", "ru", "no_parameters", "Нет Параметров")

    slib.setLang("sadmin", "ru", "edit_ban", "Изменить бан")
    slib.setLang("sadmin", "ru", "open_profile", "Открыть профиль")
    slib.setLang("sadmin", "ru", "copy_name", "Копировать имя")
    slib.setLang("sadmin", "ru", "copy_steamid", "Скопировать SteamID")
    slib.setLang("sadmin", "ru", "copy_steamid64", "Скопировать SteamID64")
    slib.setLang("sadmin", "ru", "copy_rank", "Скопировать ранг")
    slib.setLang("sadmin", "ru", "copy_playtime", "Скопировать время игры")

    slib.setLang("sadmin", "ru", "select_time", "Выберите время")

    slib.setLang("sadmin", "ru", "set_rank", "Установить ранг")

    slib.setLang("sadmin", "ru", "rank_name", "Название ранга")
    slib.setLang("sadmin", "ru", "create_rank", "Создать ранг")

    slib.setLang("sadmin", "ru", "name", "Имя")

    slib.setLang("sadmin", "ru", "input", "Вход")

    slib.setLang("sadmin", "ru", "staff_playtime_leaderboard", "Таблица лидеров игрового времени персонала")
    slib.setLang("sadmin", "ru", "total_players", "Всего игроков")
    slib.setLang("sadmin", "ru", "total_playtime", "Общее время игры")
    slib.setLang("sadmin", "ru", "players_online", "Игроки онлайн")
    slib.setLang("sadmin", "ru", "staff_online", "Персонал онлайн")

    slib.setLang("sadmin", "ru", "you", "Вы")
    slib.setLang("sadmin", "ru", "yourself", "Вы Сами")

    slib.setLang("sadmin", "ru", "execute", "Выполнить")

    slib.setLang("sadmin", "ru", "player_name", "Имя игрока")
    slib.setLang("sadmin", "ru", "msg", "Сообщение")
    slib.setLang("sadmin", "ru", "time", "Время (г, мес, ш, д, ч, м, с)")
    slib.setLang("sadmin", "ru", "amount", "Количество")
    slib.setLang("sadmin", "ru", "scale", "Scale")
    slib.setLang("sadmin", "ru", "model", "Модель ")
    slib.setLang("sadmin", "ru", "damage", "Урон")
    slib.setLang("sadmin", "ru", "sid64", "SteamID64")
    slib.setLang("sadmin", "ru", "sid64/sid", "SteamID64/SteamID")
    slib.setLang("sadmin", "ru", "classname", "Имя класса")
    slib.setLang("sadmin", "ru", "gamemode", "Игровой режим")
    slib.setLang("sadmin", "ru", "map", "Карта")

    slib.setLang("sadmin", "ru", "no_permission", "Для этого требуется разрешение '%s'.")
    slib.setLang("sadmin", "ru", "invalid_arguments", "Не удалось выполнить команду, неверные аргументы!")
    slib.setLang("sadmin", "ru", "no_valid_return_pos", "Мы не нашли подходящей позиции возврата!")
    slib.setLang("sadmin", "ru", "cant_target_self", "Вы не можете нацеливаться на себя!")
    slib.setLang("sadmin", "ru", "no_valid_pos", "Мы не нашли подходящих позиций для телепортации!")
    slib.setLang("sadmin", "ru", "no_targets", "Мы не нашли никаких целей!")

    slib.setLang("sadmin", "ru", "request_rate_limit", "Вы были ограничены!")
    slib.setLang("sadmin", "ru", "reached_limit", "Вы достигли максимального предела для %s.")

    slib.setLang("sadmin", "ru", "page_of_page", "Страница  %s/%s")
    slib.setLang("sadmin", "ru", "previous", "Предыдущий")
    slib.setLang("sadmin", "ru", "next", "Следующий")
else
    slib.setLang("sadmin", "ru", "mysql_successfull", "Мы успешно подключились к базе данных!")
    slib.setLang("sadmin", "ru", "mysql_failed", "Нам не удалось подключиться к базе данных! ")
    slib.setLang("sadmin", "ru", "ran_command", "выполнил команду")
    slib.setLang("sadmin", "ru", "with_args", "с аргументами")

    slib.setLang("sadmin", "ru", "no_reason_provided", "Причина не указана")
end

--Chat Module
slib.setLang("sadmin", "ru", "asay_response", "%s админам:%s.")
slib.setLang("sadmin", "ru", "asay_response_receive", "[aSay] %s: %s")

slib.setLang("sadmin", "ru", "pm_response", "[ПМ] %s -> %s")
slib.setLang("sadmin", "ru", "pm_response_receive", "[ПМ] %s <- %s")

slib.setLang("sadmin", "ru", "mute_response", "%s замутил %s за %t.")
slib.setLang("sadmin", "ru", "unmute_response", "%s размутил %s.")
slib.setLang("sadmin", "ru", "gag_response", "%s загагал %s за %t.")
slib.setLang("sadmin", "ru", "ungag_response", "%s разгагал %s.")

--DarkRP Module
slib.setLang("sadmin", "ru", "arrest_response", "%s арестовал %s на %t.")
slib.setLang("sadmin", "ru", "unarrest_response", "%s разарестовал %s.")
slib.setLang("sadmin", "ru", "setmoney_response", "%s установил %s's деньги на %s.")
slib.setLang("sadmin", "ru", "addmoney_response", "%s добавил %s денег в кошелёк %s.")
slib.setLang("sadmin", "ru", "selldoor_response", "%s продал дверь.")
slib.setLang("sadmin", "ru", "sellall_response", "%s продал двери %s.")
slib.setLang("sadmin", "ru", "setjailpos_response", "%s установить позицию тюрьмы.")
slib.setLang("sadmin", "ru", "addjailpos_response", "%s добавил позицию тюрьмы.")
slib.setLang("sadmin", "ru", "setjob_response", "%s установил %s профессию '%s'.")
slib.setLang("sadmin", "ru", "shipment_response", "%s заспавнил товар %s с количеством %s.")

--Fun Module
slib.setLang("sadmin", "ru", "freeze_response", "%s заморозил %s.")
slib.setLang("sadmin", "ru", "unfreeze_response", "%s разморозил %s.")
slib.setLang("sadmin", "ru", "jail_response", "%s заджайлил %s на %t.")
slib.setLang("sadmin", "ru", "unjail_response", "%s разджайлил %s.")
slib.setLang("sadmin", "ru", "strip_response", "%s стрипнул %s.")
slib.setLang("sadmin", "ru", "slay_response", "%s убил %s.")
slib.setLang("sadmin", "ru", "exitvehicle_response", "%s вынудил %s выйти из машины.")
slib.setLang("sadmin", "ru", "respawn_response", "%s силой возродил %s.")
slib.setLang("sadmin", "ru", "slap_response", "%s дал пощёчину %s с дамагом %s.")
slib.setLang("sadmin", "ru", "giveammo_response", "%s дал %s rounds to %s.")
slib.setLang("sadmin", "ru", "ignite_response", "%s зажёг %s на %t.")
slib.setLang("sadmin", "ru", "extinguish_response", "%s потушил %s.")
slib.setLang("sadmin", "ru", "setmodel_response", "%s установил %s модель %s.")
slib.setLang("sadmin", "ru", "scale_response", "%s установить масштаб модели %s на %s.")

-- Management Module
slib.setLang("sadmin", "ru", "ban_response", "%s забанил %s на %t с причиной:%s.")
slib.setLang("sadmin", "ru", "unban_response", "%s разбанил %s.")
slib.setLang("sadmin", "ru", "banid_response", "%s забанил %s на %t с причиной:%s.")
slib.setLang("sadmin", "ru", "unbanid_response", "%s разбанил %s.")
slib.setLang("sadmin", "ru", "kick_response", "%s кикнул %s с причиной:%s.")
slib.setLang("sadmin", "ru", "setrank_response", "%s установил ранг %s на %s время: %t.")
slib.setLang("sadmin", "ru", "setrankid_response", "%s установил ранг %s на %s время: %t.")
slib.setLang("sadmin", "ru", "removeuser_response", "%s убрал ранг %s.")

-- Teleport Module
slib.setLang("sadmin", "ru", "goto_response", "%s телепортировался к %s.")
slib.setLang("sadmin", "ru", "bring_response", "%s призвал %s.")
slib.setLang("sadmin", "ru", "tp_response", "%s телепортировал %s к %s.")
slib.setLang("sadmin", "ru", "return_response", "%s вернул %s.")

-- Utility Module
slib.setLang("sadmin", "ru", "noclip_response", "%s включил ноуклип для %s.")
slib.setLang("sadmin", "ru", "hp_response", "%s установить здоровье для  %s на %s.")
slib.setLang("sadmin", "ru", "armor_response", "%s установить броню для %s на %s.")
slib.setLang("sadmin", "ru", "god_response", "%s загодил %s.")
slib.setLang("sadmin", "ru", "ungod_response", "%s разгодил %s.")
slib.setLang("sadmin", "ru", "cloak_response", "%s включил невидимость %s.")
slib.setLang("sadmin", "ru", "uncloak_response", "%s выключил невидимость %s.")
slib.setLang("sadmin", "ru", "stopsound_response", "%s остановил все звуки.")
slib.setLang("sadmin", "ru", "cleardecals_response", "%s отчистил все декали.")
slib.setLang("sadmin", "ru", "map_response", "%s изменил карту на  %s & режим игры на %s.")
slib.setLang("sadmin", "ru", "maprestart_response", "%s перезапустил карту.")
slib.setLang("sadmin", "ru", "mapreset_response", "%s сбросил карту. ")
slib.setLang("sadmin", "ru", "give_response", "%s выдал %s СВЕП: %s.")

-- Miscs
slib.setLang("sadmin", "ru", "command_calls", "Командные вызовы")
slib.setLang("sadmin", "ru", "console", "КОНСОЛЬ")
slib.setLang("sadmin", "ru", "too_many_targets", "Слишком много целей!")
slib.setLang("sadmin", "ru", "silent", "Тихий")
slib.setLang("sadmin", "ru", "n/a", "N/A")

slib.setLang("sadmin", "ru", "invalid_usergroup", "Неверная группа пользователей")

sAdmin.addTimeUnderstandings("ru", "г", "мес", "ш", "д", "ч", "м", "с")