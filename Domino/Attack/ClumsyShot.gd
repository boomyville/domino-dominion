extends DominoContainer

# Clumsy shot
# Discards a random arrow and deals damage
# Downgrade - Decreases damage dealt
# Upgrade+ - Increase damage dealt
# Upgrade++ - Increase damage dealt
# Upgrade+++ - Action point cost reduces to 0

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	domino_name = "Clumsy Shot"
	criteria = ["common", "ranged", "top_stack"]
	initiate_domino()

func initiate_domino():
	if get_upgrade_level() == 4:
		action_point_cost = 0
	else:
		action_point_cost = 1
	.initiate_domino()

func damage_value() -> int:
	match self.get_upgrade_level():
		0:
			return 1
		1:
			return 3
		2:
			return 6
		3, 4:
			return 9
	print("Error: Invalid upgrade level")
	return 0

func get_description() -> String:
	return "Discard a random" + BBCode.bb_code_arrow() + "\nDeal " + str(get_damage_value(damage_value()))  + BBCode.bb_code_attack() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Requirement: Arrow dominos in hand\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + " " + BBCode.bb_code_attack()
	msg += "Discard a random arrow domino " + BBCode.bb_code_arrow() + " from your hand"
	return msg

func effect(origin, target):
	.effect(origin, target)
	
	Game.get_node("Game").trigger_domino_transfer(self, true, 1, origin.battler_type, "Hand_arrow", "Discard")

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Impulse.tscn")
	spell(origin, target, outcome, "spell", animation)

func requirements(origin, _target):
	var condition = false
	for domino in origin.get_hand().get_children():
		if "arrow" in domino.get_criteria():
			condition = true
			break
	return .requirements(origin, _target) && condition
