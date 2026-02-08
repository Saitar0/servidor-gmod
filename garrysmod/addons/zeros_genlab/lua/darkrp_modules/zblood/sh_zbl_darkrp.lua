TEAM_ZBL_RESEARCHER = DarkRP.createJob("Pesquisador genético", {
    color = Color(255,179,0,255),
    model = {"models/zerochain/props_bloodlab/zbl_hazmat.mdl"},
    description = [[Você pesquisa vírus, aumentos de habilidade e curas.]],
    weapons = {"zbl_gun"},
    command = "zbl_researcher",
    max = 2,
    salary = 25,
    admin = 0,
    vote = false,
    category = "Citizens",
    hasLicense = false,
})

DarkRP.createCategory{
    name = "Pesquisador de Vírus",
    categorises = "entities",
    startExpanded = true,
    color = Color(65, 65,65, 255),
    canSee = function(ply) return true end,
    sortOrder = 104
}

DarkRP.createEntity("Laboratório", {
    ent = "zbl_lab",
    model = "models/zerochain/props_bloodlab/zbl_lab.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzbl_lab",
    allowed = {TEAM_ZBL_RESEARCHER},
    category = "Pesquisador de Vírus",
})

DarkRP.createEntity("Respirador", {
    ent = "zbl_gasmask",
    model = "models/zerochain/props_bloodlab/zbl_maskbox.mdl",
    price = 5000,
    max = 1,
    cmd = "buyzbl_gasmask",
})

DarkRP.createShipment("Spray desinfetante", {
    model = "models/zerochain/props_bloodlab/zbl_w_spray.mdl",
    entity = "zbl_spray",
    price = 5000,
    amount = 3,
    separate = false
})
