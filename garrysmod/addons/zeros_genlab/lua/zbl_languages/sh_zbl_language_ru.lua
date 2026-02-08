zbl = zbl or {}
zbl.language = zbl.language or {}
zbl.language.General = zbl.language.General or {}
zbl.language.NPC = zbl.language.NPC or {}
zbl.language.Gun = zbl.language.Gun or {}
zbl.language.Quest = zbl.language.Quest or {}

if (zbl.config.SelectedLanguage == "ru") then

    zbl.language.General["Minutes"] = "min"
    zbl.language.General["Seconds"] = "sec"

    zbl.language.General["LabTitle"] = "$PlayerName - Geneticheskaya laboratoriya"
    zbl.language.General["analyzing"] = "analiziruyushchaya"
    zbl.language.General["Analyze"] = "Analizirovat"
    zbl.language.General["Sample Count"] = "Kolichestvo obraztsov"
    zbl.language.General["Sample Variability"] = "Izmenchivost' obraztsa"
    zbl.language.General["Reasearch Points"] = "Tochki DNK"
    zbl.language.General["NotEnoughSamples"] = "Nedostatochno obraztsov!"

    zbl.language.General["DNA"] = "DNK"
    zbl.language.General["Sample"] = "Obrazets"
    zbl.language.General["DNASample"] = "DNK Obrazets"
    zbl.language.General["Virus"] = "Virus"
    zbl.language.General["Abillity"] = "Sposobnost"
    zbl.language.General["Cure"] = "Izlecheniye"
    zbl.language.General["Clean"] = "Chistyy"

    zbl.language.General["creating"] = "sozdat"
    zbl.language.General["Create"] = "Sozdayte"
    zbl.language.General["Cure_desc"] = "Istselyayet patsiyenta ot $VaccineName i delayet yego nevospriimchivym k $ImmunityTime."
    zbl.language.General["Ranks"] = "Zvaniya"
    zbl.language.General["WrongRank"] = "U vas net pravil'nogo ranga dlya etogo!"
    zbl.language.General["NotEnoughDNA"] = "Vam ne khvatayet ochkov DNK!"

    zbl.language.General["Wrong Job"] = "Nepravil'naya rabota!"
    zbl.language.General["Wrong Owner"] = "Vy ne vladeyete etim!"
    zbl.language.General["ReceivedMoney"] = "Vy poluchili $Money!"
    zbl.language.General["ReceivedDNAPoints"] = "Vy poluchili $Points ochkov DNK!"

    zbl.language.General["AbilityStart"] = "Nachalos' povysheniye sposobnosti $AbilityName!"
    zbl.language.General["AbilityStop"] = "Navyk povysheniya navyka $AbilityName ostanovlen!"

    zbl.language.General["RespiratorUsedUp"] = "Respirator privyk!"
    zbl.language.General["RespiratorRemainingUses"] = "Ostal'nyye respirator ispol'zuyet $Count"

    zbl.language.General["DuplicatePenalty"] = "Obrazets imeyet dublikat shtrafa!"
    zbl.language.General["CooldownPenalty"] = "Obrazets imeyet vremya vosstanovleniya!"

    zbl.language.NPC["Dialog_QuestFailed"] = "Khorosho, zabud' eto."
    zbl.language.NPC["Dialog_FacePunch"] = "STAHP!" // When the player clicks on the npcs face :)
    zbl.language.NPC["Dialog_QuestUpdate"] = "U vas yest' novosti?" // NPC asks player how the quest is going
    zbl.language.NPC["Dialog_QuestProposal"] = "U menya yest' rabota dlya tebya!" // NPC tells the player he got a job for him
    zbl.language.NPC["Dialog_QuestCompleted"] = "Spasibo!"
    zbl.language.NPC["Dialog_QuestAccept"] = "Potryasayushchiye!"
    zbl.language.NPC["Dialog_QuestDecline"] = "Grustno slyshat' :("
    zbl.language.NPC["Dialog_QuestNotFinished"] = "U tebya yeshche net vsego :I"  // Tells the player the he dont has everything to complete the Quest yet
    zbl.language.NPC["Dialog_Greeting"] = "Dobro pozhalovat!"

    zbl.language.NPC["Quest_Accept"] = "Prinimat"
    zbl.language.NPC["Quest_Finish"] = "Finish"
    zbl.language.NPC["Quest_Decline"] = "Snizheniye"
    zbl.language.NPC["Quest_Cancel"] = "Otmenit"
    zbl.language.NPC["Quest_ToolTip_Time"] = "Vremya kvesta"
    zbl.language.NPC["Quest_ToolTip_Reward"] = "Voznagrazhdeniye za kvest"
    zbl.language.NPC["Quest_Completed"] = "Zadaniye vypolneno"
    zbl.language.NPC["Quest_NotAvailable"] = "Kvest nedostupen"
    zbl.language.NPC["Quest_FlaskCapacity"] = "U vashego pistoleta nedostatochno mesta dlya etoy missii!"
    zbl.language.NPC["Quest_FailedNotify"] = "Zadaniye ne vypolneno !, U vas malo vremeni."

    zbl.language.NPC["SampleInfo_Virus"] = "Obrazets DNK, sobrannyy iz virusnogo uzla."
    zbl.language.NPC["SampleInfo_Other"] = "Obrazets DNK, sobrannyy v $Name."
    zbl.language.NPC["Sell"] = "prodam"
    zbl.language.NPC["DNA_SellInfo"] = "Obraztsy DNK ne mogut byt' prodany"
    zbl.language.NPC["DNA_SellNotify"] = "Vy ne mozhete prodavat' obraztsy DNK!"

    zbl.language.Gun["Empty"] = "Pustoy"
    zbl.language.Gun["Help"] = "Pomogite"
    zbl.language.Gun["Inject"] = "Vvesti"
    zbl.language.Gun["Collect"] = "Collect"
    zbl.language.Gun["Drop"] = "Uronit"
    zbl.language.Gun["Self Inject"] = "Samostoyatel'naya in yektsiya"
    zbl.language.Gun["Delete"] = "udalyat"
    zbl.language.Gun["Switch"] = "pereklyuchatel"
    zbl.language.Gun["Scan"] = "skanirovaniye"
    zbl.language.Gun["Stage"] = "faza" // Refers to the mutation stage at which the current virus is. Examble = Stage: 2
    zbl.language.Gun["GunEmpty"] = "Pistolet inzhektora pust!"
    zbl.language.Gun["NoVaccine"] = "U inzhektornogo pistoleta net vaktsiny / lekarstva!"
    zbl.language.Gun["WrongCure"] = "Nepravil'noye lecheniye!!"
    zbl.language.Gun["PlayerNotInfected"] = "Igrok ne zarazhen!"
    zbl.language.Gun["PlayerAlreadyInfected"] = "Igrok uzhe zarazhen!"
    zbl.language.Gun["GunIsFull"] = "Pistolet inzhektora polon!"
    zbl.language.Gun["FlaskDropLimit"] = "Vy dostigli svoyego predela kapel'nykh kolb! Limit: $FlaskCount"

    zbl.language.Gun["FullProtectionCheck"] = "Vy uzhe polnost'yu zashchishcheny."
end
