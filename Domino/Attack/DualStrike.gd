extends DominoContainer

# Dual Strike
# Attack twice
# Downgrade - Decreases damage dealt
# Upgrade+ - Increase damage dealt
# Upgrade++ - Increase damage dealt
# Upgrade+++ - Action point cost reduces to 0

func _init():
	domino_name = "Dual Strike"
	criteria = ["common", "any"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		4:
			action_point_cost = 0
			self.pip_data = { "left": [2, 6, "dynamic"], "right": [-1, null, "static"] }
		3: 
			action_point_cost = 1
			self.pip_data = { "left": [2, 6, "dynamic"], "right": [-1, null, "static"] }
		2:
			action_point_cost = 1
			self.pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		1:
			action_point_cost = 1
			self.pip_data = { "left": [1, 3, "dynamic"], "right": [-1, null, "static"] }
		0:
			action_point_cost = 1
			self.pip_data = { "left": [1, null, "static"], "right": [-1, null, "static"] }
		_:
			action_point_cost = 1
			self.pip_data = { "left": [1, null, "static"], "right": [-1, null, "static"] }
	.initiate_domino()

func get_description() -> String:
	return "Deal " + str(get_damage_value(int(max(get_numbers()[0], get_numbers()[1])))) + BBCode.bb_code_attack() + " twice"

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(int(max(get_numbers()[0], get_numbers()[1])))) + BBCode.bb_code_attack() + " twice\nDamage is equal to the highest number on the domino"
	return msg

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, max(number1, number2)))
	var outcome2 = attack_message(origin, target, target.damage(origin, max(number1, number2)))
	
	var animation = preload("res://Battlers/Animations/Strike.tscn")
	var animation2 = preload("res://Battlers/Animations/DualStrike.tscn")

	multi_attack(origin, target, [outcome, outcome2], [animation, animation2], ["stab", "rise_and_fall"], "hop_towards", "hop_away")