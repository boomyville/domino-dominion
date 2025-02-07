extends DominoContainer

# Aggression
# Playable if only attack dominos in hand
# Similar to Clash or Signature Move in Slay the Spire
# Downgrade - Decrease damage dealt
# Upgrade+ - Increase damage dealt
# Upgrade++ - Increase damage dealt and allows 1 non-attack domino in hand
# Upgrade+++ - Increase damage dealt and allows 2 non-attack dominos in hand

func _init():
	pip_data = { "left": [1, 6, "erratic"], "right": [-1, null, "static"] }
	domino_name = "Aggression"
	criteria = ["common", "physical", "any"]
	action_point_cost = 1
	initiate_domino()

func damage_value() -> int:
	match self.get_upgrade_level():
		0:
			return 7
		1:
			return 9
		2:
			return 13
		3:
			return 15
		4:
			return 17
	print("Error: Invalid upgrade level")
	return 0

func maximum_non_attack_dominos() -> int:
	match self.get_upgrade_level():
		0, 1, 2:
			return 0
		3:
			return 1
		4:
			return 2
	
	print("Error: Invalid upgrade level")
	return 0

func get_description():
	match self.get_upgrade_level():
		0, 1, 2:
			return "Playable if only attack dominos in hand" + "\n" + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		3, 4:
			return "Playable if only " + str(maximum_non_attack_dominos()) + " non-attack dominos in hand" + "\n" + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Requirement: Only attack dominos in hand\n"
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Aggression.tscn")
	quick_attack(origin, target, outcome, "zoom_in", "hop_away", animation)

func requirements(origin, _target):
	var condition = false
	var counter = 0
	for domino in origin.get_hand().get_children():
		if domino.get_domino_type() != "attack":
			counter += 1
	
	if counter <= self.maximum_non_attack_dominos():
		condition = true
	
	return .requirements(origin, _target) && condition
