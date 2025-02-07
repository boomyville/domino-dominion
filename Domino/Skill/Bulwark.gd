extends DominoContainer

# Bulwark
# Apply bulwark to self which applies vulnerable to attackers when damage is fully blocked
# Downgrade - Do not gain shields
# Upgrade+ - Increase shields gained
# Upgrade++ - Increase Bulwark gained

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, null, "static"] }
	domino_name = "Bulwark"
	criteria = ["uncommon", "physical"]
	initiate_domino()

func bulwark_value() -> int:
	match get_upgrade_level():
		0, 1, 2:
			return 1
		3:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 1
	
func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 0
		1:
			return 3
		2, 3:
			return 6
		_:
			print("Error: Invalid upgrade level")
			return 0

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Self: " + str(bulwark_value()) + BBCode.bb_code_bulwark()
		1, 2, 3:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + "Self: " + str(bulwark_value()) + BBCode.bb_code_bulwark()
		_:
			print("Error: Invalid upgrade level")
			return "Self: " + str(bulwark_value()) + BBCode.bb_code_bulwark()
		
func get_detailed_description():
	var msg = get_pip_description()

	if get_upgrade_level() > 0:
		msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"

	msg += "Self: " + str(bulwark_value()) + BBCode.bb_code_bulwark() + " bulwark\n"
	msg += "Bulwark applies vulnerable when damage is fully blocked\n"
	msg += "Vulnerable increases damage taken by 50%"

	return msg

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Bulwark.tscn")
	spell(origin, origin, 0, "defend", animation)

	var effect =  load("res://Effect/Bulwark.gd").new()
	effect.duration = bulwark_value()
	apply_effect(effect, origin, bulwark_value())

	if get_upgrade_level() > 0:
		shield_message(origin, origin, origin.add_shields(shield_value()))