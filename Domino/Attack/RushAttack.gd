extends DominoContainer

# Rush attack
# Deal damage. Draw an attack
# Downgrade - Only draw attack if its the first domino played
# Upgrade+ - Right pip becomes wild
# Upgrade++ - If first domino played, draw 2 attacks, else draw 1 attack
# Upgrade+++ - Draw 2 attacks

func _init():
	domino_name = "Rush Attack"
	criteria = ["starter"]
	action_point_cost = 1
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1:
			pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
		2, 3, 4:
			pip_data = { "left": [0, null, "static"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }

	.initiate_domino()

func get_description() -> String:	
	match get_upgrade_level():
		0:
			return "1" + BBCode.bb_code_draw() + " Attack if first domino\n3 " + BBCode.bb_code_attack()
		1, 2:
			return "1" + BBCode.bb_code_draw() + " Attack\n3 " + BBCode.bb_code_attack()
		3:
			return "1" + BBCode.bb_code_draw() + " Attack if first domino\n1" + BBCode.bb_code_draw() + "\n3 " + BBCode.bb_code_attack()
		4:
			return "2" + BBCode.bb_code_draw() + " Attack\n3 " + BBCode.bb_code_attack()
		_:
			print("Error: Invalid upgrade level")
			return "1" + BBCode.bb_code_draw() + " Attack if first domino\n3 " + BBCode.bb_code_attack()
		
func get_detailed_description():
	var msg = get_pip_description()

	match get_upgrade_level():
		0:
			msg += "Draw 1 " + BBCode.bb_code_draw() + " random attack domino if this is the first domino played this turn\n"
		1, 2:
			msg += "Draw 1 " + BBCode.bb_code_draw() + " random attack domino from the draw pile\n"
		3:
			msg += "Draw 2 " + BBCode.bb_code_draw() + " random attack dominos if this is the first domino played this turn\n"
			msg += "Otherwise draw 1 " + BBCode.bb_code_draw() + " random attack domino from the draw pile\n"
		4:
			msg += "Draw 2 " + BBCode.bb_code_draw() + " random attack domino from the draw pile\n"
		_:
			print("Error: Invalid upgrade level")
			msg += "Draw 1 " + BBCode.bb_code_draw() + " random attack domino if this is the first domino played this turn\n"

	msg += "Deal " + str(get_damage_value(3)) + BBCode.bb_code_attack()
	return msg

func effect(origin, target):
	.effect(origin, target)
	
	var outcome = attack_message(origin, target, target.damage(origin, 3))
	var animation = preload("res://Battlers/Animations/RushAttack.tscn")
	quick_attack(origin, target, outcome, "zoom_in","hop_away",  animation)
	print("Rush Attack effect: " + str(get_upgrade_level()))
	match get_upgrade_level():
		0:
			# dominos_played_this_turn == 1 since Rush Attack itself would be played already
			if origin.dominos_played_this_turn.size() == 1:
				Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "Attack")
		1, 2:
			Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "Attack")
		3:
			if origin.dominos_played_this_turn.size() == 1:
				print("Draw 2 attacks")
				Game.get_node("Game").draw_hand(2, origin.name.to_upper(), "Attack")
			else:
				Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "Attack")
		4:
			Game.get_node("Game").draw_hand(2, origin.name.to_upper(), "Attack")

			