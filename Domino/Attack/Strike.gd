extends DominoContainer

func _init():
	number1 = 0
	number2 = random_value()
	domino_name = "Strike"
	description = bb_code_max_tile() + bb_code_attack()

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(origin, max(number1, number2)))