extends Node

# Declare instance variables here
var battler_name: String
var battler_type: String
var hp: int
var max_hp: int
var shield: int
var max_shield: int
var initial_draw: int
var draw_per_turn: int
var max_hand_size: int
var auto_discard: bool
var action_points: int
var action_points_per_turn: int
var gems: int
var criteria: Array
var deck: Array
var equipped_items: Array
var max_equips: int
var inventory: Array
#var hp_gauge
#var effect_text
#var shield_text
var draw_pile: Array
var discard_pile: Array
var void_space: Array
var immunity: Array
signal pre_effect_complete

var dominos_played: Array
var dominos_played_this_turn: Array

var effects: Array
onready var health_bar = $Container/HealthBar
onready var effects_window = $ScrollContainer/Effects
var game = Game.get_node("Game")

func _init(
	battler_name_arg: String = "Battler", 
	battler_type_arg: String = "Battler", 
	criteria_arg: Array = [], 
	gems_arg: int = 10, 
	max_equips_arg: int = 3, 
	max_hand_size_arg: int = 9, 
	auto_discard_arg: bool = false, 
	action_points_per_turn_arg: int = 3, 
	hp_arg: int = 50, 
	max_hp_arg: int = 50, 
	shield_arg: int = 0, 
	max_shield_arg: int = 999, 
	initial_draw_arg: int = 5, 
	draw_per_turn_arg: int = 2, 
	deck_arg: Array = [], 
	equipped_items_arg: Array = [], 
	inventory_arg: Array = [], 
	immunity_arg: Array = []
):		
	battler_name = battler_name_arg
	battler_type = battler_type_arg
	max_hand_size = max_hand_size_arg
	auto_discard = auto_discard_arg
	action_points = action_points_per_turn_arg
	action_points_per_turn = action_points_per_turn_arg
	max_equips = max_equips_arg
	gems = gems_arg
	criteria = criteria_arg
	hp = hp_arg
	max_hp = max_hp_arg	
	shield = shield_arg	
	max_shield = max_shield_arg
	initial_draw = initial_draw_arg
	draw_per_turn = draw_per_turn_arg
	deck = deck_arg
	dominos_played = []
	dominos_played_this_turn = []
	effects = []
	void_space = []
	discard_pile = []
	equipped_items = equipped_items_arg
	inventory = inventory_arg
	immunity = immunity_arg

	set_hp(get_max_hp())

func set_parameters(parameters: Dictionary = {}):
	for method in parameters.keys():
		if has_method(method):  # Ensure the method exists to avoid runtime errors
			call(method, parameters[method])
	
	# Reposition enemy AP circle
	if(self.battler_type.to_upper() == "ENEMY"):
		$TextureRect.rect_position = Vector2(104, 40)
		self.action_points = self.action_points_per_turn
		update_action_points()

func set_battler_name(name: String):
	self.battler_name = name

func set_battler_type(type: String):
	self.battler_type = type

func set_max_hand_size(size: int):
	self.max_hand_size = size

func set_auto_discard(discard: bool):
	self.auto_discard = discard

func set_action_points_per_turn(points: int):
	self.action_points_per_turn = points

func update_action_points(animation: bool = false):
	if(has_node("TextureRect/Label")):
		get_node("TextureRect/Label").text = str(self.action_points)
		if(animation):
			pass

func set_max_hp(value: int):
	self.max_hp = value
	self.hp = value
	update()

func set_max_shield(value: int):
	self.max_shield = value
	
func set_fortified_shields(value: int):
	self.max_shield = value
	self.shield = value
	
func set_initial_draw(value: int):
	self.initial_draw = value

func set_draw_per_turn(value: int):
	self.draw_per_turn = value

func set_gems(value: int):
	self.gems = value

func set_max_equips(value: int):
	self.max_equips = value

func set_criteria(new_criteria: Array):
	self.criteria = new_criteria

func add_criteria(new_criteria: String):
	self.criteria.append(new_criteria)

func get_criteria():
	return self.criteria

func set_deck(new_deck: Array):
	self.deck = new_deck

func get_gems():
	return self.gems

func add_gems(gem_value: int):
	self.gems += gem_value
	if(self.gems < 0):
		self.gems = 0

func set_equipped_items(new_items: Array):
	self.equipped_items = new_items

func get_equipped_items():
	return self.equipped_items

func get_inventory():
	return self.inventory

func get_unquipped_items():
	var unquipped_items = []
	for item in self.inventory:
		if not self.equipped_items.has(item):
			unquipped_items.append(item)
	return unquipped_items

func equip_item(item):
	if("weapon" in item.get_criteria()):
		#print("Equipping weapon: ", item.equipment_name)
		unequip_weapon()
	if("unwieldy") in item.get_criteria():
		print(item.equipment_name, " will unequip all current equips due to unwieldy nature")
		unequip_all()
	if unwieldy():
		print(item.equipment_name, " cannot be equipped due to another piece of equipment being unwieldy.")
		return
	if(self.inventory.has(item) && self.equipped_items.size() < self.max_equips && item.meets_requirements(self)):
		#print("Equipped!")
		self.equipped_items.append(item)
		self.inventory.erase(item)
	else:
		print("Cannot equip ", item.equipment_name, " | has item: ", self.inventory.has(item), " | equipped items: ", self.equipped_items.size(), " | max equips: ", self.max_equips, " | meets requirements: ", item.meets_requirements(self))

func make_space_for_equipment(item):
	if(self.equipped_items.size() >= self.max_equips):
		if(self.max_equips == 1 && self.equipped_items.size() == 1):
			# User only has 1 equippable item and it is equipped
			unequip_item(self.equipped_items[0])
			equip_item(item)
		if(self.max_equips > 1):
			for item in self.equipped_items:
				if("weapon" in item.get_criteria() == false):
					unequip_item(item)
					equip_item(item)
					return
	else:
		equip_item(item)

func unwieldy():
	for items in self.equipped_items:
		if("unwieldy" in items.get_criteria()):
			return true
	return false

func unequip_weapon():
	for item in self.equipped_items:
		if("weapon" in item.get_criteria()):
			self.inventory.append(item)
			self.equipped_items.erase(item)

func unequip_all():
	for item in self.equipped_items:
		unequip_item(item)

func unequip_item(item):
	if(self.equipped_items.has(item)):
		if(item.is_cursed()):
			print(item.equipment_name, " is cursed and cannot be unequipped.")
		else:
			self.inventory.append(item)
			self.equipped_items.erase(item)

func add_to_inventory(item):
	if(self.inventory.size() < 999):
		self.inventory.append(item)
		item.set_owner(self)

func remove_from_inventory(item):
	if(self.inventory.has(item)):
		item.set_owner(null)
		self.inventory.erase(item)

func set_inventory(new_inventory: Array):
	self.inventory = new_inventory

func is_equipped(item):
	return self.equipped_items.has(item)

func get_immunity(state_name: String):
	var current_immunity = self.immunity
	for item in self.equipped_items:
		current_immunity.append_array(item.new_immunity())
	return state_name in current_immunity

func get_name():
	return self.battler_name

func get_type():
	return self.battler_type

func is_player():
	return self.battler_type.to_lower() == "player"

func get_max_hp():
	var final_max_hp = self.max_hp
	for item in self.equipped_items:
		if "max_hp" in item.alter_stats():
			final_max_hp += item.alter_stats()["max_hp"]
	return int(max(1, final_max_hp))

func get_max_shield():
	var final_max_shield = 0
	var user_data = {"user": self, "max_shield": self.max_shield}
	
	for item in self.equipped_items:
		if "max_shield" in item.alter_stats():
			final_max_shield += item.alter_stats()["max_shield"]
	for effect in self.effects:
		if effect.event_type == "max_shield":
			effect.on_event("max_shield", user_data)
	return int(max(0, final_max_shield + int(user_data["max_shield"])))

func get_max_hand_size():
	var final_max_hand_size = self.max_hand_size
	for item in self.equipped_items:
		if "max_hand_size" in item.alter_stats():
			final_max_hand_size += item.alter_stats()["max_hand_size"]
	return int(max(1, final_max_hand_size))

func get_draw_per_turn():
	var final_draw_per_turn = self.draw_per_turn
	for item in self.equipped_items:
		if "draw_per_turn" in item.alter_stats():
			final_draw_per_turn += item.alter_stats()["draw_per_turn"]
	return int(max(0, final_draw_per_turn))

func get_action_points_per_turn():
	var final_action_points_per_turn = self.action_points_per_turn
	for item in self.equipped_items:
		if "action_points_per_turn" in item.alter_stats():
			final_action_points_per_turn += item.alter_stats()["action_points_per_turn"]
	return int(max(0, final_action_points_per_turn))

func get_hand():
	if(self.battler_type.to_upper() == "PLAYER"):
		return game.player_hand
	elif(self.battler_type.to_upper() == "ENEMY"):
		return game.enemy_hand

func remove_domino(collection, domino: DominoContainer):
	# Locate the matching domino in the collection
	for user_dominos in collection.get_children():
		if user_dominos.check_shadow_match(domino):
			# Disable interactions for the domino being removed
			user_dominos.set_block_signals(true)

			# Add a tween to animate the removal
			var tween = game.tween
			
			# Set up the fade-out animation
			tween.interpolate_property(user_dominos, "modulate:a", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			
			# Set up the fall animation (with gravity effect)
			var start_position = user_dominos.rect_global_position
			var end_position = start_position + Vector2(0, 400)  # Fall distance
			tween.interpolate_property(user_dominos, "rect_global_position", start_position, end_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)

			# Start the tween for the removal animation
			tween.start()

			yield(get_tree().create_timer(0.5), "timeout")  # Wait for the animation to finish

			remove_domino_after_tween(user_dominos, collection)
			return  # Exit after animating the matched domino

# Callback function to finalize removal and rearrange remaining dominos
func remove_domino_after_tween(user_domino, collection):

	#var start_position = user_domino.get_global_position()
	
	# Remove the domino from its collection
	collection.remove_child(user_domino)
	# Animate the remaining dominos to slide into their new positions
	var tween = game.tween
	for i in range(collection.get_child_count()):
		var remaining_domino = collection.get_child(i)
		var target_position = remaining_domino.final_domino_position(i, collection)
		
		# Interpolate the domino to the new position
		tween.interpolate_property(remaining_domino, "rect_position", remaining_domino.rect_position, target_position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	# Start the sliding animation for remaining dominos
	tween.start()
	
	# Wait for the animation to finish
	yield(get_tree().create_timer(1), "timeout")

	# Update highlights or other properties after movement
	game.update_domino_highlights()

func get_draw_pile():
	return self.draw_pile

func get_discard_pile():
	return self.discard_pile

func get_void_space():
	return self.void_space

func remove_from(selected_domino: DominoContainer, type: String):
	#print("[Battle.gd - remove_from] Removing ", selected_domino.domino_name, " from ", type)
	if(type.to_upper() == "DRAW" || type.to_upper() == "PILE"):
		for domino in self.get_draw_pile():
			if(domino.check_shadow_match(selected_domino)):
				self.draw_pile.erase(domino)
				return
	elif(type.to_upper() == "DISCARD"):
		print(self.get_discard_pile())
		for domino in self.get_discard_pile():
			if(domino.check_shadow_match(selected_domino)):
				self.discard_pile.erase(domino)
				return
	elif(type.to_upper() == "VOID"):
		for domino in self.get_void_space():
			if(domino.check_shadow_match(selected_domino)):
				self.void_space.erase(domino)
				return
	elif(type.to_upper() == "PLAY"):
		game.erase_from_board(selected_domino)
	elif type.to_upper() == "HAND":
		game.erase_from_hand(game.get_hand(self.battler_type), selected_domino)
	game.update_domino_highlights()

func add_to_discard_pile(domino: DominoContainer, type: String = "draw"):
	if(domino == null):
		return

	self.discard_pile.append(domino)
	
	# Add domino to discard pile effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_discard_pile"):
			effect.on_event("add_to_discard_pile", effect_data)

	# Remove petrification
	domino.set_petrification(0)

	remove_from(domino, type)

	print("Added ", domino.domino_name, " to discard pile")
	
func add_to_void_space(domino: DominoContainer, type: String = "draw"):
	self.void_space.append(domino)

	# Add domino to void space effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_void_pile"):
			effect.on_event("add_to_void_pile", effect_data)
			
	remove_from(domino, type)

func add_to_draw_pile(domino: DominoContainer, type: String = "draw", append_method: String = "append"):
	domino.set_user(self.battler_type)
	if(append_method == "append"):
		self.draw_pile.append(domino)	
	elif(append_method == "top_stack"):
		self.draw_pile.insert(0, domino)
	else:
		self.draw_pile.append(domino)

	# Add domino to draw pile effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_draw_pile"):
			effect.on_event("add_to_draw_pile", effect_data)

	if(type != ""):
		remove_from(domino, type)

func add_to_hand(domino: DominoContainer, type = "pile", remove_from_collection: bool = true):
	var collection = game.get_hand(self.battler_type)
	
	# Add domino to hand (non-draw effect)
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_hand"):
			effect.on_event("add_to_hand", effect_data)

	if not collection:
		print("Error: Collection node not found.")
		return
		
	if domino.is_inside_tree() and remove_from_collection:
		var current_parent = domino.get_parent()
		print(domino.domino_name, domino.get_numbers(), " has been removed from current parent: ", current_parent.name)
		current_parent.remove_child(domino)
		
	collection.add_child(domino)
	var connect_the_domino = domino.connect("domino_pressed", game, "_on_domino_pressed") # Connect the signal
	if connect_the_domino != OK:
		print("Error: Could not connect signal.")

	game.animate_domino(domino, collection)
	
	if(type != ""):
		remove_from(domino, type)

	process_excess_draw()

# Discards drawn dominos or prompts user to discard X dominos if hand size > max_hand_size
func process_excess_draw():
	var hand = self.get_hand()
	var excess = hand.get_child_count() - self.get_max_hand_size()

	if(excess > 0):
		if(self.auto_discard ||  self.battler_type.to_upper() == "ENEMY"):
			for i in range(excess):
				var domino = hand.get_child(hand.get_child_count() - i - 1)
				self.add_to_discard_pile(domino, "hand")
		else:
			game.domino_selection(excess, excess, null, self.battler_type, "hand", -1, "discard")
			# Wait until the discard is complete before continuing
			yield(self, "pre_effect_complete")

# Adds a domino to the deck (and shuffles the deck), generally called at the start of the battle
func add_dominos_to_deck(domino_name: String, amount: int, type: String = "Attack", upgrade_level: int = 1, shuffle: bool = true, top_stack: bool = false):
	for _i in range(amount):
		var new_domino_path = "res://Domino/" + type + "/" + domino_name + ".tscn"
		var new_domino = load(new_domino_path).instance()
		new_domino.set_upgrade_level(upgrade_level)
		new_domino.set_temporary(true)
		if(top_stack):
			self.add_to_draw_pile(new_domino, "top_stack")
		else:
			self.add_to_draw_pile(new_domino, "")
		new_domino.connect("domino_pressed", game, "_on_domino_pressed")
	if(shuffle && !top_stack):
		self.draw_pile = shuffle_deck(self.get_draw_pile())

# Adds a domino to the deck (and shuffles the deck), generally called at the start of the battle
func add_dominos_to_hand(domino_name: String, amount: int, type: String = "Attack"):
	for _i in range(amount):
		var new_domino_path = "res://Domino/" + type + "/" + domino_name + ".tscn"
		var new_domino = load(new_domino_path).instance()
		new_domino.set_temporary(true)
		new_domino.set_user(self.battler_type)
		self.add_to_hand(new_domino, "", false)
		new_domino.connect("domino_pressed", game, "_on_domino_pressed")
	
func add_to_deck(domino: DominoContainer, type: String):
	domino.set_user(type)
	
	# Add domino to deck (permanently) effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_deck"):
			effect.on_event("add_to_deck", effect_data)

	#var deck_size = self.deck.size()
	self.deck.append(domino)
	#print("Deck size is now: ", self.deck.size(), " | Previously it was: ", deck_size)

func shuffle_deck(collection_array: Array):
	var top_stack = []
	var normal_stack = []
	var bottom_stack = []

	# Iterate through all dominos in the draw_pile
	for domino in collection_array:
		if "top_stack" in domino.get_criteria():
			top_stack.append(domino)
		elif "bottom_stack" in domino.get_criteria():
			bottom_stack.append(domino)
		else:
			normal_stack.append(domino)
	
	# Shuffle each deck
	top_stack.shuffle()
	normal_stack.shuffle()
	bottom_stack.shuffle()

	# Combine the shuffled decks: top_stack first, then normal_stack, then bottom_stack
	return top_stack + normal_stack + bottom_stack

# This method is run when the battler is created
func initialize_deck():
	self.draw_pile = self.deck.duplicate()
	self.draw_pile = shuffle_deck(draw_pile)

# This method is run when the battler is reset
func reset_deck():
	cleanup_temporary_dominos()
	#print("Resetting deck. Current deck size: ", self.deck.size(), " and current draw pile size: ", self.draw_pile.size())
	self.draw_pile = self.deck.duplicate()
	#print("Reset complete. Current draw pile size: ", self.draw_pile.size())
	self.draw_pile = shuffle_deck(self.draw_pile)

# This method removes temporary dominos from the deck, discard pile, void space, and draw pile
# It also sets all dominos back to "clickable"
func cleanup_temporary_dominos():
	for domino in self.get_hand().get_children():
		if domino.is_temporary():  # Check if the domino was marked as temporary
			self.get_hand().remove_child(domino)
			domino.queue_free()
		else:
			domino.set_clickable(true)
			domino.reset_domino_state()
			domino.set_current_user(domino.get_user())
	for domino in self.get_discard_pile():
		if domino.is_temporary():  # Check if the domino was marked as temporary
			self.get_discard_pile().remove(domino)
			domino.queue_free()
		else:
			domino.set_clickable(true)
			domino.reset_domino_state()
			domino.set_current_user(domino.get_user())
	for domino in self.get_void_space():
		if domino.is_temporary():  # Check if the domino was marked as temporary
			self.get_void_space().remove(domino)
			domino.queue_free()
		else:
			domino.set_clickable(true)
			domino.reset_domino_state()
			domino.set_current_user(domino.get_user())
	for domino in self.get_draw_pile():
		if domino.is_temporary():  # Check if the domino was marked as temporary
			self.get_draw_pile().remove(domino)
			domino.queue_free()
		else:
			domino.set_clickable(true)
			domino.reset_domino_state()
			domino.set_current_user(domino.get_user())

func get_initial_draw() -> int:
	return self.initial_draw
	
func get_deck():
	print("get_deck() called | deck size: ", self.deck.size())
	return self.deck

func spend_action_points(amount: int):
	self.action_points = int(max(0, self.action_points - amount))
	update_action_points()
	
func refresh_action_points():
	self.action_points = self.get_action_points_per_turn()
	update_action_points(true)

func refresh_shields():
	self.shield = int(min(self.shield, self.get_max_shield()))
	self.update()

#==========================================
# Effects
#==========================================
# Apply a buff or increase its duration if it already exists
func apply_effect(effect_instance):
	effect_instance.set_attached_user(self)
	print("Applying effect: ", effect_instance.effect_name)
	
	# Check immunity status
	if self.get_immunity(effect_instance.effect_name):
		print("Immune to ", effect_instance.effect_name)
		Game.get_node("Game").show_popup("Immune: " + effect_instance.bb_code, self, "White", "PopupRiseAnimation")
		return

	# If effect already exists, add it to the user
	for effect in effects:
		if effect.effect_name == effect_instance.effect_name:
			if(effect.get_duration() != -1 && effect_instance.get_duration() > 0):
				print("Extending duration for ", effect_instance.effect_name, " by ", effect_instance.duration)
				effect.extend_duration(effect_instance.duration)
				update()
				return
			if(effect.get_triggers() != -1 && effect_instance.get_triggers() > 0):
				print("Extending triggers for ", effect_instance.effect_name, " by ", effect_instance.triggers)
				effect.extend_triggers(effect_instance.triggers)
				update()
				return
			update()
			return
		if effect_instance.effect_name in effect.get_opposite_effects():
			var effect_duration = effect.get_duration()
			var effect_triggers = effect.get_triggers()
			# Scenario: Current effect has pernament duration -1
			if effect_duration == -1:
				print("Existing effect ", effect.effect_name, " has pernament duration")
				return
			elif effect_triggers == -1:
				print("Existing effect ", effect.effect_name, " has pernament triggers")
				return
			# Scenario: If new effect has pernament duration, then remove the current effect
			elif effect_instance.get_duration() == -1:
				print("New effect ", effect_instance.effect_name, " has pernament duration")
				effects.erase(effect)
				effects.append(effect_instance)
				update()
				return
			elif effect_instance.get_duration() == -1:
				print("New effect ", effect.effect_name, " has pernament duration")
				effects.erase(effect)
				effects.append(effect_instance)
				update()
				return 
			# Scenario: If new effect has less duration/trigger than current opposite effect
			elif effect_instance.get_duration() > 0 && effect.get_duration() > 0 && effect_instance.get_duration() < effect.get_duration():
				print("New effect ", effect_instance.effect_name, " has less duration than existing effect ", effect.effect_name)
				effect.extend_duration(-effect_instance.get_duration())
				update()
				return 
			elif effect_instance.get_triggers() > 0 && effect.get_triggers() > 0 && effect_instance.get_triggers() < effect.get_triggers():
				print("New effect ", effect_instance.effect_name, " has less triggers than existing effect ", effect.effect_name)
				effect.extend_triggers(-effect_instance.get_triggers())
				update()
				return 
			
			# Scenario: If new effect has more duration/trigger than current opposite effect
			elif effect_instance.get_duration() > 0 && effect.get_duration() > 0 && effect_instance.get_duration() > effect.get_duration():
				print("New effect ", effect_instance.effect_name, " has more duration than existing effect ", effect.effect_name)
				effect_instance.duration -= effect.get_duration()
				effects.append(effect_instance)
				effects.erase(effect)
				update()
				return 
			elif effect_instance.get_triggers() > 0 && effect.get_triggers() > 0 && effect_instance.get_triggers() > effect.get_triggers():
				print("New effect ", effect_instance.effect_name, " has more triggers than existing effect ", effect.effect_name, " of ", effect.get_triggers())
				effect_instance.triggers -= effect.get_triggers()
				effects.append(effect_instance)
				effects.erase(effect)
				update()
				return 
			
			# Scenario: If new effect has equal duration/trigger than current opposite effect
			elif effect_instance.get_duration() > 0 && effect.get_duration() > 0 && effect_instance.get_duration() == effect.get_duration():
				print("New effect ", effect_instance.effect_name, " has equal duration to existing effect ", effect.effect_name)
				effects.erase(effect)
				update()
				return 
			elif effect_instance.get_triggers() > 0 && effect.get_triggers() > 0 && effect_instance.get_triggers() == effect.get_triggers():
				print("New effect ", effect_instance.effect_name, " has equal triggers to existing effect ", effect.effect_name)
				effects.erase(effect)
				update()
				return 

	# Otherwise, add the effect to the user
	print("Applying new effect: ", effect_instance.effect_name + " with triggers of: " + str(effect_instance.triggers) + " and duration of: " + str(effect_instance.duration))
	effects.append(effect_instance)
	update()
	return

# A one line call to afflict a status condition on a unit
func afflict_status(effect_name: String, triggers: int = 0, duration: int = 0):
	
	# Load the effect script dynamically
	var effect_path = "res://Effect/" + effect_name + ".gd"
	var effect = load(effect_path).new()
	var value = 0

	# Configure the effect
	if(triggers != 0):
		effect.triggers = triggers
		value = triggers
	elif(duration != 0):
		effect.duration = duration
		value = duration

	# Apply the effect
	# This is based off DominoContainer implementation
	self.apply_effect(effect)
	var value_string = ""
	if value > 0:
		value_string = str(value)
	Game.get_node("Game").show_popup(value_string + effect.bb_code, self, "White", "PopupRiseAnimation")

func is_state_affected(state_name: String):
	for effect in self.effects:
		if effect.effect_name.to_upper() == state_name.to_upper() && (effect.get_duration() != 0 || effect.get_triggers() != 0 ):
			return true
	return false

func get_state_turns(state_name: String):
	for effect in self.effects:
		if effect.effect_name.to_upper() == state_name.to_upper():
			if(effect.get_duration() != -1 && effect.get_triggers() != -1):
				return max(effect.get_duration(), effect.get_triggers())	
			else:
				return -1
	return 0

#=========================================================================
# HP and shields
#=========================================================================

# Function to set player's HP
func set_hp(new_hp):
	self.hp = int(clamp(new_hp, 0, self.get_max_hp()))
	update()

# Self-damage (removes all modifiers)
func self_damage(amount, blockable: bool = true):
	
	var damage_data = { "damage": amount, "attacker": self, "defender": self }

	var shield_difference = self.shield - amount

	if(!blockable):
		self.hp -= amount
		self.hp = int(clamp(self.hp, 0, self.get_max_hp()))

		for effect in self.effects:
			effect.on_event("take_damage", damage_data)
		
		for effect in self.effects:
			effect.on_event("receive_damage", damage_data)

	elif shield_difference < 0:
		self.shield = 0
		amount = abs(shield_difference)	
		self.hp -= amount

		for effect in self.effects:
			effect.on_event("take_damage", damage_data)
		
		for effect in self.effects:
			effect.on_event("receive_damage", damage_data)

	else:
		self.shield -= amount
		amount = 0

	update()
	return amount

# Function to deal damage to target
# Method moved to Game.gd so its accessible by all classes and not just Battler
func damage(attacker, amount: int, simulate_damage: bool = false) -> int:
	return game.damage_battler(attacker, self, amount, simulate_damage)

func add_shields(amount, simulate_shield: bool = false) -> int:
	print("Defender from battler.gd: ", self.battler_name)
	return game.self_shield(self, amount, simulate_shield)

# Function to heal the player
func heal(amount) -> int:
	self.hp += amount
	self.hp = int(clamp(self.hp, 0, self.get_max_hp()))
	self.buff_pose(amount,BBCode.bb_code_heal())
	update()
	return amount

func update():
	if(health_bar != null):
		health_bar.update_gauge()
	if(effects_window != null):
		effects_window.update_effects()
	update_action_points()

func on_buff_effects(buff):
	pass

func on_debuff_effects(buff):
	pass

func on_effect(buff):
	pass

func on_remove_buff_effects(buff):
	pass

func on_remove_debuff_effects(buff):
	pass

func on_remove_effect(buff):
	pass

#================================================================================
# Turn effects
#================================================================================

func on_turn_start():
	var effect_data = {"user": self}
	for effect in self.effects:
		effect.on_event("on_turn_start", effect_data)
	refresh_shields()
	
	for domino in self.get_hand().get_children():
		domino.on_turn_start()
	
func on_turn_end():
	self.dominos_played_this_turn = []
	var effect_data = {"user": self}
	for effect in self.effects:
		effect.on_event("on_turn_end", effect_data)
	refresh_action_points()

func battle_start():
	self.battle_pose()
	for equip in self.equipped_items:
		#print("Applying start of battle effect for ", equip.equipment_name)
		equip.apply_start_of_battle_effect()
	self.draw_pile = shuffle_deck(self.get_draw_pile())

func battle_pose():
	yield(get_tree().create_timer(0.5), "timeout")
	var pose = "idle"
	if(self.hp < self.get_max_hp() * 0.25 && randi() % 2 == 0):
		pose = "defend"
	elif(randi() % 3 == 0):
		pose = "slash"
	elif(randi() % 2 == 0):
		pose = "stab"
	else:
		pose = "spell"
	
	self.get_node("AnimatedSprite").play(pose)
	var frame_count = self.get_node("AnimatedSprite").frames.get_frame_count(pose)
	var fps = self.get_node("AnimatedSprite").frames.get_animation_speed(pose)
	var animation_length = frame_count / fps
	yield(get_tree().create_timer(animation_length), "timeout")
	self.get_node("AnimatedSprite").play("idle")

#================================================================================
# Animations
#================================================================================

func change_pose(pose: String):
	self.get_node("AnimatedSprite").play(pose)

func damage_pose(value: int, delay: int = 0):
	if value > 0:
		yield(get_tree().create_timer(delay), "timeout")
		game.show_popup(str(value), self, "Red")
		self.get_node("AnimatedSprite").play("damage")
	elif self.shield > 0:
		yield(get_tree().create_timer(delay), "timeout")
		game.show_popup("Blocked", self, "Normal")
		self.get_node("AnimatedSprite").play("defend")
	else:
		yield(get_tree().create_timer(delay), "timeout")
		game.show_popup("Miss!", self, "normal")
		self.get_node("AnimatedSprite").play("evade")
	
	yield(get_tree().create_timer(0.5), "timeout")
	self.get_node("AnimatedSprite").play("idle")
	
func buff_pose(value: int, icon: String):
	if value > 0:
		game.show_popup(str(value), self, "Green", "PopupRiseAnimation", icon)

#================================================================================
# Utility functions
#================================================================================

func load_dominos_from_folder(folder_path: String, battler: String = "player"):
	var dir = Directory.new()
	var return_list = []
	if dir.open(folder_path) == OK:
		dir.list_dir_begin()  # Begin iterating through the folder
		
		var file_name = dir.get_next()
		while file_name != "":
			# Check if the file is a `.tscn` file
			if file_name.ends_with(".tscn"):
				var full_path = folder_path + "/" + file_name
				var domino_scene = load(full_path)
				if domino_scene:
					# Instance the domino scene
					var domino_instance = domino_scene.instance()
					# Add the domino to the deck or wherever needed
					if(battler.to_lower() == "player" || battler.to_lower() == "enemy"):
						add_to_deck(domino_instance, battler)
					elif(battler.to_lower() == "" || battler == null):
						return_list.append(domino_scene)
			file_name = dir.get_next()  # Get the next file
		
		dir.list_dir_end()  # End iteration

		if(battler.to_lower() == "" || battler == null):
			return return_list
	else:
		print("Failed to open folder:", folder_path)

# Returns a list of all equipment (the filename as a string) in the game
# Simply reads every file in the Equipment folder
func list_equipment_files(folder_path: String = "res://Equipment", exclusions: Array = ["Equipment", "EquipmentContainer", "Status"]) -> Array:
	var dir = Directory.new()
	var file_names = []
	
	if dir.open(folder_path) == OK:
		dir.list_dir_begin(true)  # Skip "." and ".."
		
		var file_name = dir.get_next()
		while file_name != "":
			# Check if it's a file (not a folder) and not excluded
			if dir.file_exists(folder_path + "/" + file_name):
				# Get the root name (without the extension)
				var root_name = file_name.get_basename()

				# Extra check to make sure .gd suffix is not included
				root_name = root_name.replace(".gd", "")
				
				# Only add it if it's not in exclusions
				if !(root_name in exclusions):
					#print(root_name, " added to equipment list")
					file_names.append(root_name)
					
			
			file_name = dir.get_next()
		
		dir.list_dir_end()  # End iteration
	else:
		print("Failed to open folder:", folder_path)
	
	return get_unique_values(file_names)

func get_unique_values(array):
	var unique_array = []
	for value in array:
		if not unique_array.has(value):
			unique_array.append(value)
	return unique_array

func reset():
	#self.hp = self.max_hp
	self.shield = 0
	self.action_points = self.get_action_points_per_turn()
	self.draw_pile = []
	self.discard_pile = []
	self.void_space = []
	self.effects = []
	self.dominos_played = []
	self.dominos_played_this_turn = []
	reset_deck()
	update()

func show_ui():
	$Container.show()
	$ScrollContainer.show()
	$TextureRect.show()

func hide_ui():
	$Container.hide()
	$ScrollContainer.hide()
	$TextureRect.hide()
