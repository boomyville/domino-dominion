extends "res://Battlers/Battler.gd"

func _init(battler_name: String = "Enemy", hp: int = 50, max_hp: int = 50, shield: int = 0, max_shield: int = 999, initial_draw: int = 5, draw_per_turn: int = 2, deck: Array = []):
	._init(battler_name, hp, max_hp, shield, max_shield, initial_draw, draw_per_turn, deck)

func _ready():
	self.hp_gauge = Game.get_node("GUIContainer/EnemyHP")
	self.effect_text = Game.get_node("GUIContainer/EnemyEffects")
	self.shield_text = Game.get_node("GUIContainer/EnemyShields")
	update()

func initialize_deck():
	# Create the player's deck of dominos
	for _i in range(4):
		var domino = load("res://Domino/Attack/QuickStrike.tscn").instance()
		add_to_deck(domino, "enemy")
	for _i in range(5):
		var domino = load("res://Domino/Attack/Strike.tscn").instance()
		add_to_deck(domino, "enemy")
	.initialize_deck()