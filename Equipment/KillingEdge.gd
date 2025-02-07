extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Killing Edge",
		"set_criteria": ["uncommon", "weapon", "sword"],
		"set_description": "A deadly blade that dishes out deadly attacks. Adds 4 Quick Strike and 3 Quad Strike to the deck." ,
		"set_icon": "res://Equipment/Icons/killing_edge.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("QuickStrike", 4, "Attack")
	self.equip_owner.add_dominos_to_deck("QuadStrike", 3, "Attack")
	.apply_start_of_battle_effect()
