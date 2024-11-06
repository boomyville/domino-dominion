extends DominoContainer

func _init():
	number1 = random_value()
	number2 = 0
	domino_name = "Block"
	criteria = ["Common", "Swordfighter"]
	description = "Self: 4" + bb_code_shield()

func effect(origin, target):
	.effect(origin, target)
	shield_message(origin, origin, origin.add_shields(4))