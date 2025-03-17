extends "res://Equipment/Equipment.gd"

func initiate_equipment():
	set_parameters({
		"set_name": "Bandage",
		"set_criteria": ["common", "any"],
		"set_description": "Binds wounds and provides relief from injuries. Heal " + str(heal_value()) + " HP at the start of battle if HP is " + str(50 + (get_upgrade_level() - 1) * 10)+"% or less",
		"set_icon": "res://Equipment/Icons/bandage.png"
		})

func heal_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 2
		2:
			return 3
		3:
			return 4
		4:
			return 5
		_:
			print("Error: Invalid upgrade level")
			return 1

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	if(equip_owner.hp < equip_owner.get_max_hp() * (50 + (get_upgrade_level() - 1) * 10)):
		equip_owner.heal(heal_value())
