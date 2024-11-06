extends DominoContainer

func _init():
	number1 = random_value(3)
	number2 = -1
	domino_name = "Dual Strike"
	description = bb_code_max_tile() + bb_code_attack() + "\n" + bb_code_max_tile() + bb_code_attack() 

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(origin,  max(number1, number2)))
	yield(get_tree().create_timer(1), "timeout")
	attack_message(origin, target, target.damage(origin,  max(number1, number2)))
