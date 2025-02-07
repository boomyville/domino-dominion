extends DominoContainer

# Fire Slash
# Deal damage and apply burn to the target
# Bottom stack so its always drawn last
# Downgrade - Decreases burn level
# Upgrade+ - Increase damage dealt
# Upgrade++ - Increase burn level

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [4, 4, "static"] }
	domino_name = "Fire Slash"
	criteria = ["uncommon", "fire", "sword"]
	action_point_cost = 1
	initiate_domino()

func damage_value() -> int:
	match self.get_upgrade_level():
		0, 1:
			return 7
		2, 3:
			return 11
	print("Error: Invalid upgrade level")
	return 0

func burn_value() -> int:
	match self.get_upgrade_level():
		0:
			return 1
		1, 2:
			return 3
		3:
			return 5
	print("Error: Invalid upgrade level")
	return 0

func get_description() -> String:
	return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nApply " + str(burn_value()) + BBCode.bb_code_burn() + " burn"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n"
	msg += "Apply " + str(burn_value()) + BBCode.bb_code_burn() + " burn\n"
	msg += "Burn causes blockable damage when attacking"
	return msg

func effect(origin, target):
	.effect(origin, target)
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/FireSlash.tscn")
	basic_attack(origin, target, "slash", outcome, animation)

	var effect =  load("res://Effect/Burn.gd").new()
	effect.triggers = burn_value()
	apply_effect(effect, target, burn_value())