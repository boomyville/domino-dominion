extends DominoContainer

# Phantom Arrow
# Unplayable
# Downgrade - when used, turn ends
# Upgrade+ - Apply 2 precision
# Upgrade++ - Apply 3 precision and discard 1 domino from target
# Upgrade+++ - Apply 4 precision and discard 2 dominos from target

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-2, null, "static"] }
	ephemeral = true
	domino_name = "Phantom Arrow"
	criteria = ["arrow", "common", "top_stack"]
	initiate_domino()

func precision_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 0
		2:
			return 2
		3:
			return 3
		4:
			return 4
		_:
			print("Error: Invalid upgrade level")
			return 0

func discard_value() -> int:
	match get_upgrade_level():
		0, 1, 2:
			return 0
		3:
			return 1
		4:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 0

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Unplayable\nEnds user's turn"
		1:
			return "Unplayable"
		2:
			return "Add " + str(precision_value()) + BBCode.bb_code_attack()
		3, 4:
			return "Add " + str(precision_value()) + BBCode.bb_code_attack() + "\nTarget: " + BBCode.bb_code_discard() + str(discard_value()) + " from hand"
		_:
			print("Error: Invalid upgrade level")
			return "Unplayable"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Unplayable\n"
	match get_upgrade_level():
		0:
			msg += "Ends user's turn"
		1:
			msg += ""
		2:
			msg += "When discarded by a discard action, add " + str(precision_value()) + BBCode.bb_code_attack() + " damage"
		3, 4:
			msg += "When discarded by a discard action, add " + str(precision_value()) + BBCode.bb_code_attack() + " damage\n"
			msg += "Target: " + BBCode.bb_code_discard() + str(discard_value()) + " from hand"
		_:
			print("Error: Invalid upgrade level")
			msg += "Ends user's turn"
	return msg

func effect(origin, target):
	.effect(origin, target)
	
func discard_effect(_origin, _target):

	print("Phantom Arrow discard effect")
	_origin.add_to_discard_pile(self, "hand")

	if(get_upgrade_level() == 0):
		Game.get_node("Game").end_battler_turn(_origin.battler_type)

	if(get_upgrade_level() > 2):
		Game.get_node("Game").trigger_domino_transfer(self, true, discard_value(), _target.battler_type, "Hand", "Discard")
		
	if(get_upgrade_level() > 1):
		var effect =  load("res://Effect/Precision.gd").new()
		effect.triggers = precision_value()
		apply_effect(effect, _origin, precision_value())

	.discard_effect(_origin, _target)
