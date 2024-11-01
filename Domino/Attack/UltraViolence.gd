extends DominoContainer

func _init():
	number1 = 6
	number2 = unique_random_value([number1])
	domino_name = "Ultra Violence"
	description = "Attacks in " + bb_code_pile() + ": "+ bb_code_attack()

func effect(origin, target):
	.effect(origin, target)

	var attack_count = 0
	var domino_collection = Game.get_node("Game").get_target_collection(user, "PILE")
	for domino in domino_collection:
		if "Attack" in domino.filename: 
			attack_count += 1
	
	attack_message(origin, target, target.damage(origin, attack_count))

