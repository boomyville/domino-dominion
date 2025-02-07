extends DominoContainer

# Splinter Blade
# Deal damage and apply petrification to the target
# Downgrade - Reduce damage
# Upgrade+ - Increase damage dealt
# Upgrade++ - Reduce action cost

func _init():
	pip_data = { "left": [2, null, "static"], "right": [2, 4, "dynamic"] }
	domino_name = "Splinter Blade"
	criteria = ["uncommon", "terrain", "sword"]
	action_point_cost = 2
	description = "12" + BBCode.bb_code_attack() + "\n" + "Apply 6 " + BBCode.bb_code_petrify() + " petrification"
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			action_point_cost = 2
		3:
			action_point_cost = 1
		_:
			print("Error: Invalid upgrade level")
			action_point_cost = 2
	.initiate_domino()

func damage_value() -> int:
	match self.get_upgrade_level():
		0:
			return 9
		1:
			return 12
		2, 3:
			return 16
	print("Error: Invalid upgrade level")
	return 9

func petrification_value() -> int:
	return 6

func get_description() -> String:
	return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nApply " + str(petrification_value()) + BBCode.bb_code_petrify() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n"
	msg += "Apply " + str(petrification_value()) + BBCode.bb_code_petrify() + " petrification\n"
	msg += "Petrified dominos are unplayable when drawn\n"
	return msg

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/ShatterSlash.tscn")
	basic_attack(origin, target, "slash", outcome, animation)

	var effect =  load("res://Effect/Petrification.gd").new()
	effect.triggers = petrification_value()
	apply_effect(effect, target, effect.triggers)