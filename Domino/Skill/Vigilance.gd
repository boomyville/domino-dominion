extends DominoContainer

# Vigilance
# Gain shields and frostbite
# Downgrade - More frostbite and less shields
# Upgrade+ - More shields
# Upgrade++ - Less frostbite
# Upgrade+++ - Right pip becomes wild

func _init():
	domino_name = "Vigilance"
	criteria = ["common", "any"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2, 3:
			pip_data = { "left": [1, 3, "dynamic"], "right": [3, 4, "dynamic"] }
		4:
			pip_data = { "left": [1, 3, "dynamic"], "right": [-1, null, "static"] }
			print("Error: Invalid upgrade level")
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 3, "dynamic"], "right": [3, 4, "dynamic"] }
	.initiate_domino()
func get_description() -> String:
	return "Self: " + str(frost_value()) + BBCode.bb_code_frostbite() + "\n" + "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"
	msg += "Self: " + str(frost_value()) + BBCode.bb_code_frostbite() + " frostbite\n"
	msg += "Frostbite reduces dominos drawn at the start of the turn by 1"
	return msg

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 5
		1:
			return 8
		2, 3, 4:
			return 12
		_:
			print("Error: Invalid upgrade level")
			return 5

func frost_value() -> int:
	match get_upgrade_level():
		0:
			return 4
		1, 2:
			return 2
		3, 4:
			return 1
		_:
			print("Error: Invalid upgrade level")
			return 4

func effect(origin, target):
	.effect(origin, target)
	
	var effect =  load("res://Effect/Frostbite.gd").new()
	effect.duration = frost_value()
	apply_effect(effect, origin, frost_value())
	
	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	var animation = preload("res://Battlers/Animations/Vigilance.tscn")
	spell(origin, origin, outcome, "defend", animation)