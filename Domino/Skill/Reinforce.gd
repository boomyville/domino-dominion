extends DominoContainer

# Reinforce
# Upgrade 1 domino in hand. Gain shields
# Downgrade - Upgrade 1 random domino in hand
# Upgrade+ - Upgrade 2 dominos in hand
# Upgrade++ - Upgrade 3 dominos in hand
# Upgrade+++ - Upgrade all dominos in hand

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Reinforce"
	criteria = ["common", "swordmaster"]
	initiate_domino()
	
func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + BBCode.bb_code_up() + str(upgrade_value()) + " random domino in hand"
		1, 2, 3:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n"  + BBCode.bb_code_up() + str(upgrade_value()) + " domino in hand"
		4:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n"  + BBCode.bb_code_up() + " All dominos in hand"
		_:
			print("Error: Invalid upgrade level")
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + BBCode.bb_code_up() + str(upgrade_value()) + " random domino in hand"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"

	match get_upgrade_level():
		0:
			msg += "Upgrade a random domino in hand\n"
		1, 2, 3:
			msg += "Upgrade " + str(upgrade_value()) + " domino(s) in hand\n"
		4:
			msg += "Upgrade all dominos in hand\n"
		_:
			print("Error: Invalid upgrade level")
			msg += "Upgrade a random domino in hand\n"

	return msg

func upgrade_value() -> int:
	match get_upgrade_level():
		0:
			return 1
		1, 2, 3:
			return get_upgrade_level()
		4:
			return 1
		_:
			print("Error: Invalid upgrade level")
			return 1

func shield_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 4
		2, 3, 4:
			return get_upgrade_level() * 3
		_:
			print("Error: Invalid upgrade level")
			return 4

func effect(origin, target):
	.effect(origin, target)

	match get_upgrade_level():
		0:
			for domino in origin.get_hand().get_children().shuffle():
				if not domino.check_shadow_match(self):
					domino.alter_upgrade_domino(1)
					break
		1, 2, 3:
			Game.get_node("Game").domino_selection(1, upgrade_value(), self, self.user, "hand", -1, "same_hand", {"alter_upgrade_domino": [1]})
			yield(self, "pre_effect_complete")
		4:
			for domino in origin.get_hand().get_children():
				if not domino.check_shadow_match(self):
					domino.alter_upgrade_domino(2)

	var outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	var animation = preload("res://Battlers/Animations/Reinforce.tscn")
	spell(origin, origin, outcome, "defend", animation)

