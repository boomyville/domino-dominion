extends DominoContainer

# Ultra Hand
# Deal damage equal to the nuumber of dominos in hand
# Downgrade - Adds requirement: Max hand size of 7
# Upgrade+ - Draw 1 domino
# Upgrade++ - Add recursion

func _init():
	pip_data = { "left": [6, null, "static"], "right": [1, 5, "dynamic"] }
	domino_name = "Ultra Hand"
	criteria = ["uncommon", "any"]
	action_point_cost = 1
	initiate_domino()

func get_description() -> String:
	if get_upgrade_level() == 0:
		return "Max hand: 7\nHand size: " + BBCode.bb_code_attack()
	elif get_upgrade_level() == 1:
		return "Hand size: " + BBCode.bb_code_attack()
	elif get_upgrade_level() == 2:
		return "1" + BBCode.bb_code_draw() + "\nHand size: " + BBCode.bb_code_attack()
	elif get_upgrade_level() == 3:
		return "Recursive\n1" + BBCode.bb_code_draw() + "\nHand size: " + BBCode.bb_code_attack()
	else:
		return "Max hand: 7\nHand size: " + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	if get_upgrade_level() == 0:
		msg += "Max hand size: 7\n"
	if get_upgrade_level() == 2:
		msg += "Draw 1 domino\n"
	elif get_upgrade_level() == 3:
		msg += "Recursive\nDraw 1 domino\n"
	msg += "Deal damage equal to the number of dominos in hand"
	if (game.is_battle()):
		msg += " (" + str(Game.get_node("Game").get_target_collection(get_current_user(), "HAND").size()) + ")"  
	return msg

func effect(origin, target):
	.effect(origin, target)

	if(get_upgrade_level() == 2):
		Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "any")
	
	if(get_upgrade_level() == 3):
		origin.add_dominos_to_deck(self.get_domino_name().replace(" ", ""), 1, self.get_domino_type(), get_upgrade_level(), false, true)

	var outcome = attack_message(origin, target, target.damage(origin, Game.get_node("Game").get_target_collection(user, "HAND").size()))
	
	var animation = preload("res://Battlers/Animations/UltraHand.tscn")

	spell(origin, target,  outcome, "spell", animation)

	
func requirements(origin, _target):
	match get_upgrade_level():
		0:
			return .requirements(origin, _target) && Game.get_node("Game").get_target_collection(user, "HAND").size() <= 7
		1, 2, 3, 4:
			return .requirements(origin, _target)
		_:
			print("Error: Invalid upgrade level")
			return .requirements(origin, _target) &&  origin.dominos_played_this_turn.size() == 0

