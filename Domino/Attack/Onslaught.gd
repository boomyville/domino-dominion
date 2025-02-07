extends DominoContainer

# Onslaught
# Deal damage and createa temporary copy of this domino in the draw pile
# Downgrade - Place temporary copy in the discard pile 
# Upgrade+ - Increase damage
# Upgrade++ - Right pip becomes wild

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [2, 5, "dynamic"] }
	domino_name = "Onslaught"
	criteria = ["uncommon", "physical", "any"]
	action_point_cost = 1
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		3:
			pip_data["right"] = [-1, null, "static"]
		2, 1, 0:
			pip_data["right"] = [2, 5, "dynamic"]
		_:
			print("Error: Invalid upgrade level")
			pip_data["right"] = [2, 5, "dynamic"]
	.initiate_domino()

func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 5
		2, 3:
			return 8
		_:
			print("Error: Invalid upgrade level")
			return 5

func get_description() -> String:
	match get_upgrade_level():
		1, 2, 3:
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nAdd a temporary copy to the draw pile"
		_:
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\nAdd a temporary copy to the discard pile"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() +"\n"

	match get_upgrade_level():
		1, 2, 3:
			msg += "Add a temporary copy of this domino to the draw pile"
		_:
			msg += "Add a temporary copy of this domino to the discard pile"

	return msg

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/Onslaught.tscn")
	quick_attack(origin, target, outcome, "zoom_in","hop_away",  animation)

	match get_upgrade_level():
		0:
			origin.add_dominos_to_deck(self.get_domino_name().replace(" ", ""), 1, self.get_domino_type(), get_upgrade_level())
		1, 2, 3:
			origin.add_dominos_to_deck(self.get_domino_name().replace(" ", ""), 1, self.get_domino_type(), get_upgrade_level())
		_:
			origin.add_dominos_to_discard_pile(self.get_domino_name().replace(" ", ""), 1, self.get_domino_type(), get_upgrade_level())

