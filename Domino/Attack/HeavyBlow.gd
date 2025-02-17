extends DominoContainer

# Heavy Blow 
# Deal damage and apply vulnerable to the target
# Downgrade - No vulnerabiity applied
# Upgrade+ - Increase damage dealt
# Upgrade++ - Reduces action point cost
# Upgrade+++ - Increase vulnerability applied

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Heavy Blow"
	criteria = ["common", "physical", "any"]
	initiate_domino()
	
func initiate_domino():
	match get_upgrade_level():
		3, 4:
			action_point_cost = 2
		2, 1, 0:
			action_point_cost = 3
		_:
			action_point_cost = 3
	.initiate_domino()

func get_description() -> String:
	match upgrade_level:
		0:
			return str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		1, 2, 3:
			return BBCode.bb_code_vulnerable() + ": Number of dominos with " + BBCode.bb_code_dot(6) + " in hand\n" + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		4:
			return BBCode.bb_code_vulnerable() + ": Number of dominos with " + BBCode.bb_code_dot(6) + BBCode.bb_code_dot(5) + " in hand\n" + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		_:
			print("Error: Invalid upgrade level")
			return "0" + BBCode.bb_code_attack()


func get_detailed_description():
	var msg = get_pip_description()
	match upgrade_level:
		0:
			continue
		1, 2, 3:
			msg += "Apply " + BBCode.bb_code_vulnerable() + " vulnerable (" + str(vulnerability_value()) + ") equal to the number of " + BBCode.bb_code_dot(6) + " in hand\n"
		4:
			msg += "Apply " + BBCode.bb_code_vulnerable() + " vulnerable (" + str(vulnerability_value()) + ") equal to the number of " + BBCode.bb_code_dot(6) + " or " + BBCode.bb_code_dot(5) + " in hand\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func vulnerability_value():
	var vuln = 0
	if(Game.get_node("Game").is_battle()):
		for dominos in Game.get_node("Game").get_target_collection(get_current_user(), "HAND"):
			if upgrade_level != 0 and (dominos.number1 == 6 || dominos.number2 == 6):
				vuln += 1
			elif upgrade_level == 4 and (dominos.number1 == 5 || dominos.number2 == 5):
				vuln += 1
	return vuln

func damage_value() -> int:
	match upgrade_level:
		0, 1:
			return 18
		2, 3, 4:
			return 22
		_:
			print("Error: Invalid upgrade level")
			return 0
	
func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))

	var animation = preload("res://Battlers/Animations/HeavyBlow.tscn")
	
	quick_attack(origin, target, outcome, "rising_blow", "hop_away", animation, "knockback")
	
	if vulnerability_value() > 0:
		var effect =  load("res://Effect/Vulnerable.gd").new()

		effect.duration = vulnerability_value()
		apply_effect(effect, target, vulnerability_value())
	

