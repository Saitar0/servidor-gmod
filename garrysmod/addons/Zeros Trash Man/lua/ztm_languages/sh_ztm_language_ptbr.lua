-- Tradução Português do Brasil para Zeros Trash Man
ztm = ztm or {}
ztm.language = ztm.language or {}

ztm.language.General = ztm.language.General or {}


if (ztm.config.SelectedLanguage == "ptbr") then

    ztm.language.General["Wait"] = "Aguarde"
    ztm.language.General["TakeMoney"] = "Pegue seu Dinheiro"
    ztm.language.General["Payout"] = "Pagamento"
    ztm.language.General["InsertRecycledTrash"] = "Inserir Lixo Reciclado"
    ztm.language.General["Recycle"] = "Reciclar"
    ztm.language.General["Recycling"] = "Reciclando"
    ztm.language.General["Open"] = "Abrir"
    ztm.language.General["Close"] = "Fechar"
    ztm.language.General["Start"] = "Iniciar"
    ztm.language.General["Level"] = "Nível" //Trashgun Level
    ztm.language.General["Trash"] = "Lixo"
    ztm.language.General["Max"] = "Máx" // Maximal Level reached

    ztm.language.General["Blast"] = "Disparar" // Primary trashgun action
    ztm.language.General["Suck"] = "Sugar" // Secondary trashgun action

    ztm.language.General["WrongJob"] = "Trabalho Errado!"
    ztm.language.General["WrongRank"] = "Cargo Errado!"
    ztm.language.General["TrashbagLimit"] = "Você atingiu o limite de sacos de lixo!" // Called when the player can not spawn anymore trashbags
end
