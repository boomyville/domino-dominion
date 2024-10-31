extends DominoContainer

func _init():
	number1 = random_value()
	number2 = random_value()
	domino_name = "Defensive Position"
	description = "Self: 3" + bb_code_shield() + "\n" + "1" + bb_code_draw()
func effect(origin, target):
	.effect(origin, target)
	if(origin.name.to_upper() == "PLAYER"):
		Game.get_node("Game").draw_player_hand(1)
	elif(origin.name.to_upper() == "ENEMY"):
		Game.get_node("Game").draw_enemy_hand(1)
	shield_message(origin, origin, origin.add_shields(3))