extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Needle",
		"set_criteria": ["common", "any"],
		"set_description": "A sharp needle that hurts opponents as they approach. Apply 2 Spikes",
		"set_icon": "res://Equipment/Icons/needle.png",
		"set_unique": false
		})

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/Spikes.gd").new()
	effect.triggers = 2
	apply_effect(effect, self.equip_owner)
