extends DominoContainer

# Spiny Guard
# Gain spikes and shields
# Downgrade - Reduce spikes and shields
# Upgrade+ - Increase spikes and shields
# Upgrade++ - Reduce action point cost

func _init():
	pip_data = { "left": [1, 3, "dynamic"], "right": [1, null, "static"] }
	domino_name = "Spiny Guard"
	criteria = ["uncommon"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			action_point_cost = 2
		3:
			action_point_cost = 1
		_:
			print("Error: Invalid upgrade level")
			action_point_cost = 2
	.initiate_domino()

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 5
		1:
			return 12
		2:
			return 15
		3:
			return 20
		_:
			print("Error: Invalid upgrade level")
			return 5

func spikes_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 3
		2:
			return 4
		3:
			return 5
		_:
			print("Error: Invalid upgrade level")
			return 2

func get_description() -> String:
	return "Self: " + str(spikes_value()) + BBCode.bb_code_spikes() + "\nSelf: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: "+ str(get_shield_value(shield_value())) + " "+ BBCode.bb_code_shield() + " shields\n"
	msg += "Self: " + str(spikes_value()) + BBCode.bb_code_spikes() + " spikes\n"
	msg += "Spikes deal damage to physical attackers"
	return msg

func effect(origin, target):
	.effect(origin, target)
	var charge_animation = preload("res://Battlers/Animations/ChargeUp.tscn")

	charge_up(origin, charge_animation)
	yield(get_tree().create_timer(1.0), "timeout")

	var effect =  load("res://Effect/Spikes.gd").new()
	effect.triggers = spikes_value()
	apply_effect(effect, origin, spikes_value())

	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	var animation = preload("res://Battlers/Animations/SpinyGuard.tscn")
	spell(origin, origin, outcome, "spell", animation)