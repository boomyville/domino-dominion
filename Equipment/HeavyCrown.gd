extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Heavy Crown",
		"set_criteria": ["common", "any", "cursed"],
		"set_description": "A heavy crown that increases your max HP by 4 and max shield by 4",
		"set_icon": "res://Equipment/Icons/heavy_crown.png",
		"set_unique": true,
		"set_cursed": true
		})

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_hp": 4,
		"max_shield": 4,
	}
	return new_stats
