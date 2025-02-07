extends DominoContainer

# Riposte
# Deal damage. Gain shields
# Downgrade - Reduce shields and damage
# Upgrade+ - Increase shields and damage
# Upgrade++ - Increase shields and damage
# Upgrade+++ - Increase shields and damage. Also apply fortitude to user

func _init():
	pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
	domino_name = "Riposte"
	criteria = ["starter"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	if get_upgrade_level() != 4:
		return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + str(damage_value()) + BBCode.bb_code_attack()
	else:
		return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + str(damage_value()) + BBCode.bb_code_attack() + "\nSelf: 3" + BBCode.bb_code_fortitude() 


func get_detailed_description():
	var msg = get_pip_description()
	msg += "Shield " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() +"\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	if get_upgrade_level() == 4:
		msg += "\nSelf: " + BBCode.bb_code_fortitude() + " fortitude (max shields)"

	return msg

func damage_value() -> int:
	match get_upgrade_level():
		0:
			return 4
		1:
			return 6
		2:
			return 8
		3:
			return 10
		4:
			return 11
		_:
			print("Error: Invalid upgrade level")
			return 6

func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 4
		1:
			return 6
		2:
			return 8
		3:
			return 10
		4:
			return 11
		_:
			print("Error: Invalid upgrade level")
			return 4

func effect(origin, target):
	.effect(origin, target)
	
	Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "Attack")
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var outcome2 = shield_message(origin, origin, origin.add_shields(shield_value()))
	
	var animation = preload("res://Battlers/Animations/Riposte.tscn")
	basic_attack(origin, target, "stab", outcome, animation)
	origin.buff_pose(outcome2,BBCode.bb_code_shield())

	if get_upgrade_level() == 4:
		var effect =  load("res://Effect/Fortitude.gd").new()
		effect.triggers = 3
		apply_effect(effect, origin, effect.triggers)
	