extends Node

# UI elements
onready var player_hand = get_node("../GameBoard/PlayerHand")  # Player's hand container
onready var ai_hand = get_node("../GameBoard/EnemyHand")  # AI's hand container (non-clickable)
onready var play_board = get_node("../GameBoard/PlayBoard")   # Play field container
onready var end_turn_button = get_node("../GameBoard/EndTurn")      # Button for ending turn

# Domino data
var player_dominos = []
var ai_dominos = []
var player_pile = []
var ai_pile = []

var last_played_number = -1  # The number to match for the next move
var player_turn = true       # Keep track of whose turn it is

# Called when the node enters the scene tree
func _ready():
	randomize() # Initialize random number generator
	initialize_domino_sets()
	populate_player_hand()
	populate_ai_hand()
	draw_first_domino()

	# Connect the end turn button to switch turns
	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")

# Initialize each player's domino sets (20 random dominos) and draw 5 to start
func initialize_domino_sets():
	player_pile = generate_random_dominos(20)
	ai_pile = generate_random_dominos(20)
	
	# Each player draws 5 dominos from their pile at the start
	player_dominos = draw_dominos_from_pile(player_pile, 5)
	ai_dominos = draw_dominos_from_pile(ai_pile, 5)

# Generate a list of random dominos (20 pairs of numbers between 0 and 6)
func generate_random_dominos(amount: int) -> Array:
	var dominos = []
	for _i in range(amount):
		var n1 = randi() % 7
		var n2 = randi() % 7
		dominos.append([n1, n2])
	return dominos

# Draw `count` dominos from the pile
func draw_dominos_from_pile(pile: Array, count: int) -> Array:
	var drawn_dominos = []
	for _i in range(count):
		if pile.size() > 0:
			drawn_dominos.append(pile.pop_back())  # Take a domino from the end of the pile
	return drawn_dominos

# Populate the player's hand with clickable domino buttons
func populate_player_hand():
	for domino in player_dominos:
		var domino_instance = preload("res://Domino.tscn").instance()
		domino_instance.set_numbers(domino[0], domino[1])
		domino_instance.set_clickable(true) # Set clickable for player dominos
		domino_instance.connect("domino_pressed", self, "_on_domino_pressed")
		player_hand.add_child(domino_instance)

# Populate the AI's hand with non-clickable dominos
func populate_ai_hand():
	for domino in ai_dominos:
		var domino_instance = preload("res://Domino.tscn").instance()
		domino_instance.set_numbers(domino[0], domino[1])
		domino_instance.set_clickable(false)  # AI dominos are not clickable
		ai_hand.add_child(domino_instance)

# Draw the first domino on the play field (determined by dice roll)
func draw_first_domino():
	var first_domino_number = randi() % 6 + 1  # Roll a die (1-6)
	var first_domino = preload("res://Domino.tscn").instance()
	first_domino.set_numbers(first_domino_number, first_domino_number)  # Can be adjusted to be random
	play_board.add_child(first_domino)
	first_domino.set_clickable(false)  # Disable buttons for the first domino
	last_played_number = first_domino_number  # Set the last played number
	print("First number: " + str(first_domino_number))

# Handle the event when a player plays a domino
func _on_domino_pressed(domino_container):
	if player_turn:
		var number1 = domino_container.number1
		var number2 = domino_container.number2
		
		# Check if the domino can be played (if either number matches the last played number)
		if number1 == last_played_number or number2 == last_played_number:
			move_domino_to_playfield(domino_container)
		else:
			print("Invalid move. You can only play dominos that match the last number.")

		
# Move a valid domino to the play field and disable its buttons
# Move a valid domino to the play field and disable its buttons
func move_domino_to_playfield(domino_container):
	var number1 = domino_container.number1
	var number2 = domino_container.number2

	# Swap the numbers if needed, so the correct number becomes the new last played number
	if number2 == last_played_number:
		var temp = number1
		number1 = number2
		number2 = temp

	# Update the domino with the new correct numbers after swapping (if applicable)
	domino_container.set_numbers(number1, number2)

	if player_turn:
		player_hand.remove_child(domino_container)  # Remove from player's hand
	else:
		ai_hand.remove_child(domino_container)  # Remove from AI's hand
	
	play_board.add_child(domino_container)      # Add to play field
	domino_container.set_clickable(false)  # Disable buttons
	
	# Update the last played number (the second number of the domino)
	last_played_number = number2
	print("Played a domino! Last played number is now: ", last_played_number)
	
# End the player's turn and start the AI's turn
func _on_end_turn_pressed():
	if(!check_game_over()):  # Check if the game is over before switching turns
		if player_turn:
			player_turn = false
			end_turn_button.disabled = true  # Disable end turn button during AI's turn
			ai_play()

# AI plays its dominos
func ai_play():

	var count = 0;

	while true:
		var domino_played = false
		for domino in ai_dominos:
			var number1 = domino[0]
			var number2 = domino[1]
			print("Calculating move with: " + str(number1) + ", " + str(number2))
			
			if number1 == last_played_number or number2 == last_played_number:
				var domino_instance = ai_hand.get_child(ai_dominos.find(domino))  # Get the actual domino instance in the AI hand
				
				print("AI plays: " + str(number1) + ", " + str(number2))
				yield(get_tree().create_timer(1.0), "timeout")  # Wait 1 second before playing
				move_domino_to_playfield(domino_instance)
				ai_dominos.erase(domino)  # Remove domino from AI's list
				count += 1
				domino_played = true
				break  # Break the for loop to reiterate the while loop
		
		if not domino_played:
			break  # Exit the while loop if no domino was played

	end_turn_button.disabled = false  # Enable end turn button
	print("AI cannot play any more moves, player's turn resumes. AI played " + str(count) + " dominos.")	
	player_turn = true

	if(!check_game_over()):
		draw_additional_player_dominos(2)
		draw_additional_enemy_dominos(2)

# Check if the game is over
func check_game_over():
	if player_dominos.size() == 0:
		print("Player wins!")
		return true
	elif ai_dominos.size() == 0:
		print("AI wins!")
		return true
	else:
		print("Game continues...")

# Draw additional dominos for the player
func draw_additional_player_dominos(count: int):
	var new_dominos = draw_dominos_from_pile(player_pile, count)
	add_domino_to_hand(new_dominos, "player")

# Draw additional dominos for the enemy
func draw_additional_enemy_dominos(count: int):
	var new_dominos = draw_dominos_from_pile(ai_pile, count)
	add_domino_to_hand(new_dominos, "enemy")

# Add domino to hand
func add_domino_to_hand(dominos: Array, type: String = "player"):
	for domino in dominos:
		var domino_instance = preload("res://Domino.tscn").instance()
		domino_instance.set_numbers(domino[0], domino[1])
		
		if type == "player":
			player_dominos.append(domino)
			domino_instance.set_clickable(true)
			domino_instance.connect("domino_pressed", self, "_on_domino_pressed")
			player_hand.add_child(domino_instance)
			print("Added domino to player's hand: " + str(domino))
		elif type == "enemy":
			ai_dominos.append(domino)
			domino_instance.set_clickable(false)
			ai_hand.add_child(domino_instance)
			print("Added domino to AI's hand: " + str(domino))
