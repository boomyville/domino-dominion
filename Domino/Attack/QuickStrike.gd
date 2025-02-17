extends DominoContainer

# Quick Strike
# Deal damage. Can only be used if first domino played
# Downgrade - Reduce damage dealt
# Upgrade+ - Draw 1 domino
# Upgrade++ - Right pip becomes wild
# Upgrade+++ - Decrease action point cost. 

func _init():
	domino_name = "Quick Strike"
	criteria = ["common", "any"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			action_point_cost = 1
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
		3:
			action_point_cost = 1
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		4:
			action_point_cost = 0
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")		
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
			action_point_cost = 1
	.initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0, 1:
			return "Playable as first tile" + "\n" + str(damage_value()) + BBCode.bb_code_attack()
		2, 3, 4:
			return "Playable as first tile" + "\n" + str(damage_value()) + BBCode.bb_code_attack() + "\nDraw 1 domino"
		_:
			print("Error: Invalid upgrade level")
			return "Playable as first tile" + "\n" + str(damage_value()) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()

	match get_upgrade_level():
		0, 1:
			msg += "Requirement: Must be the first domino played this turn\n"
		2, 3, 4:
			msg += "Requirement: Must be the first domino played this turn\n"
			msg += "Draw 1 domino\n"
		_:
			print("Error: Invalid upgrade level")
			msg += "Requirement: Must be the first domino played this turn\n"
			
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func damage_value() -> int:
	match get_upgrade_level():
		0:
			return 3
		1, 2:
			return 5
		3, 4:
			return 8
		_:
			print("Error: Invalid upgrade level")
			return 6

func effect(origin, target):
	.effect(origin, target)

	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/QuickStrike.tscn")
	quick_attack(origin, target, outcome, "zoom_in", "hop_away", animation)

	if get_upgrade_level() >= 2:
		Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "ANY")

	
func requirements(origin, _target):
	return .requirements(origin, _target) &&  origin.dominos_played_this_turn.size() == 0
