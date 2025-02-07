extends DominoContainer

# Quad Strike
# Deal damage x 4
# Downgrade - Decrease damage dealt
# Upgrade+ - Increase damage dealt
# Upgrade++ - Remove bottom stack


func _init():
	pip_data = { "left": [1, 3, "dynamic"], "right": [4, 6, "dynamic"] }
	domino_name = "Quad Strike"
	criteria = ["uncommon", "bottom_stack", "any"]
	action_point_cost = 2
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2, 3:
			criteria = ["uncommon", "bottom_stack", "any"]
		4:
			criteria = ["uncommon", "any"]
		_:
			print("Error: Invalid upgrade level")
			criteria = ["uncommon", "bottom_stack", "any"]
	.initiate_domino()

func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 3
		2, 3:
			return 4
		4:
			return 5
		_:
			print("Error: Invalid upgrade level")
			return 3

func get_description() -> String:
	return BBCode.bb_code_quadruple() + str(damage_value()) + BBCode.bb_code_attack() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(damage_value()) + BBCode.bb_code_attack() + " four times"
	return msg

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var outcome2 = attack_message(origin, target, target.damage(origin,damage_value()))
	var outcome3 = attack_message(origin, target, target.damage(origin,damage_value()))
	var outcome4 = attack_message(origin, target, target.damage(origin,damage_value()))
	
	var animation = preload("res://Battlers/Animations/QuadStrike1.tscn")
	var animation4 = preload("res://Battlers/Animations/QuadStrike1.tscn")
	var animation3 = preload("res://Battlers/Animations/QuadStrike2.tscn")
	var animation2 = preload("res://Battlers/Animations/QuadStrike3.tscn")

	multi_attack(origin, target, [outcome, outcome2, outcome3, outcome4], [animation, animation2, animation3, animation4], ["stab", "rise_and_fall", "slash", "stab"], "hop_towards", "hop_away")