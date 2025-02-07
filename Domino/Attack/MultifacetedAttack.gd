extends DominoContainer

# Multifaceted attack
# Deal damage - requires 1,2,3,4,5,6 in hand
# Downgrade - Reduce damage dealt
# Upgrade+ - Accepts wilds
# Upgrade++ - Increases damage dealt if 1,2,3,4,5,6 in hand

func _init():
	pip_data = { "left": [1, 3, "dynamic"], "right": [4, 6, "dynamic"] }
	domino_name = "Multifacted Hit"
	criteria = ["uncommon", "any"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0, 1:
			return "Deal " + str(damage_value()) + BBCode.bb_code_attack() + "\nPlayable if" + "\n" + BBCode.bb_code_dot(1) + BBCode.bb_code_dot(2) + BBCode.bb_code_dot(3) + BBCode.bb_code_dot(4)+ BBCode.bb_code_dot(5)+ BBCode.bb_code_dot(6) + " in hand"
		2, 3:
			return "Deal " + str(damage_value()) + BBCode.bb_code_attack() + "\nPlayable if" + "\n" + BBCode.bb_code_wild_dot(1) + BBCode.bb_code_wild_dot(2) + BBCode.bb_code_wild_dot(3) + BBCode.bb_code_wild_dot(4)+ BBCode.bb_code_wild_dot(5)+ BBCode.bb_code_wild_dot(6) + " in hand"
		3:
			return "Deal " + str(damage_value()) + BBCode.bb_code_attack() + "\nPlayable if" + "\n" + BBCode.bb_code_dot(1) + BBCode.bb_code_dot(2) + BBCode.bb_code_dot(3) + BBCode.bb_code_dot(4)+ BBCode.bb_code_dot(5)+ BBCode.bb_code_dot(6) + " in hand.\n+20 damage if no wilds"
		_:
			print("Error: Invalid upgrade level")
			return "Deal " + str(damage_value()) + BBCode.bb_code_attack() + "\nPlayable if" + "\n" + BBCode.bb_code_dot(1) + BBCode.bb_code_dot(2) + BBCode.bb_code_dot(3) + BBCode.bb_code_dot(4)+ BBCode.bb_code_dot(5)+ BBCode.bb_code_dot(6) + " in hand"

func get_detailed_description() -> String:
	var msg = get_pip_description()
	match get_upgrade_level():
		0, 1:
			msg += "Requirement: " + BBCode.bb_code_dot(1) + BBCode.bb_code_dot(2) + BBCode.bb_code_dot(3) + BBCode.bb_code_dot(4)+ BBCode.bb_code_dot(5)+ BBCode.bb_code_dot(6) + " must be in hand\n"
		2:
			msg += "Requirement: " + BBCode.bb_code_wild_dot(1) + BBCode.bb_code_wild_dot(2) + BBCode.bb_code_wild_dot(3) + BBCode.bb_code_wild_dot(4)+ BBCode.bb_code_wild_dot(5)+ BBCode.bb_code_wild_dot(6) + " must be in hand\n"
		3:
			msg += "Requirement: " + BBCode.bb_code_dot(1) + BBCode.bb_code_dot(2) + BBCode.bb_code_dot(3) + BBCode.bb_code_dot(4)+ BBCode.bb_code_dot(5)+ BBCode.bb_code_dot(6) + " must be in hand\n"
			msg += "+20 damage if no wilds in hand\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func damage_value(origin = false) -> int:
	match get_upgrade_level():
		0:
			return 15
		1, 2:
			return 20
		3:
			var no_wilds = true
			if origin != false:
				for item in origin.get_hand().get_children():
					if item.get_numbers()[0] == -1 or item.get_numbers()[1] == -1:
						no_wilds = true
						break
			if no_wilds:
				return 40
			else:
				return 20
		_:
			print("Error: Invalid upgrade level")
			return 15

func effect(origin, target):
	.effect(origin, target)

	var charge_animation = preload("res://Battlers/Animations/ChargeUp.tscn")

	charge_up(origin, charge_animation)
	yield(get_tree().create_timer(1.0), "timeout")

	var outcome = attack_message(origin, target, target.damage(origin, damage_value(origin)))
	var animation = preload("res://Battlers/Animations/MultifacetedAttack.tscn")
	quick_attack(origin, target, outcome, "zoom_in", "hop_away", animation, "knockback")

func requirements(origin, target):
	var check = {
		1: false,
		2: false,
		3: false,
		4: false,
		5: false,
		6: false
	}

	var check2 = 0
	for domino in origin.get_hand().get_children():
		check[domino.get_numbers()[0]] = true
		check[domino.get_numbers()[1]] = true
		if(domino.get_numbers()[0] == -1 or domino.get_numbers()[1] == -1):
			check2 += 1
	
	if check[1] and check[2] and check[3] and check[4] and check[5] and check[6]:
		return  .requirements(origin, target) && true
	elif get_upgrade_level() >= 2 and (check2 + check.values().count(true) > 6):
		return  .requirements(origin, target) && false