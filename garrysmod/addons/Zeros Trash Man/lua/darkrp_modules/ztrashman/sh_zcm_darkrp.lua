TEAM_ZTM_TRASHMAN = DarkRP.createJob("Lixeiro", {
    color = Color(225, 75, 75, 255),
    model = {
        "models/kerry/agrp_work/m_work_02.mdl",
        "models/kerry/agrp_work/f_work_02.mdl"
    },
    description = [[Você coleta e gerencia o lixo da cidade. Um trabalho essencial para manter tudo limpo e funcionando!]],
    weapons = {"ztm_trashcollector"},
    command = "trashman",
    max = 2,
    salary = 600,
    admin = 0,
    vote = false,
    category = "Citizens",
    hasLicense = false,
})