extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Tainted Choker",
		"set_criteria": ["cursed", "any"],
		"set_description": "A weighty darkness that drags on one's collar",
		"set_icon": "res://Equipment/Icons/tainted_choker.png",
		"set_unique": true,
		"set_cursed": true
		})
