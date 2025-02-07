extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Medallion",
		"set_criteria": ["uncommon", "any"],
		"set_description": "Emblazoned with symbols of honour and distinction, this medallion serves as a beacon of excellence. Provides immunity to the Impair status.",
		"set_icon": "res://Equipment/Icons/medallion.png",
		"set_unique": true
		})

func new_immunity():
	return ["Impair"]
