extends "res://Equipment/Equipment.gd"
func initiate_equipment():
	set_parameters({
		"set_name": "Obscurant Cube",
		"set_criteria": ["special", "rare"],
		"set_description": "A strange cube that causes annihilation with anything it contacts. Applies " + str(double_value()) + " stacks of double damage to self at the start of battle.",
		"set_icon": "res://Equipment/Icons/antimatter.png",
		"set_unique": false,
		})

func double_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 2
		2:
			return 4
		_:
			print("Error: Invalid upgrade level")
			return 1

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/DoubleDamage.gd").new()
	effect.triggers = double_value()
	apply_effect(effect, self.equip_owner, double_value())
