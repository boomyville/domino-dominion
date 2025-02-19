extends DominoContainer

# Headbonk
# Deal damage and discard dominos from target's draw pile
# Downgrade - No dominos discarded
# Upgrade+ - Increase damage dealt
# Upgrade++ - Dominos discarded from hand

func _init():
	pip_data = { "left": [1, null, "static"], "right": [-1, null, "static"] }
	domino_name = "Headbonk"
	criteria = ["physical", "uncommon"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		1, 2:
			return "Target: 2 " + BBCode.bb_code_discard() + " from the draw pile\n"  + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		3:
			return "Target: 2 " + BBCode.bb_code_discard() + " from the hand\n"  + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		_:	
			print("Error: Invalid upgrade level")
			return "Deal " + str(str(get_damage_value(damage_value()))) + BBCode.bb_code_attack()

func get_detailed_description() -> String:
	var msg = get_pip_description()
	match get_upgrade_level():
		0:
			msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		1, 2:
			msg += "Target: 2 random dominos from the target's draw pile\n"  + str(str(get_damage_value(damage_value()))) + BBCode.bb_code_attack()
		3:
			msg += "Target: 2 random dominos from the target's from the hand\n"  + str(str(get_damage_value(damage_value()))) + BBCode.bb_code_attack()
		_:
			msg += "Error: Invalid upgrade level"

	return msg

func damage_value():
	match get_upgrade_level():
		0, 1:
			return 8
		2, 3:
			return 12
		_:
			print("Error: Invalid upgrade level")
			return 8

func effect(origin, target):
	.effect(origin, target)
	
	Game.get_node("Game").trigger_domino_transfer(self, true, 2, target.battler_type, "Pile", "Discard")

	var outcome = attack_message(origin, target, target.damage(origin, 8))
	var animation = preload("res://Battlers/Animations/Bonk.tscn")
	quick_attack(origin, target, outcome, "zoom_in","hop_away",  animation, "knockback")