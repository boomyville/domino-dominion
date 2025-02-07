extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Lucky Leaf",
		"set_criteria": ["rare", "any"],
		"set_description": "A leaf that brings luck to its owner. Prevents death once per battle",
		"set_icon": "res://Equipment/Icons/lucky_leaf.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/AutoRevive.gd").new()
	effect.duration = 3
	apply_effect(effect, self.equip_owner)