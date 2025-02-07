extends DominoContainer

# Panic Attack
# Deal damage and apply ephemeral to all dominos in hand
# Downgrade - Void all dominos in hand
# Upgrade+ - Increase damage
# Upgrade++ - Right pip becomes erratic
# Upgrade++6 - Right pip becomes volatile

func _init():
	domino_name = "Panic Attack"
	criteria = ["common", "any"]
	action_point_cost = 1
	initiate_domino()

func initiate_domino() -> void:
	match get_upgrade_level():
		4:
			pip_data = { "left": [1, 6, "volatile"], "right": [-1, null, "static"] }
		3:
			pip_data = { "left": [1, 6, "erratic"], "right": [-1, null, "static"] }
		2, 1, 0:
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
	.initiate_domino()
	
func damage_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 5
		2:
			return 8
		3:
			return 10
		4:
			return 12
		_:
			print("Error: Invalid upgrade level")
			return 5
	
func get_description() -> String:
	match get_upgrade_level():
		0:
			return "Void hand" + "\n" + str(damage_value()) + BBCode.bb_code_attack()
		1, 2, 3, 4:
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
		_:
			print("Error: Invalid upgrade level")
			return "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()

func get_detailed_description():
	var msg = get_pip_description()
	match get_upgrade_level():
		0:
			msg += "Void all dominos in hand\n"
		1, 2, 3, 4:
			msg += "Apply "  + BBCode.bb_code_ephemeral() + " ephemeral to all dominos in hand\n"
			msg += "Ephemeral dominos are sent to void space if not played this turn\n" 
	msg += "Deal " + str(get_damage_value(damage_value())) + BBCode.bb_code_attack()
	return msg

func effect(origin, target):
	.effect(origin, target)
	
	var outcome = attack_message(origin, target, target.damage(origin, damage_value()))
	var animation = preload("res://Battlers/Animations/PanicAttack.tscn")
	quick_attack(origin, target, outcome, "zoom_in", "hop_away", animation)

	match get_upgrade_level():
		0:
			Game.get_node("Game").trigger_domino_transfer(self, true, origin.get_hand().get_children().size(), target.battler_type, "Hand", "Void")
		1, 2, 3, 4:		
			for domino in origin.get_hand().get_children():
				print(domino.domino_name + " set to ephemeral")
				domino.set_ephemeral(true)
		_:
			print("Error: Invalid upgrade level")

