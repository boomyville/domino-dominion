extends "res://Equipment/Equipment.gd"

func initiate_equipment():

	set_parameters({
		"set_name": "Peridot Ring",
		"set_criteria": ["uncommon", "any"],
		"set_description": "Adorned with the vibrant green of peridot, this ring channels the gemstone's ancient energies, granting its wearer a radiant aura of vitality. Raises max HP by " + str(hp_value()) + " and increase max hand size by 1",
		"set_icon": "res://Equipment/Icons/peridot_ring.png",
		"set_unique": true
		})


func hp_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 4
		2:
			return 7
		3:
			return 12
		_:
			print("Error: Invalid upgrade level")
			return 2

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_hp": hp_value(),
		"max_hand_size": 1
	}
	return new_stats
