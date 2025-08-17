extends Node
class_name Main

# Load the DominoContainer scene
onready var DominoContainerScene = preload("res://Domino/Domino.tscn")

export var touch_mode = true # If touch mode is enabled, dominos need to be tapped TWICE to play
export var detailed_descriptors = true # If detailed descriptors are enabled, the player can view the full description of a domino when selected

# UI elements
onready var end_turn_button = get_node("../EndTurn") # Button for ending turn
onready var battle_text = get_node("../BattleText")
onready var debug_text = get_node("../DebugText")

onready var window_width = get_viewport().get_visible_rect().size.x
var separation = 240
var y_value = 256

var map_data = {
	"nodes": [],         # List of nodes with position, type, and column
}
var player_visited_nodes = []

# Game statistics
var battle_log = []
export var enemy_list: Array = []

var selection_popup

var player_scene

var player
var enemy
var turns

var last_played_number = -1 # The number to match for the next move
var player_turn = true # Keep track of whose turn it is

enum GameState {
	DEFAULT,
	DOMINO_CHECK,
	INACTIVE,
	GAMEOVER,
	WAITING,
	TITLE,
}

var game_state = GameState.DEFAULT

const GAME_STATE_STRINGS = {
	GameState.DEFAULT: "Default",
	GameState.DOMINO_CHECK: "Domino Check",
	GameState.INACTIVE: "Inactive",
	GameState.GAMEOVER: "Game Over",
	GameState.WAITING: "Waiting",
	GameState.TITLE: "Title"
}

signal domino_action_finished

# Domino land stores all dominos in the game
var domino_land = {
	"player_draw_pile": [],
	"player_hand": [],
	"player_discard": [],
	"player_void": [],
	"enemy_draw_pile": [],
	"enemy_hand": [],
	"enemy_discard": [],
	"enemy_void": [],
	"board": []
}

#=====================================================
# Debug
#=====================================================

func _input(event):
	if event is InputEventKey and event.scancode == KEY_1 and event.pressed:
		draw_hand(1, "PLAYER", "ANY")
		player.afflict_status("Fury", 0, 1)
		print(get_game_state_string())
	if event is InputEventKey and event.scancode == KEY_2 and event.pressed:
		#for domino in player.get_hand().get_children():
		#	domino.alter_upgrade_domino(1)
		#for domino in player.get_draw_pile():
		#		domino.alter_upgrade_domino(1)
		print(player.get_hand())
	if event is InputEventKey and event.scancode == KEY_3 and event.pressed:
		Engine.time_scale = 10.0
		Engine.iterations_per_second = 600  # Smoother physics updates
	if event is InputEventKey and event.scancode == KEY_4 and event.pressed:
		if is_instance_valid(enemy):
			enemy.set_hp(1)
	if event is InputEventKey and event.scancode == KEY_5 and event.pressed:
		player.set_hp(41)
		player.afflict_status("Impair", 3, 0)
		enemy.afflict_status("DoubleDamage", 3, 0)
	if event is InputEventKey and event.scancode == KEY_6 and event.pressed:
		var msg = ""
		for domino in enemy.get_draw_pile():
			msg += domino.domino_name + ", "
		print("Enemy draw pile: ", msg)
		Game.get_node("Game").trigger_domino_transfer(null, true, 999, "player", "PILE", "Discard")
		print("Player draw pile is empty")
	if event is InputEventKey and event.scancode == KEY_7 and event.pressed:
		var msg = ""
		for item in enemy.get_inventory():
			msg += item.get_name() + ", "
		print("Enemy items: ", msg)
		print(get_battle_log())
	if event is InputEventKey and event.scancode == KEY_8 and event.pressed:
		var msg = ""
		for domino in player.get_draw_pile():
			msg += domino.domino_name + ", "
		print("Player draw pile: ", msg)
		print("current level: ", current_level())
	if event is InputEventKey and event.scancode == KEY_9 and event.pressed:
		print(get_map_data())
	if event is InputEventKey and event.scancode == KEY_0 and event.pressed:
		print(get_game_state_string())
		create_csv()
			
		#print(get_tree().root.get_children())
		
func _ready():
	hide_UI()
	set_game_state(GameState.TITLE)
	
func hide_UI():
	get_node("../EndTurn").hide()
	get_node("../OptionMenu").hide()
	get_node("../BattleText").hide()	
	get_node("../DebugText").hide()

func showUI():
	get_node("../EndTurn").show()
	get_node("../OptionMenu").show()
	get_node("../BattleText").show()	
	get_node("../DebugText").show()
	
func load_player(player_name: String):
	player_scene = load("res://Battlers/Player/%s.tscn" % player_name)

#=====================================================
# Initialisation
#=====================================================
func start_game():
	randomize() # Initialize random number generator
	showUI()

	create_map()

	initialise_enemy_list() # Initialize the enemy list

	initialize_units() # Initialize the player and AI units

	initialize_dominos() # Run on_battle_start() method on all dominos

	initialize_battle() # Initialize the battle

	end_turn_button.connect("pressed", self, "_on_end_turn_pressed")

	selection_popup = preload("res://SelectionPopup.tscn").instance() 
	add_child(selection_popup)
	selection_popup.hide()

	# Draw the first (board only) domino to start the game
	draw_first_domino()

func create_map():
	#map_scene.get_node("Node2D").create_nodes()
	var first_shuffle = [3,4,5,6]
	first_shuffle.shuffle()
	var second_shuffle = [7,8,9,10]
	second_shuffle.shuffle()
	map_data = generate_map_data(12, 0, 240, 72, 48, 12, [first_shuffle[0], second_shuffle[0]], [first_shuffle[1], second_shuffle[2]], [0], [])
	#print(map_data)

func initialize_units():
	player_turn = true
	player = player_scene.instance()
	player.position = Vector2(window_width / 2 - separation / 2, y_value)
	add_child(player)
	
	var enemy_scene = load("res://Battlers/Enemy/%s.tscn" % get_next_enemy())
	add_enemy(enemy_scene)

func add_enemy(new_enemy):
	enemy = new_enemy.instance() 
	enemy.position = Vector2(window_width / 2 + separation / 2, y_value)
	add_child(enemy)

func initialise_enemy_list():
	var very_easy_list = ["Ghaduck", "Irmy", "Herbert"]
	very_easy_list.shuffle()

	enemy_list.append_array(very_easy_list.slice(0, 2))

	if("Ghaduck" in enemy_list):
		enemy_list.append_array(["Hugo", "ZycorianSwordfighter"])
	else:
		var easy_list = ["Ghaduck", "Hugo", "ZycorianSwordfighter"]
		easy_list.shuffle()
		enemy_list.append_array(easy_list.slice(0, 2))
	
	var intemediate_list = ["ZycorianSentinel", "ZycorianGuardian"]
	intemediate_list.shuffle()
	enemy_list.append_array(intemediate_list.slice(0, 1))

func get_enemy_list():
	return enemy_list

func get_next_enemy():
	if get_enemy_list().size() == 0:
		initialise_enemy_list()
	var enemy_index = get_battles_won() % get_enemy_list().size()
	return enemy_list[enemy_index]

func initialize_dominos():
	for domino in player.get_draw_pile():
		if is_instance_valid(domino):
			domino.on_battle_start()
	for domino in enemy.get_draw_pile():
		if is_instance_valid(domino):
			domino.on_battle_start()
	
func initialize_battle():

	enable_buttons()
	#print("Battle initialized. Draw pile size: ", player.get_draw_pile().size())


	player.battle_start()
	enemy.battle_start()

	draw_hand(player.get_initial_draw(), "PLAYER", "ANY")
	draw_hand(enemy.get_initial_draw(), "ENEMY", "ANY")
	turns = 1
	end_turn_button.disabled = false

# Draw the first domino on the play field (determined by dice roll)
func draw_first_domino():
	var first_domino_number = randi() % 6 + 1 # Roll a die (1-6)
	var domino = DominoContainerScene.instance()
	domino.set_user("board") # Set the user to the board
	domino.set_numbers(first_domino_number, first_domino_number, "board") # Set the numbers for the domino
	#play_board.add_child(domino)
	set_played_number(first_domino_number) # Set the last played number

#=====================================================
# Helper methods
#=====================================================
func insert_array(target: Array, index: int, to_insert: Array) -> Array:
	# Validate index
	index = clamp(index, 0, target.size())

	# Insert elements from 'to_insert' into 'target'
	for i in range(to_insert.size()):
		target.insert(index + i, to_insert[i])

	return target

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
		target_hand = domino_land.player_hand
	elif(target.to_upper() == "ENEMY"):
		target_hand = domino_land.enemy_hand
	return target_hand

# Creates a CSV of domino criteria
func create_csv():
	var all_criteria = []
	var domino_names = []
	var max_criteria_length = 0
	var items = string_to_battler("player").load_dominos_from_folder("res://Domino/Attack", "")
	items.append_array(string_to_battler("player").load_dominos_from_folder("res://Domino/Skill", ""))
	
	# Collect names and criteria, and reorganize criteria
	for scene in items:
		var item = scene.instance()
		domino_names.append(item.get_domino_name())
		var criteria = item.get_criteria()
		
		# Find and move rarity to the front
		var rarity_index = -1
		for i in range(criteria.size()):
			if criteria[i] in ["starter", "common", "uncommon", "rare"]:
				rarity_index = i
				break
		
		if rarity_index != -1:
			var rarity = criteria[rarity_index]
			criteria.remove(rarity_index)
			criteria.push_front(rarity)
		else:
			criteria.push_front("unknown")  # If no rarity found
		
		all_criteria.append(criteria)
		max_criteria_length = max(max_criteria_length, criteria.size())
		item.queue_free()

	# Create header
	var header = "Domino Name,Rarity"
	for i in range(1, max_criteria_length):
		header += ",Criteria " + str(i)
	print(header)

	# Create rows
	for i in range(items.size()):
		var row = '"%s"' % domino_names[i]
		for j in range(max_criteria_length):
			if j < all_criteria[i].size():
				row += ',"%s"' % str(all_criteria[i][j]).replace('"', '""')  # Escape quotes
			else:
				row += ","  # Empty cell
		print(row)


#=====================================================
# Getters and setters
#=====================================================
func set_game_state(state):

	game_state = state
	debug_text.text = get_game_state_string()
	
	if(state == GameState.DEFAULT):
		update_domino_highlights()

	if(state == GameState.GAMEOVER):
		print("Loading gameover!")
		yield(get_tree().create_timer(3), "timeout")
		var gameover_scene = preload("res://GameOver.tscn").instance()
		add_child(gameover_scene)

		var battle_log_stringified = ""
		var battles_won = get_battles_won()
		var damage_dealt = enemy.get_max_hp() - enemy.hp
		var dominos_played = 0
		var all_dominos_played = []

		for domino in domino_land.board:
			if domino.get_user().to_upper() == "PLAYER":
				dominos_played += 1
				all_dominos_played.append(domino.get_domino_name())

		var dominos_discarded = player.get_discard_pile().size()
		var dominos_voided = player.get_void_space().size()
		var total_turns = turns
		for entry in battle_log:
			if("turns" in entry.keys()):
				total_turns += int(entry["turns"])
			if("enemy_hp" in entry.keys()):
				damage_dealt += int(entry["enemy_hp"])
			
			if("player_played_dominos" in entry.keys()):
				dominos_played += entry["player_played_dominos"].size()
				all_dominos_played.append_array(entry["player_played_dominos"])
			if("played_discarded_dominos" in entry.keys()):
				dominos_discarded += entry["played_discarded_dominos"].size()
			if("played_voided_dominos" in entry.keys()):
				dominos_voided += entry["played_voided_dominos"].size()
		
		var favourite_domino = find_most_frequent_string(all_dominos_played)
		battle_log_stringified += str(battles_won) + "\n"
		battle_log_stringified += str(damage_dealt) + "\n"
		battle_log_stringified += str(dominos_played) + "\n"
		battle_log_stringified += str(dominos_discarded) + "\n"
		battle_log_stringified += str(dominos_voided) + "\n"
		battle_log_stringified += str(total_turns) + "\n"
		battle_log_stringified += favourite_domino + "\n"
		battle_log_stringified += str(get_events_encountered()) + "\n"

		gameover_scene.set_statistics(battle_log_stringified)
		if(player.hp <= 0):
			gameover_scene.set_reason_message("You have been defeated by " + enemy.battler_name + "!")
		elif (player.get_deck().size() == 0):
			gameover_scene.set_reason_message("You ran out of dominos to play...")
		else:
			gameover_scene.set_reason_message("You lost...")
		
		gameover_scene.show_scene()	


func get_game_state_string() -> String:
	return GAME_STATE_STRINGS[game_state]

func is_battle():
	return game_state == GameState.DEFAULT or game_state == GameState.DOMINO_CHECK or game_state == GameState.WAITING

func find_most_frequent_string(string_array):
	var string_counts = {}
	var max_count = 0
	var most_frequent_string = ""

	for string in string_array:
		if string in string_counts:
			string_counts[string] += 1
		else:
			string_counts[string] = 1

		if string_counts[string] > max_count:
			max_count = string_counts[string]
			most_frequent_string = string

	return most_frequent_string


#=====================================================
# Event handling (Dominos)
#=====================================================
func _Input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed :
		unselect_dominos()

func unselect_dominos():
	for domino in get_hand("player"):
		if domino is DominoContainer:
			domino.set_clicked(false)
	for domino in get_hand("enemy"):
		if domino is DominoContainer:
			domino.set_clicked(false)

# Handle the event when a player plays a domino
func perform_domino_action(domino_container: DominoContainer, pressed_number: int):	

	if(touch_mode):
		if(domino_container.selected):
			if(domino_container.get_current_user().to_upper() == "PLAYER" and  selection_popup.visible == false):
				play_domino(domino_container, pressed_number)
			else:
				unselect_dominos()
				update_domino_highlights()
				print("That's not your domino!")
		else:
			unselect_dominos()
			update_domino_highlights()
			domino_container.set_clicked(true)
	else:
		if player_turn && game_state == GameState.DEFAULT:
			if(domino_container.get_current_user().to_upper() == "PLAYER"):
				play_domino(domino_container, pressed_number)
			else:
				unselect_dominos()
				update_domino_highlights()
				print("That's not your domino!")
		elif player_turn && game_state != GameState.DEFAULT:
			print("Invalid move. You must complete the current action first.")
		else:
			print("It's not your turn!")

func _on_Panel_gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.pressed and game_state != GameState.TITLE:
		unselect_dominos()
		update_domino_highlights()

func play_domino(domino_container: DominoContainer, pressed_number: int):
	var user
	var target;
	if(domino_container.get_current_user().to_upper() == "PLAYER"):
		user = player
		target = enemy
	elif(domino_container.get_current_user().to_upper() == "ENEMY"):
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
		update_battle_text("Invalid move. You can only play dominos that match the last number (" + str(last_played_number) + ")")
	elif result == "prohibited":
		update_battle_text("Invalid move. Conditions do not meet requirements.")
	elif result == "locked":
		update_battle_text("This domino is unplayable.")
	elif result == "action_points_deficiency":
		update_battle_text("Domino requires " + str(domino_container.get_action_points()) + " action points to play.")
	elif result == "petrification":
		update_battle_text("Domino is unplayable due to petrification status.")

# Move a valid domino to the play field and disable its buttons
func move_domino_to_playfield(domino_container):
	# Reset colour of domino
	domino_container.modulate = Color(1, 1, 1)
	
	"""
	if not domino_container.is_connected("action_completed", self, "_on_action_completed"):
		domino_container.connect("action_completed", self, "_on_action_completed")
		print("Signal connected successfully!")
	else:
		print("Signal already connected!")

	# Apply domino effect (such as damage or shielding)
	# Action point costs
	
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
		for domino in player_hand.get_children():
			domino.on_play() # Domino volatility
	else:
		enemy_hand.remove_child(domino_container) # Remove from AI's hand
		for domino in enemy_hand.get_children():
			domino.on_play() # Domino volatility
	
	domino_container.set_current_user("board") # Set the user to the board
	domino_container.set_clicked(false)
	domino_container.clear_highlight()
	play_board.add_child(domino_container) # Add to play field
	#play_board.get_child(play_board.get_child_count() - 1).grab_focus()

	# Set the initial position to the start position
	domino_container.rect_position = start_position

	# Show the domino and animate it to its position on the board
	tween.interpolate_property(domino_container, "rect_position", start_position, target_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(domino_container, "modulate:a", 0, 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	domino_container.visible = true
	yield(tween, "tween_all_completed")

	reposition_domino_hand() # Reposition the dominos in the player's hand (and enemy's hand)

	# Update the last played number (the second number of the domino)
	
	# Wait for the "action_completed" signal from the domino
	yield(domino_container, "action_completed")
	"""
	if domino_container.get_user().to_upper() == "PLAYER":
		domino_container.effect(player, enemy)
		player.spend_action_points(domino_container.get_action_points())
	elif domino_container.get_user().to_upper() == "ENEMY":
		domino_container.effect(enemy, player)
		enemy.spend_action_points(domino_container.get_action_points())

	set_played_number(domino_container.get_numbers()[1])
	
	set_game_state(GameState.DEFAULT)	
	var _game_over_state = check_game_over() # Check if the game is over
	
func set_played_number(number: int):
	last_played_number = number
	update_domino_highlights() # Update the highlights of the dominos in the player's hand

func damage_battler(attacker, defender, amount: int, simulate_damage: bool = false) -> int:

	var damage_data

	if attacker == null:
		print("Err... attacker is invalid. Something went wrong!")
		return amount

	if defender == null and is_battle():
		defender = enemy

	damage_data = { "damage": amount, "attacker": attacker, "defender": defender }

	if (defender != null and is_battle()):
		
		# Apply additive damage modifications
		for effect in attacker.effects:
			effect.on_event("modify_damage", damage_data, simulate_damage)
		
		# Apply multiplicative damage modifications
		for effect in attacker.effects:
			effect.on_event("magnify_damage", damage_data, simulate_damage)
		
		# Apply multiplicative damage reduction effects for defender
		for effect in defender.effects:
			effect.on_event("minify_damage", damage_data, simulate_damage)
		
		# Apply additive damage reduction effects for defender
		for effect in defender.effects:
			effect.on_event("subtractive_damage", damage_data, simulate_damage)

		amount = int(round(damage_data["damage"]))


	# Skip actual HP or shield modification if this is a simulation
	if simulate_damage or defender == null:
		return amount

	for effect in attacker.effects:
		effect.on_event("use_attack", damage_data)

	if amount > 0:
		for effect in defender.effects:
			effect.on_event("take_damage", damage_data)
		
		for effect in attacker.effects:
			effect.on_event("deal_damage", damage_data)
	
	# Handle shield and HP adjustments based on final damage amount
	var shield_difference = defender.shield - amount
	if shield_difference < 0:
		defender.shield = 0
		amount = int(abs(shield_difference))
		defender.hp -= amount
		defender.hp = int(clamp(defender.hp, 0, defender.get_max_hp()))

		for effect in defender.effects:
			effect.on_event("receive_damage", damage_data)
		for effect in attacker.effects:
			effect.on_event("deal_damage", damage_data)

	else:

		# Full shield block effects
		for effect in defender.effects:
			effect.on_event("full_block", damage_data)
		# Attacker's effect for fully blocked attack
		for effect in attacker.effects:
			effect.on_event("blocked_attack", damage_data)
		
		defender.shield -= amount
		amount = 0

	defender.update()
	attacker.update()
	return amount

func self_shield(defender, amount: int, simulate_shield: bool = false) -> int:

	if (defender == null and simulate_shield):
		return amount
	
	var shield_data = { "shield_amount": amount, "defender": defender }

	for effect in defender.effects:
		effect.on_event("on_shields", shield_data)

	if(simulate_shield):
		return amount
		
	defender.shield += shield_data["shield_amount"]
	defender.update()
	return amount

func _on_action_completed():
	print("Waiting finished")
	set_game_state(GameState.DEFAULT)	

# Popup for effects
func show_popup(text: String, target, text_color = "Red", animation = "PopupAnimation", popup_string: String = ""):
	# Check if there's an existing popup in the AnimationLayer
	var animation_layer = target.get_node("AnimationLayer")
	
	# Create and show the new popup
	var popup = preload("res://Battlers/DamagePopup.tscn").instance()
	popup.initialise(text, target, text_color, animation, popup_string)
	animation_layer.add_child(popup)

#=====================================================
# Domino manipulation selection
#=====================================================
# Trigger discard selection from the special domino effect

# Gets a collection based on the target (string will be converted to battler) and collection (string will be converted to collection)
# Returns an array of dominos (such as player's hand or enemy's discard pile)
func get_target_collection(target: String, collection: String) -> Array:
	var target_collection
	if(target.to_upper() == "PLAYER"):
		target_collection = get_hand("player")
	elif(target.to_upper() == "ENEMY"):
		target_collection = get_hand("enemy")
	match collection.to_upper():
		"HAND":
			return target_collection.get_children()
		"HAND_ARROW":
			var new_collection: Array = [] 
			for domino in target_collection.get_children():
				if "arrow" in domino.get_criteria():
					new_collection.append(domino)
			return new_collection
		"PILE":
			return string_to_battler(target).get_draw_pile()
		"DISCARD":
			return string_to_battler(target).get_discard_pile() 
		"VOID":
			return string_to_battler(target).get_void_space()
		"STACK", "REMOVABLE_STACK":
			return string_to_battler(target).get_deck()
		"UPGRADABLE_STACK":
			var upgradable_stack: Array = []
			for domino in string_to_battler(target).get_deck():
				if domino.can_upgrade():
					upgradable_stack.append(domino)
			return upgradable_stack
		_:
			print("Invalid target for discard selection. Target: ", target, " Collection: ", collection)
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
			if(origin_collection.to_upper() == "HAND_ARROW"):
				var target
				var domino_user

				if(domino.get_current_user().to_upper() == "PLAYER"):
					target = string_to_battler("ENEMY")
					domino_user = string_to_battler("PLAYER")
				elif(domino.get_current_user().to_upper() == "ENEMY"):
					domino_user = string_to_battler("ENEMY")
					target = string_to_battler("PLAYER")

				print(domino.get_current_user().to_upper())
				print("[Game.gd trigger_domino_transfer] Discarding ", domino.domino_name, " from ", domino_user, "'s hand to ", target, "'s discard pile")

				domino.discard_effect(domino_user, target)
				return
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
	update_domino_highlights()

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
	update_domino_highlights()

# Special method for erasing from hand (tween animation)
func erase_from_hand(collection: Array, domino: DominoContainer):
	for user_dominos in collection:
		if user_dominos.check_shadow_match(domino):
			collection.remove(user_dominos); 
			break;
	update_domino_highlights()

func erase_from_board(domino: DominoContainer):
	for user_dominos in domino_land.board:
		if user_dominos.check_shadow_match(domino):
			domino_land.board.remove(user_dominos)
			break;
	update_domino_highlights()

func domino_selection(selection_minimum: int, maximium_selection: int, origin_domino: DominoContainer, target: String, collection: String, collection_size: int = -1, destination_collection: String = "hand", effect: Dictionary = {}, randomise: bool = false):
	var targetted_collection = get_target_collection(target, collection)
	
	if(targetted_collection.size() == 0 || collection_size == 0 || (targetted_collection.size() == 1 && collection.to_upper() == "HAND")):
		update_battle_text("Not enough dominos to select from.")
		return
	else:
		selection_popup.show()
		var collection_copy = targetted_collection.duplicate()

		# Setup collection size
		if(collection_size > 0):
			collection_copy.resize(collection_size)

		# Randomise the collection
		if(randomise):
			print("Sorting collection")
			collection_copy.sort_custom(self, "_sort_by_name")

		selection_popup.setup_selection_popup(collection_copy, selection_minimum, maximium_selection, origin_domino, target, collection, destination_collection, "process_selection", effect)
		selection_popup.get_node("PopupPanel").popup_centered()


# Sorting function
func _sort_by_name(a, b):
	# First, compare names
	if a.domino_name.to_lower() != b.domino_name.to_lower():
		return a.domino_name.to_lower() < b.domino_name.to_lower()

	# Compare the first number
	if a.get_numbers()[0] != b.get_numbers()[0]:
		return a.get_numbers()[0] < b.get_numbers()[0]

	# If the first numbers are the same, compare the second number
	return a.get_numbers()[1] < b.get_numbers()[1]

# Moves selected dominos to destination collection
# Requires: An array of dominos, the target as a string (will be turned into a battler object), original location and destination
# Can also specify an effect method that will apply a method on the selected dominos (method must be part of domino container)
func process_selection(selected_dominos: Array, target: String, origin_collection, destination_collection: String, effects: Dictionary):
			
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

		# Apply effect to a domino from the deck (such as upgrading)
		# We also need to cycle through the deck (stack) and not apply the method to the selected_domino (which is just a copy of the deck)
		"UPGRADABLE_STACK":
			for user_dominos in string_to_battler(target).get_deck():
				for domino in selected_dominos:
					if user_dominos.check_shadow_match(domino):
						for method_name in effects.keys():
							if user_dominos.has_method(method_name.to_lower()):
								print("Method ", method_name, " with args ", effects[method_name], " applied to ", user_dominos.get_domino_name())
								user_dominos.callv(method_name.to_lower(), effects[method_name])
							else:
								print("Method '%s' not found on domino." % method_name)
		"REMOVABLE_STACK":
			for user_dominos in string_to_battler(target).get_deck():
				for domino in selected_dominos:
					if user_dominos.check_shadow_match(domino):
						for method_name in effects.keys():
							if user_dominos.has_method(method_name.to_lower()):
								print("Method ", method_name, " with args ", effects[method_name], " applied to ", user_dominos.get_domino_name())
								user_dominos.callv(method_name.to_lower(), effects[method_name])
							else:
								print("Method '%s' not found on domino." % method_name)

		"SAME_HAND", "SAME_HAND_DISCARD", "SAME_HAND_UPGRADE", "SAME_HAND_REROLL":
			# For skills that apply an effect to the selected dominos
			for user_dominos in string_to_battler(target).get_hand().get_children():
				for domino in selected_dominos:
					if user_dominos.check_shadow_match(domino):
						for method_name in effects.keys():
							if user_dominos.has_method(method_name.to_lower()):
								print("Method ", method_name, " with args ", effects[method_name], " applied to ", user_dominos.get_domino_name())
								user_dominos.callv(method_name.to_lower(), effects[method_name])
							else:
								print("Method '%s' not found on domino." % method_name)

		_:
			print("Invalid destination collection: ", destination_collection)
	
	game_state = GameState.DEFAULT
	update_domino_highlights()

func is_selection() -> bool:
	return game_state != GameState.DEFAULT || game_state != GameState.INACTIVE

func game_state_default() -> bool:
	return game_state == GameState.DEFAULT

func game_state_inactive() -> bool:
	return game_state == GameState.INACTIVE

# Moves dominos from playfield their owner's collection
func return_playfield_dominos(selected_dominos: Array, destination_collection: String):
	for domino in selected_dominos:
		if domino.get_user().to_upper() == "BOARD":
			print("Ignore first domino")
		else:
			for played_domino in domino_land.board:
				print("Checking domino: ", played_domino.domino_name, " against ", domino.domino_name)
				if played_domino.check_shadow_match(domino):
					var target = played_domino.get_user()
					played_domino.set_current_user(target)
					if(target.to_upper() == "PLAYER"):
						played_domino.set_clickable(true)
					else:
						played_domino.set_clickable(false)
					process_selection([played_domino], played_domino.get_user(), "PLAY", destination_collection, {})
					break

#=====================================================
# Turn End and AI Turn
#=====================================================

func end_battler_turn(battler: String):
	print(battler, " has ended their turn.")
	if battler.to_upper() == "PLAYER":
		var timer = 20
		while(get_game_state_string() == "Waiting" && timer > 0):
			print(timer)
			yield(get_tree().create_timer(0.1), "timeout")
			timer -= 0.1
		_on_end_turn_pressed()
	elif battler.to_upper() == "ENEMY":
		enemy_end_turn()
	
# End the player's turn and start the AI's turn
func _on_end_turn_pressed():
	if(get_game_state_string() == "Waiting"):
		return
	else:
		unselect_dominos()
		end_turn_button.disabled = true # Disable end turn button during AI's turn
		if (!check_game_over()): # Check if the game is over before switching turns
			if player_turn:
				player_turn = false			
				player.on_turn_end() # Reset the dominos played this turn
				domino_turn_end_effects(get_hand("player"), player)
				enemy_start_turn()

# AI plays its dominos
func enemy_start_turn():
	enemy.on_turn_start()  # Start the AI's turn

	# Effects
	var effect_data = {"user": enemy, "target": player }
	for effect in enemy.effects:
		effect.on_event("turn_start", effect_data)   
		effect.update_duration(enemy)

	var best_sequence = calculate_best_play()  # Calculate the best sequence of dominos to play

	print("AI has decided to play the following dominos:", best_sequence)

	if(best_sequence.empty()):
		print("AI cannot play any dominos. Player's turn resumes.")
		enemy_end_turn()
		return
	
	# Step 3: Play the best sequence
	print("AI has decided to play the following dominos:", best_sequence)
	for domino in best_sequence:
		play_domino(domino, domino.get_numbers()[0])  # Play the domino
		yield(get_tree().create_timer(3.0), "timeout")

	print("AI played " + str(len(best_sequence)) + " dominos.")
	enemy_end_turn()

# Helper function: Get a list of all playable dominos
func get_playable_dominos() -> Array:
	var playable_dominos = []
	for domino in get_hand("enemy"):
		if domino.can_play(last_played_number, enemy, player, domino.get_numbers()[0]) in ["swap", "playable"]:
			playable_dominos.append(domino)
	return playable_dominos

# Score the sequence of dominos played by the AI
# Currently the AI will score based on how many dominos can be played
func evaluate_sequence(sequence: Array) -> int:
	return len(sequence)  # A basic scoring system: more dominos played = higher score

# Recursive helper function to generate all valid sequences
func generate_sequences(played_number: int, remaining_action_points: int, sequence: Array, all_sequences: Array) -> void:
	for domino in get_hand("enemy"):
		if domino in sequence:
			continue  # Skip already played dominos
		if remaining_action_points < domino.get_action_points():
			continue  # Skip if not enough action points
		
		# Check if the domino can play from the current played number
		var play_status = domino.can_play(played_number, enemy, player, domino.get_numbers()[0])
		if play_status in ["swap", "playable"]:
			# Determine the next played number
			var next_played_number = domino.get_numbers()[1] if domino.get_numbers()[0] == played_number else domino.get_numbers()[0]
			
			# Create a new sequence and add this domino to it
			var new_sequence = sequence.duplicate()
			new_sequence.append(domino)
			#print("Adding domino to sequence: ", domino.get_domino_name())
			
			# Add the new sequence to the list of all sequences
			all_sequences.append(new_sequence)
			
			# Recursively generate sequences from this state
			generate_sequences(next_played_number, remaining_action_points - domino.get_action_points(), new_sequence, all_sequences)

# Main AI decision-making function to calculate the best play
func calculate_best_play() -> Array:
	var all_sequences = []
	generate_sequences(last_played_number, enemy.action_points, [], all_sequences)  # Generate all valid sequences
	
	# Evaluate all sequences and pick the best one
	var best_sequence = []
	var max_score = 0
	
	for sequence in all_sequences:
		var score = evaluate_sequence(sequence)
		if score > max_score:
			max_score = score
			best_sequence = sequence
	
	return best_sequence

# Helper function: Simulate playing dominos recursively
func simulate_play_sequence(current_domino, played_number, sequence, remaining_action_points) -> Array:
	sequence.append(current_domino)
	remaining_action_points -= current_domino.get_action_points()  # Deduct action points from simulation

	# Simulate the played number
	var simulated_last_number = current_domino.get_numbers()[1]

	# Find the next playable domino
	for domino in get_hand("enemy"):
		if domino in sequence:
			continue  # Skip already played dominos
		if remaining_action_points < domino.get_action_points():
			continue  # Skip if not enough action points to play this domino
		if domino.can_play(simulated_last_number, enemy, player, domino.get_numbers()[0]) in ["swap", "playable"]:
			return simulate_play_sequence(domino, simulated_last_number, sequence, remaining_action_points)  # Recurse

	return sequence  # Return the full sequence
	
# Helper function: Highlight enemy intentions
func highlight_enemy_intentions():
	reset_enemy_domino_highlights()
	var sequence = calculate_best_play()  # Calculate the best sequence of dominos to play
	for domino in sequence:
		domino.modulate = Color(1, 0, 0)  # Example: Set a red tint to highlight dominos

# Helper function: Remove modulate from all enemy dominos
func reset_enemy_domino_highlights():
	for domino in get_hand("enemy"):
		domino.modulate = Color(1, 1, 1)

func enemy_end_turn():
	enemy.on_turn_end() # Reset the dominos played this turn
	domino_turn_end_effects(get_hand("enemy"), enemy)

	player_start_turn()  # Start the player's turn

func player_start_turn():
	
	player.on_turn_start()

	turns +=1
	player_turn = true
	end_turn_button.disabled = false  # Enable the end turn button

	# Effects
	var effect_data = {"user": player, "target": enemy }
	for effect in player.effects:
		effect.on_event("turn_start", effect_data)   
		effect.update_duration(player)
	
	# Dominos
	for domino in get_hand("player"):
		domino.on_turn_start()

	draw_hand(player.get_draw_per_turn(), "PLAYER", "ANY")  # Draw dominos for the player
	draw_hand(enemy.get_draw_per_turn(), "ENEMY", "ANY")  # Draw dominos for the enemy

func domino_turn_end_effects(hand: GridContainer, battler):
	# Domino effect
	for domino in hand.get_children():
		domino.set_petrification(0)
		if(domino.is_ephemeral()):
			battler.add_to_void_space(domino, "hand")

#=====================================================
# Game States
#=====================================================

# Check if the game is over
func check_game_over(turn_end: bool = false) -> bool:
	if player.get_draw_pile().size() == 0 && turn_end:
		update_battle_text("Player loses! No more dominos to draw.")
		end_turn_button.set_text("Player loses!")
		end_turn_button.disabled = true
		player.get_node("AnimationPlayer").play("player_death")
		set_game_state(GameState.GAMEOVER)
		player.set_hp(0)
		return true
	elif enemy.get_draw_pile().size() == 0 && turn_end:
		print("Enemy loses! No more dominos to draw.")
		process_enemy_death()
		return true
	elif(player.hp <= 0):
		print("Player loses! HP is 0.")
		update_battle_text("Player loses!")
		end_turn_button.disabled = true
		player.get_node("AnimationPlayer").play("player_death")
		set_game_state(GameState.GAMEOVER)
		return true
	elif(enemy.hp <= 0):
		print("Enemy loses! HP is 0.")
		process_enemy_death()
		return true
	else:
		update_battle_text("Game continues... Turn " + str(turns + 1))
		return false

func wait(time: float, next_game_state):
	set_game_state(GameState.WAITING)
	yield(get_tree().create_timer(time), "timeout")
	set_game_state(next_game_state)

# Remove dominos from their parents so they can be re-parented in a new battle
func disable_player_dominos():
	for domino in get_hand("player"):
		domino.set_clickable(false)
	
#=====================================================
# Rewards
#=====================================================
func process_enemy_death():
	update_battle_text("Enemy is defeated!")
	end_turn_button.disabled = true
	enemy.get_node("AnimationPlayer").play("enemy_death")
	enemy.buff_pose(enemy.get_gems(), BBCode.bb_code_gem())
	player.add_gems(enemy.get_gems())
	set_game_state(GameState.INACTIVE)
	disable_player_dominos()
	battle_rewards()

func battle_rewards():

	write_battle_log()

	if(get_game_state_string() == "Game Over" || player.hp <= 0):
		print("Game over!")
		return
	player.reset()
	hide_ui()
	player.hide_ui()
	enemy.hide_ui()
	disable_buttons()
	
	enemy.get_node("AnimationPlayer").play("enemy_death")
	yield(get_tree().create_timer(1.0), "timeout")
	var reward_popup = preload("res://Reward/RewardsPopup.tscn").instance() 
	add_child(reward_popup)
	var random_enemy_domino
	if is_instance_valid(enemy):
		# Get a random domino from enemy's deck that can be obtained by the player
		var obtainable_domino = []
		for domino in enemy.get_deck():
			if "any" in domino.get_criteria():
				obtainable_domino.append(domino)
		if(obtainable_domino.size() > 0):
			random_enemy_domino = obtainable_domino[randi() % obtainable_domino.size()]
	reward_popup.create_rewards(random_enemy_domino)

	yield(get_tree().create_timer(1.0), "timeout")
	reset_game_state()

func reset_game_state():
	for domino in get_hand("player"):
		get_hand("player").remove(domino)
	for domino in get_hand("enemy"):
		get_hand("enemy").remove(domino)
	for domino in domino_land.board:
		domino_land.board.remove(domino)

	if(is_instance_valid(enemy)):
		remove_child(enemy)

# This method determines the next reward to give to the player
func get_next_equipment_reward():
	pass

# Returns an array of dominos that can be obtained by the player
func get_domino_rewards(reward_number: int = 3) -> Array:
	
	# Grab all dominos in the game
	var attack_domino_list = player.load_dominos_from_folder("res://Domino/Attack", "")
	var skill_domino_list = player.load_dominos_from_folder("res://Domino/Skill", "")

	# Go through our domino list and remove the following dominos that have the criteria:
	var exclusion_criteria = ["enemy", "weapon"]

	# Filter dominos by rarity
	# Note enemy domino is referenced by DOMINO NAME

	var final_list = attack_domino_list + skill_domino_list
	
	final_list.shuffle()

	# Go through entire list of dominos and remove any that do not fit with player's criteria
	# For uncommon dominos, 75% chance to remove it from the list
	# For rare dominos, 90% chance to remove it from the list

	var curated_list = []
	var rare_list = []
	
	for domino in final_list:
		var temp_domino = domino.instance()
		if has_common_criteria(temp_domino.get_criteria(), exclusion_criteria):
			continue
		if has_common_criteria(temp_domino.get_criteria(), player.get_criteria()):
			# Check rarity
			if "common" in temp_domino.get_criteria():
				if(curated_list.size() < reward_number):
					curated_list.append(temp_domino)
			if "uncommon" in temp_domino.get_criteria():
				if(curated_list.size() < reward_number  && randf() > 0.75):
					curated_list.append(temp_domino)
			if "rare" in temp_domino.get_criteria() :
				rare_list.append(temp_domino)
				if(curated_list.size() < reward_number  && randf() > 0.9):
					curated_list.append(temp_domino)
	
	#var new_domino = load("res://Domino/Skill/NullField.tscn").instance()
	#curated_list[0] = new_domino

	if(dominos_since_last_rare() > 10):
		print("Forced rare")
		curated_list[0] = rare_list[randi() % rare_list.size()]

	add_offered_dominos(curated_list)

	print("Last rare domino: ", dominos_since_last_rare())
	return curated_list

func dominos_since_last_rare():
	var domino_count = 0
	var current_battle_log = get_battle_log()
	
	# Iterate from the last element to the first
	for i in range(current_battle_log.size() - 1, -1, -1):  # Start from last index to 0
		var entry = current_battle_log[i]
		if "offered_dominos" in entry.keys():
			for domino in entry["offered_dominos"]:
				if "rare" in domino.get_criteria():
					print("Last rare domino: ", domino.get_domino_name(), " | ", domino_count, " dominos since last rare domino")
					return domino_count  # Stop counting when a rare domino is found
				else:
					domino_count += 1

	print(domino_count, " dominos since last rare domino")
	return domino_count  # Return the count if no rare domino is found

func get_all_equipment(filter_criteria: Array = [], exclusion_criteria: Array = []) -> Array:

	var all_equips = player.list_equipment_files()
	var available_equips = []
	var final_list = []

	for item in all_equips:
		var temp_equip_instance = load("res://Equipment/" + item + ".tscn").instance()
		available_equips.append(temp_equip_instance)

	# Filter through required criteria
	for item in available_equips:
		#print("Checking: ", item.equipment_name)
		if has_common_criteria(item.get_criteria(), filter_criteria, false):
			if has_common_criteria(item.get_criteria(), exclusion_criteria, false) == false:
				if(item.is_unique() && player.get_inventory().has(item)):
					item.queue_free()
				elif(item.is_unique() && player.get_equipped_items().has(item)):
					item.queue_free()
				else:
					final_list.append(item)
			else:
				item.queue_free()
		else:
			item.queue_free()

	#print("Final list: ", final_list)
	return final_list

# Returns an array of dominos that can be obtained by the player
func get_equipment_rewards(reward_number: int = 1) -> Array:
	
	# Grab all dominos in the game
	var attack_domino_list = player.load_dominos_from_folder("res://Domino/Attack", "")
	var skill_domino_list = player.load_dominos_from_folder("res://Domino/Skill", "")

	# Filter dominos by rarity
	# Note enemy domino is referenced by DOMINO NAME

	var final_list = attack_domino_list + skill_domino_list
	final_list.shuffle()

	# Go through entire list of dominos and remove any that do not fit with player's criteria
	# For uncommon dominos, 75% chance to remove it from the list
	# For rare dominos, 90% chance to remove it from the list

	var curated_list = []
	var rare_list = []
	
	for domino in final_list:
		var temp_domino = domino.instance()
		if has_common_criteria(temp_domino.get_criteria(), player.get_criteria()):
			# Check rarity
			if "common" in temp_domino.get_criteria():
				if(curated_list.size() < reward_number):
					curated_list.append(temp_domino)
			if "uncommon" in temp_domino.get_criteria():
				if(curated_list.size() < reward_number  && randf() > 0.75):
					curated_list.append(temp_domino)
			if "rare" in temp_domino.get_criteria() :
				rare_list.append(temp_domino)
				if(curated_list.size() < reward_number  && randf() > 0.9):
					curated_list.append(temp_domino)
	
	#var new_domino = load("res://Domino/Skill/NullField.tscn").instance()
	#curated_list[0] = new_domino

	if(dominos_since_last_rare() > 10):
		print("Forced rare")
		curated_list[0] = rare_list[randi() % rare_list.size()]

	add_offered_dominos(curated_list)

	print("Last rare domino: ", dominos_since_last_rare())
	return curated_list

func equipment_since_last_rare():
	var equipment_count = 0
	var current_battle_log = get_battle_log()
	
	# Iterate from the last element to the first
	for i in range(current_battle_log.size() - 1, -1, -1):  # Start from last index to 0
		var entry = current_battle_log[i]
		if "offered_equips" in entry.keys():
			for equip in entry["offered_equips"]:
				if "rare" in equip.get_criteria():
					return equipment_count  # Stop counting when a rare domino is found
				else:
					equipment_count += 1
	
	return equipment_count  # Return the count if no rare domino is found

#=====================================================
# Map stuff
#=====================================================

func generate_map_data(number_of_columns: int, start_x: int, start_y: int, spacing_x: int, spacing_y: int, jitter: int, 
					   guaranteed_heal_columns: Array, guaranteed_upgrade_columns: Array, guaranteed_enemy_columns: Array, 
					   guaranteed_boss_columns: Array) -> Dictionary:
	
	randomize()
	var node_id = 0
	var map_structure = {
		"nodes": []  # Multi-dimensional array: columns -> nodes
	}

	# **Generate Nodes**
	for col in range(number_of_columns):
		var nodes_in_column = get_nodes_per_column(col, number_of_columns)
		var column_nodes = []
		
		for i in range(nodes_in_column):
			var x = start_x + col * spacing_x + floor(randf() * jitter)
			var y = start_y + (i - nodes_in_column / 2.0) * spacing_y + floor(randf() * jitter)
			var position = Vector2(x, y)

			var node_type = get_node_type(col, guaranteed_heal_columns, guaranteed_upgrade_columns, guaranteed_enemy_columns, guaranteed_boss_columns)

			# **Store Node Data**
			var node_data = {
				"id": node_id,
				"type": node_type,
				"position": position,
				"connected_nodes": [],  # Forward connections
				"incoming_nodes": []    # Backward connections
			}
			column_nodes.append(node_data)
			node_id += 1  # Unique ID for each node
		
		map_structure["nodes"].append(column_nodes)

	# **Generate Connections**
	for col in range(map_structure["nodes"].size() - 1):
		var current_nodes = map_structure["nodes"][col]
		var next_nodes = map_structure["nodes"][col + 1]

		var connected_nodes = {}  # Tracks which nodes in next column have at least one incoming connection

		# **Step 1: Assign Forward Connections**
		for node in current_nodes:
			var valid_next_nodes = get_valid_connections(node, next_nodes, spacing_y)
			var selected_nodes = []  # Keep track of selected nodes to avoid duplicates

			if valid_next_nodes.size() == 0:
				# No valid connections → Force connect to the closest node
				var closest_node = get_closest_node(node, next_nodes)
				if closest_node and closest_node["id"] != node["id"]:  # Ensure no self-connection
					node["connected_nodes"].append(closest_node["id"])
					closest_node["incoming_nodes"].append(node["id"])
					connected_nodes[closest_node["id"]] = true
			else:
				# Create 1 to 3 unique random connections
				var connections_count = randi() % 3 + 1
				while selected_nodes.size() < min(connections_count, valid_next_nodes.size()):
					var next_node = valid_next_nodes[randi() % valid_next_nodes.size()]
					
					# Ensure no self-connections & no duplicate connections
					if next_node["id"] != node["id"] and not next_node["id"] in selected_nodes:
						node["connected_nodes"].append(next_node["id"])
						next_node["incoming_nodes"].append(node["id"])
						connected_nodes[next_node["id"]] = true
						selected_nodes.append(next_node["id"])  # Track added connections

		# **Step 2: Ensure Every Next Column Node Has at Least 1 Incoming Connection**
		for next_node in next_nodes:
			if not next_node["id"] in connected_nodes:
				var closest_prev_node = get_closest_node(next_node, current_nodes)
				if closest_prev_node:
					closest_prev_node["connected_nodes"].append(next_node["id"])
					next_node["incoming_nodes"].append(closest_prev_node["id"])

	# Store the generated map data
	map_data = map_structure

	# Add first node to visited nodes
	player_visited_nodes.append(0)

	return map_data

func get_nodes_per_column(col, total_columns):
	if (col < total_columns * 0.75) && (col > total_columns * 0.25):
		return max(1, 9 - int(col / 2))
	elif col == 0:
		return 1
	elif col == total_columns - 1:
		return 1 + randi() % 2
	elif col <= total_columns * 0.25:
		return col + 1
	elif total_columns >= total_columns * 0.75:
		return max(1, int(total_columns - col))
	else:
		return 1

func get_node_type(col, heal_cols, upgrade_cols, enemy_cols, boss_cols):
	if col in enemy_cols:
		return "enemy"
	elif col in boss_cols:
		return "boss"
	elif col in heal_cols and randf() > 0.5:
		return "heal"
	elif col in upgrade_cols and randf() > 0.5:
		return "upgrade"
	else:
		if randf() > 0.7:
			return "event"
		elif randf() > 0.85:
			return "shop"
		else:
			return "enemy"

		
func get_valid_connections(node, next_nodes, max_distance):
	var valid_next_nodes = []
	for next_node in next_nodes:
		if abs(node["position"].y - next_node["position"].y) <= max_distance:
			valid_next_nodes.append(next_node)
	return valid_next_nodes

func get_closest_node(node, next_nodes):
	var closest_node = null
	var min_distance = INF

	for next_node in next_nodes:
		var dist = node["position"].distance_to(next_node["position"])
		if dist < min_distance:
			min_distance = dist
			closest_node = next_node

	return closest_node



func get_map_data() -> Dictionary:
	return map_data

#=====================================================
# Next event
#=====================================================
func next_event():
	#new_battle()
	var map_scene = load("res://Event/Map.tscn").instance()
	map_scene.get_node("Node2D").recreate_map(get_map_data(), player_visited_nodes)
		
	add_child(map_scene)
	
func new_shop():
	var shop_scene = load("res://Event/Shop.tscn").instance()
	add_child(shop_scene)
	
func new_mystery_event():
	var mystery_event = load("res://Event/Event.tscn").instance()
	add_child(mystery_event)
	mystery_event.get_node("Node2D").random_event()

func new_event(event_type: String):
	var event_scene = load("res://Event/Event.tscn").instance()
	add_child(event_scene)
	event_scene.get_node("Node2D").new_event(event_type)

#=====================================================
# New battle
#=====================================================

func new_battle():
	
	var enemy_scene = load("res://Battlers/Enemy/%s.tscn" % get_next_enemy())
	add_enemy(enemy_scene)

	initialize_dominos() # Run on_battle_start() method on all dominos
	pre_battle_prompt()	

func pre_battle_prompt():
	if get_battles_won() % 1 == 0:
		var challenge_popup = preload("res://Reward/ChoicePopup.tscn").instance() 
		challenge_popup.new_challenge()
		# Set the position (popup size is 400 or 200 x 2)
		challenge_popup.get_node("Control").rect_position = Vector2(960 / 2 - 200, 20)
		challenge_popup.initialise()
		Game.get_node("Game").add_child(challenge_popup)
	else:
		post_battle_prompt()

func post_battle_prompt():
	initialize_battle() # Initialize the battle
	draw_first_domino()
	enable_buttons()
	show_ui()
	player.update()
	enemy.update()
	player.show_ui()
	enemy.show_ui()

func enable_buttons():
	get_node("../OptionMenu/ShowDraw").disabled = false
	get_node("../OptionMenu/ShowVoid").disabled = false
	get_node("../OptionMenu/ShowDiscard").disabled = false
	get_node("../OptionMenu/ShowEquip").disabled = false
	get_node("../OptionMenu/ShowSettings").disabled = false

func disable_buttons():
	get_node("../OptionMenu/ShowDraw").disabled = true
	get_node("../OptionMenu/ShowVoid").disabled = true
	get_node("../OptionMenu/ShowDiscard").disabled = true
	get_node("../OptionMenu/ShowEquip").disabled = true
	get_node("../OptionMenu/ShowSettings").disabled = true
	selection_popup.hide()
	for child in get_children():
		if child.filename == "res://Settings.tscn":
			child.queue_free()	
		if child.filename == "res://Equipment/Status.tscn":
			child.queue_free()

#=====================================================
# Draw
#=====================================================

func draw_hand(count: int, target: String, type: String = "ANY"):
	var drawn_dominos = []
	var collection
	var targetDrawPile

	# Potential for get_hand to not return a container (enemy / player container)
	if target.to_upper() == "PLAYER":
		collection = get_hand("player")
	elif target.to_upper() == "ENEMY":
		collection = get_hand("enemy")
	else:
		collection = get_hand(target)
		print("Collection: ", collection, " | target: ", target)

	targetDrawPile = string_to_battler(target).get_draw_pile() 
	
	if(targetDrawPile.size() == 0):
		print("No more dominos to draw.")
		var _game_over_state = check_game_over(true) # Check if the game is over
		return

	# Modify count based on effects
	var effect_data = {"user": string_to_battler(target), "draw": count} 
	for effect in string_to_battler(target).effects:
		effect.on_event("draw_domino", effect_data)

	count = int(max(0, effect_data["draw"]))  # Ensure count is not negative

	if(type.to_upper() != "ANY"):
		targetDrawPile = get_random_draw(type, targetDrawPile)
	for _i in range(count):
		if targetDrawPile.size() > _i:
			drawn_dominos.append(targetDrawPile[_i]) # Take a domino from the end of the pile
		else:
			print("No more dominos in the pile!")
			var _game_over_state = check_game_over(true) # Check if the game is over / note only game over if String = "ANY"
			break

	# Add the drawn dominos to the player's hand
	yield(get_tree().create_timer(0.2), "timeout") 
	for domino in drawn_dominos:
		if(domino == null):
			print("No more dominos to draw.")
			return
		targetDrawPile.erase(domino) # Remove it from the draw pile
		# Set initial opacity to 0
		# domino.modulate.a = 0

		# Add domino to hand effect
		var domino_data = {"user": string_to_battler(target), "domino": domino} 
		for effect in string_to_battler(target).effects:
			effect.on_event("draw_to_hand", domino_data)

		domino = domino_data["domino"]

		count = int(max(0, effect_data["draw"]))  # Ensure count is not negative
				
		#if domino.is_inside_tree():
		#	var current_parent = domino.get_parent()
		#	print(domino.domino_name, domino.get_numbers(), " has been removed from current parent: ", current_parent.name)
		#	current_parent.remove_child(domino)

		# Need to remove parent on ephemeral dominos when the battle ends
		# HOT FIX - Remove parent from domino so we can add it
		#if domino.get_parent() != null:
		#	domino.get_parent().remove_child(domino)
		#	print(domino.get_parent(), " is parent of ", domino.domino_name)	

		collection.append(domino)
		#collection.add_child(domino)
		#print(collection.name, " | ", domino.domino_name, " | ", domino.get_numbers(), " | ", domino.get_action_points())

		domino.update_domino()
		animate_domino(domino, collection)

	string_to_battler(target).process_excess_draw()

	update_domino_highlights()

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
	pass
	update_domino_highlights() # Update the highlights of the dominos in the player's hand
	
	#domino.visible = true
#=====================================================
# UI
#=====================================================

func update_battle_text(text: String):
	battle_text.text = text
	debug_text.text = get_game_state_string()

func update_domino_highlights():
	for domino in get_hand("player"):
		if domino is DominoContainer:
			var can_be_played = domino.can_play(last_played_number, player, enemy)
			domino.update_highlight(can_be_played == "swap" || can_be_played == "playable")

	# Optional: Highlight enemy's intended action to the player
	highlight_enemy_intentions()

func exit_popup():
	selection_popup.hide()

func _on_ShowDraw_pressed():
	selection_popup.show()
	selection_popup.setup_collection_popup(player.get_draw_pile(), "DRAW")
	selection_popup.get_node("PopupPanel").popup_centered()

func _on_ShowDiscard_pressed():
	selection_popup.show()
	selection_popup.setup_collection_popup(player.get_discard_pile(), "DISCARD")
	selection_popup.get_node("PopupPanel").popup_centered()

func _on_ShowVoid_pressed():
	selection_popup.show()
	selection_popup.setup_collection_popup(player.get_void_space(), "VOID")
	selection_popup.get_node("PopupPanel").popup_centered()

func _on_ShowEquip_pressed():
	var status_screen = preload("res://Equipment/Status.tscn").instance() 
	status_screen.get_node("Node2D").initialise()
	add_child(status_screen)

func _on_ShowSettings_pressed():
	var settings = preload("res://Settings.tscn").instance()
	add_child(settings)


func hide_ui():
	get_node("../OptionMenu").hide()
	get_node("../EndTurn").hide()
	get_node("../BattleText").hide()
	get_node("../DebugText").hide()

func show_ui():
	get_node("../OptionMenu").show()
	get_node("../EndTurn").show()
	get_node("../BattleText").show()
	get_node("../DebugText").show()
	
# =====================================================
# Battle log
# =====================================================

func write_battle_log():
	var played_dominos = []
	var discarded_dominos = []
	var voided_dominos = []
	for domino in domino_land.board:
		if domino.get_user().to_upper() == "PLAYER":
			played_dominos.append(domino.get_domino_name())
	for domino in player.get_discard_pile():
		discarded_dominos.append(domino.get_domino_name())
	for domino in player.get_void_space():
		voided_dominos.append(domino.get_domino_name())

	var battle_data = {
	"turns": turns,
	"enemy_name": enemy.battler_name,
	"player_played_dominos": played_dominos,
	"played_discarded_dominos": discarded_dominos,
	"played_voided_dominos": voided_dominos,
	"current_hp": player.hp,
	"enemy_hp": enemy.get_max_hp()
	}

	battle_log.append(battle_data)

func add_offered_dominos(domino_array: Array):
	battle_log.append({"offered_dominos": domino_array})

func chosen_offered_domino(chosen_domino: DominoContainer):
	battle_log.append({"chosen_offered_domino": chosen_domino.domino_name})

func get_battle_log():
	return battle_log

func get_battles_won() -> int:
	var count = 0
	for entry in battle_log:
		if "enemy_name" in entry.keys():
			count += 1
	return count

func get_events_encountered() -> int:
	var count = 0
	for entry in battle_log:
		if "event_name" in entry.keys():
			count += 1
	return count

func current_level() -> int:
	return get_battles_won() + get_events_encountered()

# =====================================================
# Utility
# =====================================================

func has_common_criteria(item_criteria: Array, battler_criteria: Array, include_any: bool = true) -> bool:
	if(include_any):
		if not "any" in battler_criteria:
			battler_criteria.append("any") # Add any to the criteria
	if item_criteria.size() == 0:
		#print("No criteria to check")
		return false # No criteria to check
	elif "enemy" in item_criteria:
		return false # Enemy only  
	for criterion in battler_criteria:
		if item_criteria.has(criterion):
			#print("Found common criterion: ", criterion)
			return true  # Found a common criterion
	return false  # No common criteria

# Creates an instance of a domino based on its name
func get_domino_from_name(domino_name: String):
	var possible_types = ["skill", "attack", "blight"]  # List of possible types
	for type in possible_types:
		var path = "res://Domino/" + type + "/" + domino_name + ".tscn"
		if ResourceLoader.exists(path):
			var new_domino = load(path).instance()
			return new_domino
	return null  # Return a default value if not found
		
# Creates an instance of equipment based on its name
func get_equipment_from_name(equipment_name: String):
	var path = "res://Equipment/" + equipment_name.replace(" ", "") + ".tscn"
	if ResourceLoader.exists(path):
		var new_equipment = load(path).instance()
		return new_equipment
	return null  # Return a default value if not found

func find_orphaned_nodes():
	var orphaned_nodes = []
	var tree = get_tree()
	
	# Iterate over all nodes in the scene tree
	tree.get_root().propagate_call("check_orphaned", orphaned_nodes)

	# Print or handle the orphaned nodes
	for orphan in orphaned_nodes:
		if orphan is DominoContainer:
			print("Orphaned domino: ", orphan.domino_name)
		else:
			print("Orphaned node: ", orphan.name)
	return orphaned_nodes

# Add this function to all nodes to enable checking
func check_orphaned(orphaned_nodes):
	if not is_inside_tree():  # Node is not in the scene tree
		orphaned_nodes.append(self)

