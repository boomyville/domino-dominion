extends "res://Equipment/Equipment.gd"

func _init():
	._init()

	set_parameters({
		"set_name": "Kite Shield",
		"set_criteria": ["uncommon", "any"],
		"set_description": "This shield's ingenious design allows it to harness the kinetic energy of battle and channel it into an impenetrable shield of protection. Raise Max Shield by 10 and apply 10 Shields at the start of battle.",
		"set_icon": "res://Equipment/Icons/kite_shield.png",
		"set_unique": true
		})

func alter_stats() -> Dictionary:
	var new_stats = {
		"max_shield": 10,
	}
	return new_stats

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	self.equip_owner.add_shields(10)
