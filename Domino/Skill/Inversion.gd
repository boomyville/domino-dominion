extends DominoContainer

# Inversion
# Convert impair to double damage
# Downgrade - Remove impair
# Upgrade+ - Gain 1 double damage and fury for each impair lost
# Upgrade++ - Gain 2 double damage and fury for each impair lost

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Inversion"
	criteria = ["uncommon", "any"]
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Remove self " + BBCode.bb_code_impair()
		1:
			return "Convert one's " + BBCode.bb_code_impair() + " to " + BBCode.bb_code_double()
		2:	
			return "Convert one's " + BBCode.bb_code_impair() + " to " + BBCode.bb_code_double() + " and " + BBCode.bb_code_fury()
		3:
			return "Convert one's " + BBCode.bb_code_impair() + " to 2 stacks of " + BBCode.bb_code_double() + " and " + BBCode.bb_code_fury() 
		_:
			
			return "Remove self " + BBCode.bb_code_impair()

func get_detailed_description():
	var msg = get_pip_description()

	match get_upgrade_level():
		0:
			msg += "Self: Remove " + BBCode.bb_code_impair() + "\n"
		1:
			msg += "Self: Convert one's " + BBCode.bb_code_impair() + " to " + BBCode.bb_code_double() + " double damage\n"
		2:
			msg += "Self: Convert one's " + BBCode.bb_code_impair() + " to " + BBCode.bb_code_double() + " double damage and " + BBCode.bb_code_fury() + " fury\n"
		3:
			msg += "Self: Convert one's " + BBCode.bb_code_impair() + " to 2 stacks of " + BBCode.bb_code_double() + " double damage and " + BBCode.bb_code_fury() + " fury\n"
		_:
			print("Error: Invalid upgrade level")
			msg += "Self: Remove " + BBCode.bb_code_impair() + "\n"
	return msg

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/Inversion.tscn")
	spell(origin, origin, 0, "stab", animation)
	
	var effect =  load("res://Effect/DoubleDamage.gd").new()

	match get_upgrade_level():
		0:
			effect.triggers = origin.get_state_turns("Impair")
		1:
			effect.triggers = origin.get_state_turns("Impair") * 2
		3:
			effect.triggers = origin.get_state_turns("Impair") * 2
			var effect2 = load("res://Effect/Fury.gd").new()
			effect2.triggers = origin.get_state_turns("Impair")
			apply_effect(effect2, origin, effect2.triggers)
		4:
			effect.triggers = origin.get_state_turns("Impair") * 3
			var effect2 = load("res://Effect/Fury.gd").new()
			effect2.triggers = origin.get_state_turns("Impair") * 2
			apply_effect(effect2, origin, effect2.triggers)
	
	apply_effect(effect, origin)

func requirements(origin, _target):
	return .requirements(origin, _target) && origin.is_state_affected("Impair")


