extends DominoContainer

# Composure
# Gain Block, Lose Fury
# Downgrade - Can only be played if user has fury
# Upgrade+ - Increase Block amount
# Upgrade++ - Reduce fury amount
# Upgrade+++ - Add fortitude equal to half of block amount

func _init():
	domino_name = "Composure"
	criteria = ["starter"]
	pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\nLose " + str(fury_value()) + BBCode.bb_code_fury() + " Fury\nMust be in "+ BBCode.bb_code_fury()
		1, 2, 3:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\nLose " + str(fury_value()) + BBCode.bb_code_fury() + " Fury"
		4:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\nLose " + str(fury_value()) + BBCode.bb_code_fury() + " Fury\nSelf: " + str(floor(shield_value() / 2)) + BBCode.bb_code_fortitude()
		_:
			print("Error: Invalid upgrade level")
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\nLose " + str(fury_value()) + BBCode.bb_code_fury() + " Fury\nMust be in "+ BBCode.bb_code_fury()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) +  BBCode.bb_code_shield() + " shields\n"
	msg += "Lose " + str(fury_value()) + BBCode.bb_code_fury() + " fury\n"
	msg += "Fury increases damage dealt equal to level of fury\n"

	if get_upgrade_level() == 4:
		msg += "Self: "  + str(floor(shield_value() / 2)) + " " + BBCode.bb_code_fortitude() + " fortitude (max shields)"
	return msg

func shield_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 7
		2, 3, 4:
			return 10
		_:
			print("Error: Invalid upgrade level")
			return 7

func fury_value() -> int:
	match get_upgrade_level():
		0, 1, 2:
			return 2
		3, 4:
			return 1
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Composure.tscn")

	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	
	spell(origin, origin, outcome, "defend", animation, BBCode.bb_code_shield())

	if(origin.is_state_affected("fury")):
		print(" Reducing fury by " + str(fury_value()))
		origin.modify_state_turns("fury", -fury_value())
		
	if get_upgrade_level() == 4:
		var effect =  load("res://Effect/Fortitude.gd").new()
		effect.triggers = floor(shield_value() / 2)
		apply_effect(effect, origin, effect.triggers)


func requirements(origin, _target):
	if get_upgrade_level() == 0:
		return .requirements(origin, _target) && origin.is_state_affected("fury")
	else:
		return .requirements(origin, _target) 

