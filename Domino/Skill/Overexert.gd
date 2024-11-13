extends DominoContainer

func _init():
	number1 = random_value()
	number2 = unique_random_value([number1])
	domino_name = "Overexert"
	criteria = ["Common"]
	description = "Self: 1" + bb_code_paralysis() + "\n" + "3" + bb_code_draw() 

func effect(origin, target):
	.effect(origin, target)
	Game.get_node("Game").draw_hand(3, origin.name.to_upper(), "ANY")
	
	var effect =  load("res://Effect/Paralysis.gd").new()
	effect.duration = 1
	apply_effect(effect, origin)
	