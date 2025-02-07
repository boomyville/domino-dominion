extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Plate Armour",
		"set_criteria": ["uncommon", "any", "physical"],
		"set_description": "Forged from the strongest steel, this plate armor stands as an unyielding bulwark against the ravages of battle. Applies 4 Bulwark and raises max shields by 20. Hand size is reduced by 1.",
		"set_icon": "res://Equipment/Icons/plate_armour.png",
		"set_unique": true
		})

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_shield": 20,
		"max_hand_size": -1,
	}
	return new_stats

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/Bulwark.gd").new()
	effect.duration = 4
	apply_effect(effect, self.equip_owner)

