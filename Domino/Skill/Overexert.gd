extends DominoContainer

# Overexert
# Paralyse self and draw 3 dominos
# Downgrade - Apply more paralysis
# Upgrade+ - Draw more dominos
# Upgrade++ - Draw more dominos
# Upgrade+++ - Draw more dominos. Only apply paralysis if not paralysed

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [5, null, "static"] }
	domino_name = "Overexert"
	criteria = ["common", "any"]
	initiate_domino()

func get_description() -> String:
	if get_upgrade_level() == 4:
		return  "Self: " + str(paralysis_value()) + BBCode.bb_code_paralysis() + " if not " + BBCode.bb_code_paralysis() +"\n" + str(draw_value()) + BBCode.bb_code_draw() 
	else:
		return  "Self: " + str(paralysis_value()) + BBCode.bb_code_paralysis() + "\n" + str(draw_value()) + BBCode.bb_code_draw() 

func get_detailed_description():
	var msg = get_pip_description()
	if get_upgrade_level() == 4:
		msg += "Self: " + str(paralysis_value()) +  BBCode.bb_code_paralysis() + " paralysis if unparalysed\n"
	else:
		msg += "Self: " + str(paralysis_value()) +  BBCode.bb_code_paralysis() + " paralysis\n"
	msg += "When paralysed, only dominos with matching left pips are playable\n"
	msg += "Draw " + str(draw_value()) + " dominos into your hand"
	return msg

func draw_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 3
		2:
			return 4
		3: 
			return 5
		4:
			return 6
		_:
			print("Error: Invalid upgrade level")
			return 3

func paralysis_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1, 3, 2, 4:
			return 1
		_:
			print("Error: Invalid upgrade level")
			return 1

func effect(origin, target):
	.effect(origin, target)
	Game.get_node("Game").draw_hand(draw_value(), origin.name.to_upper(), "ANY")
	
	if(get_upgrade_level() <= 3 or (get_upgrade_level() == 4 and !origin.is_state_affected("Paralysis"))):
		var effect =  load("res://Effect/Paralysis.gd").new()
		effect.duration = paralysis_value()
		apply_effect(effect, origin, paralysis_value())
	
	var animation = preload("res://Battlers/Animations/Overexert.tscn")
	spell(origin, origin, draw_value(), "spell", animation)