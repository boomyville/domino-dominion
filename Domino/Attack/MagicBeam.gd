extends DominoContainer

# Magic Beam
# Deal damage and apply impair to self
# Downgrade - Increase impair applied to self
# Upgrade+ - Increase damage
# Upgrade++ - Increase damage

func _init():
	pip_data = { "left": [1, 5, "dynamic"], "right": [6, null, "static"] }
	domino_name = "Magic Beam"
	criteria = ["magical", "uncommon"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nSelf: " + str(impair_value()) + BBCode.bb_code_impair() 

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value()))  + " damage\n"
	msg += "Apply " + str(impair_value()) + BBCode.bb_code_impair() + " impair to self\n"
	msg += "Impair reduces damage dealt by 50%"
	return msg

func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 17
		2:
			return 23
		3:
			return 29
	print("Error: Invalid upgrade level")
	return 17

func impair_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1, 2, 3:
			return 1
	print("Error: Invalid upgrade level")
	return 2

func effect(origin, target):
	.effect(origin, target)

	var charge_animation = preload("res://Battlers/Animations/ChargeUp.tscn")

	charge_up(origin, charge_animation)
	yield(get_tree().create_timer(1.0), "timeout")

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	
	var animation = preload("res://Battlers/Animations/MagicBeam.tscn")

	var effect =  load("res://Effect/Impair.gd").new()
	effect.triggers = impair_value()
	apply_effect(effect, origin, impair_value())
	
	spell(origin, target, outcome, "spell", animation)
