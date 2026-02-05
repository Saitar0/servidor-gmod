ztm = ztm or {}
ztm.language = ztm.language or {}

ztm.language.General = ztm.language.General or {}


if (ztm.config.SelectedLanguage == "cn") then

    ztm.language.General["Wait"] = "等待"
    ztm.language.General["TakeMoney"] = "取走你的钱"
    ztm.language.General["Payout"] = "支付"
    ztm.language.General["InsertRecycledTrash"] = "插入回收垃圾"
    ztm.language.General["Recycle"] = "回收"
    ztm.language.General["Recycling"] = "回收中"
    ztm.language.General["Open"] = "打开"
    ztm.language.General["Close"] = "关闭"
    ztm.language.General["Start"] = "开始"
    ztm.language.General["Level"] = "等级" //Trashgun Level
    ztm.language.General["Trash"] = "垃圾"
    ztm.language.General["Max"] = "最大" // Maximal Level reached

    ztm.language.General["Blast"] = "爆炸" // Primary trashgun action
    ztm.language.General["Suck"] = "糟糕" // Secondary trashgun action

    ztm.language.General["WrongJob"] = "错误的职业!"
    ztm.language.General["WrongRank"] = "错误的等级!"
    ztm.language.General["TrashbagLimit"] = "达到垃圾袋限制!" // Called when the player can not spawn anymore trashbags
end
