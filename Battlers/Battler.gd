extends Node

# Declare instance variables here
var battler_name: String
var hp: int
var max_hp: int
var shield: int
var max_shield: int
var initial_draw: int
var draw_per_turn: int
var deck: Array
var hp_gauge
var shield_text

var dominos_played: Array
var dominos_played_this_turn: Array

func _init(battler_name: String = "Battler", hp: int = 50, max_hp: int = 50, shield: int = 0, max_shield: int = 999, initial_draw: int = 5, draw_per_turn: int = 2, deck: Array = [], hp_gauge = null, shield_text = null):		
	self.battler_name = battler_name
	self.hp = hp
	self.max_hp = max_hp	
	self.shield = shield	
	self.max_shield = max_shield
	self.initial_draw = initial_draw
	self.draw_per_turn = draw_per_turn
	self.deck = deck
	self.hp_gauge = hp_gauge
	self.shield_text = shield_text
	self.dominos_played = []
	self.dominos_played_this_turn = []

	set_hp(max_hp)
	initialize_deck()

func name():
	return self.battler_name

func initialize_deck():
	pass

func get_initial_draw() -> int:
	return self.initial_draw

func get_draw_per_turn() -> int:
	return self.draw_per_turn
	
func get_deck():
	for domino in self.deck:
		print(domino.get_user(), ": ", domino.get_numbers())
	return self.deck

func add_to_deck(domino: DominoContainer, type: String):
	domino.set_user(type)
	self.deck.append(domino)
	
# Function to set player's HP
func set_hp(new_hp):
	self.hp = clamp(new_hp, 0, self.max_hp)
	update()

# Function to deal damage to the player
func damage(amount) -> int:
	print("Dealing damage: ", amount)
	var shield_difference = self.shield - amount
	if shield_difference < 0:
		self.shield = 0
		amount = abs(shield_difference)
		self.hp -= amount
		self.hp = clamp(self.hp, 0, self.max_hp)
	else:
		print("Full shield block")
		self.shield -= amount
	update()
	return amount

func add_shields(amount) -> int:
	self.shield += amount
	update()
	return amount

# Function to heal the player
func heal(amount) -> int:
	self.hp += amount
	self.hp = clamp(self.hp, 0, self.max_hp)
	update()
	return amount

func update():
	if(self.hp_gauge != null):
		self.hp_gauge.new_value(float(self.hp)/float(self.max_hp)*100)
		self.hp_gauge.get_node("HPLabel").text = str(self.hp) + " / " + str(self.max_hp)
	if(self.shield_text != null):
		self.shield_text.text = "[" + str(self.shield) + "]"