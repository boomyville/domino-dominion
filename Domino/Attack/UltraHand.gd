extends DominoContainer

func _init():
	number1 = 6
	number2 = unique_random_value([number1])
	domino_name = "Ultra Hand"
	description = "Hand size: " + bb_code_attack()

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(origin, Game.get_node("Game").get_target_collection(user, "HAND").size()))

