extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Obscurant Cube",
		"set_criteria": ["special"],
		"set_description": "A strange cube that causes annihilation with anything it contacts. Applies double damage to self at the start of battle.",
		"set_icon": "res://Equipment/Icons/antimatter.png",
		"set_unique": false,
		})

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/DoubleDamage.gd").new()
	effect.triggers = 1
	apply_effect(effect, self.equip_owner)
