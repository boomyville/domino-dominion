extends DominoContainer

# Fury Trigger
# Gain Fury
# Downgrade - Gain less fury
# Upgrade+ - Gain more fury
# Upgrade++ - Gain more fury
# Upgrade+++ - Gain more fury

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	domino_name = "Fury Trigger"
	action_point_cost = 2
	criteria = ["common"]
	initiate_domino()

func get_description() -> String:
	return  "Self: " + str(fury_value()) + BBCode.bb_code_fury() 

func get_detailed_description() -> String:
	var msg = get_pip_description()
	msg += "Self: Apply " + str(fury_value()) + BBCode.bb_code_fury() + " fury\n"
	msg += "Fury increases damage dealt equal to level of fury\n"
	return msg

func fury_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 4
		2:
			return 6
		3:
			return 8
		4: 
			return 10
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/FuryTrigger.tscn")
	spell(origin, origin, 0, "slash", animation)
	
	var effect2 =  load("res://Effect/Fury.gd").new()
	effect2.duration = fury_value()
	apply_effect(effect2, origin, fury_value())
