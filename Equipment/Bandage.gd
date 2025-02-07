extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Bandage",
		"set_criteria": ["common", "any"],
		"set_description": "Binds wounds and provides relief from injuries. Heal 2HP at the start of battle if HP is 50% or less",
		"set_icon": "res://Equipment/Icons/bandage.png"
		})

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	if(equip_owner.hp < equip_owner.get_max_hp() * 0.5):
		equip_owner.heal(2)
