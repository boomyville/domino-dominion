extends "res://Battlers/Battler.gd"

func _init(hp: int = 50, max_hp: int = 50, shield: int = 0, max_shield: int = 999, initial_draw: int = 5, draw_per_turn: int = 2, deck: Array = []):
	._init(hp, max_hp, shield, max_shield, initial_draw, draw_per_turn, deck)

func _ready():
	self.hp_gauge = get_node("/root/Main/GUIContainer/PlayerHP")
	self.shield_text = get_node("/root/Main/GUIContainer/PlayerShields")
	update()
	
func initialize_deck():
	# Create the player's deck of dominos
	for _i in range(4):
		var domino = load("res://Domino/Attack/WildSwing.tscn").instance()
		add_to_deck(domino, "player")
	for _i in range(5):
		var domino = load("res://Domino/Attack/Strike.tscn").instance()
		add_to_deck(domino, "player")
	for _i in range(5):
		var domino = load("res://Domino/Attack/QuickStrike.tscn").instance()
		add_to_deck(domino, "player")
	for _i in range(5):
		var domino = load("res://Domino/Skill/Block.tscn").instance()
		add_to_deck(domino, "player")
