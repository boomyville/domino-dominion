extends DominoContainer

# Thorn Armour
# Gain spikes
# Downgrade - Less Spikes
# Upgrade+ - More Spikes
# Upgrade++ - More Spikes

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, null, "static"] }
	domino_name = "Thorn Armour"
	criteria = ["uncommon", "any"]
	initiate_domino()

func description() -> String:
	return "Self: " + str(spikes_value()) + BBCode.bb_code_spikes()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(spikes_value()) + BBCode.bb_code_spikes() + " spikes\n"
	msg += "Spikes deal damage to physical attackers"
	return msg

func spikes_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 3
		2:
			return 5
		3:
			return 7
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):
	.effect(origin, target)
	var effect =  load("res://Effect/Spikes.gd").new()
	effect.triggers = spikes_value()
	apply_effect(effect, origin, spikes_value())

	var animation = preload("res://Battlers/Animations/ThornArmour.tscn")
	spell(origin, origin, 0, "spell", animation)