extends Node2D

var current_event_index: int = 0
var active = true
var npc_name: String = "Boomarian Civilian 1" # Default NPC name
var event_data = []
var is_typing = false  # Flag to check if typing is ongoing
var can_process_input: bool = false
var event_log = {
	"event_name": "",
	"gems_gained": 0,
	"gain_hp": 0,
	"domino_gained": "",
	"domino_lost": "",
	"domino_upgraded": "",
	"equipment_gained": "",
	"equipment_lost": "",
	"max_hp_gained": 0
}

# ==============================================================================
# Event functions
# ==============================================================================

func set_event_name(name: String):
	event_log.event_name = name	

func add_event_log(key: String, value):
	event_log[key] = value

func write_event_log() -> void:
	var new_log = {}
	new_log.event_name = event_log.event_name
	if event_log.gems_gained != 0:
		new_log["gems_gained"] = event_log.gems_gained
	if event_log.gain_hp != 0:
		new_log["gain_hp"] = event_log.gain_hp
	if event_log.domino_gained != "":
		new_log["domino_gained"] = event_log.domino_gained
	if event_log.domino_lost != "":
		new_log["domino_lost"] = event_log.domino_lost
	if event_log.equipment_gained != "":
		new_log["equipment_gained"] = event_log.equipment_gained
	if event_log.equipment_lost != "":
		new_log["equipment_lost"] = event_log.equipment_lost
	if event_log.max_hp_gained != 0:
		new_log["max_hp_gained"] = event_log.max_hp_gained
		
	Game.get_node("Game").battle_log.append(new_log)
	print("Event log: ", new_log)

# Called when the node enters the scene tree for the first time.
func _ready():
	active = true

	$VBoxContainer.hide()

	# Make first input require 1 second delay before processing
	# When we click the ? event, it will require a click which will also be registered by this event
	# And cause the event to increment the index twice
	can_process_input = false

	#Game.get_node("Game").player.hp = 34
	#Game.get_node("Game").player.gems += 102
	# sacrifice_event, equipment_offering, healer_event, thorny_treasure, gamble_matching_domino
	new_event("free_upgrade")
	reset()

func new_event(event: String):
	reset()
	active = true
	match event:
		"sacrifice":
			sacrifice_event()
		"equipment_offering":
			equipment_offering()
		"healer":
			healer_event()
		"thorny_treasure":
			thorny_treasure()
		"gamble_matching_domino":
			gamble_matching_domino()
		"free_heal":
			free_heal()
		"free_upgrade":
			free_upgrade()
		"random":
			random_event()
		_:
			print("Event not found.")
			conversation()
	initialise()

func random_event():

	# Create an array of potential unexplored events
	var potential_events = [
		"sacrifice",
		"equipment_offering",
		"healer",
		"thorny_treasure",
		"gamble_matching_domino"
	]

	var perennial_events = [
		"thorny_treasure",
		"gamble_matching_domino"
	]

	# Remove events that the player has encountered
	for event in Game.get_node("Game").get_battle_log():
		if "event_name" in event.keys():
			if potential_events.has(event["event_name"]):
				potential_events.erase(event["event_name"])
	
	if potential_events.size() == 0:
		print("All events have been encountered.")
		potential_events = perennial_events

	potential_events.shuffle()
	new_event(potential_events[0])
	yield($AnimationPlayer, "animation_finished")

func reset():
	$VBoxContainer.hide()
	$PlayerSprite.hide()
	$HBoxContainer.hide()
	$NPCBust.hide()
	$Status.hide()
	$Stack.hide()
	$Next.hide()
	$Container.hide()
	current_event_index = 0
	can_process_input = false

func destroy():
	reset()
	$AnimationPlayer.play("fade_out_reward")
	yield($AnimationPlayer, "animation_finished")
	print("Destroying event scene")
	queue_free()

func initialise():

	$AnimationPlayer.play("fade_in_reward")
	yield($AnimationPlayer, "animation_finished")

	# Initiate busts
	# First and second elements of the event_data array should correspond to our speakers
	# First speaker must be the player
	var speaker1 = event_data[0]["speaker"]
	var speaker2 = event_data[1]["speaker"]

	
	if speaker1 != speaker2:
		$NPCBust.play(speaker2.replace(" ", ""))
		$NPCBust.show()
	
	
	if speaker1.to_lower() == "player":
		$PlayerSprite.play(Game.get_node("Game").string_to_battler("player").battler_name)
		$PlayerSprite.show()
	else:
		$PlayerSprite.play(speaker1.replace(" ", ""))

	# Initiate conversation
	#$VBoxContainer.show()
	#next_sequence_in_event()

func next_sequence_in_event():
	print("Running next sequence in event")
	update_debug_text()
	if (current_event_index < 0):
		current_event_index = 0
	elif (is_valid_index(event_data, current_event_index)):
		pass
		#print(event_data[current_event_index], " Has speaker: , ", event_data[current_event_index].has("speaker"))
	else:
		#print("Event size: ", event_data.size(), " | Current index: ", current_event_index)
		print("Event finished.")
		write_event_log()	
		reset()
		active = false
		$Status.show()
		$Stack.show()
		$Next.show()
		return
	
	# Convo
	if event_data[current_event_index].has("speaker"):
		print("reading text, current index is: ", current_event_index)
		read_text()

	# Option
	elif event_data[current_event_index].has("option"):
		show_buttons()

	# Method
	elif event_data[current_event_index].has("process_method"):
		var method = event_data[current_event_index]["process_method"]
		var args = event_data[current_event_index].get("args", [])
		
		# Check if the method exists
		if has_method(method):
			if args.size() > 0:
				callv(method, args)  # Call the method with arguments
			else:
				call(method)  # Call the method without arguments
		else:
			print("Error: Method", method, "not found.")
		increment_index()
		print("Process method incrementation")
		next_sequence_in_event()

	# Jump to
	elif event_data[current_event_index].has("jump_to"):
		jump_to(event_data[current_event_index]["jump_to"])

	# Show Reward Domino
	elif event_data[current_event_index].has("reward_domino"):
		$Container.show()
		var reward_domino_node = $Container/Node2D
		reward_domino_node.active = false
		if(event_data[current_event_index]["reward_domino"][0] == "domino"):
			var domino = Game.get_node("Game").get_domino_from_name(event_data[current_event_index]["reward_domino"][1])
			reward_domino_node.type = reward_domino_node.reward_type.DOMINO
			reward_domino_node.set_domino(domino)
		elif(event_data[current_event_index]["reward_domino"][0] == "equipment"):
			var equipment = Game.get_node("Game").get_equipment_from_name(event_data[current_event_index]["reward_domino"][1])
			reward_domino_node.type = reward_domino_node.reward_type.EQUIPMENT
			reward_domino_node.set_equipment(equipment)
		print("Reward domino incrementation")
		increment_index()
		next_sequence_in_event()
		
func read_text():
	if event_data[current_event_index]["speaker"].to_lower() == "player":
		event_data[current_event_index]["speaker"] = Game.get_node("Game").string_to_battler("player").battler_name

	$VBoxContainer.get_node("NameBox/RichTextLabel").bbcode_text = format_string(event_data[current_event_index]["speaker"])
	type_text(event_data[current_event_index]["text"])
	print("Read text incrementation")
	increment_index()

func type_text(text: String):
	if is_typing:  # If already typing, skip to the end
		$VBoxContainer.get_node("NinePatchRect/RichTextLabel").bbcode_text = text
		$VBoxContainer/NinePatchRect/WindowCursor.show()
		is_typing = false
		return
	
	is_typing = true
	$VBoxContainer/NinePatchRect/WindowCursor.hide()
	var displayed_text = ""
	var i = 0

	while i < text.length():
		if not is_typing:  # If interrupted by a user click
			$VBoxContainer.get_node("NinePatchRect/RichTextLabel").bbcode_text = text
			break
		if text.substr(i, 6) == "[font=":  # Check for [font] tag
			var end_index = text.find("[/font]", i) + 7  # Find the closing tag and include its length
			if end_index > 6:  # Ensure the tag exists
				var full_tag = text.substr(i, end_index - i)  # Extract the entire tag
				displayed_text += full_tag
				print("Tag: ", full_tag)
				$VBoxContainer.get_node("NinePatchRect/RichTextLabel").bbcode_text = displayed_text
				i = end_index  # Skip ahead to after the closing tag
				continue

		# Regular character handling
		displayed_text += text[i]
		$VBoxContainer.get_node("NinePatchRect/RichTextLabel").bbcode_text = displayed_text
		yield(get_tree().create_timer(0.02), "timeout")  # Adjust typing speed
		i += 1
	
	$VBoxContainer/NinePatchRect/WindowCursor.show()
	is_typing = false
	return

	
func _input(event):
	update_debug_text()

	if event is InputEventMouseButton and event.pressed and active == true:

		print("Can process input: ", can_process_input, " | Current event index: ", current_event_index, " VBOX visible: ", $VBoxContainer.visible)

		# Mouse was clicked anywhere on the screen
		if event.button_index == BUTTON_LEFT:  # Detect left mouse button
			if is_typing:  # If typing, interrupt
				is_typing = false
			else:  # Otherwise, progress to the next dialogue or action
				print("Input detected")
				next_sequence_in_event()
		elif event is InputEventScreenTouch and event.pressed and active == true:
			if is_typing:  # If typing, interrupt
				is_typing = false
			else:  # Otherwise, progress to the next dialogue or action
				print("Input detected")
				next_sequence_in_event()
		if  $VBoxContainer.visible == false and can_process_input == true:
			$VBoxContainer.show()

func show_buttons():
	var options = event_data[current_event_index]["option"]
	$HBoxContainer.show()	
	$Stack.show()
	$Status.show()
	for child in $HBoxContainer.get_children():
		child.hide()
	
	for i in range(options.size()):  # Assuming three buttons
		var button_path = "HBoxContainer/Button" + str(i + 1)
		var button = get_node(button_path)
		
		var option = options[i]
		button.text = option["name"]

		# Disconnect previous signals to avoid duplicates
		if button.is_connected("pressed", self, "_on_button_pressed"):
			button.disconnect("pressed", self, "_on_button_pressed")
		
		# Connect the button's pressed signal with metadata
		button.connect("pressed", self, "_on_button_pressed", [option])
		button.show()

		# Check requirements
		if option.has("requirement"):
			if not option["requirement"]:
				button.disabled = true
				button.modulate = Color(0.5, 0.5, 0.5, 1)
			else:
				button.disabled = false
				button.modulate = Color(1, 1, 1, 1)
	
# Signal handler for button press
func _on_button_pressed(option):

	# Call the specified method with arguments
	if option.has("method"):
		var method = option["method"]
		var args = option.get("args", [])
		
		# Check if the method exists
		if has_method(method):
			if args.size() > 0:
				callv(method, args)  # Call the method with arguments
			else:
				call(method)  # Call the method without arguments
		else:
			print("Error: Method", method, "not found.")

	# Proceed to the next sequence
	print("Button incrementation")
	increment_index()
	$HBoxContainer.hide()
	$Container.hide()
	$Status.hide()
	$Stack.hide()
	next_sequence_in_event()

func _on_Status_pressed():
	var status_screen = preload("res://Equipment/Status.tscn").instance() 
	status_screen.get_node("Node2D").initialise()
	Game.get_node("Game").add_child(status_screen)

func _on_Stack_pressed():
	var library = preload("res://Reward/Library.tscn").instance() 
	library.clear()
	library.populate_deck()
	Game.get_node("Game").add_child(library)

func _on_Next_pressed():
	destroy()
	Game.get_node("Game").player.reset_deck()
	Game.get_node("Game").next_event()

func continue(option: String = "deny_help"):
	if(option == "deny_help"):
		var outro = [
			{ "speaker": "Player", "text": "Sorry, can't help you." },
			{ "speaker": npc_name, "text": "Oh." },
			{ "speaker": npc_name, "text": "Well, I'll be on my way then." }			
		]
		event_data = insert_array(event_data, current_event_index + 1, outro)
	elif(option == "time_to_go"):
		var outro = [
			{ "speaker": "Player", "text": "Time to go!" }
		]
		current_event_index = event_data.size() - 2
		event_data = insert_array(event_data, event_data.size(), outro)
		

	elif(option == "no_thanks"):
		var outro = [
			{ "speaker": "Player", "text": "I'm good, thanks." },
			{ "speaker": npc_name, "text": "Okay. Farewell!" }
		]
		event_data = insert_array(event_data, current_event_index + 1, outro)
	elif(option == "pass"):
		pass

	next_sequence_in_event()

func jump_to(index: int, auto_advance: bool = true):
	set_index(index)
	if(auto_advance):
		next_sequence_in_event()

func reward(reward_array: Array = []):
	
	# Reward array goes like:
	# [type, item, amount]
	# type can be equipment or domino
	# item can be dominoContainer or equipment name
	
	if(reward_array.size() > 0):
		if(reward_array[0] == "equipment"):
			var equipment = Game.get_node("Game").get_equipment_from_name(reward_array[1])
			Game.get_node("Game").string_to_battler("player").add_to_inventory(equipment)
			add_event_log("equipment_gained", reward_array[1])
		elif(reward_array[0] == "domino"):
			var domino_to_add = Game.get_node("Game").get_domino_from_name(reward_array[1])
			Game.get_node("Game").string_to_battler("player").add_to_deck(domino_to_add, "player")
			add_event_log("domino_gained", reward_array[1])
		elif(reward_array[0] == "gems"):
			Game.get_node("Game").string_to_battler("player").add_gems(reward_array[1])
			add_event_log("gems_gained", reward_array[1])
	else:
		pass

func grant_reward(reward_array: Array = [], jump_to_index: int = -1):
	reward(reward_array)

	var jump_to_event = [
		{ "jump_to": jump_to_index }	
	]

	if jump_to_index is int:
		if(jump_to_index != -1):
			event_data = insert_array(event_data, current_event_index + 1, jump_to_event)
	return

# ==============================================================================
# Gamble functions
# ==============================================================================
func random_match(number_of_dominos: int = 1, random_value: int = 0, random_value2: int = 0, reward_array: Array = []):
	if(reward_array.size() == 0):
		# Default reward will be
		match number_of_dominos:
			1, -1:
				var equipment_reward = Game.get_node("Game").get_all_equipment(["uncommon", "rare"], [])
				var reward = equipment_reward[randi() % equipment_reward.size()].equipment_name
				reward_array = ["equipment", reward]
			2:
				var equipment_reward = Game.get_node("Game").get_all_equipment(["uncommon", "common"], [])
				var reward = equipment_reward[randi() % equipment_reward.size()].equipment_name
				reward_array = ["equipment", reward]
			_:
				var equipment_reward = Game.get_node("Game").get_all_equipment(["common"], [])
				var reward = equipment_reward[randi() % equipment_reward.size()].equipment_name
				reward_array = ["equipment", reward]
		
		var domino_array = Game.get_node("Game").player.shuffle_deck(Game.get_node("Game").player.get_deck())
		var number_array = []

		print("Number of dominos :" , number_of_dominos)

		if number_of_dominos > 0:

			for _i in range(number_of_dominos):
				number_array.append(domino_array[_i].get_numbers()[0])
				number_array.append(domino_array[_i].get_numbers()[1])

		else:
			
			for _i in range(-number_of_dominos):
				number_array.append(domino_array[-_i].get_numbers()[0])
				number_array.append(domino_array[-_i].get_numbers()[1])

		print("Number array: ", number_array)
		var domino_string = "My dominos: "
		for _j in range(number_array.size()):
			domino_string += BBCode.bb_code_dot(number_array[_j])
			if _j % 2 == 1:
				domino_string += " "

		if random_value in number_array or random_value2 in number_array:
			
			var gambler_event = [
				{ "speaker": npc_name, "text": domino_string },
				{ "speaker": "player", "text": "Nice! I got a match!"},
				{ "speaker": npc_name, "text": "Nice indeed! Here is your reward! Here is your " + get_equipment_bb_code(reward_array[1]) + "." },	
			]

			reward(reward_array)
			event_data = insert_array(event_data, current_event_index + 1, gambler_event)

		else:
			var damage = min(Game.get_node("Game").player.hp - 1, round(rand_range(4, 8)))
			var damage_string = ""
			
			if(damage > 0):
				Game.get_node("Game").player.self_damage(damage, false)
				
				add_event_log("hp_gained", -damage)
				damage_string = "What!? No! Please! (Took " + str(damage) + " damage)"
			else:
				damage_string = "Heh, can't get blood out if I've got nothing to give!"

			var gambler_event = [
				{ "speaker": npc_name, "text": domino_string },
				{ "speaker": npc_name, "text": "You did not get match! Haha! You lose! Stabby time!"},	
				{ "speaker": "player", "text": damage_string}
			]
			event_data = insert_array(event_data, current_event_index + 1, gambler_event)
			

# ==============================================================================
# Equipment functions
# ==============================================================================
func remove_set_unequipped_equipment(equipment, reward_type: String = "gems", reward_amount: int = 0):
	var gem_amount = reward_amount + round (0.2 * equipment.get_value())
	Game.get_node("Game").string_to_battler("player").remove_from_inventory(equipment)
	add_event_log("equipment_lost", equipment.get_name())
	
	if "uncommon" in equipment.criteria:
		gem_amount += rand_range(8,12)
	elif "rare" in equipment.criteria:
		gem_amount += rand_range(12,20)
	elif "legendary" in equipment.criteria:
		gem_amount += rand_range(20,35)

	if(reward_type == "gems"):
		gem_amount = round(gem_amount)

		var equipment_event = [
			{ "speaker": "Player", "text": "Here is a " + equipment.get_equipment_name_with_bb_code() + "." },
			{ "speaker": npc_name, "text": "Thank you!" },
			{ "speaker": npc_name, "text": "Take these gems as payment (" + str(gem_amount) + ") " }			
		]

		reward([reward_type, gem_amount])
		event_data = insert_array(event_data, current_event_index + 1, equipment_event)
		
	return

func remove_random_unequipped_equipment(reward_type: String = "gems", reward_amount: int = 0):
	var unequipped_equipment = Game.get_node("Game").string_to_battler("player").get_unquipped_items()

	if unequipped_equipment.size() > 0:
		var random_equipment = unequipped_equipment[randi() % unequipped_equipment.size()]
		Game.get_node("Game").string_to_battler("player").remove_from_inventory(random_equipment)
		add_event_log("equipment_lost", random_equipment.get_name())

		if(reward_type == "gems"):
			var gem_amount = reward_amount + round (0.5 * random_equipment.get_value())
			
			if "uncommon" in random_equipment.criteria:
				gem_amount += rand_range(10,15)
			elif "rare" in random_equipment.criteria:
				gem_amount += rand_range(20,30)
			elif "legendary" in random_equipment.criteria:
				gem_amount += rand_range(30,50)

			gem_amount = round(gem_amount)

			var equipment_event = [
				{ "speaker": "Player", "text": "Here is a " + random_equipment.get_equipment_name_with_bb_code() + "." },
				{ "speaker": npc_name, "text": "Thank you!" },
				{ "speaker": npc_name, "text": "Take these gems as payment (" + str(gem_amount) + ") "  }			
			]
			reward([reward_type, gem_amount])
			event_data = insert_array(event_data, current_event_index + 1, equipment_event)
		
		return
	else:
		var equipment_event = [
			{ "speaker": "Player", "text": "Hmm... I don't actually have anything spare to offer you" },
			{ "speaker": npc_name, "text": "Okay..." }	
		]
		event_data = insert_array(event_data, current_event_index + 1, equipment_event)
	
	
	reward([reward_type, reward_amount])
			
	return 

func gain_random_cursed_equipment(reward_array: Array = []):
	var cursed_equipment = Game.get_node("Game").get_all_equipment(["cursed"], [])
	
	reward(reward_array)

	if cursed_equipment.size() > 0:
		var random_equipment = cursed_equipment[randi() % cursed_equipment.size()]
		Game.get_node("Game").string_to_battler("player").add_to_inventory(random_equipment)
		Game.get_node("Game").string_to_battler("player").make_space_for_equipment(random_equipment)
		add_event_log("equipment_gained", random_equipment.get_name())

		var equipment_event = [
			{ "speaker": "Player", "text": "Oh, you shouldn't have... taken this... " + random_equipment.get_equipment_name_with_bb_code() + "..." },
			{ "speaker": "Player", "text": "But at least I got a " + reward_array[1] }
		]
		event_data = insert_array(event_data, current_event_index + 1, equipment_event)
		
		return
	else:
		var equipment_event = [
			{ "speaker": npc_name, "text": "Okay... That was not the right choice..." }	,
			{ "speaker": "Player", "text": "But at least I got a " + reward_array[1] }
		]
		event_data = insert_array(event_data, current_event_index + 1, equipment_event)
	
	
	reward(reward_array)

	return


# ==============================================================================
# Gem functions
# ==============================================================================

# This adds 3 indices to the event_data array
func donate_gems(gems_amount: int, reward_array: Array = [], jump_to_index: int = -1):

	# Reward array goes like:
	# [type, item, amount]
	# type can be equipment or domino
	# item can be dominoContainer or equipment name

	Game.get_node("Game").string_to_battler("player").add_gems(-gems_amount)
	
	add_event_log("gems_gained", -gems_amount)
	reward(reward_array)
	
	var gem_event = []

	if(reward_array.size() > 0):

		gem_event = [
			{ "speaker": "Player", "text": "There goes my " + str(gems_amount) + " gems." },
			{ "speaker": "Player", "text": "But at least I got a " + reward_array[1] }
		]
	else:
		gem_event = [
			{ "speaker": "Player", "text": "Hmm..." },
			{ "speaker": "Player", "text": str(gems_amount) + " gems eh?" },
		]

	var jump_to_event = [
		{ "jump_to": jump_to_index }	
	]

	event_data = insert_array(event_data, current_event_index + 1, gem_event)

	if jump_to_index is int:
		if(jump_to_index != -1):
			event_data = insert_array(event_data, current_event_index + gem_event.size() + 1, jump_to_event)

	return
# ==============================================================================
# HP functions
# ==============================================================================

# This adds 3 indices to the event_data array
func lose_health(hp_cost: int, reward_array: Array = [], jump_to_index = -1):

	Game.get_node("Game").string_to_battler("player").self_damage(hp_cost, false)
	add_event_log("hp_gained", -hp_cost)

	reward(reward_array)
	var hp_event = []
	
	if(reward_array.size() > 0):

		hp_event = [
			{ "speaker": "Player", "text": "Ouch! That hurt (took " + str(hp_cost) + " damage)." },
			{ "speaker": "Player", "text": "But at least I got a " + reward_array[1] }
		]
	else:
		hp_event = [
			{ "speaker": "Player", "text": "Ouch! That hurt." },
			{ "speaker": "Player", "text": "I lost " + str(hp_cost) + " HP." },
		]
	
	var jump_to_event = [
		{ "jump_to": jump_to_index }	
	]

	event_data = insert_array(event_data, current_event_index + 1, hp_event)

	if jump_to_index is int:
		if(jump_to_index != -1):
			event_data = insert_array(event_data, current_event_index + hp_event.size() + 1, jump_to_event)
	
	return


# This adds 3 indices to the event_data array
func lose_max_health(max_hp_cost: int, reward_array: Array = [], jump_to_index = -1):
	Game.get_node("Game").string_to_battler("player").max_hp -= max_hp_cost
	add_event_log("max_hp_gained", -max_hp_cost)
	
	reward(reward_array)
	var hp_event = []

	if(reward_array.size() > 0):
		hp_event = [
			{ "speaker": "Player", "text": "Ouch! I feel weaker... (lost " + str(max_hp_cost) + " max HP)." },
			{ "speaker": "Player", "text": "But at least I got a " + reward_array[1] }
		]
	else:
		hp_event = [
			{ "speaker": "Player", "text": "Ouch! That hurt." },
			{ "speaker": "Player", "text": "I lost " + str(max_hp_cost) + " max HP." },
		]
	
	var jump_to_event = [
		{ "jump_to": jump_to_index }	
	]

	event_data = insert_array(event_data, current_event_index + 1, hp_event)

	if jump_to_index is int:
		if(jump_to_index != -1):
			event_data = insert_array(event_data, current_event_index + hp_event.size() + 1, jump_to_event)

	return

# This method adds 1 index to the event_data array
func gain_health(hp_gain: int, gem_cost: int, jump_to_index: int = -1):
	Game.get_node("Game").string_to_battler("player").heal(hp_gain)
	Game.get_node("Game").string_to_battler("player").add_gems(-gem_cost)
	add_event_log("hp_gained", hp_gain)
	if(gem_cost > 0):
		add_event_log("gems_gained", -gem_cost)

	var jump_to_event = [
		{ "jump_to": jump_to_index }	
	]

	if jump_to_index is int:
		if(jump_to_index != -1):
			event_data = insert_array(event_data, current_event_index + 1, jump_to_event)

		
	return

# This method adds 1 index to the event_data array
func gain_max_hp(max_hp_gain: int, gem_cost: int, jump_to_index: int = -1):
	Game.get_node("Game").string_to_battler("player").max_hp += max_hp_gain
	Game.get_node("Game").string_to_battler("player").heal(max_hp_gain)
	Game.get_node("Game").string_to_battler("player").add_gems(-gem_cost)
	add_event_log("max_hp_gained", max_hp_gain)
	if(gem_cost > 0):
		add_event_log("gems_gained", -gem_cost)


	var jump_to_event = [
		{ "jump_to": jump_to_index }	
	]

	if jump_to_index is int:
		if(jump_to_index != -1):
			event_data = insert_array(event_data, current_event_index + 1, jump_to_event)

		
	return
# ==============================================================================
# Helper functions
# ==============================================================================

# Helper method
func get_option_index(option_name: String, options: Array) -> int:
	for i in range(options.size()):
		if options[i]["name"] == option_name:
			return i
	return -1  # Return -1 if not found

# Helper method
func insert_array(target: Array, index: int, to_insert: Array) -> Array:
	return Game.get_node("Game").insert_array(target, index, to_insert)

func is_valid_index(array: Array, index: int) -> bool:
	return index >= 0 and index < array.size()

# ==============================================================================
# Example events
# ==============================================================================

# Gain sacrifice dominos

func sacrifice_event():

	set_event_name("sacrifice")
	
	event_data = [
		{"speaker": "Player", "text": "Hmm... an alluring power remains trapped on this altar."},
		{"speaker": "Player", "text": "I wonder what would happen if I touched it..."},
		{"reward_domino": ["domino", "Sacrifice"]},
		{"option": [
			{"name": "Leave", "method": "continue", "args": ["time_to_go"]},
			{"name": "Touch the altar (gain a cursed item)", "method": "gain_random_cursed_equipment", "args": [["domino", "Sacrifice"]]}
		]},
		{"speaker": "Player", "text": "I should leave now."}
	]

	var gems_amount = round(randi() % 10 + 14) 
	if(Game.get_node("Game").string_to_battler("player").get_gems() > gems_amount) :
		event_data[3]["option"].append({"name": "Make an offering (donate " + str(gems_amount) + " gems)", "method": "donate_gems", "args": [gems_amount, ["domino", "Sacrifice"]]})

	var hp_cost = 4 + randi() % 6
	if(Game.get_node("Game").player.hp > hp_cost):
		event_data[3]["option"].append({"name": "Offer your health (lose " + str(hp_cost) + " HP)", "method": "lose_health", "args": [hp_cost,  ["domino", "Sacrifice"]]})

	var max_hp_cost = round(hp_cost * 0.5 - 1)
	if(Game.get_node("Game").player.max_hp > max_hp_cost):
		event_data[3]["option"].append({"name": "Offer your vitality (lose " + str(max_hp_cost) + " Max HP)", "method": "lose_max_health", "args": [max_hp_cost,  ["domino", "Sacrifice"]]})

# Gain gems for random equipment

func equipment_offering():

	set_event_name("equipment_offering")

	npc_name = "BoomarianCivilian1"

	event_data = [
		{ "speaker": "Player", "text": "Hello!" },
		{ "speaker": npc_name, "text": "Hey" },
		{ "speaker": npc_name, "text": "Do you have any spare equipment?" },
		{ "speaker": npc_name, "text": "I got mugged and lost all my current equipment and the nearest town is quite some distance away." },
		{ "option": [	
			{ "name": "Offer a random piece of equipment", "method": "remove_random_unequipped_equipment", "args": ["gems", rand_range(5, 10)] },
			{ "name": "Offer nothing", "method": "continue", "args": ["deny_help"] },
		]},
		{ "speaker": npc_name, "text": "Good luck!" },
		{ "speaker": "Player", "text": "Thank you!" }
	]

	var unequipped_equipment = Game.get_node("Game").string_to_battler("player").get_unquipped_items()
	if unequipped_equipment.size() > 0:
		event_data[4]["option"].append({"name": "Offer " + unequipped_equipment[0].equipment_name, "method": "remove_set_unequipped_equipment", "args": [unequipped_equipment[0], "gems", round( unequipped_equipment[0].get_value() * 0.6)]})

# Gain healing or max HP buff
func healer_event():

	set_event_name("healer")

	npc_name = ["BoomarianHealer", "BoomarianDisciple"][randi() % 2]
	var random_value = round(4 + randi() % 10)
	var random_value2 = round(24 + randi() % 10)
	var final_index = 12

	event_data = [
		{"speaker": "Player", "text": "Hello!"},
		{"speaker": npc_name, "text": "Hello fellow adventurer!"},
		{"speaker": npc_name, "text": "I'm a healer!"},
		{"speaker": npc_name, "text": "Would you like me to heal you or increase your max HP?"},
		{"option": [
			{"name": "Heal " + str(random_value * 3) + " HP (cost: " + str(random_value) + " gems)", "requirement": Game.get_node("Game").player.get_gems() >= random_value, "method": "gain_health", "args": [random_value * 3, random_value]},
			{"name": "Increase max HP by " + str(round(random_value * 0.35)) + " (cost: " + str(random_value) + " gems)", "requirement": Game.get_node("Game").player.get_gems() >= random_value, "method": "gain_max_hp", "args": [round(0.35 * random_value), random_value, 8]},
			{"name": "Buy bandages (cost: " + str(random_value2) + " gems)", "requirement": Game.get_node("Game").player.get_gems() >= random_value2, "method": "donate_gems", "args": [random_value2, ["equipment", "Bandage"], 12	]},
			{"name": "I'm good, thanks", "method": "jump_to", "args": [8, false]}
		]},
		{"speaker": "Player", "text": "Thanks for healing me (" + str(random_value * 3) + " HP healed)"},		
		{"jump_to": 9},	
		{"speaker": "Player", "text": "I feel stronger now (" +  str(round(random_value * 0.35)) + " max HP gained)"},		
		{"jump_to": 10},		
		{"speaker": npc_name, "text": "Stay safe out there!"},
	]


# Gain healing or max HP buff
func free_heal():

	set_event_name("free_heal")

	event_data = [
		{"speaker": "Player", "text": "What's that?"},
		{"speaker": "Player", "text": "This must be one of those healing springs I've heard about."},
		{"speaker": "Player", "text": "I should take advantage of this opportunity."},
		{"option": [
			{"name": "Heal 35% of max HP", "method": "gain_health", "args": [ceil(0.35 * Game.get_node("Game").string_to_battler("player").get_max_hp()), 0]},
			{"name": "Collect some healing water", "method": "grant_reward", "args": [["equipment", "Pure Water"], 6]},
			{"name": "Leave", "method": "jump_to", "args": [4, false]}
		]},
		{"speaker": "Player", "text": "I feel refreshed! (Healed " + str(ceil(0.35 *  Game.get_node("Game").string_to_battler("player").get_max_hp())) +  "HP / Current HP: " + str(Game.get_node("Game").string_to_battler("player").hp) + "/" + str(Game.get_node("Game").string_to_battler("player").get_max_hp()) + ")"},		
		{"jump_to": 7},	
		{"speaker": "Player", "text": "This bottle of regenerative water may come in handy later."},	
		{"speaker": "Player", "text": "I should get going."}
		]


# Upgrade dominos
func free_upgrade():
	set_event_name("free_upgrade")

	npc_name = "BoomarianCivilian1"

	event_data = [
		{ "speaker": "Player", "text": "Hey." },
		{ "speaker": npc_name, "text": "Hey!" },
		{ "speaker": npc_name, "text": "Fancy some upgrades to your kit?" },
		{ "option": [
			{ "name": "No thanks", "method": "continue", "args": ["no_thanks"] },
			{"name": "Upgrade 2 random dominos", "method": "upgrade_domino", "args": [["random", 2], 6]},
			{"name": "Upgrade 1 domino", "method": "upgrade_domino", "args": [["domino", 1], 6]}
		]}
	]

# Creates a selection popup and upgrades the selected domino
func upgrade_domino(arguments: Array = ["domino", 1], jump_to_index: int = -1):
	match arguments[0]:
		"domino":
			var upgradable_dominos = []
			for domino in Game.get_node("Game").player.get_deck():
				if domino.can_upgrade():
					upgradable_dominos.append(domino)
			
			if upgradable_dominos.size() >= arguments[1]:
				Game.get_node("Game").domino_selection(arguments[1], arguments[1], null, "player", "UPGRADABLE_STACK", -1, "UPGRADABLE_STACK", {"upgrade_domino": [1]})
			else:
				Game.get_node("Game").domino_selection(0, arguments[1], null, "player", "UPGRADABLE_STACK", -1, "UPGRADABLE_STACK", {"upgrade_domino": [1]})
		"random":
			var upgradable_dominos = []
			var upgraded_dominos = []
			for domino in Game.get_node("Game").player.get_deck():
				if domino.can_upgrade():
					upgradable_dominos.append(domino)
			upgradable_dominos.shuffle()
			for i in range(arguments[1]):
				if upgradable_dominos.size() > 0:
					upgradable_dominos[i].upgrade_domino(1)
					upgraded_dominos.append(upgradable_dominos[i].get_domino_name())
					add_event_log("domino_upgraded", upgradable_dominos[i].get_domino_name())

			var upgrade_text = ""
			for _i in range(upgraded_dominos.size()):
				if _i == upgraded_dominos.size() - 1:
					upgrade_text += upgraded_dominos[_i]
				else:
					upgrade_text += upgraded_dominos[_i] + ", "

			var upgrade_event = [
				{ "speaker": "Player", "text": "Wow! " + upgrade_text + " just got upgraded!" }
			]
			
			var jump_to_event = [
				{ "jump_to": jump_to_index }	
			]

			event_data = insert_array(event_data, current_event_index + 1, upgrade_event)

			if jump_to_index is int:
				if(jump_to_index != -1):
					event_data = insert_array(event_data, current_event_index + upgrade_event.size() + 1, jump_to_event)

			return
			
# Sacrifice health for a piece of equipment
func thorny_treasure():

	set_event_name("thorny_treasure")

	var hp_cost = min(round(Game.get_node("Game").string_to_battler("player").get_max_hp() * 0.1), 4 + randi() % 6)
	var hp_cost2 = round(Game.get_node("Game").string_to_battler("player").get_max_hp() * 0.25)
	var hp_cost3 = round(Game.get_node("Game").string_to_battler("player").get_max_hp() * 0.4)
	var uncommon_equipment_reward = Game.get_node("Game").get_all_equipment(["uncommon", "rare"])[randi() % Game.get_node("Game").get_all_equipment(["uncommon", "rare"]).size()]
	var common_equipment_reward = Game.get_node("Game").get_all_equipment(["common"])[randi() % Game.get_node("Game").get_all_equipment(["common"]).size()]
	var random_equipment_reward = Game.get_node("Game").get_all_equipment(["common", "uncommon", "rare"])[randi() % Game.get_node("Game").get_all_equipment(["common", "uncommon", "rare"]).size()]	
		
	event_data = [
		{ "speaker": "Player", "text": "Hmm... there are a lot of trinkets hidden amongst the thorns." },
		{ "speaker": "Player", "text": "And a treasure chest of some sorts... I wonder what's inside..." },
		{ "speaker": "Player", "text": "It will be a painful reach to grab it though..." },
		{ "option": [
			{ "name": "Leave", "method": "jump_to", "args": [4]},
			{"name": "Investigate (lose " + str(hp_cost) + " HP)", "requirement": Game.get_node("Game").string_to_battler("player").hp > hp_cost, "method": "lose_health", "args": [4, []]},
			{"name": "Grab trinket (lose " + str(hp_cost2) + " HP)", "requirement": Game.get_node("Game").string_to_battler("player").hp > hp_cost2, "method": "lose_health", "args": [hp_cost2,  ["equipment", common_equipment_reward.equipment_name], 9]},
			{"name": "Grab treasure (lose " + str(hp_cost3) + " HP)", "requirement": Game.get_node("Game").string_to_battler("player").hp > hp_cost3, "method": "lose_health", "args": [hp_cost3,  ["equipment", uncommon_equipment_reward.equipment_name], 9]} 
		]},
		{ "option": [
			{"name": "Leave", "method": "jump_to", "args": [7]},
			{"name": "Grab " + random_equipment_reward.equipment_name + " (lose " + str(hp_cost2) + " HP)", "requirement": Game.get_node("Game").string_to_battler("player").hp > hp_cost2 + hp_cost, "method": "lose_health", "args": [hp_cost2,  ["equipment", random_equipment_reward.equipment_name], 11]}
		]},
		{ "speaker": "Player", "text": "This place is a trap." },
		{ "speaker": "Player", "text": "I should leave now." }
	]

# Conversation
func conversation(type: String = "default"):
	match type:
		"default":
			event_data = [
				{ "speaker": "Player", "text": "Hello!" },
				{ "speaker": "BoomarianCivilian3", "text": "Hey" },
				{ "speaker": "BoomarianCivilian3", "text": "How are you?" },
				{ "speaker": "Player", "text": "I'm good, thanks." },
				{ "option": [
					{ "name": "Goodbye", "method": "continue", "args": ["time_to_go"] },
					{ "name": "No thanks", "method": "continue", "args": ["no_thanks"] },
					{ "name": "Try again", "method": "jump_to", "args": [-1, false] }
				]},
				{ "speaker": "BoomarianCivilian3", "text": "Okay. Farewell!" }
			]

#  Gamble
func gamble_matching_domino():

	set_event_name("gamble_matching_domino")

	var random_values = [1, 2, 3, 4, 5, 6]
	random_values.shuffle()
	var random_value = random_values[0]
	var random_value2 = random_values[1]
	event_data = [
		{ "speaker": "Player", "text": "Hello!" },
		{"speaker": "BoomarianCivilian4", "text": "Greetings!"},
		{"speaker": "BoomarianCivilian4", "text": "I have a proposition for you."},
		{"speaker": "BoomarianCivilian4", "text": "I have a " + BBCode.bb_code_dot(random_value) + BBCode.bb_code_dot(random_value2) + " domino in my hand."},
		{"speaker": "BoomarianCivilian4", "text": "If you can match it with one of your own, you win a prize."},
		{"option": [
			{"name": "Draw 1 domino", "method": "random_match", "args": [1, random_value, random_value2]},
			{"name": "Draw 2 dominos", "method": "random_match", "args": [2, random_value, random_value2]},
			{"name": "Draw 3 dominos", "method": "random_match", "args": [3, random_value, random_value2]},
			{"name": "Draw 1 domino from the bottom", "method": "random_match", "args": [-1]},
			{"name": "Pass", "jump_to": [7]}
		]},
		{ "speaker": "Player", "text": "Well, see ya!" }
	]


# ==============================================================================
# Debug functions
# ==============================================================================

func update_debug_text():
	var msg = ""
	for i in range(event_data.size()):
		msg += str(i) + ": " + str(event_data[i]) + "\n"
	$TextContainer/DebugText.text = msg + "Current index: " + str(current_event_index) + "\n" + "Current event_data size: " + str(event_data.size())

func increment_index():
	print("Incrementing index ", current_event_index)
	if(current_event_index < event_data.size() - 1):
		pass
		#print("Current event: ", event_data[current_event_index], " | Current index: ", current_event_index, " | next event", event_data[current_event_index + 1])
	else:
		pass
		#print("Current event: ", event_data[current_event_index], " | Current index: ", current_event_index)
	current_event_index += 1

func get_equipment_bb_code(equipment_name: String) -> String:
	var equipment = Game.get_node("Game").get_equipment_from_name(equipment_name)
	return equipment.get_equipment_name_with_bb_code()

func set_index(index: int):
	current_event_index = index

func add_spaces_to_caps(input: String) -> String:
	var regex = RegEx.new()
	regex.compile("(?<=[a-zA-Z])(?=[A-Z])")
	return regex.sub(input, " ", true)

func remove_digits(input: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\d")  # Matches any digit (0–9)
	return regex.sub(input, "", true)

func format_string(input: String) -> String:
	var without_digits = remove_digits(input)
	return add_spaces_to_caps(without_digits)

func _on_Timer_timeout():
	can_process_input = true
