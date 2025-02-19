extends "res://Equipment/Equipment.gd"

func initiate_equipment():

	set_parameters({
		"set_name": "Pure Water",
		"set_criteria": ["common", "consumable", "any"],
		"set_description": "A bottle of water that purifies the soul. Heals "+str(hp_percentage_value()) + "% of max HP on use",
		"set_icon": "res://Equipment/Icons/pure_water.png",
		"set_unique": false
		})

func hp_percentage_value() -> int:
	match get_upgrade_level():
		0:
			return 15
		1:
			return 25
		2:
			return 35
		3:
			return 50
		4:
			return 100
		_:
			print("Error: Invalid upgrade level")
			return 15

func item_effect():
	equip_owner.heal(round(equip_owner.get_max_hp() * hp_percentage_value() * 0.01))