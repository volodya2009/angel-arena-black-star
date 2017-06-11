item_battlefury_baseclass = {}
LinkLuaModifier("modifier_item_battlefury_arena", "items/item_battlefury.lua", LUA_MODIFIER_MOTION_NONE)

function item_battlefury_baseclass:GetIntrinsicModifierName()
	return "modifier_item_battlefury_arena"
end

function item_battlefury_baseclass:CastFilterResultTarget(hTarget)
	return (hTarget:GetClassname() == "ent_dota_tree" or hTarget:IsCustomWard()) and UF_SUCCESS or UF_FAIL_CUSTOM
end

function item_battlefury_baseclass:GetCustomCastErrorTarget(hTarget)
	return (hTarget:GetClassname() == "ent_dota_tree" or hTarget:IsCustomWard()) and "" or "dota_hud_error_cant_cast_on_non_tree_ward"
end

if IsServer() then
	function item_battlefury_baseclass:OnSpellStart()
		self:GetCursorTarget():CutTreeOrWard(self:GetCaster(), self)
	end
end

item_quelling_fury = class(item_battlefury_baseclass)
item_quelling_fury.cleave_pfx = "particles/items_fx/battlefury_cleave.vpcf"
item_battlefury_arena = class(item_battlefury_baseclass)
item_battlefury_arena.cleave_pfx = "particles/items_fx/battlefury_cleave.vpcf"


modifier_item_battlefury_arena = class({})

function modifier_item_battlefury_arena:IsHidden() return true end
function modifier_item_battlefury_arena:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_item_battlefury_arena:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_battlefury_arena:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_battlefury_arena:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_battlefury_arena:GetModifierPercentageManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen_pct")
end

if IsServer() then
	function modifier_item_battlefury_arena:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker == self:GetParent() --[[and not attacker:IsMuted()]] then
			local ability = self:GetAbility()
			local target = keys.target
			if target:IsRealCreep() then
				ApplyDamage({
					attacker = attacker,
					victim = target,
					damage = keys.damage * (ability:GetSpecialValueFor("quelling_bonus_damage_pct") * 0.01 - 1),
					damage_type = DAMAGE_TYPE_PURE,
					damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
					ability = ability
				})
			end
			if not attacker:IsRangedUnit() then
				DoCleaveAttack(attacker, target, ability, keys.damage * ability:GetSpecialValueFor("cleave_damage_percent") * 0.01, ability:GetSpecialValueFor("cleave_distance"), ability:GetSpecialValueFor("cleave_starting_width"), ability:GetSpecialValueFor("cleave_ending_width"), self:GetAbility().cleave_pfx)
			end
		end
	end
end
