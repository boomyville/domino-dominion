extends Node
class_name Main

# Load the DominoContainer scene
onready var DominoContainerScene = preload("res://Domino/Domino.tscn")

# UI elements
onready var player_hand = get_node("../GameBoard/PlayerHand") # Player's hand container
onready var enemy_hand = get_node("../GameBoard/EnemyHand") # AI's hand container (non-clickable)
onready var play_board = get_node("../GameBoard/PlayBoard") # Play field container
onready var end_turn_button = get_node("../GameBoard/EndTurn") # Button for ending turn
onready var battle_text = get_node("../GUIContainer/BattleText")
onready var debug_text = get_node("../GUIContainer/DebugText")
onready var tween = get_node("../GameBoard/Tween")
var player_scene = preload("res://Battlers/Player/Player.tscn")
var enemy_scene = preload("res://Battlers/Enemy/Enemy.tscn")

var player
var enemy
var turns

var last_played_number = -1 # The number to match for the next move
var player_turn = true # Keep track of whose turn it is

enum GameState {
	DEFAULT,
	DISCARD_SELECTION,
	PILE_SELECTION,
	HAND_SELECTION,
	VOID_SELECTION,
	INACTIVE
}
var game_state = GameState.DEFAULT

const GAME_STATE_STRINGS = {
	GameState.DEFAULT: "Default",
	GameState.DISCARD_SELECTION: "Discard Selection",
	GameState.PILE_SELECTION: "Pile Selection",
	GameState.HAND_SELECTION: "Hand Selection",
	GameState.VOID_SELECTION: "Void Selection",
	GameState.INACTIVE: "Inactive"
}

func get_game_state_string() -> String:
	return GAME_STATE_STRINGS[game_state]


#=====================================================
# Initialisation
#=====================================================
func _ready():
	
	randomize() # Initialize random number generator

	initialize_units() # Initialize the player and AI units

	initialize_battle() # Initialize the battle

	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")

	# You may also want to initialize the board with the first domino
	draw_first_domino()

func initialize_units():
	player = player_scene.instance()
	add_child(player)
	player.connect("hand_discard", self, "_on_hand_discard")

	enemy = enemy_scene.instance()
	add_child(enemy)
	
func initialize_battle():
	player.initialize_deck()
	enemy.initialize_deck()
	for domino in player.get_draw_pile():
		domino.connect("domino_pressed", self, "_on_domino_pressed") # Connect the signal
	draw_player_hand(player.get_initial_draw())
	draw_enemy_hand(enemy.get_initial_draw())
	turns = 1

func _on_hand_discard(domino):
	if(domino.user == "player"):
		player_hand.remove(domino)
	elif(domino.user == "enemy"):
		enemy_hand.remove(domino)

# Draw the first domino on the play field (determined by dice roll)
func draw_first_domino():
	var first_domino_number = randi() % 6 + 1 # Roll a die (1-6)
	var domino = DominoContainerScene.instance()
	domino.set_numbers(first_domino_number, first_domino_number, "board") # Set the numbers for the domino
	play_board.add_child(domino)
	set_played_number(first_domino_number) # Set the last played number

#=====================================================
# Event handling (Dominos)
#=====================================================

# Handle the event when a player plays a domino
func _on_domino_pressed(domino_container: DominoContainer, pressed_number: int):
	print("Domino pressed: " + str(pressed_number))
	if player_turn && game_state == GameState.DEFAULT:
		play_domino(domino_container, pressed_number)
	elif player_turn && game_state != GameState.DEFAULT:
		print("Invalid move. You must complete the current action first.")
	else:
		print("It's not your turn!")

func play_domino(domino_container: DominoContainer, pressed_number: int):
	var user
	var target;
	if(domino_container.get_user().to_upper() == "PLAYER"):
		user = player
		target = enemy
	elif(domino_container.get_user().to_upper() == "ENEMY"):
		target = player
		user = enemy
	
	var result = domino_container.can_play(last_played_number, user, target, pressed_number)
	# Check if the domino can be played (if either number matches the last played number)
	if result == "playable":
		move_domino_to_playfield(domino_container)
	elif result == "swap":
		domino_container.swap_values()
		move_domino_to_playfield(domino_container)
	elif result == "unplayable":
		update_battle_text("Invalid move. You can only play dominos that match the last number.")
	elif result == "prohibited":
		update_battle_text("Invalid move. Conditions do not meet requirements.")

# Move a valid domino to the play field and disable its buttons
func move_domino_to_playfield(domino_container):
	
	domino_container.clear_highlight()
	# Damage
	if domino_container.get_user().to_upper() == "PLAYER":
		domino_container.effect(player, enemy)
	elif domino_container.get_user().to_upper() == "ENEMY":
		domino_container.effect(enemy, player)

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
	set_played_number(domino_container.get_numbers()[1])
	
	# Update player and enemy
	player.update()
	enemy.update()
	
func set_played_number(number: int):
	last_played_number = number
	update_domino_highlights() # Update the highlights of the dominos in the player's hand


#=====================================================
# Domino manipulation selection
#=====================================================
# Trigger discard selection from the special domino effect

func trigger_discard_selection(minimum_discards: int, maximum_discards: int, origin_domino: DominoContainer = null, target: String = "PLAYER", collection: String = "HAND"):
	var targetted_collection
	
	if(target.to_upper() == "PLAYER"):
		targetted_collection = player_hand
	elif(target.to_upper() == "ENEMY"):
		targetted_collection = enemy_hand
	else:
		print("Invalid target for discard selection.")
		return
	
	if(targetted_collection.get_children().size() == 0):
		print("Not enough dominos to discard.")
		return
	elif(targetted_collection.get_children().size() == 1 && collection.to_upper() == "HAND"):
		print("Only domino in hand is played domino... not enough dominos to discard.")
		return
	else:
		game_state = GameState.DISCARD_SELECTION
		var discard_popup = preload("res://SelectionPopup.tscn").instance()
		add_child(discard_popup)
		discard_popup.setup_discard_popup(targetted_collection, minimum_discards, maximum_discards, origin_domino, target, collection)
		discard_popup.popup_centered()

func process_discard(selected_dominos: Array):
	print ("Processing discard selection...", get_game_state_string())
	if game_state == GameState.DISCARD_SELECTION:
		for domino in selected_dominos:
			player.add_to_discard_pile(domino, "hand")
		game_state = GameState.DEFAULT

func is_selection() -> bool:
	return game_state != GameState.DEFAULT || game_state != GameState.INACTIVE

func game_state_default() -> bool:
	return game_state == GameState.DEFAULT

#=====================================================
# Turn End and AI Turn
#=====================================================

# End the player's turn and start the AI's turn
func _on_end_turn_pressed():
	print("Ending turn...")
	if (!check_game_over()): # Check if the game is over before switching turns
		if player_turn:
			player_turn = false
			end_turn_button.disabled = true # Disable end turn button during AI's turn
			player.dominos_played_this_turn = [] # Reset the dominos played this turn
			enemy_start_turn()

func enemy_end_turn():
	player_start_turn()  # Start the player's turn

# AI plays its dominos
func enemy_start_turn():

	# Effects
	var effect_data = {"user": enemy, "target": player }
	for effect in enemy.effects:
		effect.on_event("turn_start", effect_data)   
		effect.update_duration(enemy)
	
	var count = 0
	var playable_dominos = true  # Flag to indicate if there are playable dominos

	while playable_dominos:
		playable_dominos = false  # Reset the flag for this iteration
		var domino_to_play = null  # Variable to hold the domino to play

		# Find a playable domino
		for domino in enemy_hand.get_children():
			if domino.can_play(last_played_number, enemy, player, domino.get_numbers()[0]) != "unplayable" && domino.can_play(last_played_number, enemy, player, domino.get_numbers()[0]) != "prohibited":
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
	enemy_end_turn()  # End the AI's turn

func player_start_turn():

	turns +=1
	player_turn = true
	end_turn_button.disabled = false  # Enable the end turn button

	# Effects
	var effect_data = {"user": player, "target": enemy }
	for effect in player.effects:
		effect.on_event("turn_start", effect_data)   
		effect.update_duration(player)
	
	draw_player_hand(player.get_draw_per_turn())  # Draw dominos for the player
	draw_enemy_hand(enemy.get_draw_per_turn())  # Draw dominos for the enemy

#=====================================================
# Game States
#=====================================================

# Check if the game is over
func check_game_over():
	if player.get_draw_pile().size() == 0:
		update_battle_text("Player loses! No more dominos to draw.")
		end_turn_button.set_text("Player loses!")
		end_turn_button.disabled = true
		game_state = GameState.INACTIVE
		return true
	elif enemy.get_draw_pile().size() == 0:
		update_battle_text("Enemy loses! No more dominos to draw.")
		end_turn_button.set_text("Enemy loses!")
		end_turn_button.disabled = true
		game_state = GameState.INACTIVE
		return true
	elif(player.hp <= 0):
		print("Player loses! HP is 0.")
		update_battle_text("Player loses!")
		end_turn_button.disabled = true
		game_state = GameState.INACTIVE
		return true
	elif(enemy.hp <= 0):
		print("Enemy loses! HP is 0.")
		update_battle_text("Enemy is defeated!")
		end_turn_button.disabled = true
		game_state = GameState.INACTIVE
		return true
	else:
		update_battle_text("Game continues... Turn " + str(turns + 1))
		return false

#=====================================================
# Between Turns
#=====================================================

# Draw additional dominos for the player
func draw_player_hand(count: int):
	print("Drawing " + str(count) + " dominos for the player...")
	var drawn_dominos = []
	for _i in range(count):
		if player.get_draw_pile().size() > 0:
			drawn_dominos.append(player.draw_pile.pop_back()) # Take a domino from the end of the pile
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
		if enemy.get_draw_pile().size() > 0:
			drawn_dominos.append(enemy.draw_pile.pop_back()) # Take a domino from the end of the pile
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
	#container.add_child(domino)
	
	# Calculate the end position based on the number of children in the container
	var domino_index = container.get_child_count() - 1
	var domino_width = domino.get_combined_minimum_size().x + container.get_constant("separation")
	var end_position = Vector2(domino_width * domino_index, domino.rect_position.y)
	
	# Set the initial position to the start position
	domino.rect_position = start_position
	
	# Show the domino and animate it to its position in the container
	var delay = 1.0
	tween.interpolate_property(domino, "rect_position", start_position, end_position, delay, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(domino, "modulate:a", 0, 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	yield(get_tree().create_timer(delay), "timeout") # Wait for the animation to finish
	update_domino_highlights() # Update the highlights of the dominos in the player's hand
	
	#domino.visible = true


#=====================================================
# UI
#=====================================================

func update_battle_text(text: String):
	battle_text.text = text
	print(get_game_state_string())
	debug_text.text = get_game_state_string()

func update_domino_highlights():
	#print("Updating domino highlights...")
	for domino in player_hand.get_children():
		if domino is DominoContainer:
			var can_be_played = domino.can_play(last_played_number, player, enemy)
			domino.update_highlight(can_be_played != "unplayable" && can_be_played != "prohibited")
