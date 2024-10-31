extends DominoContainer

func _init():
	number1 = random_value()
	number2 = random_value()
	domino_name = "Deflection"
	description = "Self: 8" + bb_code_shield() + "\n" + "1" + bb_code_random() + bb_code_discard()

func effect(origin, target):
	.effect(origin, target)
	Game.get_node("Game").trigger_random_discard_from_hand(self, 1, origin.name.to_upper())
	shield_message(origin, origin, origin.add_shields(7))