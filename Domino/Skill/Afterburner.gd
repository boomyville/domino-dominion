extends DominoContainer

func _init():
	number1 = -1
	number2 = -1
	domino_name = "Afterburner"
	criteria = ["Common"]
	description = "Self: 3" + bb_code_burn()

func effect(origin, target):
	.effect(origin, target)
	
	var effect =  load("res://Effect/Burn.gd").new()
	effect.triggers = 3
	apply_effect(effect, origin)
	