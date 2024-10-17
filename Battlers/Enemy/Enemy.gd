extends "res://Battlers/Battler.gd"

func initialize_deck():
	# Create the player's deck of dominos
	for _i in range(4):
		var domino = load("res://Domino/Attack/WildSwing.tscn").instance()
		add_to_deck(domino, "enemy")
	for _i in range(5):
		var domino = load("res://Domino/Attack/Strike.tscn").instance()
		add_to_deck(domino, "enemy")
