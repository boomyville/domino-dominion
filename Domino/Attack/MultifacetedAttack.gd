extends DominoContainer

func _init():
	number1 = random_value()
	number2 = unique_random_value([number1])
	domino_name = "Multifacted Attack"
	description = "Playable as if" + "\n" + bb_code_dot(1) + bb_code_dot(2) + bb_code_dot(3) + bb_code_dot(4)+ bb_code_dot(5)+ bb_code_dot(6) + " in hand \n" + "15" + bb_code_attack() 

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(origin, 15))

func requirements(origin, target):
	var check = {
		1: false,
		2: false,
		3: false,
		4: false,
		5: false,
		6: false
	}

	for domino in origin.get_hand().get_children():
		check[domino.get_numbers()[0]] = true
		check[domino.get_numbers()[1]] = true
	
	if check[1] and check[2] and check[3] and check[4] and check[5] and check[6]:
		return true
	else:
		return false