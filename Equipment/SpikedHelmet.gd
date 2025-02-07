extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Spiked Helmet",
		"set_criteria": ["innate", "weapon"],
		"set_description": "A uncomfortable helmet with a big spike on it. Adds 5 Headbonk to the draw pile",
		"set_icon": "res://Equipment/Icons/spiked_helmet.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("Headbonk", 5, "Attack")

	.apply_start_of_battle_effect()
