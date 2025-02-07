extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Small Bow",
		"set_criteria": ["common", "weapon", "bow", "ranged"],
		"set_description": "A compact and hard to use bow. Adds 4 Clumsy Shot to the draw pile.",
		"set_icon": "res://Equipment/Icons/small_bow.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("ClumsyShot", 4, "Attack")
	.apply_start_of_battle_effect()
