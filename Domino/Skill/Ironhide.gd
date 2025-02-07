extends DominoContainer

# Ironhide
# Shield 
# Downgrade - Gain less shield
# Upgrade+ - Gain more shield
# Upgrade++ - Right pip becomes wild
# Upgrade+++ - Action cost reduced

func _init():
	domino_name = "Ironhide"
	criteria = ["irmy"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			action_point_cost = 2
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
		3:
			action_point_cost = 2
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		4:
			action_point_cost = 1
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			action_point_cost = 2
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	.initiate_domino()

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 7
		1:
			return 10
		2, 3, 4:
			return 15
		_:
			print("Error: Invalid upgrade level")
			return 7

func get_description() -> String: 
	return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"
	return msg

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Ironhide.tscn")

	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	
	spell(origin, origin, outcome, "defend", animation)