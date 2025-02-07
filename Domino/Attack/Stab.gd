extends DominoContainer

# Stab
# Deal damage
# Downgrade - Less damage
# Upgrade+ - More damage
# Upgrade++ - More damage
# Upgrade+++ - More damage

func _init():
	pip_data = { "left": [3, 6, "dynamic"], "right": [-1, null, "static"] }
	domino_name = "Stab"
	criteria = ["spear"]
	action_point_cost = 1
	initiate_domino()

func damage_value() -> int:
	match get_upgrade_level():
		0:
			return 3
		1:
			return 5
		2:
			return 9
		3:
			return 14
		4:
			return 20
		_:
			print("Error: Invalid upgrade level")
			return 3

func get_description() -> String:
	return str(damage_value()) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + " damage"
	return msg

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Stab.tscn")
	basic_attack(origin, target, "stab", outcome, animation)