extends "res://Domino/DominoContainer.gd"

func _init():
	number1 = -1;
	number2 = random_value()	
	domino_name = "Wild Swing"

func effect(origin, target):
	.effect(origin, target)
	attack_message(origin, target, target.damage(5))