extends DominoContainer

# Shoot
# Deal damage - Requires arrow
# Downgrade - Reduce damage dealt
# Upgrade+ - Increase damage dealt
# Upgrade++ - Action cost becomes 0
# Upgrade+++ - Left pip becomes erratic. Increase damage dealt

func _init():
	domino_name = "Shoot"
	criteria = ["common", "ranged"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		1, 2:
			action_point_cost = 1
			pip_data = { "left": [1, 6, "static"], "right": [1, 6, "dynamic"] }
		3:
			action_point_cost = 0
			pip_data = { "left": [1, 6, "static"], "right": [1, 6, "dynamic"] }
		4:			
			action_point_cost = 0
			pip_data = { "left": [1, 6, "erratic"], "right": [1, 6, "dynamic"] }
		_:
			print("Error: Invalid upgrade level")
			action_point_cost = 1
			pip_data = { "left": [1, 6, "static"], "right": [1, 6, "dynamic"] }

	.initiate_domino()

func damage_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1:
			return 3
		2, 3, 4:
			return 6
		_:
			print("Error: Invalid upgrade level")
			return 1

func get_description() -> String:
	return "Recursive\nDiscard " + BBCode.bb_code_arrow() + "\nDeal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Recursive: Duplicates itself onto the top of the domino stack\n"
	msg += "Requirement: Arrow dominos in hand\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + " " + BBCode.bb_code_attack() + "\n"
	msg += "Discard an arrow domino " + BBCode.bb_code_arrow() + " from your hand"
	return msg

func effect(origin, target):
	.effect(origin, target)

	Game.get_node("Game").domino_selection(1, 1, self, self.user, "hand_arrow", -1, "same_hand", {"discard_effect": [origin, target]})

	yield(self, "pre_effect_complete")

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Shoot.tscn")
	spell(origin, target, outcome, "spell", animation)
	
	origin.add_dominos_to_deck(self.get_domino_name().replace(" ", ""), 1, self.get_domino_type(), get_upgrade_level(), false, true)

func requirements(origin, _target):
	var condition = false
	for domino in origin.get_hand().get_children():
		if "arrow" in domino.get_criteria():
			condition = true
			break
	return .requirements(origin, _target) && condition
