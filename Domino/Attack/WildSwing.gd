extends DominoContainer

# Wild Swing
# Deal damage and apply vulnerable to self
# Downgrade - Increase vulnerable afflicted to self
# Upgrade+ - Increase damage dealt
# Upgrade++ - No longer discard a random domino
# Upgrade+++ - Increase damage dealt

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	domino_name = "Wild Swing"
	criteria = ["common", "physical", "any"]
	action_point_cost = 1
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0, 1, 2:
			return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n" + "1" + BBCode.bb_code_discard() + "\n" + "Self: " + str(vulnerable_value()) + BBCode.bb_code_vulnerable()
		3, 4:
			return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n" + "Self: " + str(vulnerable_value()) + BBCode.bb_code_vulnerable()
		_:
			print("Error: Invalid upgrade level")
			return str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n" + "1" + BBCode.bb_code_discard() + "\n" + "Self: " + str(vulnerable_value()) + BBCode.bb_code_vulnerable()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack() + "\n"
	if (get_upgrade_level() <= 2):
		msg += "Discard 1 random domino from your hand\n"
	msg += "Self: " + str(vulnerable_value()) + BBCode.bb_code_vulnerable() + " vulnerable\n"
	msg += "Vulnerable increases damage taken by 50%"
	return msg

func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 5
		2, 3:
			return 7
		4:
			return 11
		_:
			print("Error: Invalid upgrade level")
			return 5

func vulnerable_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1, 2, 3, 4:
			return 1
		_:
			print("Error: Invalid upgrade level")
			return 2

func effect(origin, target):

	if get_upgrade_level() <= 2:
		Game.get_node("Game").domino_selection(1, 1, self, self.user, "hand", -1, "discard")
		# Wait until the discard is complete before continuing
		yield(self, "pre_effect_complete")

	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	
	var animation = preload("res://Battlers/Animations/WildSwing.tscn")

	quick_attack(origin, target, outcome, "rising_blow", "hop_away", animation)

	var effect =  load("res://Effect/Vulnerable.gd").new()
	effect.duration = vulnerable_value()
	apply_effect(effect, origin, vulnerable_value())

func requirements(origin, _target):

	if get_upgrade_level() <= 2:
		return .requirements(origin, _target) &&  origin.get_hand().get_children().size() > 1
	else:
		return .requirements(origin, _target) 
