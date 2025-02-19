extends "res://Equipment/Equipment.gd"


func initiate_equipment():
	set_parameters({
		"set_name": "Ethereal Cape",
		"set_criteria": ["rare", "any"],
		"set_description": "This cape weaves the fabric of reality, rendering its wearer impervious to harm. Applies " + str(nullify_value()) + " Nullify",
		"set_icon": "res://Equipment/Icons/ethereal_cape.png",
		"set_unique": true
		})

func nullify_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 2
		2:
			return 3
		_:
			print("Error: Invalid upgrade level")
			return 1

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/Nullify.gd").new()
	effect.triggers = nullify_value()
	apply_effect(effect, self.equip_owner)
