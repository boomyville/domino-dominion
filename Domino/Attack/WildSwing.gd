extends "res://Domino/DominoContainer.gd"

func _init():
	number1 = -1;
	number2 = random_value()	
	domino_name = "Wild Swing"

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(origin, 5))
	var effect =  load("res://Effect/Vulnerable.gd").new()
	effect.duration = 1
	apply_effect(effect, origin)
