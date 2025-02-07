extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Peridot Ring",
		"set_criteria": ["uncommon", "any"],
		"set_description": "Adorned with the vibrant green of peridot, this ring channels the gemstone's ancient energies, granting its wearer a radiant aura of vitality. Raises max HP by 6 and increase max hand size by 1",
		"set_icon": "res://Equipment/Icons/peridot_ring.png",
		"set_unique": true
		})

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_hp": 6,
		"max_hand_size": 1
	}
	return new_stats
