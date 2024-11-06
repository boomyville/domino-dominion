extends DominoContainer

func _init():
	number1 = random_value()
	number2 = random_value()
	domino_name = "Glance"
	criteria = ["Common"]
	description = bb_code_search() + " top 5: " + bb_code_pile() + "\n" + "1 " + bb_code_draw()

func effect(origin, target):
	Game.get_node("Game").domino_selection(1, 1, self, self.user, "pile", 5, "hand")
	# Wait until the discard is complete before continuing
	yield(self, "pre_effect_complete")

	.effect(origin, target)
	