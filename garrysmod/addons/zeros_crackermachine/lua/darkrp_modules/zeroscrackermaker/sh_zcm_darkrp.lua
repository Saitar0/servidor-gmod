
TEAM_ZCM_FIREWORKMAKER = DarkRP.createJob("Fabricante de Fogos de Artifício", {
    color = Color(225, 75, 75, 255),
    model = {"models/player/group03/male_04.mdl"},
    description = [[Você está fabricando fogos de artifício ilegais!]],
    weapons = {},
    command = "zcm_illegalfireworkmaker",
    max = 2,
    salary = 0,
    admin = 0,
    vote = false,
    category = "Criminals",
    hasLicense = false
})

DarkRP.createCategory{
    name = "Fogos de Artifício",
    categorises = "entities",
    startExpanded = true,
    color = Color(255, 107, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 104
}

DarkRP.createEntity("Fabricante de Fogos", {
    ent = "zcm_crackermachine",
    model = "models/zerochain/props_crackermaker/zcm_base.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzcm_crackermachine",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Fogos de Artifício"
})

DarkRP.createEntity("Pólvora", {
    ent = "zcm_blackpowder",
    model = "models/zerochain/props_crackermaker/zcm_blackpowder.mdl",
    price = 1000,
    max = 3,
    cmd = "buyzcm_blackpowder",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Fogos de Artifício"
})

DarkRP.createEntity("Papel", {
    ent = "zcm_paperroll",
    model = "models/zerochain/props_crackermaker/zcm_paper.mdl",
    price = 1000,
    max = 3,
    cmd = "buyzcm_paperroll",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Fogos de Artifício"
})

DarkRP.createEntity("Caixa", {
    ent = "zcm_box",
    model = "models/zerochain/props_crackermaker/zcm_box.mdl",
    price = 100,
    max = 3,
    cmd = "buyzcm_box",
    allowed = {TEAM_ZCM_FIREWORKMAKER},
    category = "Fogos de Artifício"
})
