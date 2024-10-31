extends DominoContainer

func _init():
	number1 = random_value()
	number2 = -1
	domino_name = "Quick Strike"
	description = "Playable as first tile" + "\n" + str(7) + bb_code_attack() 

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(origin, 7))

func requirements(origin, target):
	if origin.dominos_played_this_turn.size() > 0:
		return false
	else:
		return true	