extends DominoContainer

# Lunge
# Deal damage
# Downgrade - No impair applied
# Upgrade+ - Increase Impair applied
# Upgrade++ - Turn does not end

func _init():
	pip_data = { "left": [1, null, "static"], "right": [-1, null, "static"] }
	domino_name = "Lunge"
	criteria = ["uncommon", "spear", "terminal"]
	action_point_cost = 1
	initiate_domino()

func damage_value() -> int:
	return 5

func get_description() -> String:
	if(get_upgrade_level() <= 2):
		return "Deal " + str(damage_value()) + BBCode.bb_code_attack() + "\nApply " + str(impair_value()) + BBCode.bb_code_impair() + "\nEnd user's turn"
	elif(get_upgrade_level() == 3):
		return "Deal " + str(damage_value()) + BBCode.bb_code_attack() + "\nApply " + str(impair_value()) + BBCode.bb_code_impair()
	else:
		print("Error: Invalid upgrade level")
		return "Deal " + str(damage_value()) + BBCode.bb_code_attack() + "\nApply " + str(impair_value()) + BBCode.bb_code_impair() + "\nEnd user's turn"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Using this domino ends the user's turn\n"
	msg += "Deal " + str(get_damage_value(5)) + BBCode.bb_code_attack() + "\n"
	msg += "Apply 1 " + BBCode.bb_code_impair() + " onto the target\n"
	msg += "Impair reduces damage dealt by 50%"
	
	return msg

func impair_value() -> int:
	match get_upgrade_level():
		0:
			return 0
		1:
			return 1
		2, 3:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 1

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Lunge.tscn")
	
	quick_attack(origin, target, outcome, "cut_through", "ranged_return", animation)
	
	var effect =  load("res://Effect/Impair.gd").new()

	if(impair_value() > 0):
		effect.triggers = impair_value()
		apply_effect(effect, target, effect.triggers)

	if(get_upgrade_level() <= 2):
		Game.get_node("Game").end_battler_turn(origin.battler_type)