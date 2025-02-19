extends "res://Equipment/Equipment.gd"

func initiate_equipment():
	set_parameters({
		"set_name": "Kite Shield",
		"set_criteria": ["uncommon", "any"],
		"set_description": "This shield's ingenious design allows it to harness the kinetic energy of battle and channel it into an impenetrable shield of protection. Raise Max Shield by " + str(shield_value()) + " and apply " + str(shield_value()) + " Shields at the start of battle.",
		"set_icon": "res://Equipment/Icons/kite_shield.png",
		"set_unique": true
		})

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 6
		1:
			return 9
		2:
			return 12
		3:
			return 18
		_:
			print("Error: Invalid upgrade level")
			return 6

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_shield": shield_value(),
	}
	return new_stats

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	self.equip_owner.add_shields(shield_value())
