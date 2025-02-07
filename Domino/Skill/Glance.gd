extends DominoContainer

# Glance
# Look at the top " + str(peek_value() + " dominos in your draw pile and draw 1 of them
# Downgrade - Look at the top " + str(peek_value() + " dominos in your draw pile and draw 1 of them
# Upgrade+ - Look at the top " + str(peek_value() + " dominos in your draw pile and draw 1 of them
# Upgrade++ - Look at the top " + str(peek_value()) + " dominos in your draw pile and draw 1 of them
# Upgrade+++ - Look at the top " + str(peek_value()) + " dominos in your draw pile and draw 2 of them

func _init():
	pip_data = { "left": [1, 6, "dynamic"], "right": [1, 6, "dynamic"] }
	domino_name = "Glance"
	criteria = ["common", "any"]
	initiate_domino()

func get_description() -> String:
	match get_upgrade_level():
		0:
			return BBCode.bb_code_search() + " top " + str(peek_value()) + ": " + BBCode.bb_code_pile() + "\n" + str(draw_value()) + BBCode.bb_code_draw()
		1:
			return BBCode.bb_code_search() + " top " + str(peek_value()) + ": " + BBCode.bb_code_pile() + "\n" + str(draw_value()) + BBCode.bb_code_draw()
		2:
			return BBCode.bb_code_search() + " top " + str(peek_value()) + ": " + BBCode.bb_code_pile() + "\n" + str(draw_value()) + BBCode.bb_code_draw()
		3:
			return BBCode.bb_code_search() + " top " + str(peek_value()) + ": " + BBCode.bb_code_pile() + "\n" + str(draw_value()) + BBCode.bb_code_draw()
		4:
			return BBCode.bb_code_search() + " top " + str(peek_value()) + ": " + BBCode.bb_code_pile() + "\n" + str(draw_value()) + BBCode.bb_code_draw()
		_:
			print("Error: Invalid upgrade level")
			return BBCode.bb_code_search() + " top " + str(peek_value()) + ": " + BBCode.bb_code_pile() + "\n" + str(draw_value()) + BBCode.bb_code_draw()

func draw_value() -> int:
	match get_upgrade_level():
		0, 1, 2, 3:
			return 1
		4:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 1

func peek_value() -> int:
	match get_upgrade_level():
		0:
			return 2
		1:
			return 3
		2:
			return 5
		3, 4:
			return 7
		_:
			print("Error: Invalid upgrade level")
			return 2

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Look  " + BBCode.bb_code_search() + " at the top " + str(peek_value()) + " dominos of your " +  BBCode.bb_code_pile() + " draw pile\n"
	msg += "Select " + str(draw_value())+ " of the dominos to draw into your hand"
	return msg

func effect(origin, target):
	Game.get_node("Game").domino_selection(1, draw_value(), self, self.user, "pile", peek_value(), "hand")
	# Wait until the discard is complete before continuing
	yield(self, "pre_effect_complete")

	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/Glance.tscn")
	spell(origin, origin, 0, "stab", animation)
