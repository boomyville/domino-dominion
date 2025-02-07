extends DominoContainer

# Wooden Arrow
# Unplayable
# Downgrade - Less precision
# Upgrade+ - More precision
# Upgrade++ - More precision
# Upgrade+++ - More precision

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-2, null, "static"] }
	domino_name = "Wooden Arrow"
	criteria = ["common", "arrow"]
	initiate_domino()

func get_description() -> String:
	return "Unplayable\nAdd " + str(attack_value()) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Unplayable\n"
	msg += "When discarded by a discard action, add "+ str(attack_value()) + BBCode.bb_code_attack() + " damage"
	return msg

func attack_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 4
		2:
			return 6
		3:
			return 10
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):
	.effect(origin, target)
	
func discard_effect(_origin, _target):
	var effect =  load("res://Effect/Precision.gd").new()
	effect.triggers = attack_value()
	apply_effect(effect, _origin, attack_value())

	_origin.add_to_discard_pile(self, "hand")
