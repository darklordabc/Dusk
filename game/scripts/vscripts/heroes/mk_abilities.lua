function ManaSealRemoveMana(keys)
	local caster = keys.caster
	local target = keys.target
	local mana = target:GetMaxMana()
	local mana_removal = keys.mana_removal/100
	local mana_damage = mana*mana_removal*0.1
	local damage = keys.damage

	if target:IsMagicImmune() then return end

	if not target:HasModifier("modifier_mana_seal_ignore_unit") and target:GetMana() < mana_damage then
		target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=0.5}) --[[Returns:void
		No Description Set
		]]
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_mana_seal_slow", {Duration=3}) --[[Returns:void
		No Description Set
		]]
		keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_mana_seal_ignore_unit", {Duration=10}) --[[Returns:void
		No Description Set
		]]
		ParticleManager:CreateParticle("particles/econ/items/silencer/silencer_ti6/silencer_last_word_dmg_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
		Creates a new particle effect
		]]
		target:EmitSound("Hero_Silencer.LastWord.Damage") --[[Returns:void
		 
		]]

		DealDamage(target,caster,damage,DAMAGE_TYPE_MAGICAL)
	end

	target:ReduceMana(mana_damage)

end

function infusionBoltFire(keys)
	local caster = keys.caster
	local target = keys.target

	local mana = caster:GetMana()
	local amount = 0.20
	local use = mana*amount

	caster:EmitSound("Hero_ChaosKnight.ChaosBolt.Cast")

	caster:SpendMana(use, keys.ability) --[[Returns:void
	Spend mana from this unit, this can be used for spending mana from abilities or item usage.
	]]

	caster.infusion_bolt_mana_used = use
end

function infusionBolt(keys)
	local caster = keys.caster
	local target = keys.target or keys.unit

	local damage = keys.damage/100

	local amount = math.ceil((target:GetMaxMana()-target:GetMana()) * damage)

	if amount < 50 then amount = 50 end

	DealDamage(target,caster,amount,DAMAGE_TYPE_MAGICAL)

	PopupSpecDamage(target,amount)

	target:RemoveModifierByName("modifier_tek_microarray_charge")

	target:EmitSound("Hero_ChaosKnight.ChaosBolt.Impact")

	target:AddNewModifier(caster, nil, "modifier_stunned", {Duration=2}) --[[Returns:void
	No Description Set
	]]
end

function ArcanumBreak(keys)
	local caster = keys.caster
	local target = keys.target
	local mana_removal = keys.mana_removal

	if CheckClass(target,"npc_dota_building") then return end
	if caster:PassivesDisabled() then return end

	if mana_removal > target:GetMana() then mana_removal = target:GetMana() end

	target:ReduceMana(mana_removal) --[[Returns:void
	Remove mana from this unit, this can be used for involuntary mana loss, not for mana that is spent.
	]]

	caster:GiveMana(mana_removal/2) --[[Returns:void
	Give mana to this unit, this can be used for mana gained by abilities or item usage.
	]]

	--DealDamage(target,caster,mana_removal/2,DAMAGE_TYPE_PHYSICAL)

	ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) --[[Returns:int
	Creates a new particle effect
	]]
end

function VorpalAssault(keys)
	local caster = keys.caster

	local amount = keys.amount

	local mod = keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_vorpal_assault", {Duration=60}) --[[Returns:void
	No Description Set
	]]
	mod:SetStackCount(amount)
	local mod2 = keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_vorpal_assault_attackspeed", {Duration=60}) --[[Returns:void
	No Description Set
	]]
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_vorpal_assault_prehit", {Duration=60})

end

function VorpalAssaultStrike(keys)
	local caster = keys.attacker
	local target = keys.target or keys.unit

	if CheckClass(target,"npc_dota_building") then return end

	local mod = caster:FindModifierByName("modifier_vorpal_assault")
	local mod_aspd = caster:FindModifierByName("modifier_vorpal_assault_attackspeed")
	local mod_hits = caster:FindModifierByName("modifier_vorpal_assault_prehit")
	local mod_strike = caster:FindModifierByName("modifier_vorpal_assault_onhit")

	local mana = target:GetMana()
	local max_mana = target:GetMaxMana()
	local difference = max_mana - mana

	local bonus_damage = keys.damage
	local mana_damage = keys.mana_damage

	bonus_damage = bonus_damage*difference

	target:ReduceMana(mana_damage) --[[Returns:void
	Remove mana from this unit, this can be used for involuntary mana loss, not for mana that is spent.
	]]

	DealDamage(target,caster,bonus_damage,DAMAGE_TYPE_MAGICAL)

	Timers:CreateTimer(0.25,function() target:EmitSound("Hero_razor.lightning") end)

	if mod == nil then return end

	mod:SetStackCount(mod:GetStackCount()-1)

	if mod:GetStackCount() <= 0 then
		mod:Destroy()
		mod_aspd:Destroy()
		mod_hits:Destroy()
		mod_strike:Destroy()
	end
end