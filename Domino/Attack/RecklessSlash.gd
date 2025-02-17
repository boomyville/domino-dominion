extends DominoContainer

# Reckless Slash
# Discard entire hand. Deal damage equal to the number of dominos discarded 
# Downgrade - Action cost 1
# Upgrade+ - Draw 1 domino
# Upgrade++ - Select X dominos to discard, deal damage equal to number of dominos discarded
# Upgrade+++ - Wild 

func _init():
	domino_name = "Reckless Slash"
	criteria = ["common", "physical", "sword", "top_stack"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0:
			action_point_cost = 1
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "static"] }
		1, 2, 3:
			action_point_cost = 0
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "static"] }
		4:
			action_point_cost = 0
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			action_point_cost = 1
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "static"] }
	.initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0, 1:
			return BBCode.bb_code_discard() + " all dominos" + "\n" + "Discarded dominos: " + BBCode.bb_code_attack() 
		2:
			return BBCode.bb_code_discard() + " all dominos" + "\n" + "Discarded dominos: " + BBCode.bb_code_attack() + "\nDraw 1 domino"
		3, 4:
			return BBCode.bb_code_discard() + " any dominos" + "\n" + "Discarded dominos: " + BBCode.bb_code_attack() + "\nDraw 1 domino"
		_:
			print("Error: Invalid upgrade level")
			return BBCode.bb_code_discard() + " all dominos" + "\n" + "Discarded dominos: " + BBCode.bb_code_attack() 

func get_detailed_description():
	var msg = get_pip_description()

	match get_upgrade_level():
		0, 1:
			msg += "Discard all dominos\nDeal damage equal to number of dominos discarded\n"
		2:
			msg += "Discard all dominos\nDeal damage equal to number of dominos discarded\n"
			msg += "Draw 1 domino\n"
		3, 4:
			msg += "Discard any number of dominos\nDeal damage equal to number of dominos discarded\n"
			msg += "Draw 1 domino\n"
		_:
			print("Error: Invalid upgrade level")
			msg += "Discard all dominos\nDeal damage equal to number of dominos discarded\n"

	return msg

func effect(origin, target):

	var hand_size = origin.get_hand().get_children().size()

	if get_upgrade_level() > 2:
		Game.get_node("Game").domino_selection(0, Game.get_node("Game").get_hand(origin.battler_type).get_children().size(), self, self.user, "hand", -1, "discard")
		# Wait until the discard is complete before continuing
		yield(self, "pre_effect_complete")
	else:
		Game.get_node("Game").trigger_domino_transfer(self, true, Game.get_node("Game").get_hand(origin.battler_type).get_children().size(), origin.name.to_upper(), "Hand", "Discard")

	if get_upgrade_level() > 1:
		Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "Any")

	.effect(origin, target)

	var damage = hand_size - origin.get_hand().get_children().size()

	var outcome = attack_message(origin, target, target.damage(origin, damage))
	
	var animation = preload("res://Battlers/Animations/RecklessSlash.tscn")

	quick_attack(origin, target, outcome, "rising_blow", "hop_away", animation)
