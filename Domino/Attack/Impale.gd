extends DominoContainer

# Impale 
# Deal damage and discard dominos from the target if they are vulnerable
# Downgrade - Discard 1 domino from draw pile
# Upgrade+ - Increase damage dealt
# Upgrade++ - Remove condition

func _init():
	pip_data = { "left": [1, null, "static"], "right": [-1, null, "static"] }
	domino_name = "Impale"
	criteria = ["uncommon", "spear"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nTarget: " + BBCode.bb_code_discard() + " 1 from draw pile if " + BBCode.bb_code_vulnerable()
		1, 2:
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nTarget: " + BBCode.bb_code_discard() + " 2 from hand if " + BBCode.bb_code_vulnerable()
		3:
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nTarget: " + BBCode.bb_code_discard() + " 2 from hand"
	print("Error: Invalid upgrade level")
	return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n"
	match get_upgrade_level():
		0:
			msg += "Target: " + BBCode.bb_code_discard() + " discard 1 random domino from their draw pile if " + BBCode.bb_code_vulnerable()
		1, 2:
			msg += "Target: " + BBCode.bb_code_discard() + " discard 2 random dominos from their hand if " + BBCode.bb_code_vulnerable()
		3:
			msg += "Target: " + BBCode.bb_code_discard() + " discard 2 random dominos from their hand"
	
	return msg

func damage_value() -> int:
	match get_upgrade_level():
		0:
			return 12
		1, 2, 3:
			return 14
	print("Error: Invalid upgrade level")
	return 14

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Impale.tscn")
	basic_attack(origin, target, "stab", outcome,  animation)

	match get_upgrade_level():
		0:
			if(target.is_state_affected("Vulnerable")):
				Game.get_node("Game").trigger_domino_transfer(self, true, 1, target.battler_type, "Draw", "Discard")
		1, 2:
			if(target.is_state_affected("Vulnerable")):
				Game.get_node("Game").trigger_domino_transfer(self, true, 2, target.battler_type, "Hand", "Discard")
		3:
			Game.get_node("Game").trigger_domino_transfer(self, true, 2, target.battler_type, "Hand", "Discard")
