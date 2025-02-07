extends DominoContainer

# Forlorn Hope
# Duplicate hand and shuffle into the deck
# Downgrade - Adds restriction, cannot be used if any skills in hand
# Upgrade+ - Right pip becomes wild
# Upgrade++ - Gain 1 action point
# Upgrade+++ - Lose bottom_stack

func _init():
	domino_name = "Forlorn Hope"
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1:
			criteria = ["starter", "bottom_stack"]
			pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
		2, 3:
			criteria = ["starter", "bottom_stack"]
			pip_data = { "left": [0, null, "static"], "right": [-1, null, "wild"] }
		4:
			criteria = ["starter", "recursive"]
			pip_data = { "left": [0, null, "static"], "right": [-1, null, "wild"] }
		_:
			criteria = ["starter", "bottom_stack"]
			pip_data = { "left": [0, null, "static"], "right": [1, 6, "dynamic"] }
	.initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Bottom deck\nOnly " + BBCode.bb_code_attack() + " in hand\nDuplicate hand "+  BBCode.bb_code_shuffle() + BBCode.bb_code_pile()
		1, 2:
			return "Bottom deck\nDuplicate hand " + BBCode.bb_code_shuffle() + BBCode.bb_code_pile()
		3:
			return "Bottom deck\nDuplicate hand "+  BBCode.bb_code_shuffle() + BBCode.bb_code_pile() + "\nGain 1" + BBCode.bb_code_action_point()
		4:
			return "Duplicate hand " + BBCode.bb_code_shuffle() + BBCode.bb_code_pile() + "\nGain 1" + BBCode.bb_code_action_point()
		_:
			return "Bottom deck\nOnly " + BBCode.bb_code_attack() + " in hand\nDuplicate hand " + BBCode.bb_code_shuffle() + BBCode.bb_code_pile()
	
func get_detailed_description():
	var msg = get_pip_description()
	if (get_upgrade_level() <= 3):
		msg += "Bottom stack dominos are placed on the bottom of the draw pile at the start of battle\n"
	if(get_upgrade_level() == 0):
		msg += "Duplicate your attack dominos in hand and shuffle it into the draw pile"
	else:
		msg += "Duplicate your hand and shuffle it into the the draw pile"

	if(get_upgrade_level() >= 3):
		msg += "\nGain 1" + BBCode.bb_code_action_point() + " action point"
	
	return msg

func effect(origin, target):
	.effect(origin, target)

	var animation = preload("res://Battlers/Animations/ForlornHope.tscn")
	spell(origin, origin, 0, "spell", animation)

	for domino in origin.get_hand().get_children():
		if !domino.check_shadow_match(self):
			origin.add_dominos_to_deck(domino.get_domino_name().replace(" ", ""), 1, domino.get_domino_type(), get_upgrade_level())

	if get_upgrade_level() >= 3:
		origin.action_points += 1


func requirements(origin, _target):
	if(get_upgrade_level() <= 0):
		var condition = true
		for domino in origin.get_hand().get_children():
			if domino.get_domino_type() != "attack":
				condition = false
				break
		return .requirements(origin, _target) && condition
	else:
		return .requirements(origin, _target)