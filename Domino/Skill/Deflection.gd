extends DominoContainer

# Deflection
# Discard a random domino. Gain shields
# Downgrade - Discard 2 random dominos
# Upgrade+ - Increase shields gained
# Upgrade++ - Choose which domino to discard
# Upgrade+++ - Domino discard becomes optional. Can discard up to 3

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Deflection"
	criteria = ["common", "swordmaster"]
	initiate_domino()
	
func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + "2" + BBCode.bb_code_random() + BBCode.bb_code_discard()
		1, 2:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + "1" + BBCode.bb_code_random() + BBCode.bb_code_discard()
		3:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + "1" + BBCode.bb_code_discard()
		4:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + "0-3" + BBCode.bb_code_discard()
		_:
			print("Error: Invalid upgrade level")
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + "2" + BBCode.bb_code_random() + BBCode.bb_code_discard()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"

	match get_upgrade_level():
		0:
			msg += "Discard 2 random dominos from your hand\n"
		1, 2:
			msg += "Discard 1 random domino from your hand\n"
		3:
			msg += "Discard 1 domino from your hand\n"
		4:
			msg += "Choose up to 3 dominos to discard from your hand\n"
		_:
			print("Error: Invalid upgrade level")
			msg += "Discard 2 random domino from your hand\n"

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

func effect(origin, target):
	.effect(origin, target)

	match get_upgrade_level():
		0:
			for _i in range(2):
				$Game.get_node("Game").trigger_domino_transfer(self, true, 1, origin.name.to_upper(), "Hand", "Discard")
		1, 2:
			$Game.get_node("Game").trigger_domino_transfer(self, true, 1, origin.name.to_upper(), "Hand", "Discard")
		3:
			Game.get_node("Game").domino_selection(1, 1, self, self.user, "hand", -1, "discard")
			# Wait until the discard is complete before continuing
			yield(self, "pre_effect_complete")
		4:
			Game.get_node("Game").domino_selection(0, 3, self, self.user, "hand", -1, "discard")
			# Wait until the discard is complete before continuing
			yield(self, "pre_effect_complete")

	var outcome = shield_message(origin, origin, origin.add_shields(7))
	var animation = preload("res://Battlers/Animations/Deflection.tscn")
	spell(origin, origin, outcome, "defend", animation)

