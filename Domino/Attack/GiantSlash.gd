extends DominoContainer

# Giant Cut
# Deal big damage but apply impair to self
# Downgrade - Decreases damage dealt
# Upgrade+ - Decrease impair applied to self
# Upgrade++ - Increase damage dealt

func _init():
	pip_data = { "left": [5, 6, "dynamic"], "right": [5, 6, "dynamic"] }
	domino_name = "Giant Slash"
	criteria = ["uncommon", "sword", "any"]
	action_point_cost = 2
	initiate_domino()

func damage_value():
	match get_upgrade_level():
		0:
			return 18
		1, 2:
			return 22
		3:
			return 28
	print("Error: Invalid upgrade level")
	return 0

func impair_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 3
		2, 3:
			return 2
	print("Error: Invalid upgrade level")
	return 3

func get_description():
	return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nApply " + str(impair_value()) + BBCode.bb_code_impair()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: Apply " + str(impair_value()) + BBCode.bb_code_impair() + " impair\n"
	msg += "Impair reduces damage dealt by 50%\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	
	var animation = preload("res://Battlers/Animations/GiantSlash.tscn")
	charge_smash(origin, target, outcome, null, animation)

	var effect =  load("res://Effect/Impair.gd").new()
	effect.triggers = impair_value()
	apply_effect(effect, origin, impair_value())
	

