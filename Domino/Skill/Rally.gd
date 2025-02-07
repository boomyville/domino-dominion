extends DominoContainer

# Rally
# Draw 1 random skill and shield
# Downgrade - Draw 1 random skill (no shield)
# Upgrade+ - Gain extra shields
# Upgrade++ - Right pip becomes wild
# Upgrade+++ - Draw 2 random skills

func _init():
	domino_name = "Rally"
	criteria = ["common", "sword"]
	initiate_domino()

func initiate_domino():
	match get_upgrade_level():
		0, 1, 2:
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
		3, 4:
			pip_data = { "left": [1, 6, "dynamic"], "right": [-1, null, "static"] }
		_:
			print("Error: Invalid upgrade level")
			pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	.initiate_domino()
	
func shield_value() -> int:
	match get_upgrade_level():
		0:
			return 0
		1:
			return 3
		2, 3, 4:
			return 6
		_:
			print("Error: Invalid upgrade level")
			return 0

func draw_value() -> int:
	match get_upgrade_level():
		0, 1, 2, 3:
			return 1
		4:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 1

func get_description() -> String:
	match get_upgrade_level():
		0:
			return "1" + BBCode.bb_code_draw() + " Skill"
		1, 2, 3, 4:
			return "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + "\n" + str(draw_value()) + BBCode.bb_code_draw() + " Skill"
		_:
			return "1" + BBCode.bb_code_draw() + " Skill"
		
func get_detailed_description():
	var msg = get_pip_description()
	if shield_value() > 0:
		msg += "Self: " + str(get_shield_value(shield_value())) + BBCode.bb_code_shield() + " shields\n"
	msg += "Draw " + str(draw_value()) + " random skill domino into your hand"
	return msg

func effect(origin, target):
	.effect(origin, target)
	Game.get_node("Game").draw_hand(draw_value(), origin.name.to_upper(), "Skill")
	var outcome = 0
	if(shield_value() > 0):
		outcome = shield_message(origin, origin, origin.add_shields(shield_value()))
	var animation = preload("res://Battlers/Animations/Rally.tscn")
	spell(origin, origin, outcome, "defend", animation)