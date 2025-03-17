extends DominoContainer

# Enrage
# Gain Fury
# Downgrade - Reduce Fury
# Upgrade+ - Top Stack
# Upgrade++ - Increase Fury duration
# Upgrade+++ - Increase Fury duration

func _init():
	pip_data = { "left": [0, null, "static"], "right": [3, 6, "dynamic"] }
	domino_name = "Enrage"
	initiate_domino()

func initiate_domino():
	if(get_upgrade_level() >= 2):
		criteria = ["starter", "physical", "top_stack"]
	else:
		criteria = ["starter", "physical"]
	.initiate_domino()
	
func get_description() ->  String:
	if (get_upgrade_level() >= 2):
		return "Top stack\nSelf: " + str(fury_value()) + BBCode.bb_code_fury()
	else:
		return "Self: " + str(fury_value()) + BBCode.bb_code_fury()

func get_detailed_description():
	var msg = get_pip_description()
	if get_upgrade_level() >= 2:
		msg += "Top stack dominos are placed on the top of the draw pile at the start of battle\n"
	msg += "Self: Apply " + str(fury_value()) + BBCode.bb_code_fury() + " fury\n"
	msg += "Fury increases damage dealt equal to level of fury"
	return msg

func fury_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 2
		2, 3:
			return 4
		4:
			return 7
		_:
			print("Error: Invalid upgrade level")
			return 1

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Enrage.tscn")
	spell(origin, origin, 0, "rise", animation)

	var effect2 =  load("res://Effect/Fury.gd").new()
	effect2.duration = fury_value()
	apply_effect(effect2, origin, fury_value())
