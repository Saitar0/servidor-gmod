if (not SERVER) then return end
ztm = ztm or {}
ztm.f = ztm.f or {}

// Here are some Hooks you can use for Custom Code

// Called when a player burns trash
hook.Add("ztm_OnTrashBurned", "ztm_OnTrashBurned_Test", function(ply, trashburner, earning, trash)
    /*
    print("ztm_OnTrashBurned")
    print("Player who started the Burning Process: " .. tostring(ply))
    print("Trashburner: " .. tostring(trashburner))
    print("Money: " .. earning)
    print("Trash: " .. trash)
    print("----------------")
    */
end)

// Called when a player blows away a leafpile
hook.Add("ztm_OnLeafpileBlast", "ztm_OnLeafpileBlast_Test", function(ply, leafpile)
    /*
    print("ztm_OnLeafpileBlast")
    print("Player: " .. tostring(ply))
    print("Leafpile: " .. tostring(leafpile))
    print("----------------")
    */
end)

// Called when a player collects trash
hook.Add("ztm_OnTrashCollect", "ztm_OnTrashCollect_Test", function(ply, trash)
    /*
    print("ztm_OnTrashCollect")
    print("Player: " .. tostring(ply))
    print("Trash: " .. trash)
    print("----------------")
    */
end)

// Called when a player sells a recycled trash block
hook.Add("ztm_OnTrashBlockSold", "ztm_OnTrashBlockSold_Test", function(ply, buyermachine, earning)
    /*
    print("ztm_OnTrashBlockSold")
    print("Player: " .. tostring(ply))
    print("Buyermachine: " .. tostring(buyermachine))
    print("Money: " .. earning)
    print("----------------")
    */
end)

// Called when a player makes a recycled trash block
hook.Add("ztm_OnTrashBlockCreation", "ztm_OnTrashBlockCreation_Test", function(ply, recyclemachine, trashblock)
    /*
    print("ztm_OnTrashBlockCreation")
    print("Player: " .. tostring(ply))
    print("Recyclemachine: " .. tostring(recyclemachine))
    print("Trashblock: " ..  tostring(trashblock))
    print("----------------")
    */
end)
