extends DominoContainer

# 2: Terrain 3: Water 4: Fire 5: Lightning

func _init():
	number1 = random_value_range(1, 2)
	number2 = 3
	domino_name = "Lockdown"
	criteria = ["Common"]
	description = "Self: 6" + bb_code_petrify() + "\n" + "Self: 1" + bb_code_nullify()

func effect(origin, target):
	.effect(origin, target)
	
	var effect =  load("res://Effect/Nullify.gd").new()
	effect.triggers = 1
	apply_effect(effect, origin)
	
	var effect2 =  load("res://Effect/Petrification.gd").new()
	effect2.triggers = 6
	apply_effect(effect2, origin)
	