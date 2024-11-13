extends DominoContainer

func _init():
	number1 = 1
	number2 = random_value()
	domino_name = "Bulwark"
	criteria = ["Common"]
	description = "Self: 5" + bb_code_shield() + "\n" + "1" + bb_code_bulwark()

func effect(origin, target):
	.effect(origin, target)
	var effect =  load("res://Effect/Bulwark.gd").new()
	effect.duration = 1
	apply_effect(effect, origin)
	shield_message(origin, origin, origin.add_shields(5))