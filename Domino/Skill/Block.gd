extends DominoContainer

# Block
# Gain Block
# Downgrade - Reduce block amount
# Upgrade+ - Increase Block amount
# Upgrade++ - Right pip becomes wild
# Upgrade+++ - Also gain max shields (fortitude) equal to half of base shields gained

func _init():
	initiate_domino()
	domino_name = "Block"
	criteria = ["starter"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
		3, 4:
			pip_data = { "left": [0, null, "static"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
	.initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0, 1, 2, 3:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield()
		4:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\nSelf: " + str(floor(shield_value() / 2)) + BBCode.bb_code_fortitude()
		_:
			print("Error: Invalid upgrade level")
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) +  BBCode.bb_code_shield() + " shields"

	if get_upgrade_level() == 4:
		msg += "\nSelf: " + str(floor(shield_value() / 2)) + " " + BBCode.bb_code_fortitude() + " fortitude (max shields)"
	return msg

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 4
		2, 3, 4:
			return 7
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Block.tscn")

	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	
	spell(origin, origin, outcome, "defend", animation, BBCode.bb_code_shield())

	
	if get_upgrade_level() == 4:
		var effect =  load("res://Effect/Fortitude.gd").new()
		effect.triggers = floor(shield_value() / 2)
		apply_effect(effect, origin, effect.triggers)