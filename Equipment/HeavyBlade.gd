extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Heavy Blade",
		"set_criteria": ["uncommon", "weapon", "sword", "unwieldy"],
		"set_description": "An unwieldy blade that is so heavy that it cannot be paired with any other equipment. Adds 4 Heavy Blow and 3 Ultra Violence to the draw pile.",
		"set_icon": "res://Equipment/Icons/heavy_blade.png",
		"set_unique": true,
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("UltraViolence", 3, "Attack")
	self.equip_owner.add_dominos_to_deck("HeavyBlow", 4, "Attack")
	
	var effect =  load("res://Effect/Fury.gd").new()
	effect.duration = 4
	apply_effect(effect, self.equip_owner)

	.apply_start_of_battle_effect()
