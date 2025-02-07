extends DominoContainer

# Replay Attack
# Deal damage. Return a random attack domino back into your hand
# Downgrade - Apply 1 paralyse to self
# Upgrade+ - Deal extra damage
# Upgrade++ - Left pip becomes erratic. Deal extra damage
# Upgrade+++ - Left pip becomes wild. Deal extra damage

func _init():
	domino_name = "Replay Attack"
	criteria = ["Common", "any"]
	action_point_cost = 1
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		3:
			pip_data = { "right": [-1, null, "static"], "left": [-1, null, "static"] }
		2:
			pip_data = { "right": [-1, null, "static"], "left": [1, 6, "erratic"] }
		1:
			pip_data = { "right": [-1, null, "static"], "left": [1, 6, "erratic"] }
			pip_data = { "left": [-1, null, "dynamic"], "right": [1, 6, "dynamic"] }
		0:
			pip_data = { "left": [-1, null, "dynamic"], "right": [1, 6, "dynamic"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [-1, null, "dynamic"], "right": [1, 6, "dynamic"] }

func get_description():
	match get_upgrade_level():
		0:
			return "Return random attack domino to hand\n" + str(damage_value()) + BBCode.bb_code_attack() + "\nSelf: 1" + BBCode.bb_code_paralysis() 
		1, 2, 3, 4:
			return "Return random attack domino to hand\n" + str(damage_value()) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Place a random played attack domino back into your hand\n"
	msg += "Deal " + str(get_damage_value(4)) + BBCode.bb_code_attack()
	match get_upgrade_level():
		0:
			msg += "\nSelf: 1 " + BBCode.bb_code_paralysis() + " Paralysis"
			msg += "\nWhen paralysed, only dominos with matching left pips are playable"

	return msg

func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 4
		2, 3, 4:
			return get_upgrade_level() + 5
		_:
			print("Error: Invalid upgrade level")
			return 4

func effect(origin, target):
	.effect(origin, target)
	
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))

	var animation = preload("res://Battlers/Animations/ReplayAttack.tscn")
	
	spell(origin, target,  outcome, "spell", animation)

	var played_dominos = Game.get_node("Game").play_board.get_children()
	var candidates = []
	for domino in played_dominos:
		#print("Checking: " + domino.filename + " " + str(domino.get_user()) + " " + str(origin.battler_type))
		if domino.filename.find("Attack") == -1:
			#print(domino.domino_name + " is not an attack domino")
			pass
		elif domino.get_user().to_upper() != origin.battler_type.to_upper():
			#print(domino.domino_name + " does not belong to " + origin.battler_type)
			pass
		else:
			#print(domino.domino_name + " is a candidate")
			candidates.append(domino)
	candidates.shuffle()

	if candidates.size() > 0:
		print("Replay Attack: " + candidates[0].domino_name)
		Game.get_node("Game").return_playfield_dominos([candidates[0]], "HAND")

	if get_upgrade_level() == 0:
		
		var effect =  load("res://Effect/Paralysis.gd").new()
		effect.duration = 1
		apply_effect(effect, origin, effect.duration)
