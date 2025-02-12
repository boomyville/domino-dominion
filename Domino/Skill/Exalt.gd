extends DominoContainer

# Exalt
# Upgrade all dominos in the draw pile, void space, discard pile, played dominos and hand
# Downgrade - Upgrade all dominos in the draw pile
# Upgrade+ - Super upgrade all dominos in the draw pile, void space, discard pile, played dominos and hand

func _init():
	pip_data = { "left": [1, 3, "static"], "right": [4, 6, "static"] }
	domino_name = "Exalt"
	criteria = ["rare", "any", "top_stack"]
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return BBCode.bb_code_up() + " All dominos in hand"
		1:
			return BBCode.bb_code_up() + " All dominos"
		2:
			return BBCode.bb_code_superup() + " All dominos"	
		_:
			print("Error: Invalid upgrade level")	
			return BBCode.bb_code_up() + " All dominos in hand"
		
func get_detailed_description():
	var msg = get_pip_description()
	match get_upgrade_level():
		0:
			msg += BBCode.bb_code_up() + " Upgrade all dominos in hand"
		1:
			msg += BBCode.bb_code_up() + " Upgrade all dominos"
		2, 3:
			msg += BBCode.bb_code_superup() + " Super upgrade all dominos\n"
			msg += "Sets all dominos to maximum upgrade level"
	return msg

func effect(origin, target):
	
	match get_upgrade_level():
		0:
			for domino in origin.get_hand().get_children():
				if not domino.check_shadow_match(self):
					domino.alter_upgrade_domino(1)
		1:
			print("Upgrade all dominos")
			print("Draw size: ", origin.get_draw_pile().size(), " Discard size: ", origin.get_discard_pile().size(), " Void size: ", origin.get_void_space().size())
			for domino in origin.get_hand().get_children():
				domino.alter_upgrade_domino(1)
			for domino in origin.get_draw_pile():
				print(domino.domino_name)
				domino.alter_upgrade_domino(1)
			for domino in origin.get_discard_pile():
				domino.alter_upgrade_domino(1)
			for domino in origin.get_void_space():
				domino.alter_upgrade_domino(1)
			for domino in Game.get_node("Game").play_board.get_children():
				if domino.get_user().to_upper() == origin.battler_type.to_upper():
					domino.alter_upgrade_domino(1)
		2:
			for domino in origin.get_hand().get_children():
				domino.alter_upgrade_domino(2)
			for domino in origin.get_draw_pile():
				domino.alter_upgrade_domino(2)
			for domino in origin.get_discard_pile():
				domino.alter_upgrade_domino(2)
			for domino in origin.get_void_space():
				domino.alter_upgrade_domino(2)
			for domino in Game.get_node("Game").play_board.get_children():
				if domino.get_user().to_upper() == origin.battler_type.to_upper():
					domino.alter_upgrade_domino(2)
	
	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/Exalt.tscn")
	spell(origin, origin, 0, "rise", animation)

