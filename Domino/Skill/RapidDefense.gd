extends DominoContainer

# Rapid Defense
# Unplayable
# Downgrade - Reduce shields
# Upgrade+ - Extra shields
# Upgrade++ - Extra shields, pips become erratic
# Upgrade+++ - Extra shields, right pip becomes wild

func _init():
	domino_name = "Rapid Defense"
	criteria = ["common"]
	action_point_cost = 1
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
		3:
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "erratic"] }
		4:
			pip_data = { "left": [1, 6, "erratic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	.initiate_domino()
	
func get_description() -> String:
	return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) +  BBCode.bb_code_shield() + " shields"
	return msg

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 6
		1:
			return 9
		2:
			return 12
		3: 
			return 13
		4:
			return 14
		_:
			print("Error: Invalid upgrade level")
			return 9

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/RapidDefense.tscn")

	var outcome = shield_message(origin, origin, origin.add_shields(9))
	
	spell(origin, origin, outcome, "defend", animation, BBCode.bb_code_shield())