extends "res://Equipment/Equipment.gd"

func initiate_equipment():
	set_parameters({
		"set_name": "Heavy Crown",
		"set_criteria": ["common", "any", "cursed"],
		"set_description": "A cursed crown that increases your max HP by " + str(hp_value()) + " and max shield by " + str(hp_value()),
		"set_icon": "res://Equipment/Icons/heavy_crown.png",
		"set_unique": true,
		"set_cursed": true
		})

func hp_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 4
		2:
			return 7
		3:
			return 12
		4:
			return 20
		_:
			print("Error: Invalid upgrade level")
			return 2

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_hp": hp_value(),
		"max_shield": hp_value()
	}
	return new_stats
