extends Node
class_name Main

# Load the DominoContainer scene
onready var DominoContainerScene = preload("res://Domino/Domino.tscn")

export var touch_mode = true # If touch mode is enabled, dominos need to be tapped TWICE to play

# UI elements
onready var player_hand = get_node("../GameBoard/PlayerHand") # Player's hand container
onready var enemy_hand = get_node("../EnemyHand") # AI's hand container (non-clickable)
onready var play_board = get_node("../PlayBoard/HBoxContainer") # Play field container
onready var end_turn_button = get_node("../GameBoard/EndTurn") # Button for ending turn
onready var battle_text = get_node("../GUIContainer/BattleText")
onready var debug_text = get_node("../GUIContainer/DebugText")
onready var tween = get_node("../GameBoard/Tween")
var selection_popup

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
# Debug
#=====================================================
func _input(event):
	if event is InputEventKey and event.scancode == KEY_1 and event.pressed:
		draw_hand(1, "PLAYER", "ANY")
	if event is InputEventKey and event.scancode == KEY_2 and event.pressed:
		trigger_domino_transfer(null, true, 1, "PLAYER", "HAND", "DISCARD")
		play_board.get_parent().set_h_scroll(play_board.rect_size.x)
		print(play_board.get_parent().get_h_scroll(), ": scroll size")
		print("Playboard size: ", play_board.rect_size.x)
	if event is InputEventKey and event.scancode == KEY_3 and event.pressed:
		print(player.discard_pile.size(), " dominos in player's discard pile.")
#=====================================================
# Initialisation
#=====================================================
func _ready():
	
	randomize() # Initialize random number generator

	initialize_units() # Initialize the player and AI units

	initialize_battle() # Initialize the battle

	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")

	selection_popup = preload("res://SelectionPopup.tscn").instance() 
	add_child(selection_popup)
	selection_popup.hide()

	# Draw the first (board only) domino to start the game
	draw_first_domino()

func initialize_units():
	player = player_scene.instance()
	add_child(player)
	
	enemy = enemy_scene.instance()
	add_child(enemy)
	
func initialize_battle():
	for domino in player.get_draw_pile():
		domino.connect("domino_pressed", self, "_on_domino_pressed") # Connect the signal
	draw_hand(player.get_initial_draw(), "PLAYER", "ANY")
	draw_hand(enemy.get_initial_draw(), "ENEMY", "ANY")
	turns = 1

# Draw the first domino on the play field (determined by dice roll)
func draw_first_domino():
	var first_domino_number = randi() % 6 + 1 # Roll a die (1-6)
	var domino = DominoContainerScene.instance()
	domino.set_numbers(first_domino_number, first_domino_number, "board") # Set the numbers for the domino
	play_board.add_child(domino)
	set_played_number(first_domino_number) # Set the last played number

#=====================================================
# Helper methods
#=====================================================
func string_to_battler(target: String):
	match target.to_upper():
		"PLAYER":
			return player
		"ENEMY":
			return enemy
	return null

func get_hand(target: String) -> GridContainer:
	var target_hand
	if(target.to_upper() == "PLAYER"):
		target_hand = player_hand
	elif(target.to_upper() == "ENEMY"):
		target_hand = enemy_hand
	return target_hand

#=====================================================
# Event handling (Dominos)
#=====================================================
func _Input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed :
		unselect_dominos()

func unselect_dominos():
	for domino in player_hand.get_children():
		if domino is DominoContainer:
			domino.set_clicked(false)

# Handle the event when a player plays a domino
func _on_domino_pressed(domino_container: DominoContainer, pressed_number: int):	
	if(touch_mode):
		if(domino_container.selected):
			play_domino(domino_container, pressed_number)
		else:
			unselect_dominos()
			update_domino_highlights()
			domino_container.set_clicked(true)
	else:
		if player_turn && game_state == GameState.DEFAULT:
			play_domino(domino_container, pressed_number)
		elif player_turn && game_state != GameState.DEFAULT:
			print("Invalid move. You must complete the current action first.")
		else:
			print("It's not your turn!")

func _on_Panel_gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.pressed:
		unselect_dominos()
		update_domino_highlights()

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
	domino_container.set_clicked(false)

	# Apply domino effect (such as damage or shielding)
	if domino_container.get_user().to_upper() == "PLAYER":
		domino_container.effect(player, enemy)
	elif domino_container.get_user().to_upper() == "ENEMY":
		domino_container.effect(enemy, player)

	# Movement is relative to play_board so we need to subtract the playboard absolute position (such that the resultant vector is relative to play_board)
	var start_position = domino_container.get_global_position() - play_board.get_global_position()
	
	# Calculate the target position
	var target_positionX = play_board.get_child_count()  * (domino_container.get_combined_minimum_size().x + play_board.get_constant("separation"))
	var target_positionY = 0 * (domino_container.get_combined_minimum_size().y + play_board.get_constant("separation"))
	var target_position = Vector2(target_positionX, target_positionY)

	# Temporarily hide the domino
	domino_container.modulate.a = 0
						
	if player_turn:
		player_hand.remove_child(domino_container) # Remove from player's hand
	else:
		enemy_hand.remove_child(domino_container) # Remove from AI's hand
	
	domino_container.set_user("board") # Set the user to the board
	play_board.add_child(domino_container) # Add to play field
	play_board.get_child(play_board.get_child_count() - 1).grab_focus()

	# Set the initial position to the start position
	domino_container.rect_position = start_position

	# Show the domino and animate it to its position on the board
	tween.interpolate_property(domino_container, "rect_position", start_position, target_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(domino_container, "modulate:a", 0, 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	domino_container.visible = true

	reposition_domino_hand() # Reposition the dominos in the player's hand (and enemy's hand)

	# Update the last played number (the second number of the domino)
	set_played_number(domino_container.get_numbers()[1])
	
	update_domino_highlights() # Update the highlights of the dominos in the player's hand

	# Update player and enemy
	player.update()
	enemy.update()
	
func set_played_number(number: int):
	last_played_number = number
	update_domino_highlights() # Update the highlights of the dominos in the player's hand

func reposition_domino_hand():
	# Animate the remaining dominos in the player's hand to their new positions
	for i in range(player_hand.get_child_count()):
		var remaining_domino = player_hand.get_child(i)
		var new_position = remaining_domino.final_domino_position(i, player_hand)
		tween.interpolate_property(remaining_domino, "rect_position", remaining_domino.rect_position, new_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	for i in range(enemy_hand.get_child_count()):
		var remaining_domino = enemy_hand.get_child(i)
		var new_position = remaining_domino.final_domino_position(i, enemy_hand)
		tween.interpolate_property(remaining_domino, "rect_position", remaining_domino.rect_position, new_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	tween.start()

#=====================================================
# Domino manipulation selection
#=====================================================
# Trigger discard selection from the special domino effect

func get_target_collection(target: String, collection: String) -> Array:
	var target_collection
	if(target.to_upper() == "PLAYER"):
		target_collection = player_hand
	elif(target.to_upper() == "ENEMY"):
		target_collection = enemy_hand
	match collection.to_upper():
		"HAND":
			return target_collection.get_children()
		"PILE":
			return string_to_battler(target).get_draw_pile()
		"DISCARD":
			return string_to_battler(target).get_discard_pile()
		"VOID":
			return string_to_battler(target).get_void_space()
		_:
			print("Invalid target for discard selection.")
	return []

# Moves X dominos from one collection to another; no selection prompt is shown
func trigger_domino_transfer(current_domino, randomise: bool, number: int, target_battler: String, origin_collection: String, destination_collection: String):

	var targetted_collection = get_target_collection(target_battler, origin_collection.to_upper())

	if(targetted_collection.size() == 0):
		print("No dominos in " + origin_collection.to_lower() + " to transfer.")
		return
	else:
		var potential_options = targetted_collection.duplicate()

		if(current_domino in potential_options and origin_collection.to_upper() == "HAND"):
			potential_options.erase(current_domino) # We do not include the played domino in the selection

		if(randomise):	
			potential_options.shuffle()

		if(potential_options.size() < number):
			pass # No need to truncate potential dominos to transfer
		else:
			potential_options.resize(number)
		print("[Game.gd trigger_domino_transfer] Potential options: ",potential_options)

		for domino in potential_options:
			add_to_collection(domino, target_battler, destination_collection, origin_collection)
			print("[Game.gd trigger_domino_transfer] Adding ", domino.domino_name, " to ", target_battler, "'s ", destination_collection ," from ", origin_collection)
			#if(origin_collection.to_upper() == "HAND" and potential_options.size() == 0):
				#pass # Domino is played from hand and its the only domino in the hand (so it goes to the board)
			#else:
				#remove_from_collection(domino, target_battler, origin_collection)
			

func add_to_collection(domino: DominoContainer, target_battler: String, destination_collection: String, origin_collection: String):
	match destination_collection.to_upper():
		"HAND":
			string_to_battler(target_battler).add_to_hand(domino, origin_collection)
		"PILE":
			string_to_battler(target_battler).add_to_draw_pile(domino, origin_collection)
		"DISCARD":
			string_to_battler(target_battler).add_to_discard_pile(domino, origin_collection)
		"VOID":
			string_to_battler(target_battler).add_to_void_space(domino, origin_collection)

func remove_from_collection(domino: DominoContainer, target_battler: String, origin: String):
	var target_hand = get_hand(target_battler)
	print("[Game.gd remove_from_collection] Removing ", domino.domino_name, " from ", origin)
	match origin.to_upper():
		"HAND":
			erase_from_hand(target_hand, domino)
		"PILE":
			string_to_battler(target_battler).get_draw_pile().erase(domino)
		"DISCARD":
			string_to_battler(target_battler).get_discard_pile().erase(domino)
		"VOID":
			string_to_battler(target_battler).get_void_space().erase(domino)

# Special method for erasing from hand (tween animation)
func erase_from_hand(collection: GridContainer, domino: DominoContainer):
	for user_dominos in collection.get_children():
		if user_dominos.check_shadow_match(domino):
			# Disable interactions for the domino being removed
			user_dominos.set_block_signals(true)

			# Get the global position of the domino before removing it
			var global_position = user_dominos.rect_global_position

			# Temporarily remove the domino from the container so it can be freely animated
			collection.remove_child(user_dominos)
			get_tree().root.add_child(user_dominos)  # Add it directly to the root or main node of the scene tree

			# Set the position to the original global position
			user_dominos.rect_global_position = global_position

			# Set up the fade-out animation
			tween.interpolate_property(user_dominos, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
			# Set up the fall animation (with gravity effect)
			var start_position = user_dominos.rect_position
			var end_position = start_position + Vector2(0, 400)  # Fall distance
			
			tween.interpolate_property(user_dominos, "rect_position", start_position, end_position, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)

			# Start the tween for the removal animation
			tween.start()

			# Wait for the animation to finish
			yield(get_tree().create_timer(1), "timeout")

			# Free the domino after the animation
			#user_dominos.queue_free()

			# Reposition remaining dominos in the collection
			reposition_domino_hand()
			return  # Exit after animating the matched domino

func domino_selection(selection_minimum: int, maximium_selection: int, origin_domino: DominoContainer, target: String, collection: String, collection_size: int = -1, destination_collection: String = "hand"):
	var targetted_collection = get_target_collection(target, collection)
	
	if(targetted_collection.size() == 0 || collection_size == 0 || (targetted_collection.size() == 1 && collection.to_upper() == "HAND")):
		update_battle_text("Not enough dominos to select from.")
		return
	else:
		game_state = GameState.get(collection.to_upper() + "_SELECTION")
		selection_popup.show()
		var collection_copy = targetted_collection.duplicate()

		# Setup collection size
		if(collection_size > 0):
			collection_copy.resize(collection_size)

		selection_popup.setup_selection_popup(collection_copy, selection_minimum, maximium_selection, origin_domino, target, collection, destination_collection, "process_selection")
		selection_popup.popup_centered()


func process_selection(selected_dominos: Array, target: String, origin_collection, destination_collection: String):
	
	match destination_collection.to_upper():
		"DISCARD":
			for domino in selected_dominos:
				string_to_battler(target).add_to_discard_pile(domino, origin_collection)
		
		"HAND":
			for domino in selected_dominos:
				string_to_battler(target).add_to_hand(domino, origin_collection)

		"PILE":
			for domino in selected_dominos:
				string_to_battler(target).add_to_draw_pile(domino, origin_collection)
		
		"VOID":
			for domino in selected_dominos:
				string_to_battler(target).add_to_void_space(domino, origin_collection)
	
	game_state = GameState.DEFAULT
	update_domino_highlights()

func is_selection() -> bool:
	return game_state != GameState.DEFAULT || game_state != GameState.INACTIVE

func game_state_default() -> bool:
	return game_state == GameState.DEFAULT

#=====================================================
# Turn End and AI Turn
#=====================================================

# End the player's turn and start the AI's turn
func _on_end_turn_pressed():
	unselect_dominos()
	if (!check_game_over()): # Check if the game is over before switching turns
		if player_turn:
			player_turn = false
			end_turn_button.disabled = true # Disable end turn button during AI's turn
			player.on_turn_end() # Reset the dominos played this turn
			enemy_start_turn()

func enemy_end_turn():
	enemy.on_turn_end() # Reset the dominos played this turn
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
	
	draw_hand(player.get_draw_per_turn(), "PLAYER", "ANY")  # Draw dominos for the player
	draw_hand(enemy.get_draw_per_turn(), "ENEMY", "ANY")  # Draw dominos for the enemy

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
# Draw
#=====================================================

func draw_hand(count: int, target: String, type: String = "ANY"):
	print("Drawing " + str(count) + " dominos")
	var drawn_dominos = []
	var collection
	var targetDrawPile

	collection = get_hand(target)

	targetDrawPile = string_to_battler(target).get_draw_pile() 
	
	if(targetDrawPile.size() == 0):
		print("No more dominos to draw.")
		check_game_over() # Check if the game is over
		return
	
	if(type.to_upper() != "ANY"):
		targetDrawPile = get_random_draw(type, targetDrawPile)
	for _i in range(count):
		if targetDrawPile.size() > _i:
			drawn_dominos.append(targetDrawPile[_i]) # Take a domino from the end of the pile
		else:
			print("No more dominos in the pile!")
			check_game_over() # Check if the game is over / note only game over if String = "ANY"
			break

	# Add the drawn dominos to the player's hand
	yield(get_tree().create_timer(0.2), "timeout") 
	for domino in drawn_dominos:
		if(domino == null):
			print("No more dominos to draw.")
			return
		targetDrawPile.erase(domino) # Remove it from the draw pile
		# Set initial opacity to 0
		domino.modulate.a = 0
		collection.add_child(domino)
		animate_domino(domino, collection)

func get_random_draw(type: String, targetDrawPile: Array) -> Array:
	# Filter the target draw pile for dominos of the specified type
	var filtered_dominos = []
	
	for domino in targetDrawPile:
		if type.to_lower() == "attack" and domino.filename.find("Attack") != -1:
			filtered_dominos.append(domino)
		elif type.to_lower() == "skill" and domino.filename.find("Skill") != -1:
			filtered_dominos.append(domino)
		elif type.to_lower() == "ability" and domino.filename.find("Ability") != -1:
			filtered_dominos.append(domino)

	# If we have any matching dominos, randomly select one
	if filtered_dominos.size() > 0:
		filtered_dominos.shuffle()
		return filtered_dominos
	
	# Return null if no dominos of the specified type are found
	return []

# Animate the domino sliding from the right to its position in the HBoxContainer
func animate_domino(domino, container: GridContainer):
	# Calculate the starting position (off-screen to the right)
	var start_position = Vector2(OS.window_size.x, domino.rect_position.y)
	
	# Set the initial position to the start position
	domino.rect_position = start_position
	var end_position = domino.final_domino_position(max(0, container.get_child_count() - 1), container)
	
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
	debug_text.text = get_game_state_string()

func update_domino_highlights():
	#print("Updating domino highlights...")
	for domino in player_hand.get_children():
		if domino is DominoContainer:
			var can_be_played = domino.can_play(last_played_number, player, enemy)
			domino.update_highlight(can_be_played != "unplayable" && can_be_played != "prohibited")
