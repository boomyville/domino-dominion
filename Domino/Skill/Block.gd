extends DominoContainer

func _init():
	number1 = random_value()
	number2 = 0
	domino_name = "Block"

func effect(user, target):
	user.add_shields(4)