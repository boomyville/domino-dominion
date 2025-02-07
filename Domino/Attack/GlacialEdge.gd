extends DominoContainer

# Glacial Edge
# Deal damage and apply frostbite to the target
# Downgrade - Decreases frostbite level
# Upgrade+ - Increase damage dealt
# Upgrade++ - Changes dynamic to erratic and increases frostbite level

func _init():
	domino_name = "Glacial Edge"
	criteria = ["uncommon", "ice", "sword"]
	action_point_cost = 1
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			pip_data = { "left": [1, 6, "dynamic"], "right": [4, 4, "static"] }
		3:
			pip_data = { "left": [1, 6, "erratic"], "right": [4, 4, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "dynamic"], "right": [4, 4, "static"] }
	.initiate_domino()

func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 7
		2, 3:
			return 10
		_:
			print("Error: Invalid upgrade level")
			return 0

func frostbite_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 3
		2:
			return 4
		3:
			return 5
		_:
			print("Error: Invalid upgrade level")
			return 2

func get_description() -> String:
	return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n" + "Apply " + str(frostbite_value()) + BBCode.bb_code_frostbite()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n"
	msg += "Apply " + str(frostbite_value()) + BBCode.bb_code_frostbite() + " frostbite\n"
	msg += "Frostbite reduces dominos drawn at the start of the turn by 1"
	return msg

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))	
	var animation = preload("res://Battlers/Animations/FrostSlash.tscn")
	basic_attack(origin, target, "slash", outcome, animation)

	var effect =  load("res://Effect/Frostbite.gd").new()
	effect.triggers = frostbite_value()
	apply_effect(effect, target, effect.triggers)