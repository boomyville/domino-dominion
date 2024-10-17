extends Node

# Battler's variables
var hp = 50
var max_hp = 50
var deck = [] # The battler's deck of dominos
var initial_draw = 5 # Starting draw size
var draw_per_turn = 2 # Number of dominos drawn per turn

func _init():
	set_hp(max_hp)
	initialize_deck()

func initialize_deck():
	pass

func get_initial_draw() -> int:
	return initial_draw

func get_draw_per_turn() -> int:
	return draw_per_turn
	
func get_deck():
	for domino in deck:
		print(domino.get_user(), ": ", domino.get_numbers())
	return deck


func add_to_deck(domino: DominoContainer, type: String):
	domino.set_user(type)
	deck.append(domino)
	
# Function to set player's HP
func set_hp(new_hp):
    hp = clamp(new_hp, 0, max_hp)

# Function to deal damage to the player
func damage(amount):
    hp -= amount
    hp = clamp(hp, 0, max_hp)

# Function to heal the player
func heal(amount):
    hp += amount
    hp = clamp(hp, 0, max_hp)

