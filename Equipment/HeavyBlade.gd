extends "res://Equipment/Equipment.gd"

func initiate_equipment():
	var upgrade_suffix: String = "-" if self.get_upgrade_level() == 0 else "+".repeat(self.get_upgrade_level() - 1) if self.get_upgrade_level() > 1 else ""
	
	set_parameters({
		"set_name": "Heavy Blade",
		"set_criteria": ["uncommon", "weapon", "sword", "unwieldy"],
		"set_description": "An unwieldy blade that is so heavy that it cannot be paired with any other equipment. Adds 4 Heavy Blow" + upgrade_suffix+" and 3 Ultra Violence" + upgrade_suffix+" to the draw pile.",
		"set_icon": "res://Equipment/Icons/heavy_blade.png",
		"set_unique": true,
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("UltraViolence", 3, "Attack", get_upgrade_level())
	self.equip_owner.add_dominos_to_deck("HeavyBlow", 4, "Attack", get_upgrade_level())

	var effect =  load("res://Effect/Fury.gd").new()
	if(get_upgrade_level() > 0):
		effect.duration = get_upgrade_level() * 2
		apply_effect(effect, self.equip_owner, get_upgrade_level() * 2)

	.apply_start_of_battle_effect()
