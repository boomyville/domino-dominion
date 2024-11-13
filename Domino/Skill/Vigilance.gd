extends DominoContainer

func _init():
	number1 = random_value_range(1, 3)
	number2 = random_value_range(3, 4)
	domino_name = "Vigilance"
	criteria = ["Common"]
	description = "Self: 2" + bb_code_frostbite() + "\n" + "Self: 15" + bb_code_shield()

func effect(origin, target):
	.effect(origin, target)
	
	var effect =  load("res://Effect/Frostbite.gd").new()
	effect.duration = 2
	apply_effect(effect, origin)
	
	
	shield_message(origin, origin, origin.add_shields(15))