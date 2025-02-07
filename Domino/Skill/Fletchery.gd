extends DominoContainer

# Fletchery
# Add a domino to hand every turn
# Downgrade - Add restriction, cannot be used if any arrows in hand
# Upgrade+ - Right pip becomes wild
# Upgrade++ - Add 2 Fletchery

func _init():
	domino_name = "Fletchery"
	criteria = ["ranged", "uncommon", "top_stack"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1:
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "erratic"] }
		2, 3:
			pip_data = { "left": [1, 6, "erratic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "erratic"] }
	.initiate_domino()

func get_description() -> String:
	return "Add " + str(fletchery_value()) + BBCode.bb_code_arrow() + " fletchery"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Add " + str(fletchery_value()) + BBCode.bb_code_arrow() + " Phantom Arrow to hand every turn"
	return msg

func fletchery_value() -> int:
	if (get_upgrade_level() <= 2):
		return 1
	elif (get_upgrade_level() == 3):
		return 2
	else:
		print("Error: Invalid upgrade level")
		return 1

func effect(origin, target):
	.effect(origin, target)

	var effect =  load("res://Effect/Fletchery.gd").new()
	effect.triggers = fletchery_value()
	apply_effect(effect, origin, fletchery_value())

	var animation = preload("res://Battlers/Animations/Fletchery.tscn")
	spell(origin, origin, 0, "rise", animation)
