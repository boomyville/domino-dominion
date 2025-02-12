extends DominoContainer

# Horn Attack
# Deal damage
# Downgrade - Lose wild pip
# Upgrade+ - Increase damage dealt
# Upgrade++ - Change left pip to erratic
# Upgrade+++ - Change left pip to volatile

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	domino_name = "Horn Attack"
	criteria = ["irmy", "common"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	return str(get_damage_value(damage_value())) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Irmy only\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func damage_value() -> int:
	match get_upgrade_level():
		4, 3, 2:
			return 15
		1, 0:
			return 10
		_:
			print("Error: Invalid upgrade level")
			return 10

func initiate_domino():
	match get_upgrade_level():
		4:
			pip_data["left"] = [1, 6, "volatile"]
		3:
			pip_data["left"] = [1, 6, "erratic"]
		2, 1, 0:
			pip_data["left"] = [1, 6, "dynamic"]
		_:
			print("Error: Invalid upgrade level")
			pip_data["left"] = [1, 6, "dynamic"]
	.initiate_domino()

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/HornAttack.tscn")
	basic_attack(origin, target, "stab", outcome, animation)
