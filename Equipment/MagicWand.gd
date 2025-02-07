extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Short Spear",
		"set_criteria": ["common", "weapon", "wand"],
		"set_description": "A simple wand bestowed with ancient magic. Adds 4 Impulse to the draw pile.",
		"set_icon": "res://Equipment/Icons/magic_wand.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("Impulse", 4, "Attack")
	.apply_start_of_battle_effect()
