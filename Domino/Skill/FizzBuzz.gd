extends DominoContainer

# Fizz Buzz
# Discard random dominos from target's hand
# Downgrade - Action cost increases
# Upgrade+ - Discard more dominos
# Upgrade++ - Discard more dominos, left pip becomes erratic

func _init():
	domino_name = "Fizz Buzz"
	criteria = ["frog", "uncommon"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0:
			action_point_cost = 2
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		1, 2: 
			action_point_cost = 1
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		3:	
			action_point_cost = 1
			pip_data = { "left": [1, 6, "erratic"], "right": [-1, null, "static"] }
		_:
			action_point_cost = 2
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	.initiate_domino()

func get_description() -> String:
	return "Target: " + str(discard_value()) + BBCode.bb_code_random() + BBCode.bb_code_discard() + " from hand"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Discard " + str(discard_value()) + " random dominos from the enemy hand"
	return msg

func discard_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 2
		2:
			return 3
		3:
			return 4
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):
	.effect(origin, target)

	Game.get_node("Game").trigger_domino_transfer(self, true, discard_value(), target.battler_type, "Hand", "Discard")

	var animation = preload("res://Battlers/Animations/BubbleAttack.tscn")
	spell(origin, target, 0, "spell", animation)
	target.buff_pose(discard_value(), BBCode.bb_code_discard())