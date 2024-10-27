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

	set_hp(max_hp)
	initialize_deck()

func name():
	return self.battler_name

func initialize_deck():
	pass

func get_initial_draw() -> int:
	return self.initial_draw

func get_draw_per_turn() -> int:
	return self.draw_per_turn
	
func get_deck():
	for domino in self.deck:
		print(domino.get_user(), ": ", domino.get_numbers())
	return self.deck

func add_to_deck(domino: DominoContainer, type: String):
	domino.set_user(type)
	self.deck.append(domino)

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

# Function to deal damage to the player
func damage(attacker, amount) -> int:
	print("Initial Damage:", amount)
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
	print("Final Damage:", amount)
	
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
