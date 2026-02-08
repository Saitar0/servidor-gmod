zbl = zbl or {}
zbl.f = zbl.f or {}

zbl.Sounds = {
	["VomitExplosion"] = Sound("physics/flesh/flesh_squishy_impact_hard1.wav"),
	["JarBreak01"] = Sound("physics/glass/glass_bottle_break1.wav"),
	["JarBreak02"] = Sound("physics/glass/glass_bottle_break2.wav"),
	["spore_explo"] = Sound("zbl/zbl_spore_explosion.wav"),
}



sound.Add({
	name = "zbl_lab_scan",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {"npc/scanner/combat_scan_loop6.wav"}
})

sound.Add({
	name = "zbl_lab_move",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 75,
	pitch = {100, 100},
	sound = {"doors/door_metal_thin_move1.wav"}
})

sound.Add({
	name = "zbl_lab_stop",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 75,
	pitch = {100, 100},
	sound = {"doors/door_metal_thin_open1.wav"}
})



sound.Add({
	name = "zbl_scan_action",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 75,
	pitch = {100, 100},
	sound = {"npc/scanner/combat_scan1.wav", "npc/scanner/combat_scan2.wav", "npc/scanner/combat_scan3.wav", "npc/scanner/combat_scan4.wav", "npc/scanner/combat_scan5.wav"}
})

sound.Add({
	name = "zbl_vomit_explode",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/vomit_male/male_boomer_disruptvomit_01.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_03.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_05.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_06.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_07.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_09.wav",
	}
})

sound.Add({
	name = "zbl_mask_off",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/zbl_mask_off.wav",
	}
})


sound.Add({
	name = "zbl_mask_on",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/zbl_mask_on.wav",
	}
})


sound.Add({
	name = "zbl_spray",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/zbl_spray01.wav",
		"zbl/zbl_spray02.wav",
		"zbl/zbl_spray03.wav",
		"zbl/zbl_spray04.wav",
		"zbl/zbl_spray05.wav",
	}
})
sound.Add({
	name = "zbl_cash",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/zbl_cash01.wav",
	}
})


// Generic
sound.Add({
	name = "zbl_ui_click",
	channel = CHAN_STATIC,
	volume = 1,
	level = 60,
	pitch = {100, 100},
	sound = {"UI/buttonclick.wav"}
})

sound.Add({
	name = "zbl_error",
	channel = CHAN_STATIC,
	volume = 0.25,
	level = 60,
	pitch = {100, 100},
	sound = {"common/warning.wav"}
})

sound.Add({
	name = "zbl_succees",
	channel = CHAN_STATIC,
	volume = 0.25,
	level = 60,
	pitch = {100, 100},
	sound = {"common/bugreporter_succeeded.wav"}
})

sound.Add({
	name = "zbl_ouch_male",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"vo/npc/Barney/ba_pain01.wav",
		"vo/npc/Barney/ba_pain02.wav",
		"vo/npc/Barney/ba_pain03.wav",
		"vo/npc/Barney/ba_pain04.wav",
		"vo/npc/Barney/ba_pain05.wav",
		"vo/npc/Barney/ba_pain06.wav",
		"vo/npc/Barney/ba_pain07.wav",
		"vo/npc/Barney/ba_pain08.wav",
		"vo/npc/Barney/ba_pain09.wav",
		"vo/npc/Barney/ba_pain10.wav",

		"vo/npc/male01/ow01.wav",
		"vo/npc/male01/ow02.wav",
		"vo/npc/male01/pain01.wav",
		"vo/npc/male01/pain02.wav",
		"vo/npc/male01/pain03.wav",
		"vo/npc/male01/pain04.wav",
		"vo/npc/male01/pain05.wav",
		"vo/npc/male01/pain06.wav",
		"vo/npc/male01/pain07.wav",
		"vo/npc/male01/pain08.wav",
		"vo/npc/male01/pain09.wav",
	}
})

sound.Add({
	name = "zbl_ouch_female",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"vo/npc/female01/ow01.wav",
		"vo/npc/female01/ow02.wav",
		"vo/npc/female01/pain01.wav",
		"vo/npc/female01/pain02.wav",
		"vo/npc/female01/pain03.wav",
		"vo/npc/female01/pain04.wav",
		"vo/npc/female01/pain05.wav",
		"vo/npc/female01/pain06.wav",
		"vo/npc/female01/pain07.wav",
		"vo/npc/female01/pain08.wav",
		"vo/npc/female01/pain09.wav",
	}
})



sound.Add({
	name = "zbl_gun_inject",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/adrenaline_needle_in.wav",
	}
})

sound.Add({
	name = "zbl_gun_fill",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/adrenaline_needle_open.wav",
	}
})

sound.Add({
	name = "zbl_gun_extract",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"items/ammocrate_open.wav",
	}
})



sound.Add({
	name = "zbl_cough_male",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/cough_male/cough01.wav",
		"zbl/cough_male/cough02.wav",
		"zbl/cough_male/cough03.wav",
		"zbl/cough_male/cough04.wav",
		"zbl/cough_male/cough05.wav",
		"zbl/cough_male/cough06.wav",
		"zbl/cough_male/cough07.wav",
		"zbl/cough_male/cough08.wav",
	}
})

sound.Add({
	name = "zbl_cough_female",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/cough_female/cough01.wav",
		"zbl/cough_female/cough02.wav",
		"zbl/cough_female/cough03.wav",
		"zbl/cough_female/cough04.wav",
		"zbl/cough_female/cough05.wav",
		"zbl/cough_female/cough06.wav",
		"zbl/cough_female/cough07.wav",
	}
})

sound.Add({
	name = "zbl_vomit_female",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/vomit_female/female_boomer_disruptvomit_01.wav",
		"zbl/vomit_female/female_boomer_disruptvomit_03.wav",
		"zbl/vomit_female/female_boomer_disruptvomit_05.wav",
		"zbl/vomit_female/female_boomer_disruptvomit_06.wav",
		"zbl/vomit_female/female_boomer_disruptvomit_07.wav",
		"zbl/vomit_female/female_boomer_disruptvomit_09.wav",
	}
})


sound.Add({
	name = "zbl_vomit_male",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/vomit_male/male_boomer_disruptvomit_01.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_03.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_05.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_06.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_07.wav",
		"zbl/vomit_male/male_boomer_disruptvomit_09.wav",
	}
})



sound.Add({
	name = "zbl_fart",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 75,
	pitch = {100, 100},
	sound = {
		"zbl/fart/zbl_fart01.wav",
		"zbl/fart/zbl_fart02.wav",
	}
})


sound.Add({
	name = "zbl_npc_staph",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"npc/combine_soldier/pain1.wav",
		"npc/combine_soldier/pain2.wav",
		"npc/combine_soldier/pain3.wav",
	}
})

sound.Add({
	name = "zbl_vo_inject",
	channel = CHAN_STATIC,
	volume = 1,
	level = 75,
	pitch = {100, 100},
	sound = {
		"npc/metropolice/vo/inject.wav",
	}
})
