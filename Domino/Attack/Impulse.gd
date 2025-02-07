extends DominoContainer

# Impulse
# Deal damage
# Downgrade - Right pip becomes non-wild
# Upgrade+ - Increase damage dealt
# Upgrade++ - Left pip becomes erratic
# Upgrade+++ - Left pip becomes wild

func _init():
	domino_name = "Impulse"
	criteria = ["magical", "common"]
	action_point_cost =1
	initiate_domino()

func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 4
		2:
			return 6
		3, 4:
			return 7
		_:
			return 4
			print("Error: Invalid upgrade level")

func initiate_domino():
	match get_upgrade_level():
		4:
			pip_data = { "left": [-1, null, "static"], "right": [-1, null, "static"] }
		3:
			pip_data = { "left": [2, 5, "erratic"], "right": [-1, null, "static"] }
		2, 1, 0:
			pip_data = { "left": [2, 5, "dynamic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [2, 5, "dynamic"], "right": [-1, null, "static"] }
	.initiate_domino()

func get_description() -> String:
	return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Impulse.tscn")
	spell(origin, target, outcome, "spell", animation)

