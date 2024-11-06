extends DominoContainer

func _init():
	number1 = -1;
	number2 = random_value()	
	domino_name = "Wild Swing"
	description = str(5) + bb_code_attack() + "\n" + "1" + bb_code_discard() + "\n" + "Self: 1 " + bb_code_vulnerable()

func effect(origin, target):
	Game.get_node("Game").domino_selection(1, 1, self, self.user, "hand", -1, "discard")
	# Wait until the discard is complete before continuing
	yield(self, "pre_effect_complete")

	.effect(origin, target)
	attack_message(origin, target, target.damage(origin, 5))
	var effect =  load("res://Effect/Vulnerable.gd").new()
	effect.duration = 1
	apply_effect(effect, origin)

func requirements(origin, target):
	return origin.get_hand().get_children().size() > 1
