extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Short Sword",
		"set_criteria": ["common", "weapon", "sword"],
		"set_description": "A common sword that provides basic combat functionality. Adds 4 Quick Strike to the draw pile.",
		"set_icon": "res://Equipment/Icons/short_sword.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	self.equip_owner.add_dominos_to_deck("QuickStrike", 4, "Attack")
	.apply_start_of_battle_effect()
