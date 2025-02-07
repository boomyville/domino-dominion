extends DominoContainer

# Fury Attack
# Deal damage thrice
# Downgrade - Decreases damage dealt
# Upgrade+ - Increase damage dealt
# Upgrade++ - Increase damage dealt

func _init():
	pip_data = { "left": [1, null, "static"], "right": [-1, null, "static"] }
	domino_name = "Fury Attack"
	criteria = ["physical", "uncommon", "enemy"]
	action_point_cost = 2
	initiate_domino()

func damage_value():
	match get_upgrade_level():
		0:
			return 2
		1:
			return 4
		2:
			return 6
		3: 
			return 8
	print("Error: Invalid upgrade level")
	return 0

func get_description():
	return BBCode.bb_code_triple() + str(damage_value()) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(damage_value()) + BBCode.bb_code_attack() + " 3 times\n"
	return msg

func effect(origin, target):
	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/FuryAttack.tscn")	
	multi_hit_attack(origin, target, "stab", 4, animation, "hop_towards", damage_value())