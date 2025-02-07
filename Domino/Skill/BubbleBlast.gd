extends DominoContainer

# Bubble Blast
# Apply impair to target
# Downgrade - Lose wild right pip
# Upgrade+ - Both pips become wild
# Upgrade++ - Action cost becomes 0
# Upgrade+++ - Increase impair stacks to 3

func _init():
	domino_name = "Bubble Blast"
	criteria = ["frog", "common"]
	initiate_domino()

func get_description() -> String:
	return "Apply " + str(impair_value()) + BBCode.bb_code_impair()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Target: " + str(impair_value()) + BBCode.bb_code_impair() + " impair\n"
	msg += "Impair reduces damage dealt by 50%"
	return msg

func impair_value() -> int:
	match get_upgrade_level():
		0, 1, 2, 3:
			return 2
		4:
			return 3
		_:
			print("Error: Invalid upgrade level")
			return 2

func initiate_domino() -> void:
	match get_upgrade_level():
		0:
			pip_data = { "left": [1, 6, "static"], "right": [1, 6, "dynamic"] }
			action_point_cost = 1
		1: 
			pip_data = { "left": [-1, null, "static"], "right": [1, 6, "dynamic"] }
			action_point_cost = 1
		2:
			pip_data = { "left": [-1, null, "static"], "right": [-1, null, "static"] }
			action_point_cost = 1
		3, 4:
			pip_data = { "left": [-1, null, "static"], "right": [-1, null, "static"] }
			action_point_cost = 0
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
	.initiate_domino()

func effect(origin, target):
	.effect(origin, target)

	var effect =  load("res://Effect/Impair.gd").new()
	effect.triggers = impair_value()
	apply_effect(effect, target, effect.triggers)

	var animation = preload("res://Battlers/Animations/BubbleBeam.tscn")
	spell(origin, target, 0, "spell", animation)

