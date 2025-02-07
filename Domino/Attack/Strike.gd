extends DominoContainer

# Strike
# Deal damage
# Downgrade - Less damage
# Upgrade+ - More damage
# Upgrade++ - More damage
# Upgrade+++ - Action cost 0

func _init():
	domino_name = "Strike"
	criteria = ["starter"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0:
			pip_data = { "left": [0, null, "static"], "right": [1, 4, "dynamic"] }
			action_point_cost = 1
		1:
			pip_data = { "left": [0, null, "static"], "right": [3, 6, "dynamic"] }
			action_point_cost = 1
		2:
			pip_data = { "left": [0, null, "static"], "right": [5, 6, "erratic"] }
			action_point_cost = 1
		3:
			pip_data = { "left": [0, null, "static"], "right": [5, 6, "erratic"] }
			action_point_cost = 0
		4:
			pip_data = { "left": [0, null, "static"], "right": [5, 6, "volatile"] }
			action_point_cost = 0
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [0, null, "static"], "right": [1, 4, "dynamic"] }

	.initiate_domino()

func get_description() -> String:
	return BBCode.bb_code_max_tile(get_numbers()) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + " damage is equal to the highest pip (" + str(get_damage_value(int(max(get_numbers()[0], get_numbers()[1])))) + ")"
	return msg

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, max(number1, number2)))
	var animation = preload("res://Battlers/Animations/Strike.tscn")
	basic_attack(origin, target, "slash", outcome, animation)