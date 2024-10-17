extends Node

# Load the DominoContainer scene
onready var DominoContainerScene = preload("res://Domino/Domino.tscn")

# UI elements
onready var player_hand = get_node("../GameBoard/PlayerHand") # Player's hand container
onready var enemy_hand = get_node("../GameBoard/EnemyHand") # AI's hand container (non-clickable)
onready var play_board = get_node("../GameBoard/PlayBoard") # Play field container
onready var end_turn_button = get_node("../GameBoard/EndTurn") # Button for ending turn

var player = preload("res://Battlers/Player/Player.tscn").instance()
var enemy = preload("res://Battlers/Enemy/Enemy.tscn").instance()

# Domino data
var player_pile = []
var enemy_pile = []

var last_played_number = -1 # The number to match for the next move
var player_turn = true # Keep track of whose turn it is

# Called when the node enters the scene tree
func _ready():
	randomize() # Initialize random number generator

	initialize_battle() # Initialize the battle

	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")

	# You may also want to initialize the board with the first domino
	draw_first_domino()

	
func initialize_battle():
	# Initialize the battle with player and AI
	player_pile = player.get_deck()
	player_pile.shuffle()
	enemy_pile = enemy.get_deck()
	enemy_pile.shuffle()
	for domino in player_pile:
		domino.connect("domino_pressed", self, "_on_domino_pressed") # Connect the signal
	draw_player_hand(player.get_initial_draw())
	draw_enemy_hand(player.get_initial_draw())


# Draw the first domino on the play field (determined by dice roll)
func draw_first_domino():
	var first_domino_number = randi() % 6 + 1 # Roll a die (1-6)
	var domino = DominoContainerScene.instance()
	domino.set_numbers(first_domino_number, first_domino_number, "board") # Set the numbers for the domino
	play_board.add_child(domino)
	last_played_number = first_domino_number # Set the last played number
	print("First number: " + str(first_domino_number))

# Handle the event when a player plays a domino
func _on_domino_pressed(domino_container: DominoContainer, pressed_number: int):
	if player_turn:
		play_domino(domino_container, pressed_number)
	else:
		print("It's not your turn!")

func play_domino(domino_container: DominoContainer, pressed_number: int):
	print("Domino pressed!  ", pressed_number)
	# Check if the domino can be played (if either number matches the last played number)
	if domino_container.can_play(last_played_number) == "playable":
		move_domino_to_playfield(domino_container)
	elif domino_container.can_play(last_played_number) == "swap":
		domino_container.swap_values() # Swap the numbers
		move_domino_to_playfield(domino_container)
	elif domino_container.can_play(last_played_number) == "unplayable":
		print("Invalid move. You can only play dominos that match the last number.")

# Move a valid domino to the play field and disable its buttons
func move_domino_to_playfield(domino_container):

	var tween = get_node("../GameBoard/Tween")
	var start_position = domino_container.get_global_position()

	# Calculate the target position
	var target_positionX = play_board.get_child_count() % play_board.columns * (domino_container.get_combined_minimum_size().x + play_board.get_constant("hseparation"))
	var target_positionY = floor(play_board.get_child_count() / play_board.columns) * (domino_container.get_combined_minimum_size().y + play_board.get_constant("vseparation"))
	var target_position = Vector2(target_positionX, target_positionY)

	# Temporarily hide the domino
	domino_container.modulate.a = 0
						
	if player_turn:
		player_hand.remove_child(domino_container) # Remove from player's hand
	else:
		enemy_hand.remove_child(domino_container) # Remove from AI's hand
	
	domino_container.set_user("board") # Set the user to the board
	play_board.add_child(domino_container) # Add to play field

	# Set the initial position to the start position
	domino_container.rect_position = start_position

	# Show the domino and animate it to its position on the board
	tween.interpolate_property(domino_container, "rect_position", start_position, target_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(domino_container, "modulate:a", 0, 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	domino_container.visible = true

	# Animate the remaining dominos in the player's hand to their new positions
	for i in range(player_hand.get_child_count()):
		var remaining_domino = player_hand.get_child(i)
		var new_position = Vector2(i * (remaining_domino.get_combined_minimum_size().x + player_hand.get_constant("separation")), remaining_domino.rect_position.y)
		tween.interpolate_property(remaining_domino, "rect_position", remaining_domino.rect_position, new_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	for i in range(enemy_hand.get_child_count()):
		var remaining_domino = enemy_hand.get_child(i)
		var new_position = Vector2(i * (remaining_domino.get_combined_minimum_size().x + enemy_hand.get_constant("separation")), remaining_domino.rect_position.y)
		tween.interpolate_property(remaining_domino, "rect_position", remaining_domino.rect_position, new_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()

	# Update the last played number (the second number of the domino)
	last_played_number = domino_container.get_numbers()[1]
	print("Played a domino! ", domino_container.get_numbers(), " Last played number is now: ", last_played_number)

	
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
		for domino in enemy_hand.get_children():
			if domino.can_play(last_played_number) != "unplayable":
				domino_to_play = domino  # Found a playable domino
				break  # Exit the loop since we found a domino

		# If a domino was found, play it
		if domino_to_play:
			playable_dominos = true  # Set the flag to true to continue the loop
			play_domino(domino_to_play, domino_to_play.get_numbers()[0])  # Sim

			yield(get_tree().create_timer(1.0), "timeout")  # Wait 1 second before playing
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
		draw_player_hand(player.get_draw_per_turn())
		draw_enemy_hand(enemy.get_draw_per_turn())



# Check if the game is over
func check_game_over():
	if player_pile.size() == 0:
		print("Player loses! No more dominos to draw.")
		end_turn_button.set_text("Player loses!")
		end_turn_button.disabled = true
		return true
	elif enemy_pile.size() == 0:
		print("Enemy loses! No more dominos to draw.")
		end_turn_button.set_text("Enemy loses!")
		end_turn_button.disabled = true
		return true
	else:
		print("Game continues...")
		return false




# Draw additional dominos for the player
func draw_player_hand(count: int):
	print("Drawing " + str(count) + " dominos for the player...")
	var drawn_dominos = []
	for _i in range(count):
		if player_pile.size() > 0:
			print("Drawing for ", player_pile.back().get_user(), ": ", player_pile.back().get_numbers())
			drawn_dominos.append(player_pile.pop_back()) # Take a domino from the end of the pile
		else:
			print("No more dominos in the pile!")
			check_game_over() # Check if the game is over
			break
	
	# Add the drawn dominos to the player's hand
	yield(get_tree().create_timer(0.2), "timeout") 
	for domino in drawn_dominos:
		# Set initial opacity to 0
		domino.modulate.a = 0
		player_hand.add_child(domino)
		animate_domino(domino, player_hand)

# Draw additional dominos for the enemy
func draw_enemy_hand(count: int):
	print("Drawing " + str(count) + " dominos for the enemy...")
	var drawn_dominos = []
	for _i in range(count):
		if enemy_pile.size() > 0:
			print("Drawing for ", enemy_pile.back().get_user(), ": ", enemy_pile.back().get_numbers())
			drawn_dominos.append(enemy_pile.pop_back()) # Take a domino from the end of the pile
		else:
			print("No more dominos in the pile!")
			check_game_over() # Check if the game is over
			break
	
	# Add the drawn dominos to the player's hand
	yield(get_tree().create_timer(0.2), "timeout") 
	for domino in drawn_dominos:
		# Set initial opacity to 0
		domino.modulate.a = 0
		enemy_hand.add_child(domino)
		animate_domino(domino, enemy_hand)

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
