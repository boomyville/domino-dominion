extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Plate Armour",
		"set_criteria": ["uncommon", "any", "physical"],
		"set_description": "Forged from the strongest steel, this plate armor stands as an unyielding bulwark against the ravages of battle. Applies "+str(bulwark_value())+" Bulwark and raises max shields by "+str(bulwark_value()*2)+". Hand size is reduced by 1.",
		"set_icon": "res://Equipment/Icons/plate_armour.png",
		"set_unique": true
		})

func bulwark_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 4
		2:
			return 7
		3:
			return 12
		_:
			print("Error: Invalid upgrade level")
			return 2

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_shield": bulwark_value()*2,
		"max_hand_size": -1,
	}
	return new_stats

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/Bulwark.gd").new()
	effect.duration = bulwark_value()
	apply_effect(effect, self.equip_owner, bulwark_value())

