extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Red Bow-Tie",
		"set_criteria": ["common", "any"],
		"set_description": "This red bow tie makes a bold statement: its wearer is a master of refinement and a virtuoso of victory. Applies 1 Impair on the enemy at the start of battle.",
		"set_icon": "res://Equipment/Icons/red_bow_tie.png",
		"set_unique": true
		})

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/Impair.gd").new()
	var target
	effect.triggers = 1
	if(self.equip_owner.battler_type.to_lower() == "enemy"):
		target = "player"
	else:
		target = "enemy"
	Game.get_node("Game").string_to_battler(target).apply_effect(effect)

