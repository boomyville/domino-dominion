extends DominoContainer

func _init():
	number1 = random_value()
	number2 = random_value()
	domino_name = "Double Damage"

func effect(origin, target):
	.effect(origin, target)
	var effect =  load("res://Effect/DoubleDamage.gd").new()
	effect.triggers = 1
	apply_effect(effect, origin)