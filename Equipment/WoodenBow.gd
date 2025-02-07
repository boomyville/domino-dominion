extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Wooden Bow",
		"set_criteria": ["common", "weapon", "bow", "ranged"],
		"set_description": "A traditional wooden bow. Adds 6 Shoot to the draw pile.",
		"set_icon": "res://Equipment/Icons/wooden_bow.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("Shoot", 6, "Attack")
	.apply_start_of_battle_effect()
