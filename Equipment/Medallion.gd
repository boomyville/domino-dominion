extends "res://Equipment/Equipment.gd"


func initiate_equipment():

	set_parameters({
		"set_name": "Medallion",
		"set_criteria": ["rare", "any"],
		"set_icon": "res://Equipment/Icons/medallion.png",
		"set_unique": true
		})

	match get_upgrade_level():
		0:
			set_description("A simple medallion that does nothing.")
		1:
			set_description("A simple medallion that grants immunity to Impair.")
		2:
			set_description("A simple medallion that grants immunity to Impair and Vulnerable.")
		_:
			print("Error: Invalid upgrade level")
			set_description("A simple medallion that does nothing.")

func new_immunity():
	match get_upgrade_level():
		0:
			return []
		1:
			return ["Impair"]
		2:
			return ["Impair", "Vulnerable"]
		_:
			print("Error: Invalid upgrade level") 
			return ["Impair"]
