extends DominoContainer

func _init():
	number1 = random_value()
	number2 = random_value()
	domino_name = "Rally"
	criteria = ["Common", "Swordfighter"]
	description = "Self: 3" + bb_code_shield() + "\n" + "1" + bb_code_draw() + " Skill"

func effect(origin, target):
	.effect(origin, target)
	Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "Skill")
	shield_message(origin, origin, origin.add_shields(3))