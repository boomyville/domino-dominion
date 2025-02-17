extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Pure Water",
		"set_criteria": ["common", "consumable", "any"],
		"set_description": "A bottle of water that purifies the soul. Heals 25% of max HP on use",
		"set_icon": "res://Equipment/Icons/pure_water.png",
		"set_unique": false
		})

func item_effect():
	equip_owner.heal(round(equip_owner.get_max_hp() * 0.25))