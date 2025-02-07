extends DominoContainer

# Final Cut
# Deal big damage but end user's turn
# Bottom stack so its always drawn last
# Downgrade - Decreases damage dealt
# Upgrade+ - Increase damage dealt
# Upgrade++ - Decrease action point cost

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	roll_numbers("all")
	domino_name = "Final Cut"
	criteria = ["uncommon", "sword", "bottom_stack"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		3:
			action_point_cost = 1
		2, 1, 0:
			action_point_cost = 2
		_:
			action_point_cost = 2
	.initiate_domino()
	

func damage_value() -> int:
	match self.get_upgrade_level():
		0:
			return 15
		1:
			return 19
		2, 3:
			return 25
		_:
			print("Error: Invalid upgrade level")
			return 15

func get_description() -> String:
	return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nEnds user's turn"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Using this domino ends the user's turn\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() 
	
	return msg

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/FinalCut.tscn")
	quick_attack(origin, target, outcome, "cut_through", "ranged_return", animation)

	Game.get_node("Game").end_battler_turn(origin.battler_type)