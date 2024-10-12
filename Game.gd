extends Node

# Load the DominoContainer scene
onready var DominoContainerScene = preload("res://Domino.tscn")

# UI elements
onready var player_hand = get_node("../GameBoard/PlayerHand") # Player's hand container
onready var ai_hand = get_node("../GameBoard/EnemyHand") # AI's hand container (non-clickable)
onready var play_board = get_node("../GameBoard/PlayBoard") # Play field container
onready var end_turn_button = get_node("../GameBoard/EndTurn") # Button for ending turn

# Domino data
var player_dominos = []
var ai_dominos = []
var player_pile = []
var ai_pile = []

var last_played_number = -1 # The number to match for the next move
var player_turn = true # Keep track of whose turn it is

# Called when the node enters the scene tree
func _ready():
	print("Loading...")
	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")

	initialize_domino_sets() # Generate the dominos for player and AI

	# You may also want to initialize the board with the first domino
	draw_first_domino()

	# Starting hand
	draw_additional_player_dominos(5)
	draw_additional_enemy_dominos(5)

# Initialize each player's domino sets (20 random dominos) and draw 5 to start
func initialize_domino_sets():
	player_pile = generate_random_dominos(20, "player")
	ai_pile = generate_random_dominos(20, "enemy")
	
	# Each player draws 5 dominos from their pile at the start
	player_dominos = draw_dominos_from_pile(player_pile, 5)
	ai_dominos = draw_dominos_from_pile(ai_pile, 5)

# Generate a list of random dominos (20 pairs of numbers between 0 and 6) for the owner (either player or AI)
func generate_random_dominos(amount: int, owner: String) -> Array:
	var dominos = []
	for _i in range(amount):
		var n1 = randi() % 7
		var n2 = randi() % 7

		var domino = DominoContainerScene.instance()
		domino.set_numbers(n1, n2, owner) # Set the numbers for the domino

		domino.connect("domino_pressed", self, "_on_domino_pressed") # Connect the signal
		dominos.append(domino) # Create new Domino object
	return dominos

# Draw `count` dominos from the pile
func draw_dominos_from_pile(pile: Array, count: int) -> Array:
	var drawn_dominos = []
	for _i in range(count):
		if pile.size() > 0:
			drawn_dominos.append(pile.pop_back()) # Take a domino from the end of the pile
	return drawn_dominos

# Draw the first domino on the play field (determined by dice roll)
func draw_first_domino():
	var first_domino_number = randi() % 6 + 1 # Roll a die (1-6)
	var domino = DominoContainerScene.instance()
	domino.set_numbers(first_domino_number, first_domino_number, "board") # Set the numbers for the domino
	play_board.add_child(domino)
	last_played_number = first_domino_number # Set the last played number
	print("First number: " + str(first_domino_number))

# Handle the event when a player plays a domino
func _on_domino_pressed(domino_container):
	print("Domino pressed!")
	if player_turn:
		var number1 = domino_container.get_numbers()[0]
		var number2 = domino_container.get_numbers()[1]
		
		# Check if the domino can be played (if either number matches the last played number)
		if number1 == last_played_number or number2 == last_played_number:
			move_domino_to_playfield(domino_container)
		else:
			print("Invalid move. You can only play dominos that match the last number.")

		
# Move a valid domino to the play field and disable its buttons
func move_domino_to_playfield(domino_container):
	var number1 = domino_container.get_numbers()[0]
	var number2 = domino_container.get_numbers()[1]

	# Swap the numbers if needed, so the correct number becomes the new last played number
	if number2 == last_played_number:
		var temp = number1
		number1 = number2
		number2 = temp

	# Update the domino's internal values (swap if needed)
	domino_container.set_numbers(number1, number2, "board") # Update visual representation

	if player_turn:
		player_hand.remove_child(domino_container) # Remove from player's hand
	else:
		ai_hand.remove_child(domino_container) # Remove from AI's hand
	
	play_board.add_child(domino_container) # Add to play field
	
	# Update the last played number (the second number of the domino)
	last_played_number = number2
	print("Played a domino! Last played number is now: ", last_played_number)

	
# End the player's turn and start the AI's turn
func _on_end_turn_pressed():
	print("Ending turn...")
	if (!check_game_over()): # Check if the game is over before switching turns
		if player_turn:
			player_turn = false
			end_turn_button.disabled = true # Disable end turn button during AI's turn
			ai_play()

# AI plays its dominos
func ai_play():
	var count = 0
	var playable_dominos = true  # Flag to indicate if there are playable dominos

	while playable_dominos:
		playable_dominos = false  # Reset the flag for this iteration
		var domino_to_play = null  # Variable to hold the domino to play

		# Find a playable domino
		for domino in ai_dominos:
			var number1 = domino.get_numbers()[0]
			var number2 = domino.get_numbers()[1]
			print("Checking domino: " + str(number1) + ", " + str(number2))

			if number1 == last_played_number or number2 == last_played_number:
				domino_to_play = domino  # Found a playable domino
				break  # Exit the loop since we found a domino

		# If a domino was found, play it
		if domino_to_play:
			playable_dominos = true  # Set the flag to true to continue the loop
			print("AI plays: " + str(domino_to_play.get_numbers()[0]) + ", " + str(domino_to_play.get_numbers()[1]))

			# Swap numbers if number2 is the matching number
			if domino_to_play.get_numbers()[1] == last_played_number:
				var temp = domino_to_play.get_numbers()[0]
				domino_to_play.set_numbers(domino_to_play.get_numbers()[1], temp, "board")

			yield(get_tree().create_timer(1.0), "timeout")  # Wait 1 second before playing
			move_domino_to_playfield(domino_to_play)  # Play the domino
			ai_dominos.erase(domino_to_play)  # Remove domino from AI's list
			count += 1  # Increment count of played dominos

	# Check if the AI played any dominos
	if count == 0:
		print("AI cannot play any more moves, player's turn resumes.")
	else:
		print("AI played " + str(count) + " dominos.")

	end_turn_button.disabled = false  # Enable end turn button
	player_turn = true  # Switch to player's turn

	# Draw additional dominos for the player and AI if the game is not over
	if not check_game_over():
		draw_additional_player_dominos(2)  # Draw additional dominos for the player
		draw_additional_enemy_dominos(2)  # Draw additional dominos for the AI



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
		if type == "player":
			player_dominos.append(domino)
			player_hand.add_child(domino)
		elif type == "enemy":
			ai_dominos.append(domino)
			ai_hand.add_child(domino)
