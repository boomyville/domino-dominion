extends DominoContainer

# Rapier Wit
# Shield and gain double damage
# Downgrade - Reduce shields
# Upgrade+ - Gain 2 stacks of double damage
# Upgrade++ - Gain more shields

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Rapier Wit"
	criteria = ["frog", "uncommon"]
	action_point_cost = 1
	initiate_domino()

func double_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 1
		2, 3:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 1

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1, 2:
			return 5
		3:
			return 9
		_:
			print("Error: Invalid upgrade level")
			return 2

func get_description() -> String:
	return "Next " + str(double_value()) + BBCode.bb_code_attack() + ": " + BBCode.bb_code_double() +"\n" + "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"
	
	if(double_value() > 1):
		msg += "Next " + str(double_value()) + " attacks will deal double damage\n"
	elif(double_value() == 1):
		msg += "Next attack will deal double damage\n"

	msg +=  BBCode.bb_code_double() + " does not expire until an attack is made"
	return msg

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/RapierWit.tscn")
	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	spell(origin, origin, outcome, "stab", animation)
	
	var effect =  load("res://Effect/DoubleDamage.gd").new()
	effect.triggers = double_value()
	apply_effect(effect, origin, double_value())
