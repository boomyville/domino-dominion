extends DominoContainer

# Afterburner
# Apply Burn to self
# Downgrade - Increase burn amount
# Upgrade+ - Decrease burn amount
# Upgrade++ - Also grant 1 action point
# Upgrade+++ - Also draw 1 domino


func _init():
	pip_data = { "left": [-1, null, "static"], "right": [-1, null, "static"] }
	domino_name = "Afterburner"
	criteria = ["common", "any"]
	initiate_domino()

func burn_value() -> int:
	match get_upgrade_level():
		0:
			return 5
		1:
			return 3
		2, 3, 4:
			return 1
		_:
			print("Error: Invalid upgrade level")
			return 3

func get_description():
	match get_upgrade_level():
		0, 1, 2:
			return "Self:" + str(burn_value()) + BBCode.bb_code_burn()
		3:
			return "Self:" + str(burn_value()) + BBCode.bb_code_burn() + "\n" + "1 " + BBCode.bb_code_action_point()
		4:
			return "Self:" + str(burn_value()) + BBCode.bb_code_burn() + "\n" + "1 " + BBCode.bb_code_action_point() + "\n" + "1 " + BBCode.bb_code_draw()
		_:
			print("Error: Invalid upgrade level")
			return "Self:" + str(burn_value()) + BBCode.bb_code_burn()

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Self: " + str(burn_value()) + BBCode.bb_code_burn() + " burn\n"
	msg += "Burn causes blockable damage when attacking"
	if (get_upgrade_level() == 3):
		msg += "\nGrant 1 " + BBCode.bb_code_action_point() + " action point"
	if (get_upgrade_level() == 4):
		msg += "\nGrant 1 " + BBCode.bb_code_action_point() + " action point" + "\nDraw 1 " + BBCode.bb_code_draw() + " domino"
	return msg

func effect(origin, target):
	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/Afterburner.tscn")
	spell(origin, origin, 0, "spell", animation)

	if (get_upgrade_level() == 3):
		origin.action_points += 1
	if (get_upgrade_level() == 4):
		origin.action_points += 1
		Game.get_node("Game").draw_hand(1, origin.name.to_upper(), "any")

	var effect =  load("res://Effect/Burn.gd").new()
	effect.triggers = burn_value()
	apply_effect(effect, origin, burn_value())
	
