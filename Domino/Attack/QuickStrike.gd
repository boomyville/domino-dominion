extends DominoContainer

func _init():
	number1 = random_value()
	number2 = -1
	domino_name = "Quick Strike"

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(7))

func requirements(origin, target):
	print(origin.dominos_played_this_turn)
	if origin.dominos_played_this_turn.size() > 0:
		return false
	else:
		return true