zcm = zcm or {}
zcm.f = zcm.f or {}


zcm.sounds = zcm.sounds or {}

// This packs the requested sound Data
function zcm.f.CatchSound(id)
    local soundData = {}
    local soundTable = zcm.sounds[id]
    soundData.sound = soundTable.paths[math.random(#soundTable.paths)]
    soundData.lvl = soundTable.lvl
    soundData.pitch = math.Rand(soundTable.pitchMin, soundTable.pitchMax)
    soundData.volume = GetConVar("zcm_cl_sfx_volume"):GetFloat() or 1

    return soundData
end

zcm.sounds["zcm_sell"] = {
    paths = {"zcm/zcm_cash01.wav"},
    lvl = SNDLVL_75dB,
    pitchMin = 100,
    pitchMax = 100
}


sound.Add({
    name = "zcm_sell",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_cash01.wav"}
})


sound.Add({
    name = "zcm_paperroller",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_paperroller.wav"}
})

sound.Add({
    name = "zcm_box_close",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_boxclose.wav"}
})

sound.Add({
    name = "zcm_rollmover",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_rollmover.wav"}
})

sound.Add({
    name = "zcm_cutter",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_cutter.wav"}
})

sound.Add({
    name = "zcm_rollrelease",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_rollrelease.wav"}
})

sound.Add({
    name = "zcm_rollpacker",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_rollpacker.wav"}
})

sound.Add({
    name = "zcm_binder",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_binder.wav"}
})

sound.Add({
    name = "zcm_powderfiller",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_powderfiller.wav"}
})

sound.Add({
    name = "zcm_fuse",
    channel = CHAN_STATIC,
    volume = 1,
    level = SNDLVL_75dB,
    pitch = {100, 100},
    sound = {"zcm/zcm_fuse.wav"}
})
