extends Node

# Declare instance variables here
var hp: int
var max_hp: int
var shield: int
var max_shield: int
var initial_draw: int
var draw_per_turn: int
var deck: Array
var hp_gauge
var shield_text


func _init(hp: int = 50, max_hp: int = 50, shield: int = 0, max_shield: int = 999, initial_draw: int = 5, draw_per_turn: int = 2, deck: Array = [], hp_gauge = null, shield_text = null):		
	self.hp = hp
	self.max_hp = max_hp	
	self.shield = shield	
	self.max_shield = max_shield
	self.initial_draw = initial_draw
	self.draw_per_turn = draw_per_turn
	self.deck = deck
	self.hp_gauge = hp_gauge
	self.shield_text = shield_text

	set_hp(max_hp)
	initialize_deck()

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
func damage(amount):
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

func add_shields(amount):
	self.shield += amount
	update()

# Function to heal the player
func heal(amount):
	self.hp += amount
	self.hp = clamp(self.hp, 0, self.max_hp)
	update()

func update():
	if(self.hp_gauge != null):
		self.hp_gauge.new_value(float(self.hp)/float(self.max_hp)*100)
	if(self.shield_text != null):
		self.shield_text.text = "[" + str(self.shield) + "]"