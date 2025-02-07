extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Irmy Horn",
		"set_criteria": ["irmy", "weapon", "innate"],
		"set_description": "This wicked horn adorns the forehead of Irmy and is plenty sharp despite its looks.",
		"set_icon": "res://Equipment/Icons/irmy_horn.png",
		"set_unique": true,
		"set_cursed": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("HornAttack", 8, "Attack")
	.apply_start_of_battle_effect()
