extends DominoContainer

# Sacrifice
# Lose 2 HP. Pick any domino to draw
# Downgrade - Lose 10 HP
# Upgrade+ - Pick any 2 dominos to draw

func _init():
	pip_data = { "left": [-1, null, "static"], "right": [-1, null, "static"] }
	domino_name = "Sacrifice"
	criteria = ["rare", "top_stack"]
	initiate_domino()
	
func get_description() -> String:
	return BBCode.bb_code_search() + " " + BBCode.bb_code_pile() + "\n" + str(draw_value()) + BBCode.bb_code_draw() + "\nSelf: Lose " + str(hp_value()) + " HP"

func draw_value() -> int:
	match get_upgrade_level():
		0, 1:
			return 1
		2:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 1

func hp_value() -> int:
	match get_upgrade_level():
		0:
			return 10
		1, 2:
			return 2
		_:
			print("Error: Invalid upgrade level")
			return 10

func get_detailed_description():
	var msg = get_pip_description()
	msg += "Look  " + BBCode.bb_code_search() + " at your " +  BBCode.bb_code_pile() + " draw pile\n"
	
	if (draw_value() == 1):
		msg += "Select 1 domino to draw into your hand\n"
	else:
		msg += "Select up to 2 dominos to draw into your hand\n"
	
	msg += "Lose " + str(hp_value()) +" HP"
	return msg

func effect(origin, target):
	Game.get_node("Game").domino_selection(1, draw_value(), self, self.user, "pile", Game.get_node("Game").string_to_battler(get_current_user()).get_draw_pile().size(), "hand", {}, true)
	# Wait until the discard is complete before continuing
	yield(self, "pre_effect_complete")

	.effect(origin, target)
	
	var animation = preload("res://Battlers/Animations/Sacrifice.tscn")
	spell(origin, origin, 0, "defend", animation)

	origin.self_damage(hp_value(), false)

func requirements(origin, _target):
	return .requirements(origin, _target) &&  origin.hp > hp_value()
		
