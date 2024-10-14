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
	randomize() # Initialize random number generator
	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")

	initialize_domino_sets() # Generate the dominos for player and AI

	# You may also want to initialize the board with the first domino
	draw_first_domino()

	# Starting hand
	draw_additional_dominos(2, "all") 
	

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
		else:
			print("No more dominos in the pile!")
			check_game_over() # Check if the game is over
			break
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

	var tween = get_node("../GameBoard/Tween")
	var start_position = domino_container.get_global_position()

	# Calculate the target position
	var target_positionX = play_board.get_child_count() % play_board.columns * (domino_container.get_combined_minimum_size().x + play_board.get_constant("hseparation"))
	var target_positionY = floor(play_board.get_child_count() / play_board.columns) * (domino_container.get_combined_minimum_size().y + play_board.get_constant("vseparation"))
	var target_position = Vector2(target_positionX, target_positionY)

	# Temporarily hide the domino
	domino_container.visible = false
						
	if player_turn:
		player_hand.remove_child(domino_container) # Remove from player's hand
	else:
		ai_hand.remove_child(domino_container) # Remove from AI's hand
	
	play_board.add_child(domino_container) # Add to play field

	# Set the initial position to the start position
	domino_container.rect_position = start_position

	# Show the domino and animate it to its position on the board
	domino_container.visible = true
	tween.interpolate_property(domino_container, "rect_position", start_position, target_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	

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
		for domino in ai_hand.get_children():
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
		draw_additional_dominos(1, "all")  # Draw additional dominos for the player and AI



# Check if the game is over
func check_game_over():
	if player_hand.get_children().size() == 0:
		print("Player wins!")
		end_turn_button.set_text("Player wins!")
		end_turn_button.disabled = true
		return true
	elif ai_hand.get_children().size() == 0:
		print("AI wins!")
		end_turn_button.set_text("Enemy wins!")
		end_turn_button.disabled = true
		return true
	elif player_pile.size() == 0:
		print("Player loses! No more dominos to draw.")
		end_turn_button.set_text("Player loses!")
		end_turn_button.disabled = true
		return true
	elif ai_pile.size() == 0:
		print("Enemy loses! No more dominos to draw.")
		end_turn_button.set_text("Enemy loses!")
		end_turn_button.disabled = true
		return true
	else:
		print("Game continues...")

# Draw additional dominos for the player
func draw_additional_dominos(count: int, type: String):
	if(type == "player"):
		var new_dominos = draw_dominos_from_pile(player_pile, count)
		print("Drawing for player: ", new_dominos[0].get_numbers())
		add_domino_to_hand(new_dominos, type)
	elif(type == "enemy"):
		var new_dominos = draw_dominos_from_pile(ai_pile, count)
		print("Drawing for enemy: ", new_dominos[0].get_numbers())
		add_domino_to_hand(new_dominos, type)
	elif(type == "all"):
		var new_dominos = draw_dominos_from_pile(player_pile, count)
		var new_dominos2 = draw_dominos_from_pile(ai_pile, count)
		add_domino_to_hand(new_dominos, "player")
		add_domino_to_hand(new_dominos2, "enemy")
		print("Drawing for player: ", new_dominos[0].get_numbers())
		print("Drawing for enemy: ", new_dominos2[0].get_numbers())
	else:
		return;
	

# Add domino to hand
func add_domino_to_hand(dominos: Array, type: String = "player"):
	yield(get_tree().create_timer(0.2), "timeout") 
	for domino in dominos:
		if type == "player":
			# Set initial opacity to 0
			domino.modulate.a = 0
			player_dominos.append(domino)
			player_hand.add_child(domino)
			animate_domino(domino, player_hand)
		elif type == "enemy":
			# Set initial opacity to 0
			domino.modulate.a = 0
			ai_dominos.append(domino)
			ai_hand.add_child(domino)
			animate_domino(domino, ai_hand)

# Animate the domino sliding from the right to its position in the HBoxContainer
func animate_domino(domino, container: HBoxContainer):
	# Calculate the starting position (off-screen to the right)
	var start_position = Vector2(OS.window_size.x, domino.rect_position.y)
	
	
	# Add the domino to the container to get its intended position
	container.add_child(domino)
	
	# Calculate the end position based on the number of children in the container
	var domino_index = container.get_child_count() - 1
	var domino_width = domino.get_combined_minimum_size().x + container.get_constant("separation")
	var end_position = Vector2(domino_width * domino_index, domino.rect_position.y)
	
	# Set the initial position to the start position
	domino.rect_position = start_position
	
	# Show the domino and animate it to its position in the container
	var tween = container.get_parent().get_node("Tween")
	tween.interpolate_property(domino, "rect_position", start_position, end_position, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(domino, "modulate:a", 0, 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	#domino.visible = true
