if CLIENT then return end

// Here are some Hooks you can use for Custom Code
// If you need any more hooks just open a ticket or write me on steam

// Called when a player gets infected
hook.Add("zbl_OnPlayerInfect", "zbl_OnPlayerInfect_Test", function(ply, vaccine_id)
    /*
    print("zbl_OnPlayerInfect")
    print("Player: " .. tostring(ply))
    print("VaccineID: " .. vaccine_id)
    print("-----------------------------")
    */
end)

// Called when a player injects another player
hook.Add("zbl_OnPlayerInject", "zbl_OnPlayerInject_Test", function(target, vaccine_id, inflictor)
    /*
    print("zbl_OnPlayerInject")
    print("Target: " .. tostring(target))
    print("Inflictor: " .. tostring(inflictor))
    print("VaccineID: " .. vaccine_id)
    print("-----------------------------")
    */
end)


// Called when a player cures another player
hook.Add("zbl_OnPlayerCurePlayer", "zbl_OnPlayerCurePlayer_Test", function(target, vaccine_id, inflictor)
    /*
    print("zbl_OnPlayerInject")
    print("Target: " .. tostring(target))
    print("Inflictor: " .. tostring(inflictor))
    print("VaccineID: " .. vaccine_id)
    print("-----------------------------")
    */
end)

// Called when a player gets a sample from a other player or entity
hook.Add("zbl_OnPlayerGetSample", "zbl_OnPlayerGetSample_Test", function(target, inflictor, sample_name, sample_identifier, sample_points)
    /*
    print("zbl_OnPlayerGetSample")
    print("Target: " .. tostring(target))
    print("Inflictor: " .. tostring(inflictor))
    print("Sample_name: " .. sample_name)
    print("Sample_identifier: " .. sample_identifier)
    print("Sample_points: " .. sample_points)
    print("-----------------------------")
    */
end)

// Called when a player gets cured
hook.Add("zbl_OnPlayerCured", "zbl_OnPlayerCured_Test", function(ply, vaccine_id)
    /*
    print("zbl_OnPlayerCured")
    print("Player: " .. tostring(ply))
    print("VaccineID: " .. vaccine_id)
    print("-----------------------------")
    */
end)
