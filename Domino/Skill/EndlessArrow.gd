extends DominoContainer

# Endless Arrow
# Add 4 Phantom Arrow to hand
# Downgrade - Add 2 Phantom Arrow to hand
# Upgrade+ - Add 6 Phantom Arrow to hand
# Upgrade++ - Draw an additional domino

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	domino_name = "Endless Arrow"
	criteria = ["ranged", "uncommon"]
	initiate_domino()
	
func arrow_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 4
		2, 3:
			return 6
		_:
			print("Error: Invalid upgrade level")
			return 4

func get_description() -> String:
	if get_upgrade_level() < 3:
		return "Add " + str(arrow_value()) + " Phantom " + BBCode.bb_code_arrow() + " to hand"
	else:
		return "Add " + str(arrow_value()) + " Phantom " + BBCode.bb_code_arrow() + " to hand\n1" + BBCode.bb_code_draw() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Add " + str(arrow_value()) + " Phantom " + BBCode.bb_code_arrow() + " arrow to hand"
	if get_upgrade_level() == 3:
		msg += "\nDraw 1 " + BBCode.bb_code_draw() + " domino"

	return msg

func effect(origin, target):
	.effect(origin, target)
	
	origin.add_dominos_to_hand("PhantomArrow", arrow_value(), "Skill")
	
	var animation = preload("res://Battlers/Animations/SpiritArrow.tscn")
	spell(origin, origin, 0, "rise", animation)

	if get_upgrade_level() == 3:
		Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "any")
