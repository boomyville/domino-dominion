extends DominoContainer

# Shield Bash
# Gain shields. Deal damage equal to shields. Apply vulnerable if target has no shields
# Downgrade - Does not apply vulnerable
# Upgrade+ - Vulnerable is applied regardless of target's shield status
# Upgrade++ - Shield is gained regardless of user's shield status

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Shield Bash"
	criteria = ["uncommon", "shield"]
	action_point_cost = 2
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Self: 5 " + BBCode.bb_code_shield() + " if shieldless\n" + BBCode.bb_code_shield() + BBCode.bb_code_attack()
		1:
			return "Self: 5 " + BBCode.bb_code_shield() + " if shieldless\n" + "\n" + BBCode.bb_code_shield() + BBCode.bb_code_attack() + "\nTarget: 3 " + BBCode.bb_code_vulnerable() + " if unblocked"
		2:
			return "Self: 5 " + BBCode.bb_code_shield() + " if shieldless\n" + "\n" + BBCode.bb_code_shield() + BBCode.bb_code_attack() + "\nTarget: 3 " + BBCode.bb_code_vulnerable() 
		3:
			return "Self: 5 " + BBCode.bb_code_shield() + "\n" + "\n" + BBCode.bb_code_shield() + BBCode.bb_code_attack() + "\nTarget: 3 " + BBCode.bb_code_vulnerable() 
		_:
			print("Error: Invalid upgrade level")
			return "Self: 5 " + BBCode.bb_code_shield() + " if shieldless\n" + BBCode.bb_code_shield() + BBCode.bb_code_attack() + "\nTarget: 3 " + BBCode.bb_code_vulnerable() + " if unblocked"

func vulnerable_value() -> int:
	return 2

func get_detailed_description():
	var msg = get_pip_description()
	if (get_upgrade_level() <= 2):
		msg += "If user has no shields, shield 5 " + BBCode.bb_code_shield() + "\n"
	else:
		msg += "Shield 5 " + BBCode.bb_code_shield() + "\n"
	
	msg += "Deal damage is equal to user's shields (" +  str(get_damage_value(damage_value())) + ")\n"

	if (get_upgrade_level() == 1):
		msg += "If target has no shields, apply 3 " + BBCode.bb_code_vulnerable() + " vulnerable\n"
		msg += "Vulnerable increases damage taken by 50%"
	elif (get_upgrade_level() >= 2):
		msg += "Apply 3 " + BBCode.bb_code_vulnerable() + " vulnerable\n"
		msg += "Vulnerable increases damage taken by 50%"
	
	return msg

func damage_value() -> int:
	return get_shield_value(5) + Game.get_node("Game").string_to_battler(get_user()).shield

func effect(origin, target):
	.effect(origin, target)

	if (get_upgrade_level() <= 2):	
		if(origin.shield == 0):
			var outcome = shield_message(origin, origin, origin.add_shields(5))
			origin.buff_pose(outcome,BBCode.bb_code_shield())
	else:
		var outcome = shield_message(origin, origin, origin.add_shields(5))
		origin.buff_pose(outcome,BBCode.bb_code_shield())

		
	if (get_upgrade_level() == 1):
		if(target.shield == 0):
			var effect =  load("res://Effect/Vulnerable.gd").new()
			effect.duration = vulnerable_value()
			apply_effect(effect, target, vulnerable_value())
	elif (get_upgrade_level() >= 2):
		var effect =  load("res://Effect/Vulnerable.gd").new()
		effect.duration = vulnerable_value()
		apply_effect(effect, target, vulnerable_value())

	var outcome = attack_message(origin, target, target.damage(origin,  Game.get_node("Game").string_to_battler(get_current_user()).shield))
	var animation = preload("res://Battlers/Animations/ShieldBash.tscn")
	basic_attack(origin, target, "stab", outcome,  animation)

