if CLIENT then return end
ztm = ztm or {}
ztm.f = ztm.f or {}


function ztm.f.Entity_OnTakeDamage(ent,dmg)
	ent:TakePhysicsDamage(dmg)
	local damage = dmg:GetDamage()
	local entHealth = ztm.config.Damageable[ent:GetClass()]

	if (entHealth > 0) then
		ent.CurrentHealth = (ent.CurrentHealth or entHealth) - damage

		if (ent.CurrentHealth <= 0) then

			ent:Remove()
		end
	end
end
