AddCSLuaFile()

game.AddParticles("particles/zbl_effects.pcf")
PrecacheParticleSystem("zbl_cough_infect")

PrecacheParticleSystem("zbl_vomit_explosion")
PrecacheParticleSystem("zbl_vomit_trail")

PrecacheParticleSystem("zbl_diaria_explosion")
PrecacheParticleSystem("zbl_diaria_spot")

PrecacheParticleSystem("zbl_explode_head")

PrecacheParticleSystem("zbl_infect_sporecloud")

PrecacheParticleSystem("zbl_disinfect")

PrecacheParticleSystem("zbl_infect_nodeexplode")

PrecacheParticleSystem("zbl_jar_explode_blue")
PrecacheParticleSystem("zbl_jar_explode_green")
PrecacheParticleSystem("zbl_jar_explode_yellow")
PrecacheParticleSystem("zbl_jar_explode_blood")
PrecacheParticleSystem("zbl_scan")
PrecacheParticleSystem("zbl_scan_small")

PrecacheParticleSystem("zbl_scan_effect01")
PrecacheParticleSystem("zbl_scan_effect02")


util.PrecacheModel("models/zerochain/props_bloodlab/zbl_n95mask_worn.mdl")


for k,v in pairs(zbl.config.Respirator.styles) do
    util.PrecacheModel(v.model)
end
