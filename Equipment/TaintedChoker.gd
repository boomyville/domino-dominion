extends "res://Equipment/Equipment.gd"


func initiate_equipment():

	set_parameters({
		"set_name": "Tainted Choker",
		"set_criteria": ["rare", "cursed", "any"],
		"set_description": "A weighty darkness that drags on one's collar. Reduces max HP by " + str(hp_value()),
		"set_icon": "res://Equipment/Icons/tainted_choker.png",
		"set_unique": true,
		"set_cursed": true
		})

func hp_value() -> int:
	match get_upgrade_level():
		0:
			return 12
		1:
			return 8
		2:
			return 4
		_:
			print("Error: Invalid upgrade level")
			return 12

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_hp": -hp_value()
	}
	return new_stats