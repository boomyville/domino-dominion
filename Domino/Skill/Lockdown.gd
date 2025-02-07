extends DominoContainer

# 2: Terrain 3: Water 4: Fire 5: Lightning

# Lockdown
# Apply petrify to self and nullify
# Downgrade - Apply more petrify
# Upgrade+ - Apply less petrify
# Upgrade++ - Apply more nullify
# Upgrade+++ - Apply more nullify

func _init():
	pip_data = { "left": [3, null, "static"], "right": [1, 2, "dynamic"] }
	domino_name = "Lockdown"
	criteria = ["common", "any"]
	initiate_domino()

func get_description() -> String:
	return "Self: " + str(petrify_value()) + BBCode.bb_code_petrify() + "\n" + "Self: " + str(nullify_value()) + BBCode.bb_code_nullify()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(petrify_value()) +  BBCode.bb_code_petrify() + " petrification\n"
	msg += "Petrified dominos are unplayable when drawn\n"
	msg += "Self: " + str(nullify_value()) + BBCode.bb_code_nullify() + " nullification\n"
	msg += "Nullification prevents all damage" 
	return msg

func nullify_value() -> int:
	match get_upgrade_level():
		0, 1, 2:
			return 1
		3:
			return 2
		4:
			return 3
		_:
			print("Error: Invalid upgrade level")
			return 1

func petrify_value() -> int:
	match get_upgrade_level():
		0:
			return 12
		1:
			return 6
		2, 3, 4:
			return 4
		_:
			print("Error: Invalid upgrade level")
			return 12

func effect(origin, target):
	.effect(origin, target)
	
	var effect =  load("res://Effect/Nullify.gd").new()
	effect.triggers = nullify_value()
	apply_effect(effect, origin, nullify_value())
	
	var effect2 =  load("res://Effect/Petrification.gd").new()
	effect2.triggers = petrify_value()
	apply_effect(effect2, origin, petrify_value())
	
	var animation = preload("res://Battlers/Animations/Lockdown.tscn")
	spell(origin, origin, nullify_value(), "spell", animation)