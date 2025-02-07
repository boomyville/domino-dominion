extends DominoContainer

# Ultra Violence
# Deal damage equal to the nuumber of attack dominos in draw pile
# Downgrade - Deal damage equal to number of attack dominos in hand
# Upgrade+ - Deal damage equal to the nuumber of attack dominos in draw pile and hand
# Upgrade++ - Deal damage equal to the nuumber of attack dominos in draw pile, hand, void space and discard pile

func _init():
	pip_data = { "left": [6, null, "static"], "right": [1, 5, "dynamic"] }
	domino_name = "Ultra Violence"
	criteria = ["uncommon", "physical", "any"]
	action_point_cost = 1
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Attacks in hand: " + BBCode.bb_code_attack()
		1:
			return "Attacks in " + BBCode.bb_code_pile() + ": "+ BBCode.bb_code_attack()
		2:
			return "Attacks in hand and draw pile: "+ BBCode.bb_code_attack()
		3:
			return "Attacks in play: "+ BBCode.bb_code_attack()
		_:
			print("Error: Invalid upgrade level")
			return "Attacks in hand: " + BBCode.bb_code_attack()
	

func get_detailed_description():
	var msg = get_pip_description()

	match get_upgrade_level():
		0:
			msg += "Deal damage equal to the number of attack dominos in hand"
		1:
			msg += "Deal damage equal to the number of attack dominos in the draw pile"
		2:
			msg += "Deal damage equal to the number of attack dominos in the draw pile and hand"
		3:
			msg += "Deal damage equal to the number of attack dominos in the draw pile, hand, void space and discard pile"
		_:
			print("Error: Invalid upgrade level")
			msg += "Deal damage equal to the number of attack dominos in hand"

	if (game.is_battle()):	
		msg += " (" + str(damage_value()) + ")"  
	return msg

func damage_value() -> int:
	match get_upgrade_level():
		0:
			var attack_count = 0
			var domino_collection = Game.get_node("Game").get_target_collection(user, "HAND")
			for domino in domino_collection:
				if "Attack" in domino.filename: 
					attack_count += 1
			return attack_count
		1:
			var attack_count = 0
			var domino_collection = Game.get_node("Game").get_target_collection(user, "PILE")
			for domino in domino_collection:
				if "Attack" in domino.filename: 
					attack_count += 1
			return attack_count
		2:
			var attack_count = 0
			var domino_collection = Game.get_node("Game").get_target_collection(user, "PILE")
			for domino in domino_collection:
				if "Attack" in domino.filename: 
					attack_count += 1
			var domino_collection2 = Game.get_node("Game").get_target_collection(user, "HAND")
			for domino in domino_collection2:
				if "Attack" in domino.filename: 
					attack_count += 1
			return attack_count
		3:
			var attack_count = 0
			var domino_collection = Game.get_node("Game").get_target_collection(user, "PILE")
			for domino in domino_collection:
				if "Attack" in domino.filename: 
					attack_count += 1
			var domino_collection2 = Game.get_node("Game").get_target_collection(user, "HAND")
			for domino in domino_collection2:
				if "Attack" in domino.filename: 
					attack_count += 1
			var domino_collection3 = Game.get_node("Game").get_target_collection(user, "VOID")
			for domino in domino_collection3:
				if "Attack" in domino.filename: 
					attack_count += 1
			var domino_collection4 = Game.get_node("Game").get_target_collection(user, "DISCARD")
			for domino in domino_collection4:
				if "Attack" in domino.filename: 
					attack_count += 1
			return attack_count
		_:
			print("Error: Invalid upgrade level")
			return 0

func effect(origin, target):
	.effect(origin, target)
	
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	
	var animation = preload("res://Battlers/Animations/UltraViolence.tscn")

	spell(origin, target, outcome, "stab", animation)

	

