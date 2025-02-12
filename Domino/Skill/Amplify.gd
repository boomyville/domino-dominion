extends DominoContainer

# Amplify
# Grant double damage status
# Downgrade - Adds restriction: Must have a double domino in hand
# Upgrade+ - Both pips becomes erratic
# Upgrade++ - Both pips become volatile
# Upgrade+++ - Get two stacks of double damage

func _init():
	domino_name = "Double Damage"
	criteria = ["common", "any"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1:
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
		2:
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "erratic"] }
		3, 4:
			pip_data = { "left": [1, 6, "volatile"], "right": [1, 6, "volatile"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	.initiate_domino()

func get_description() -> String:
	return "Next " + str(amplify_value()) + BBCode.bb_code_attack() + ": " + BBCode.bb_code_double()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: Next " + str(amplify_value()) + " attack does " + BBCode.bb_code_double() + " double damage\n"
	msg +=  BBCode.bb_code_double() + " does not expire until an attack is made"
	return msg

func amplify_value() -> int:
	match get_upgrade_level():
		0, 1, 2, 3:
			return 1
		4:
			return 2
		_:	
			print("Error: Invalid upgrade level")
			return 1

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Amplify.tscn")
	spell(origin, origin, 0, "slash", animation)
	
	var effect =  load("res://Effect/DoubleDamage.gd").new()
	effect.triggers = amplify_value()
	apply_effect(effect, origin, amplify_value())
