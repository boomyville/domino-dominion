extends "res://Equipment/Equipment.gd"

func initiate_equipment():

	set_parameters({
		"set_name": "Red Bow-Tie",
		"set_criteria": ["rare", "any"],
		"set_description": "This red bow tie makes a bold statement: its wearer is a master of refinement and a virtuoso of victory. Applies " + str(impair_value()) + " Impair on the enemy at the start of battle.",
		"set_icon": "res://Equipment/Icons/red_bow_tie.png",
		"set_unique": true
		})

func impair_value() -> int:
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
	var effect =  load("res://Effect/Impair.gd").new()
	var target
	effect.triggers = impair_value()
	if(self.equip_owner.battler_type.to_lower() == "enemy"):
		target = "player"
	else:
		target = "enemy"
	Game.get_node("Game").string_to_battler(target).apply_effect(effect)

