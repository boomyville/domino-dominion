extends DominoContainer

# Combative
# Become Berserk, Gain Fury
# Downgrade - Increase Berserk duration
# Upgrade+ - Increase Fury duration
# Upgrade++ - Decrease Berserk duration
# Upgrade+++ - Top Stack

func _init():
	pip_data = { "left": [5, 6, "dynamic"], "right": [3, 6, "dynamic"] }
	domino_name = "Combative"
	initiate_domino()

func initiate_domino():
	if(get_upgrade_level() == 4):
		criteria = ["common", "physical", "top_stack"]
	else:
		criteria = ["common", "physical"]
	.initiate_domino()
	
func get_description() ->  String:
	if get_upgrade_level() == 4:
		return "Top stack\nSelf: " + str(fury_value()) + BBCode.bb_code_fury() + "\nSelf: " + str(berserk_value()) + BBCode.bb_code_berserk()
	else:
		return "Self: " + str(fury_value()) + BBCode.bb_code_fury() + "\nSelf: " + str(berserk_value()) + BBCode.bb_code_berserk()

func get_detailed_description():
	var msg = get_pip_description()
	if get_upgrade_level() == 4:
		msg += "Top stack dominos are placed on the top of the draw pile at the start of battle\n"
	msg += "Self: Apply " + str(fury_value()) + BBCode.bb_code_fury() + " fury\n"
	msg += "Fury increases damage dealt equal to level of fury\n"
	msg += "Self: Apply " + str(berserk_value()) + BBCode.bb_code_berserk() + " berserk\n"
	msg += "Berserk prevents skills being played"
	return msg

func fury_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 3
		2, 3, 4:
			return 5
		_:
			print("Error: Invalid upgrade level")
			return 3

func berserk_value() -> int:
	match get_upgrade_level():
		0:
			return 3
		1, 2:
			return 2
		3, 4:
			return 1
		_:
			print("Error: Invalid upgrade level")
			return 3

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Combative.tscn")
	spell(origin, origin, 0, "slash", animation)
	
	var effect =  load("res://Effect/Berserk.gd").new()
	effect.duration = berserk_value()
	apply_effect(effect, origin, berserk_value())

	var effect2 =  load("res://Effect/Fury.gd").new()
	effect2.duration = fury_value()
	apply_effect(effect2, origin, fury_value())
