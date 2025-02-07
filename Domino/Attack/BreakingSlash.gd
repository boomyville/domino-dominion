extends DominoContainer

# Breaking Slash
# Playable if user has 3+ AP and also applies Impair
# Similar effect to Breaking Swipe in Pokemon
# Downgrade - Increases AP requirement
# Upgrade+ - Increase damage dealt
# Upgrade++ - Increases Impair triggers 
# Upgrade+++ - Decreases AP requirement

func _init():
	pip_data = { "left": [2, 6, "dynamic"], "right": [1, 1, "static"] }
	domino_name = "Breaking Slash"
	criteria = ["common", "sword"]
	action_point_cost = 1
	initiate_domino()

func damage_value() -> int:
	match self.get_upgrade_level():
		0, 1:
			return 7
		2, 3, 4:
			return 10
	print("Error: Invalid upgrade level")
	return 0

func impair_triggers() -> int:
	match self.get_upgrade_level():
		0, 1, 2:
			return 1
		3, 4:
			return 2
	
	print("Error: Invalid upgrade level")
	return 0

func ap_requirement() -> int:
	match self.get_upgrade_level():
		0:
			return 4
		1, 2, 3:
			return 3
		4:
			return 2
	
	print("Error: Invalid upgrade level")
	return 4

func get_description():
	return "Playable if user has " + str(ap_requirement()) + "+ AP\n" + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n" + str(impair_triggers()) + BBCode.bb_code_impair()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Requirement: Must have at least " + str(ap_requirement()) + " action points\n"
	msg += "Apply " + str(impair_triggers()) + BBCode.bb_code_impair() + "\n"
	msg += "Impair reduces damage dealt by 50%\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/BreakingSlash.tscn")
	quick_attack(origin, target, outcome, "zoom_in", "hop_away", animation)

	var effect =  load("res://Effect/Impair.gd").new()
	effect.triggers = 2
	apply_effect(effect, target, 2)

func requirements(origin, _target):
	return .requirements(origin, _target) && origin.action_points >= 3
