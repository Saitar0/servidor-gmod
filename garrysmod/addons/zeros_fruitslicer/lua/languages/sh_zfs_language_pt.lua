zfs = zfs or {}
zfs.language = zfs.language or {}

if (zfs.config.selectedLanguage == "pt") then
    zfs.language.VGUI = zfs.language.VGUI or {}
    zfs.language.Shop = zfs.language.Shop or {}
    zfs.language.Benefit = zfs.language.Benefit or {}

    if (zfs.config.UseHungermod) then
        zfs.language.VGUI.HealthBoni = "Bônus de Energia:"
    else
        zfs.language.VGUI.HealthBoni = "Bônus de Vida:"
    end

    zfs.language.Shop.MixerWrongStage = "Você não pode usar isto ainda!"
    zfs.language.Shop.StorageTitle = "Armazenamento"
    zfs.language.Shop.MissingFruits = "Você não tem frutas suficientes!"
    zfs.language.Shop.StorageBackButton = "Voltar"
    zfs.language.Shop.NotOwner = "Você não é o dono disto!"
    zfs.language.Shop.SellTableFull = "Sua mesa de venda está cheia, espere até que seja vendida!"
    zfs.language.Shop.SelectTopping_WrongUlx01 = "Este topping só pode ser adicionado por "
    zfs.language.Shop.SelectTopping_WrongUlx02 = "Você não está no grupo ULX correto para adicionar este topping!"
    zfs.language.Shop.ItemBought = "Você comprou $itemName por $itemPrice$currency"
    zfs.language.Shop.Screen_Info01 = "Pegue um copo!"
    zfs.language.Shop.Screen_Info02 = "Fatie as frutas!"
    zfs.language.Shop.Screen_Info03 = "Ligue o liquidificador!"
    zfs.language.Shop.Screen_Info04 = "Escolha um\nAdoçante!"
    zfs.language.Shop.Screen_Wait = "Aguarde..."
    zfs.language.Shop.Screen_Cancel = "Cancelar"
    zfs.language.Shop.Screen_Info = "Informações"
    zfs.language.Shop.Screen_Product_Select = "Selecione um produto"
    zfs.language.Shop.Screen_Product_Price = "Preço:"
    zfs.language.Shop.Screen_Product_Ingrediens = "Ingredientes:"
    zfs.language.Shop.Screen_Product_BasePrice = "Preço base:"
    zfs.language.Shop.Screen_Product_FruitBoni = "Bônus de fruta:"
    zfs.language.Shop.ChangePrice_PriceMinimum = "Você não pode definir o preço menor que "
    zfs.language.Shop.ChangePrice_PriceMaximum = "Você não pode definir o preço maior que "
    zfs.language.Shop.ChangePrice_PriceChanged = "Você mudou o preço para "
    zfs.language.Shop.ChangePrice_Cancel = "CANCELAR"
    zfs.language.Shop.ChangePrice_Confirm = "CONFIRMAR"
    zfs.language.Shop.Screen_Confirm_Product = "Confirmar produto"
    zfs.language.Shop.Screen_Confirm_Topping = "Confirmar topping"
    zfs.language.Shop.Screen_Confirm_Yes = "SIM"
    zfs.language.Shop.Screen_Confirm_No = "NÃO"
    zfs.language.Shop.Screen_Topping_Select = "Selecione um topping"
    zfs.language.Shop.Screen_Topping_Price = "Preço extra:"
    zfs.language.Shop.Screen_Topping_Add_Restricted = "Este topping pode ser adicionado por"
    zfs.language.Shop.Screen_Topping_Consum_Restricted = "Este topping pode ser consumido por"
    zfs.language.Shop.Screen_Topping_NoRestricted = "Todos"
    zfs.language.Shop.Item_InUse = "Este produto já está em uso!"
    zfs.language.Shop.Item_PurchaseButton = "Comprar agora!"
    zfs.language.Shop.Item_WrongUlx01 = "Este Smoothie só pode ser consumido por "
    zfs.language.Shop.Item_WrongUlx02 = "Você não está no grupo ULX correto para comprar este Smoothie!"
    zfs.language.Shop.Item_WrongJob01 = "Este Smoothie só pode ser consumido por "
    zfs.language.Shop.Item_WrongJob02 = "Você não tem o trabalho correto para usar este Smoothie!"
    zfs.language.Shop.Item_NoMoney = "Você não tem dinheiro suficiente!"
    zfs.language.Benefit.CantAdd_ExtraHealth = "Você já está com a saúde máxima!"
    zfs.language.Benefit.CantAdd_Speedboost = "Você já tem um aumento de velocidade!"
    zfs.language.Benefit.CantAdd_AntiGravity = "Você já tem a habilidade AntiGravidade!"
    zfs.language.Benefit.CantAdd_Ghost = "Você já tem a habilidade Fantasma!"
    zfs.language.Benefit.CantAdd_Drugs = "Você já tem a habilidade Drogas!"
    zfs.language.Benefit.Start = "Sua habilidade $benefit desaparecerá em $benefitime segundos"
    zfs.language.Benefit.End = "Sua habilidade $benefit acabou!"
end
