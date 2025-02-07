extends DominoContainer

# Volt Slice
# Deal damage and apply paralysis to the target
# Downgrade - Increase action point cost
# Upgrade+ - Decrease action point cost
# Upgrade++ - Increase damage if target is paralysed

func _init():
	pip_data = { "left": [5, null, "static"], "right": [5, 6, "dynamic"] }
	domino_name = "Volt Slice"
	criteria = ["uncommon", "lightning", "sword"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1:
			action_point_cost = 1
		2, 3:
			action_point_cost = 0
		_:
			print("Error: Invalid upgrade level")
			action_point_cost = 1
	.initiate_domino()

func damage_value(target = false) -> int:
	match get_upgrade_level():
		0, 1, 2:
			return 6
		3:
			if(target != false):
				if target.is_state_affected("Paralysis"):
					return 15
				else:
					return 8
			return 8
		_:
			print("Error: Invalid upgrade level")
			return 6

func get_description() -> String:
	return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n" + "Apply 2 " + BBCode.bb_code_paralysis() + " paralysis"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n"
	msg += "Apply 2 " + BBCode.bb_code_paralysis() + " paralysis\n"
	msg += "When paralysed, only dominos with matching left pips are playable\n"
	if (get_upgrade_level() == 3):
		msg += "If target is paralysed, deal additional 7" + BBCode.bb_code_attack() 
	return msg

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/ThunderSlash.tscn")
	basic_attack(origin, target, "slash", outcome, animation)
	
	var effect =  load("res://Effect/Paralysis.gd").new()
	effect.triggers = 2
	apply_effect(effect, target, effect.triggers)