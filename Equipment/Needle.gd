extends "res://Equipment/Equipment.gd"

func initiate_equipment():

	set_parameters({
		"set_name": "Needle",
		"set_criteria": ["common", "any"],
		"set_description": "A sharp needle that hurts opponents as they approach. Apply "+str(spike_value()) + " Spikes",
		"set_icon": "res://Equipment/Icons/needle.png",
		"set_unique": false
		})

func spike_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 2
		2:
			return 4
		3:
			return 7
		4:
			return 12
		_:
			print("Error: Invalid upgrade level")
			return 1

func apply_start_of_battle_effect():
	.apply_start_of_battle_effect()
	var effect =  load("res://Effect/Spikes.gd").new()
	effect.triggers = spike_value()
	apply_effect(effect, self.equip_owner, spike_value())
