ztm = ztm or {}
ztm.language = ztm.language or {}

ztm.language.General = ztm.language.General or {}


if (ztm.config.SelectedLanguage == "en") then

    ztm.language.General["Wait"] = "Espere"
    ztm.language.General["TakeMoney"] = "Pegue seu dinheiro"
    ztm.language.General["Payout"] = "Pagamento"
    ztm.language.General["InsertRecycledTrash"] = "Insira o lixo reciclado"
    ztm.language.General["Recycle"] = "Rciclar"
    ztm.language.General["Recycling"] = "Reciclando"
    ztm.language.General["Open"] = "Abre"
    ztm.language.General["Close"] = "Fecha"
    ztm.language.General["Start"] = "Start"
    ztm.language.General["Level"] = "Level" //Trashgun Level
    ztm.language.General["Trash"] = "Lixo"
    ztm.language.General["Max"] = "Max" // Maximal Level reached

    ztm.language.General["Blast"] = "Assoprar" // Primary trashgun action
    ztm.language.General["Suck"] = "Sugar" // Secondary trashgun action

    ztm.language.General["WrongJob"] = "Job errada!"
    ztm.language.General["WrongRank"] = "Rank errado!"
    ztm.language.General["TrashbagLimit"] = "Limite do saco de lixo atingido!" // Called when the player can not spawn anymore trashbags
end
