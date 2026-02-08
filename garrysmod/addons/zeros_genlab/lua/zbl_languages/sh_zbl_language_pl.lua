zbl = zbl or {}
zbl.language = zbl.language or {}
zbl.language.General = zbl.language.General or {}
zbl.language.NPC = zbl.language.NPC or {}
zbl.language.Gun = zbl.language.Gun or {}
zbl.language.Quest = zbl.language.Quest or {}

if (zbl.config.SelectedLanguage == "pl") then

    zbl.language.General["Minutes"] = "min"
    zbl.language.General["Seconds"] = "sek"

    zbl.language.General["LabTitle"] = "$PlayerName - Laboratorium genetyczne"
    zbl.language.General["analyzing"] = "analizowanie"
    zbl.language.General["Analyze"] = "Zbadaj"
    zbl.language.General["Sample Count"] = "Liczba próbek"
    zbl.language.General["Sample Variability"] = "Zmienność próbki"
    zbl.language.General["Reasearch Points"] = "Punkty DNA"
    zbl.language.General["NotEnoughSamples"] = "Nie wystarczająca ilość próbek!"

    zbl.language.General["DNA"] = "DNA"
    zbl.language.General["Sample"] = "Próbka"
    zbl.language.General["DNASample"] = "Próbka DNA"
    zbl.language.General["Virus"] = "Wirus"
    zbl.language.General["Abillity"] = "Umiejętność"
    zbl.language.General["Cure"] = "Lekarstwo"
    zbl.language.General["Clean"] = "Wyczyść"

    zbl.language.General["creating"] = "tworzenie"
    zbl.language.General["Create"] = "Stwórz"
    zbl.language.General["Cure_desc"] = "Leczy pacjenta z $VaccineName i czyni go odpornym przez $ImmunityTime."
    zbl.language.General["Ranks"] = "Rangi"
    zbl.language.General["WrongRank"] = "Nie masz odpowiedniej rangi, by to zrobić!"
    zbl.language.General["NotEnoughDNA"] = "Nie masz wystarczającej ilości punktów DNA!"

    zbl.language.General["Wrong Job"] = "Nieodpowiednia praca!"
    zbl.language.General["Wrong Owner"] = "Nie posiadasz tego!"
    zbl.language.General["ReceivedMoney"] = "Otrzymałeś $Money!"
    zbl.language.General["ReceivedDNAPoints"] = "Otrzymałeś $Points punktów DNA!"

    zbl.language.General["AbilityStart"] = "Wzmocnienie zdolności $AbilityName rozpoczęte!"
    zbl.language.General["AbilityStop"] = "Wzmocnienie zdolności $AbilityName zakończone!"

    zbl.language.General["RespiratorUsedUp"] = "Respirator się zużył!"
    zbl.language.General["RespiratorRemainingUses"] = "Liczba pozostałych użyć respiratora $Count"

    zbl.language.General["DuplicatePenalty"] = "Próbka ma podwójną karę!"
    zbl.language.General["CooldownPenalty"] = "Próbka ma karę odnowienia!"

    zbl.language.NPC["Dialog_QuestFailed"] = "Okej, zapomnij o tym."
    zbl.language.NPC["Dialog_FacePunch"] = "PRZESTAŃ!" // When the player clicks on the npcs face :)
    zbl.language.NPC["Dialog_QuestUpdate"] = "Masz jakieś nowe wieści?" // NPC asks player how the quest is going
    zbl.language.NPC["Dialog_QuestProposal"] = "Mam dla ciebie pracę!" // NPC tells the player he got a job for him
    zbl.language.NPC["Dialog_QuestCompleted"] = "Dziękuje!"
    zbl.language.NPC["Dialog_QuestAccept"] = "Wspaniale!"
    zbl.language.NPC["Dialog_QuestDecline"] = "Przykro mi to słyszeć :("
    zbl.language.NPC["Dialog_QuestNotFinished"] = "Nie masz jeszcze wszystkiego :I"  // Tells the player the he dont has everything to complete the Quest yet
    zbl.language.NPC["Dialog_Greeting"] = "Witaj!"

    zbl.language.NPC["Quest_Accept"] = "Akceptuj"
    zbl.language.NPC["Quest_Finish"] = "Zakończ"
    zbl.language.NPC["Quest_Decline"] = "Odrzuć"
    zbl.language.NPC["Quest_Cancel"] = "Anuluj"
    zbl.language.NPC["Quest_ToolTip_Time"] = "Czas misji"
    zbl.language.NPC["Quest_ToolTip_Reward"] = "Nagroda"
    zbl.language.NPC["Quest_Completed"] = "Ukończono misję"
    zbl.language.NPC["Quest_NotAvailable"] = "Brak dostępnych misji"
    zbl.language.NPC["Quest_FlaskCapacity"] = "Wstrzykiwacz nie ma wystarczającej pojemności do tej misji!"
    zbl.language.NPC["Quest_FailedNotify"] = "NIEPOWODZENIE! ZABRAKŁO CI CZASU."

    zbl.language.NPC["SampleInfo_Virus"] = "Pobrano próbkę DNA z kodu genetycznego wirusa."
    zbl.language.NPC["SampleInfo_Other"] = "Pobrano próbkę DNA z $Name."
    zbl.language.NPC["Sell"] = "Sprzedaj"
    zbl.language.NPC["DNA_SellInfo"] = "Próbki DNA nie mogą zostać sprzedane!"
    zbl.language.NPC["DNA_SellNotify"] = "Nie możesz sprzedać próbek DNA!"

    zbl.language.Gun["Empty"] = "Pusta"
    zbl.language.Gun["Help"] = "Pomoc"
    zbl.language.Gun["Inject"] = "Wstrzyknij"
    zbl.language.Gun["Collect"] = "Zbierz"
    zbl.language.Gun["Drop"] = "Wyrzuć"
    zbl.language.Gun["Self Inject"] = "Wstrzyknij w siebie"
    zbl.language.Gun["Delete"] = "Usuń"
    zbl.language.Gun["Switch"] = "Zmień"
    zbl.language.Gun["Scan"] = "Skanuj"
    zbl.language.Gun["Stage"] = "Faza" // Refers to the mutation stage at which the current virus is. Examble = Stage: 2
    zbl.language.Gun["GunEmpty"] = "Wstrzykiwacz jest pusty!"
    zbl.language.Gun["NoVaccine"] = "Wstrzykiwacz nie ma żadnego lekarstwa!"
    zbl.language.Gun["WrongCure"] = "Nieprawidłowe lekarstwo!"
    zbl.language.Gun["PlayerNotInfected"] = "Ten gracz nie jest zainfekowany!"
    zbl.language.Gun["PlayerAlreadyInfected"] = "Ten gracz jest już zainfekowany!"
    zbl.language.Gun["GunIsFull"] = "Wstrzykiwacz jest pełen!"
    zbl.language.Gun["FlaskDropLimit"] = "Osiągnąłeś limit fiolek! Twój limit wynosi: $FlaskCount"

    zbl.language.Gun["FullProtectionCheck"] = "Jesteś już w pełni chroniony."
end
