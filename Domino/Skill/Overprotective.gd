extends DominoContainer

# Overprotective
# Gain shields. Apply impair to self. Gain fortitude
# Downgrade - Apply more impair to self
# Upgrade+ - Apply more shields and fortitude
# Upgrade++ - Apply less impair to self

func _init():
	pip_data = { "left": [1, 3, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Overprotective"
	criteria = ["uncommon", "any"]
	initiate_domino()

func get_description() -> String:
	return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\nSelf: " + str(impair_value()) + BBCode.bb_code_impair() + "\nSelf: " + str(fortitude_value()) + BBCode.bb_code_fortitude()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: Apply " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields to self\n"
	msg += "Self: Apply " + str(impair_value()) + BBCode.bb_code_impair() + " fortitude to self\n"
	msg += "Impair reduces damage dealt by 50%\n"
	msg += "Self: Apply " + str(fortitude_value()) + BBCode.bb_code_fortitude() + " fortitude to self\n"
	msg += "Fortitude increases max shields " + BBCode.bb_code_max_shield()
	return msg

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 10
		1:
			return 13
		2, 3:
			return 16
		_:
			print("Error: Invalid upgrade level")
			return 10

func impair_value() -> int:
	match get_upgrade_level():
		0:
			return 4
		1, 2:
			return 3
		3:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 4

func fortitude_value() -> int:
	match get_upgrade_level():
		0:
			return 3
		1, 2, 3:
			return 5
		_:
			print("Error: Invalid upgrade level")
			return 3

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Overprotective.tscn")
	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	spell(origin, origin, outcome, "defend", animation)

	var effect =  load("res://Effect/Fortitude.gd").new()
	effect.triggers = fortitude_value()
	apply_effect(effect, origin, fortitude_value())

	var effect2 =  load("res://Effect/Impair.gd").new()
	effect2.triggers = impair_value()
	apply_effect(effect2, origin, impair_value())
