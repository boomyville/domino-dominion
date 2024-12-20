extends Node

# Declare instance variables here
var battler_name: String
var hp: int
var max_hp: int
var shield: int
var max_shield: int
var initial_draw: int
var draw_per_turn: int
var deck: Array
var hp_gauge
var effect_text
var shield_text
var draw_pile: Array
var discard_pile: Array
var void_space: Array

var dominos_played: Array
var dominos_played_this_turn: Array

var effects: Array

func _init(battler_name: String = "Battler", hp: int = 50, max_hp: int = 50, shield: int = 0, max_shield: int = 999, initial_draw: int = 5, draw_per_turn: int = 2, deck: Array = [], hp_gauge = null, effect_text = null, shield_text = null):		
	self.battler_name = battler_name
	self.hp = hp
	self.max_hp = max_hp	
	self.shield = shield	
	self.max_shield = max_shield
	self.initial_draw = initial_draw
	self.draw_per_turn = draw_per_turn
	self.deck = deck
	self.hp_gauge = hp_gauge
	self.effect_text = effect_text
	self.shield_text = shield_text
	self.dominos_played = []
	self.dominos_played_this_turn = []
	self.effects = []
	self.void_space = []
	self.discard_pile = []

	set_hp(max_hp)
	initialize_deck()

func name():
	return self.battler_name

func get_hand():
	if(self.battler_name == "Player"):
		return Game.get_node("Game").player_hand
	elif(self.battler_name == "Enemy"):
		return Game.get_node("Game").enemy_hand

func remove_domino(collection, domino: DominoContainer):
	# Locate the matching domino in the collection
	for user_dominos in collection.get_children():
		if user_dominos.check_shadow_match(domino):
			# Disable interactions for the domino being removed
			user_dominos.set_block_signals(true)

			# Add a tween to animate the removal
			var tween = Game.get_node("Game").tween
			
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
	var tween = Game.get_node("Game").tween
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
	Game.get_node("Game").update_domino_highlights()

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
	elif type.to_upper() == "HAND":
		Game.get_node("Game").erase_from_hand(Game.get_node("Game").get_hand(self.battler_name), selected_domino)
	Game.get_node("Game").update_domino_highlights()

func add_to_discard_pile(domino: DominoContainer, type: String = "draw"):
	self.discard_pile.append(domino)
	
	# Add domino to discard pile effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_discard_pile"):
			effect.on_event("add_to_discard_pile", effect_data)

	# Remove petrification
	domino.set_petrification(0)

	remove_from(domino, type)
	
func add_to_void_space(domino: DominoContainer, type: String = "draw"):
	self.void_space.append(domino)

	# Add domino to void space effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_void_pile"):
			effect.on_event("add_to_void_pile", effect_data)
			
	remove_from(domino, type)

func add_to_draw_pile(domino: DominoContainer, type: String = "draw"):
	self.draw_pile.append(domino)	

	# Add domino to draw pile effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_draw_pile"):
			effect.on_event("add_to_draw_pile", effect_data)

	remove_from(domino, type)

func add_to_hand(domino: DominoContainer, type: String = "pile"):
	var collection = Game.get_node("Game").get_hand(self.battler_name)
	
	# Add domino to hand (non-draw effect)
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_hand"):
			effect.on_event("add_to_hand", effect_data)

	if not collection:
		print("Error: Collection node not found.")
		return
		
	if domino.is_inside_tree():
		var current_parent = domino.get_parent()
		current_parent.remove_child(domino)
		print("Removed from current parent: ", current_parent.name)

	collection.add_child(domino)
	domino.connect("domino_pressed", Game.get_node("Game"), "_on_domino_pressed") # Connect the signal
		
	Game.get_node("Game").animate_domino(domino, collection)
	
	remove_from(domino, type)
	
func add_to_deck(domino: DominoContainer, type: String):
	domino.set_user(type)
	
	# Add domino to deck (permanently) effect
	var effect_data = {"domino": domino, "user": self}
	for effect in self.effects:
		if(effect.event_type == "add_to_deck"):
			effect.on_event("add_to_deck", effect_data)

	self.deck.append(domino)

func initialize_deck():
	draw_pile = self.get_deck()
	draw_pile.shuffle()
		# domino.connect("domino_pressed", game, "_on_domino_pressed") # Connect the signal
		# Perform a priori setup for the domino

func get_initial_draw() -> int:
	return self.initial_draw

func get_draw_per_turn() -> int:
	return self.draw_per_turn
	
func get_deck():
	return self.deck

#==========================================
# Effects
#==========================================

func has_effect(effect_type: String):
	for effect in effects:
		if effect.event_type == effect_type:
			return effect  # Return the existing buff instance
	return null

# Apply a buff or increase its duration if it already exists
func apply_effect(effect_instance):
	effect_instance.set_attached_user(self)
	var existing_effect = has_effect(effect_instance.event_type)
	
	if existing_effect != null:
		print("Buff already exists, increasing duration / triggers")
		# If the buff exists, extend its duration
		if(existing_effect.get_duration() != -1):
			existing_effect.extend_duration(existing_effect.duration)
		if(existing_effect.get_triggers() != -1):
			existing_effect.extend_triggers(existing_effect.triggers)
	else:
		print("Applying new effect of ", effect_instance.event_type)
		# Otherwise, apply the new buff
		effects.append(effect_instance)
	update()

# Function to set player's HP
func set_hp(new_hp):
	self.hp = clamp(new_hp, 0, self.max_hp)
	update()

# Self-damage (removes all modifiers)
func self_damage(amount, blockable: bool = true):
	var shield_difference = self.shield - amount
	if(!blockable):
		self.hp -= amount
		self.hp = clamp(self.hp, 0, self.max_hp)
	elif shield_difference < 0:
		self.shield = 0
		amount = abs(shield_difference)	
		self.hp -= amount
	else:
		self.shield -= amount
		amount = 0
	update()
	return amount

# Function to deal damage to target
func damage(attacker, amount) -> int:
	var damage_data = { "damage": amount, "attacker": attacker, "defender": self }
	
	# Apply additive damage modifications
	for effect in attacker.effects:
		effect.on_event("modify_damage", damage_data)
	
	# Apply multiplicative damage modifications
	for effect in attacker.effects:
		effect.on_event("magnify_damage", damage_data)
	
	# Apply multiplicative damage reduction effects for defender
	for effect in self.effects:
		effect.on_event("minify_damage", damage_data)
	
	# Apply additive damage reduction effects for defender
	for effect in self.effects:
		effect.on_event("subtractive_damage", damage_data)

	amount = damage_data["damage"]

	for effect in attacker.effects:
		effect.on_event("use_attack", damage_data)

	if amount > 0:
		for effect in self.effects:
			effect.on_event("take_damage", damage_data)
		
		for effect in attacker.effects:
			effect.on_event("deal_damage", damage_data)
	
	# Handle shield and HP adjustments based on final damage amount
	var shield_difference = self.shield - amount
	if shield_difference < 0:
		self.shield = 0
		amount = abs(shield_difference)
		self.hp -= amount
		self.hp = clamp(self.hp, 0, self.max_hp)
	else:
		# Full shield block effects
		for effect in self.effects:
			effect.on_event("full_block", damage_data)
		
		# Attacker's effect for fully blocked attack
		for effect in attacker.effects:
			effect.on_event("blocked_attack", damage_data)
		
		self.shield -= amount
		amount = 0
	
	update()
	return amount

func add_shields(amount) -> int:
	
	self.shield += amount
	update()
	return amount

# Function to heal the player
func heal(amount) -> int:
	self.hp += amount
	self.hp = clamp(self.hp, 0, self.max_hp)
	update()
	return amount

func update():
	if(self.hp_gauge != null):
		self.hp_gauge.new_value(float(self.hp)/float(self.max_hp)*100)
		self.hp_gauge.get_node("HPLabel").text = str(self.hp) + " / " + str(self.max_hp)
	if(self.shield_text != null):
		self.shield_text.text = "[" + str(self.shield) + "]"
	if(self.effect_text != null):
		self.effect_text.text = "Effects: "
		for effect in effects:
			if(effect.get_duration() != -1):
				self.effect_text.text += effect.name + " (" + str(effect.get_duration()) + ") "
			elif(effect.get_triggers() != -1):
				self.effect_text.text += effect.name + " (" + str(effect.get_triggers()) + ") "
			else:
				self.effect_text.text += effect.name + " "

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

func on_turn_end():
	self.dominos_played_this_turn = []
	var effect_data = {"user": self}
	for effect in self.effects:
		effect.on_event("on_turn_end", effect_data)
