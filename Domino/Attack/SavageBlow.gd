extends DominoContainer

# Savage Blow
# Deal damage. Apply vulnerable
# Downgrade - Add requirement: Must have played 2 attacks this turn
# Upgrade+ - Increase vulnerable applied
# Upgrade++ - Increase damage dealt
# Upgrade+++ - If user is Berserk, deal additional damage

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Savage Blow"
	criteria = ["common", "any"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	if (get_upgrade_level() == 0):
		return "Must played 2 attacks this turn\n" + str(damage_value()) + BBCode.bb_code_attack() + "\n" + str(vulnerable_value()) + BBCode.bb_code_vulnerable()
	else:
		return str(damage_value()) + BBCode.bb_code_attack() + "\n" + str(vulnerable_value()) + BBCode.bb_code_vulnerable()

func get_detailed_description():
	var msg = get_pip_description()

	if (get_upgrade_level() == 0):
		msg += "Requirement: Must have played 2 attacks this turn\n"

	msg += "Apply " + str(vulnerable_value()) + BBCode.bb_code_vulnerable() + "\n"
	msg += "Vulnerable increases damage taken by 50%\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()

	if (get_upgrade_level() == 3):
		msg += "\nIf user is Berserk, deal additional damage"
	return msg

func damage_value(origin = false) -> int:
	match get_upgrade_level():
		0, 1, 2:
			return 8
		3:
			return 12
		4:
			if origin != false:
				if origin.is_state_affected("Berserk"):
					return 28
				else:
					return 14
			else:
				return 16
		_:
			print("Error: Invalid upgrade level")
			return 5

func vulnerable_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 2
		2, 3, 4:
			return 3
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value(origin)))
	var animation = preload("res://Battlers/Animations/SavageBlow.tscn")
	quick_attack(origin, target, outcome, "zoom_in","hop_away",  animation, "knockback")

	var effect =  load("res://Effect/Vulnerable.gd").new()
	effect.duration = vulnerable_value()
	apply_effect(effect, target, vulnerable_value())


func requirements(origin, _target):
	var attacks = 0
	for domino in origin.dominos_played_this_turn:
		if domino.get_domino_type().to_lower() == "attack":
			attacks += 1

	match get_upgrade_level():
		0:
			return .requirements(origin, _target) && attacks >= 2
		1, 2, 3, 4:
			return .requirements(origin, _target)
		_:
			print("Error: Invalid upgrade level")
			return .requirements(origin, _target)