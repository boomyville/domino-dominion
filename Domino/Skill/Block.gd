extends DominoContainer

func _init():
	number1 = random_value()
	number2 = 0
	domino_name = "Block"

func effect(origin, target):
	.effect(origin, target)
	shield_message(origin, 4)