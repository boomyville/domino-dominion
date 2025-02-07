extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Short Spear",
		"set_criteria": ["common", "weapon", "spear"],
		"set_description": "A short spear designed for close quarters combat. Adds 4 Lunge to the draw pile.",
		"set_icon": "res://Equipment/Icons/short_spear.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("Lunge", 4, "Attack")
	.apply_start_of_battle_effect()
