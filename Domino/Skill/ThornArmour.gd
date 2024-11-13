extends DominoContainer

func _init():
	number1 = 1
	number2 = random_value()
	domino_name = "Thorn Armour"
	criteria = ["Uncommon"]
	description = "Self: 3" + bb_code_spikes()

func effect(origin, target):
	.effect(origin, target)
	var effect =  load("res://Effect/Spikes.gd").new()
	effect.triggers = 3
	apply_effect(effect, origin)