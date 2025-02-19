extends "res://Equipment/Equipment.gd"


func initiate_equipment():

	set_parameters({
		"set_name": "Lucky Leaf",
		"set_criteria": ["rare", "any"],
		"set_description": "A leaf that brings luck to its owner. Prevents death once per battle for the first " + str(turn_value()) + " turns",
		"set_icon": "res://Equipment/Icons/lucky_leaf.png",
		"set_unique": true
		})

func turn_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 3
		2:
			return 5
		_:
			print("Error: Invalid upgrade level")
			return 1

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/AutoRevive.gd").new()
	effect.duration = turn_value()
	apply_effect(effect, self.equip_owner, turn_value())