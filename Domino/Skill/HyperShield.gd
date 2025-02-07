extends DominoContainer

# Hyper Shield
# Self: 20 shields and fortitude
# Downgrade - Reduce shields and fortitude
# Upgrade+ - Increase shields and fortitude

func _init():
	pip_data = { "left": [4, 6, "dynamic"], "right": [1, 3, "dynamic"] }
	domino_name = "Hyper Shield"
	criteria = ["rare", "any"]
	initiate_domino()

func get_description() -> String:
	return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + str(shield_value()) + BBCode.bb_code_fortitude()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"
	msg += "Self: " + str(shield_value()) + BBCode.bb_code_fortitude()+ " fortitude (max shields)\n"
	return msg

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 15
		1:
			return 20
		2:
			return 25
		_:
			print("Error: Invalid upgrade level")
			return 15

func effect(origin, target):
	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/HyperShield.tscn")
	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	spell(origin, origin, outcome, "defend", animation)

	var effect =  load("res://Effect/Fortitude.gd").new()
	effect.triggers = shield_value()
	apply_effect(effect, origin, shield_value())

	
