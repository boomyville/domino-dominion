extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Ethereal Cape",
		"set_criteria": ["uncommon", "any"],
		"set_description": "This cape weaves the fabric of reality, rendering its wearer impervious to harm. Applies 1 Nullify",
		"set_icon": "res://Equipment/Icons/ethereal_cape.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/Nullify.gd").new()
	effect.triggers = 1
	apply_effect(effect, self.equip_owner)
