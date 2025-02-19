class_name DominoContainer
extends Container

# Variables for the two numbers on the domino
var number1: int = 0
var number2: int = 0
var number_data = {}

# pip_data is used to store the range of values for the pips
# {"left": [x, y, "type"]} Denotes the values for the left pip
# {"right": [x, y, "type"]} Denotes the values for the right pip
# Type is either static / dynamic / erratic / volatile
var pip_data = {"left": [null, null, null], "right": [null, null, null]}
var user: String = "none"
var current_user: String = "none"
var domino_name = ""
var criteria = []
# Upgrade levels; start at 1 by default
var upgrade_level = 1
var current_upgrade_level = 1
var max_upgrade_level = 3
var description = ""
var is_mouse_in_container = false
var battle_text;
var shader_material_left: ShaderMaterial
var shader_material_right: ShaderMaterial
var shader_material_domino: ShaderMaterial
var shadow_variant: bool = false
var selected: bool = false
var petrification: int = 0
var ephemeral: bool = false
var temporary: bool = false
var action_point_cost: int = 0
var left_status = "" # Can be erratic or volatile
var right_status = "" # Can be erratic or volatile
signal pre_effect_complete
signal action_completed

var description_popup = preload("res://Domino/DominoPopup.tscn")
var description_descriptor = preload("res://Domino/DominoDescriptor.tscn")
var default_background = preload("res://Domino/DominoBackground.png")
var petrified_background = preload("res://Domino/DominoBackgroundPetrified.png")

var game = Game.get_node("Game")

var dot_images = {
	-2: preload("res://Domino/Dots/-2_dots.png"),
	-1: preload("res://Domino/Dots/-1_dots.png"),
	0: preload("res://Domino/Dots/0_dots.png"),
	1: preload("res://Domino/Dots/1_dots.png"),
	2: preload("res://Domino/Dots/2_dots.png"),
	3: preload("res://Domino/Dots/3_dots.png"),
	4: preload("res://Domino/Dots/4_dots.png"),
	5: preload("res://Domino/Dots/5_dots.png"),
	6: preload("res://Domino/Dots/6_dots.png")
}

func get_criteria() -> Array:
	return self.criteria

func get_domino_name() -> String:
	return self.domino_name

func get_domino_type() -> String:
	var script_path = get_script().resource_path
	return script_path.get_base_dir().get_file()

func shadow_copy() -> DominoContainer:
	var duplicate_instance = self.duplicate()
	
	# Create deep copies of scripts and resources
	duplicate_instance.set_script(null)  # Break script reference
	duplicate_instance.set_script(load(self.get_script().get_path()))  # Re-attach script
	
	# Deep copy custom properties (if they are objects)
	duplicate_instance.number_data = self.number_data.duplicate()
	duplicate_instance.pip_data = self.pip_data.duplicate()
	duplicate_instance.number1 = self.number1
	duplicate_instance.number2 = self.number2
	duplicate_instance.criteria = self.criteria.duplicate()
	duplicate_instance.upgrade_level = self.upgrade_level
	duplicate_instance.current_upgrade_level = self.current_upgrade_level
	duplicate_instance.user = self.user
	duplicate_instance.current_user = self.current_user
	duplicate_instance.domino_name = self.domino_name
	duplicate_instance.is_mouse_in_container = self.is_mouse_in_container
	duplicate_instance.battle_text = self.battle_text
	
	# Create material copies to break texture references
	if(self.shader_material_left):
		duplicate_instance.shader_material_left = self.shader_material_left.duplicate()
	
	if(self.shader_material_right):
		duplicate_instance.shader_material_right = self.shader_material_right.duplicate()
	
	if(self.shader_material_domino):
		duplicate_instance.shader_material_domino = self.shader_material_domino.duplicate()
	
	# Set the flag to indicate this domino is in popup mode
	duplicate_instance.shadow_variant = true
	
	return duplicate_instance

func check_shadow_match(domino: DominoContainer) -> bool:
	return self.number1 == domino.number1 && self.number2 == domino.number2 && domino.user == self.user && domino.domino_name == self.domino_name && domino.upgrade_level == self.upgrade_level && domino.current_upgrade_level == self.current_upgrade_level

# Function to set the numbers of the domino
# -1 represents a wild domino (equals the last played domino number)

func set_numbers(n1: int, n2: int, owner: String = ""):
	if self.number1 != -2:
		self.number1 = n1
	if self.number2 != -2:
		self.number2 = n2
	if owner != "":
		self.set_current_user(owner)
	#print("Setting numbers: " + str(n1) + ", " + str(n2))
	update_domino()

func set_user(new_user: String):
	self.user = new_user.to_upper()
	self.current_user = new_user.to_upper()
	update_domino()

func get_user() -> String:
	return user

func set_current_user(new_user: String):
	self.current_user = new_user.to_upper()
	update_domino()

func get_current_user() -> String:
	return self.current_user

func get_numbers() -> Array:
	return [number1, number2]

func get_pip_value() -> Array:
	var returned_value = []
	if pip_data["left"][2] == "static":
		returned_value.append(pip_data["left"][0])
	elif pip_data["left"][1] == null:
		returned_value.append(pip_data["left"][0])
	else:
		returned_value.append(random_range(pip_data["left"][0], pip_data["left"][1]))
		
	if pip_data["right"][2] == "static":
		returned_value.append(pip_data["right"][0])
	elif pip_data["right"][1] == null:
		returned_value.append(pip_data["right"][0])
	else:
		returned_value.append(random_range(pip_data["right"][0], pip_data["right"][1])) 
	return returned_value
	
func get_action_points() -> int:
	return action_point_cost

func set_temporary(value: bool):
	temporary = value

func is_temporary() -> bool:
	return temporary

func get_upgrade_level() -> int:
	return current_upgrade_level

func reset_upgrade_level():
	current_upgrade_level = self.upgrade_level

# Can only upgrade to penultimate tier
func alter_upgrade_domino(value: int = 1):
	current_upgrade_level = max(0, min(value + current_upgrade_level, self.get_max_upgrade_level() - 1))
	#self._init()
	self.update_domino()
	self.initiate_domino()

func get_max_upgrade_level() -> int:
	if "common" in self.criteria or "starter" in self.criteria:
		return 4
	if "uncommon" in self.criteria:
		return 3
	if "rare" in self.criteria:
		return 2
	print("Error: Invalid criteria for ", self.domino_name)
	return 4

func upgrade_domino(value: int = 1) -> bool:
	if can_upgrade():
		upgrade_level = min(value + upgrade_level, self.get_max_upgrade_level())
		current_upgrade_level = upgrade_level
		#self._init()
		self.update_domino()
		self.initiate_domino()
		print("Upgrading ", self.domino_name, " to level ", upgrade_level)
		return true
	return false

func set_upgrade_level(value: int):
	upgrade_level = max(0, min(self.get_max_upgrade_level(), value))
	current_upgrade_level = upgrade_level
	#self._init()
	self.initiate_domino()
	self.update_domino()

func can_upgrade(over_upgrade = false) -> bool:
	if (over_upgrade):
		return upgrade_level < get_max_upgrade_level()
	else:
		return upgrade_level < get_max_upgrade_level() - 1

# Sets maximum upgrade level based on rarity
func initiate_domino() -> void:
	roll_numbers("all")

# Update the buttons to show the domino numbers
func update_domino():

	if(number1 >= -2):
		if(left_status == "erratic" || pip_data["left"][2] == "erratic"):
			$HBoxContainer/LeftTile/AnimatedSprite.play(str(number1) + "_shaking")
		elif(left_status == "volatile" || pip_data["left"][2] == "volatile"):
			$HBoxContainer/LeftTile/AnimatedSprite.play(str(number1) + "_rainbow")
		else:
			$HBoxContainer/LeftTile/AnimatedSprite.play(str(number1))
	
	if(number2 >= -2):
		if(right_status == "erratic"|| pip_data["right"][2] == "erratic"):
			$HBoxContainer/RightTile/AnimatedSprite.play(str(number2) + "_shaking")
		elif(right_status == "volatile" || pip_data["right"][2] == "volatile"):
			$HBoxContainer/RightTile/AnimatedSprite.play(str(number2) + "_rainbow")
			#print("playing " + str(number2) + "_rainbow")
		else:
			$HBoxContainer/RightTile/AnimatedSprite.play(str(number2))

	if(get_current_user().to_upper() == "BOARD"):
		# or get_current_user().to_upper() == "ENEMY"
		set_clickable(false)
	else:
		set_clickable(true)

	# Update action points cost
	if(action_point_cost > 0 && user.to_upper() != "BOARD"):
		$DominoLabel/ActionPointLabel.text = str(action_point_cost)
		$DominoLabel/ActionPointCircle.show()
		$DominoLabel/ActionPointLabel.show()
	else:
		$DominoLabel/ActionPointCircle.hide()
		$DominoLabel/ActionPointLabel.hide()

	# Set upgrade animation
	match get_upgrade_level():
		0, 1:
			$Node2D/AnimatedSprite.play("default")
			if(self.domino_name.length() > 12):
				var nano_font = preload("res://Fonts/MicroSlim.fnt")
				$DominoLabel/Label.add_font_override("font", nano_font)
			else:
				var regular_font = preload("res://Fonts/Micro.fnt")
				$DominoLabel/Label.add_font_override("font", regular_font)
		2:
			$Node2D/AnimatedSprite.play("upgrade1")
			if(self.domino_name.length() > 12):
				var nano_font = preload("res://Fonts/MicroSlimGreen.fnt")
				$DominoLabel/Label.add_font_override("font", nano_font)
			else:
				var regular_font = preload("res://Fonts/MicroGreen.fnt")
				$DominoLabel/Label.add_font_override("font", regular_font)
		3:
			$Node2D/AnimatedSprite.play("upgrade2")
			if(self.domino_name.length() > 12):
				var nano_font = preload("res://Fonts/MicroSlimGold.fnt")
				$DominoLabel/Label.add_font_override("font", nano_font)
			else:
				var regular_font = preload("res://Fonts/MicroGold.fnt")
				$DominoLabel/Label.add_font_override("font", regular_font)
		4:	
			$Node2D/AnimatedSprite.play("upgrade3")
			if(self.domino_name.length() > 12):
				var nano_font = preload("res://Fonts/MicroSlimRed.fnt")
				$DominoLabel/Label.add_font_override("font", nano_font)
			else:
				var regular_font = preload("res://Fonts/MicroRed.fnt")
				$DominoLabel/Label.add_font_override("font", regular_font)
		_:
			$Node2D/AnimatedSprite.play("default")
			if(self.domino_name.length() > 12):
				var nano_font = preload("res://Fonts/MicroSlim.fnt")
				$DominoLabel/Label.add_font_override("font", nano_font)
			else:
				var regular_font = preload("res://Fonts/MicroSlim.fnt")
				$DominoLabel/Label.add_font_override("font", regular_font)

	update_background()

func set_clickable(clickable: bool):
	$HBoxContainer/LeftTile.disabled = not clickable # Disable Button1 if not clickable
	$HBoxContainer/RightTile.disabled = not clickable # Disable Button2 if not clickable
	if(not clickable):
		$HBoxContainer/LeftTile.focus_mode = Control.FOCUS_NONE
		$HBoxContainer/RightTile.focus_mode = Control.FOCUS_NONE
	else:
		$HBoxContainer/LeftTile.focus_mode = Control.FOCUS_CLICK
		$HBoxContainer/RightTile.focus_mode = Control.FOCUS_CLICK	


# For debug purposes
func get_clickable() -> bool:
	return !$HBoxContainer/LeftTile.disabled && !$HBoxContainer/RightTile.disabled

func reset_domino_state():
	#print(domino_name, " reset. Clickable: ", !$HBoxContainer/LeftTile.disabled)
	set_ephemeral(false)
	set_petrification(0)
	set_upgrade_level(upgrade_level)

func get_non_matching_values(arr: Array, value: int) -> Array:
	var non_matching_values = []
	for element in arr:
		if element != value:
			non_matching_values.append(element)
	return non_matching_values

func can_play(last_played_number: int, playing_user, target, pressed_number: int = get_numbers()[0]) -> String:
	var result = "unplayable"

	if game.game_state != game.GameState.DEFAULT:
		return result # Unplayable if not in default game state or petrified
	elif is_petrified():
		return "petrification" 
	elif action_point_cost > playing_user.action_points:
		return "action_points_deficiency" 
	elif(requirements(playing_user, target) == false):
		return "prohibited"
	elif(get_numbers()[0] == -2 || get_numbers()[1] == -2):
		return "locked"
	elif(pressed_number == last_played_number || pressed_number == -1 || last_played_number == -1):
		if(get_numbers()[0] == pressed_number):
			result = "playable"
		else:
			result = "swap"
	elif(get_numbers()[0] == -1 || get_numbers()[0] == last_played_number):
		result = "playable"
	elif(get_numbers()[1] == -1 || get_numbers()[1] == last_played_number):
		result = "swap"

	var effect_data = {"user": playing_user, "target": target, "domino_played": self, "result": result}

	if(result == "swap"):
		for effect in playing_user.effects:
			effect.on_event("after_swap", effect_data)
		result = effect_data["result"]

	return result

func swap_values():
	var temp = number1
	number1 = number2
	number2 = temp
	print("Swapping numbers...")
	update_domino()

# Called when the node enters the scene tree for the first time
func _ready():

	$DominoLabel/Label.text = self.domino_name
	
	shader_material_left = ShaderMaterial.new()
	shader_material_right = ShaderMaterial.new()
	shader_material_domino = ShaderMaterial.new()

	var shader = load("res://Domino/domino_shader.gdshader")
	shader_material_left.shader = shader
	shader_material_right.shader = shader
	shader_material_domino.shader = shader
	
	# Set initial parameters
	shader_material_left.set_shader_param("outline_enabled", false)
	shader_material_right.set_shader_param("outline_enabled", false)
	shader_material_domino.set_shader_param("outline_enabled", false)
	shader_material_left.set_shader_param("outline_color", Color(1.0, 0.0, 0.0, 1.0))
	shader_material_right.set_shader_param("outline_color", Color(1.0, 0.0, 0.0, 1.0))
	shader_material_domino.set_shader_param("outline_color", Color(0.0, 1.0, 0.0, 1.0))
	
	$HBoxContainer/LeftTile.get_node("AnimatedSprite").material = shader_material_left
	$HBoxContainer/RightTile.get_node("AnimatedSprite").material = shader_material_right
	$Node2D/TextureRect.material = shader_material_domino
	
	$HBoxContainer/LeftTile.rect_min_size = Vector2(48, 48)
	$HBoxContainer/RightTile.rect_min_size = Vector2(48,48)
	
	var left_tile_click_connection = $HBoxContainer/LeftTile.connect("pressed", self, "_on_left_button_pressed") # Connect HBoxContainer/LeftTile button
	var right_tile_click_connection =	$HBoxContainer/RightTile.connect("pressed", self, "_on_right_button_pressed") # Connect HBoxContainer/RightTile button
	if left_tile_click_connection != OK:
		push_error("Failed to connect signal. Error code: %s" % left_tile_click_connection)
	if right_tile_click_connection != OK:
		push_error("Failed to connect signal. Error code: %s" % right_tile_click_connection)

	var right_tile_mouse_enter_connection = $HBoxContainer/RightTile.connect("mouse_entered", self, "_on_button_hovered", [$HBoxContainer/RightTile])
	var right_tile_mouse_exit_connection = $HBoxContainer/RightTile.connect("mouse_exited", self, "_on_button_hover_exited", [$HBoxContainer/RightTile])
	if right_tile_mouse_enter_connection != OK:
		push_error("Failed to connect signal. Error code: %s" % right_tile_mouse_enter_connection)
	if right_tile_mouse_exit_connection != OK:
		push_error("Failed to connect signal. Error code: %s" % right_tile_mouse_exit_connection)

	var left_tile_mouse_exit_connection = $HBoxContainer/LeftTile.connect("mouse_entered", self, "_on_button_hovered", [$HBoxContainer/LeftTile])
	var left_tile_mouse_enter_connection = 	$HBoxContainer/LeftTile.connect("mouse_exited", self, "_on_button_hover_exited", [$HBoxContainer/LeftTile])
	if left_tile_mouse_exit_connection != OK:
		push_error("Failed to connect signal. Error code: %s" % left_tile_mouse_exit_connection)
	if left_tile_mouse_enter_connection != OK:
		push_error("Failed to connect signal. Error code: %s" % left_tile_mouse_enter_connection)

	#$Node2D/TextureRect.connect("mouse_entered", self, "_on_domino_mouse_entered")
	#$Node2D/TextureRect.connect("mouse_exited", self, "_on_domino_mouse_exited")

	update_domino()
	
# Highlight based on playability
func update_highlight(can_play: bool):
	if(self.user.to_upper() == "PLAYER" && $Node2D/TextureRect.material != null):
		$Node2D/TextureRect.material.set_shader_param("outline_enabled", can_play)

func set_pip_data(left_min_range: int = 1, left_max_range: int = 6, right_min_range: int = 1, right_max_range: int = 6, left_type: String = "dynamic", right_type: String = "dynamic"):
	pip_data["left"] = [left_min_range, left_max_range, left_type]
	pip_data["right"] = [right_min_range, right_max_range, right_type]

# Static / Dynamic / Erratic / Volatile
func roll_numbers(type: String = "dynamic"):
	if pip_data["left"][2] == type || type == "all":
		number_data[0] = random_range(pip_data["left"][0], pip_data["left"][1])
	if pip_data["right"][2] == type || type == "all":
		number_data[1] = random_range(pip_data["right"][0], pip_data["right"][1])
		#print("Rolling numbers: ", number1, number2, " | Type: ", type, " | Domino: ", domino_name)
	
	if(number_data.size() == 0):
		print(self.domino_name, " has no pip data")

	number1 = number_data[0]["value"]
	number2 = number_data[1]["value"]
	update_domino()
		
func random_range(min_value: int, max_value):
	if max_value == null:
		return {
			"value": min_value,
			"range": [min_value]
		}
	else :
		return {
			"value": randi() % (max_value - min_value + 1) + min_value,
			"range": [min_value, max_value]
		}

func random_value(max_value: int = 6):
	return random_range(1, max_value)["value"]

# Handle left button press and emit signal with number1
func _on_left_button_pressed():
	Game.get_node("Game").perform_domino_action(self, number1)
	
# Handle right button press and emit signal with number2
func _on_right_button_pressed():
	Game.get_node("Game").perform_domino_action(self, number2)

# Handle mouse enter - turn outline on
func _on_button_hovered(button):
	var material = button.get_node("AnimatedSprite").material as ShaderMaterial # Red dot outline
	var material2 = $Node2D/TextureRect.material as ShaderMaterial # Green outline

	# Only apply hover effects based on the mode (popup vs. main game)
	if shadow_variant && self.user.to_upper() == "PLAYER" and game.is_selection():
		# Use material2 for popups
		if material2:
			material2.set_shader_param("outline_enabled", true)
		# Show description specific to the popup domino
		
		if game.touch_mode == false:
			show_domino_description(self)
	
	elif !shadow_variant &&  material and self.user.to_upper() == "PLAYER" and game.game_state_default():
		material.set_shader_param("outline_enabled", true)
		
		if game.touch_mode == false:
			show_domino_description(self)

# Handle mouse exit - turn outline off
func _on_button_hover_exited(button):
	var material = button.get_node("AnimatedSprite").material as ShaderMaterial # Red dot outline
	var material2 = $Node2D/TextureRect.material as ShaderMaterial # Green outline

	if material and game.game_state_default():
		material.set_shader_param("outline_enabled", false)
	elif(material2 and game.is_selection() && !selected && shadow_variant):
		material2.set_shader_param("outline_enabled", false)
	if game.touch_mode == false:
		hide_domino_description(false)

func clear_highlight():
	$HBoxContainer/LeftTile.get_node("AnimatedSprite").material.set_shader_param("outline_enabled", false)
	$HBoxContainer/RightTile.get_node("AnimatedSprite").material.set_shader_param("outline_enabled", false)
	$Node2D/TextureRect.material.set_shader_param("outline_enabled", false)

func set_clicked(clicked: bool):
	selected = clicked
	if(clicked):
		$Node2D/TextureRect.material.set_shader_param("outline_enabled", true)
		shader_material_domino.set_shader_param("outline_color", Color(1.0, 1.0, 0.0, 1.0))
		show_domino_description(self)
	else:
		$Node2D/TextureRect.material.set_shader_param("outline_enabled", false)
		shader_material_domino.set_shader_param("outline_color", Color(0.0, 1.0, 0.0, 1.0))

func requirements(origin, target):
	for effect in origin.effects:
		if effect.on_event("domino_requirements", {"user": origin, "target": target, "domino_played": self}) == false:
			return false
	return true 
	#print("Origin: ", origin, " | Domino: ", domino_name)

func effect(origin, target):
	# Play domino effects
	var effect_data = {"user": origin, "target": target, "domino_played": self}

	for effect in origin.effects:
		effect.on_event("play_domino", effect_data)
	
	origin.dominos_played.append(self)
	origin.dominos_played_this_turn.append(self)

func attack_message(origin, target, damage) -> int:
	game.update_battle_text(origin.get_name() + " used " + domino_name + " on " + target.get_name() + " for " + str(damage) + " damage!")	
	return damage

func shield_message(origin, target, shield):
	game.update_battle_text(origin.get_name() + " used " + domino_name + " and " + target.get_name() + " gained " + str(shield) + " shield(s)!")
	return shield

func apply_effect(effect, target, value = 0):
	target.apply_effect(effect)
	var value_string = ""
	if value > 0:
		value_string = str(value)
	game.show_popup(value_string + effect.bb_code, target, "White", "PopupRiseAnimation")

#================================
# Description Popup
#================================
# Function to handle showing the popup
# Show domino description with a flag for popup vs main game
func show_domino_description(domino):
	# If it's a popup clone, show description in a specific way
	if game.is_selection():

		if(game.detailed_descriptors == false):
			var popup = description_popup.instance()  # Assuming Popup is your description UI element
			add_child(popup)

			# Set the popup description
			popup.set_description("[center]" +  domino.get_description() + "[/center]")	
			
			# Get the window width
			var window_width = get_viewport_rect().size.x

			# Calculate the popup's position centered above the domino
			var popup_position_x = domino.get_global_position().x - (popup.rect_min_size.x - domino.rect_size.x) / 2
			var popup_position_y = domino.get_global_position().y - popup.rect_min_size.y -  domino.rect_size.y / 2

			# Adjust to keep the popup within the screen bounds
			popup_position_x = max(0, min(popup_position_x, window_width - popup.rect_min_size.x))

			# Set the popup position
			popup.rect_global_position = Vector2(popup_position_x, popup_position_y)
			
			# Display the popup
			popup.popup()
		else:
			# Show detailed domino description
			var popup = description_descriptor.instance()
			add_child(popup)
			popup.get_node("Control/Popup/Node2D").set_type(popup.get_node("Control/Popup/Node2D").reward_type.DOMINO)
			popup.get_node("Control").initialise(self)
			
			# Upgraded domino pops up if:
				# 1. The selection popup is visible
				# 2. The game state is default (so in battle) or inactive (events)
				# 3. The destination collection is either "same_hand_upgrade" or "upgradable_stack"
			if(game.selection_popup.visible == true and (game.game_state_default() or game.game_state_inactive()) and (game.selection_popup.destination_collection.to_lower() == "same_hand_upgrade" || game.selection_popup.destination_collection.to_lower() == "upgradable_stack")):
				var upgrade_popup = description_descriptor.instance()
				add_child(upgrade_popup)
				upgrade_popup.get_node("Control/Popup/Node2D").set_type(upgrade_popup.get_node("Control/Popup/Node2D").reward_type.DOMINO)
				upgrade_popup.get_node("Control").upgrade_domino_initialise(self, 1, false)
				

	else:
		# Existing description logic for main game dominos
		if has_node("DominoPopup"):
			get_node("DominoPopup").queue_free()
			var popup = description_popup.instance()  # Assuming Popup is your description UI element
			# Set the popup description
			popup.set_description("[center]" + domino.get_description() + "[/center]")	
			
			# Get the window width
			var window_width = get_viewport_rect().size.x

			# Calculate the popup's position centered above the domino
			var popup_position_x = domino.get_global_position().x - (popup.rect_min_size.x - domino.rect_size.x) / 2
			var popup_position_y = domino.get_global_position().y - popup.rect_min_size.y -  domino.rect_size.y / 2

			# Adjust to keep the popup within the screen bounds
			popup_position_x = max(0, min(popup_position_x, window_width - popup.rect_min_size.x))

			# Set the popup position
			popup.rect_global_position = Vector2(popup_position_x, popup_position_y)
			
			# Display the popup
			popup.popup()
			add_child(popup)
		if has_node("DominoDescriptor"):
			get_node("DominoDescriptor").queue_free()
			# Show detailed domino description
			var popup = description_descriptor.instance()
			add_child(popup)
			popup.initialise(self)

			



func hide_domino_description(is_popup: bool = false):
	if is_popup:
		if has_node("Popup"):  # Assuming "Popup" is the name of the description popup node
			get_node("Popup").queue_free()  # Remove popup for the clone
			
	else:
		if has_node("DominoPopup"):
			get_node("DominoPopup").queue_free()  # Remove popup for the main game domino
		if has_node("DominoDescriptor"):
			get_node("DominoDescriptor").queue_free()  # Remove popup for the main game domino

func get_description() -> String:
	return ""

func get_detailed_description() -> String:
	return ""

func get_damage_value(amount: int) -> int:
	return game.damage_battler(game.string_to_battler(get_user()), null, amount, true)

func get_shield_value(amount: int) -> int:
	return game.self_shield(game.string_to_battler(get_user()), amount, true)


func get_pip_description() -> String:
	# Static - Number does not change (set at pick up)
	# Dynamic - Number changes when domino is drawn
	# Erratic - Number changes at the start of the turn
	# Volatile - Number changes after a domino is played
	var msg = ""
	if (pip_data["left"][0] != null):
		msg = "Left pip: " + pip_data["left"][2].capitalize() + " ";
		if(pip_data["left"][1] == null):	
			if pip_data["left"][0] == -1:
				msg += "(Wild)"
			elif pip_data["left"][0] == -2:
				msg += "(X)"
			else:
				msg += "(" + str(pip_data["left"][0]) + ")"
		else:
			msg += "(" + str(pip_data["left"][0]) + "-" + str(pip_data["left"][1]) + ")"
		msg += "\n"
		msg += "Right pip: " + pip_data["right"][2].capitalize() + " ";
		if(pip_data["right"][1] == null):	
			if pip_data["right"][0] == -1:
				msg += "(Wild)"
			elif pip_data["right"][0] == -2:
				msg += "(X)"
			else:
				msg += "(" + str(pip_data["right"][0]) + ")"
		else:
			msg += "(" + str(pip_data["right"][0]) + "-" + str(pip_data["right"][1]) + ")"
		msg += "\n"
	else: 
		msg = "Left pip: " + left_status.capitalize() + " ";

		if number_data[0]["range"].size() == 1:
			if(number_data[0]["range"][0] == -1):
				msg += "(Wild)"
			elif(number_data[0]["range"][0] == -2):
				msg += "(X)"
			else:
				msg += "(" + str(number_data[0]["range"][0]) + ")"
		elif number_data[0]["range"].size() == 2:
			msg += "(" + str(number_data[0]["range"][0]) + "-" + str(number_data[0]["range"][1]) + ")"
		
		msg += "\n"
		
		msg += "Right pip: " + right_status.capitalize() + " ";

		if number_data[1]["range"].size() == 1:
			if(number_data[1]["range"][0] == -1):
				msg += "(Wild)"
			elif(number_data[0]["range"][0] == -2):
				msg += "(X)"
			else:
				msg += "(" + str(number_data[1]["range"][0]) + ")"
		elif number_data[1]["range"].size() == 2:
			msg += "(" + str(number_data[1]["range"][0]) + "-" + str(number_data[1]["range"][1]) + ")"
		
		msg += "\n"

	if("top_stack" in self.criteria):
		print("Top Stack (Drawn first)")
		msg += "Top Stack (Drawn first)\n"
	if("bottom_stack" in self.criteria):
		msg += "Bottom Stack (Drawn last)\n"

	if(ephemeral):
		msg += "Ephemeral (Void at turn end)\n"
	msg += "\n"
	return msg
#================================================================
# Domino repositioning
#================================================================
func final_domino_position(position: int, collection):
	var target_positionX: int
	var target_positionY: int

	if(collection is GridContainer):
		target_positionX = position % collection.columns * (self.get_combined_minimum_size().x + collection.get_constant("hseparation"))
		target_positionY = floor(position / collection.columns) * (self.get_combined_minimum_size().y + collection.get_constant("vseparation"))	
	elif(collection is HBoxContainer):
		target_positionX = position % collection.columns * (self.get_combined_minimum_size().x + collection.get_constant("hseparation"))
		target_positionY = floor(position / collection.columns) * (self.get_combined_minimum_size().y + collection.get_constant("vseparation"))	
	else:
		target_positionX = position * (self.get_combined_minimum_size().x + collection.get_constant("hseparation"))
		target_positionY = 0

	return Vector2(target_positionX, target_positionY)
#================================================================
# Domino specified effects
#   - Petrification
#   - Ephemeral
#   - Uptick / Downtick
#	- Reroll
#================================================================
func uptick(value_change: int):
	if number1 >= 0:
		number1 = int(max(1, max(6, number1 + value_change)))
	if number2 >= 0:
		number2 = int(max(1, max(6, number2 + value_change)))
	update_domino()

func discard_effect(_origin, _target):
	return

func reroll(max_value: int = 6):
	set_numbers(random_value(max_value), random_value(max_value), user)

func set_petrification(value: int):
	petrification = value
	update_background()

func set_ephemeral(value: bool):
	ephemeral = value
	update_background()

func is_petrified() -> bool:
	return petrification > 0

func is_ephemeral() -> bool:
	return ephemeral

func update_background():
	if is_petrified():
		$Node2D/TextureRect.texture = petrified_background
	else:
		$Node2D/TextureRect.texture = default_background
	if is_ephemeral() and user.to_upper() == "PLAYER":
		$Node2D/TextureRect.modulate = Color(1.0, 1.0, 1.0, 0.75)
	else:
		$Node2D/TextureRect.modulate = Color(1.0, 1.0, 1.0, 1.0)

#================================================================
# Domino turn effects (mainly re-rolling numbers)
#================================================================
func on_battle_start():
	# Dynamic / Called at the start of battle on all dominos in the draw pile
	roll_numbers("dynamic")

func on_turn_start():
	# Erratic / Called at the end of the turn on all dominos in hand
	roll_numbers("erratic")

func on_play():
	print("Volatile!")
	# Volatile / Called after a domino is played on all dominos in hand
	roll_numbers("volatile")

#================================================================
# Animation effects
#================================================================

func basic_attack(attacker, defender, type = "slash", outcome = 0, animation = null):
	game.set_game_state(game.GameState.WAITING)
	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_hop_towards")
	yield(get_tree().create_timer(attacker.get_node("AnimationPlayer").get_animation(attacker.battler_type.to_lower() + "_hop_towards").length), "timeout")
	
	attacker.get_node("AnimatedSprite").play(type)
	yield(get_tree().create_timer(0.5), "timeout")
	defender.damage_pose(outcome)

	# Add to the current scene (or a specific parent node)
	var animation_instance = animation.instance()
	defender.get_node("AnimationLayer").add_child(animation_instance)
	animation_instance.play_animation(defender)
	yield(animation_instance, "animation_finished")

	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_hop_away")
	yield(get_tree().create_timer(0.5), "timeout")	
	emit_signal("action_completed")  # Notify that this domino's action is done

func quick_attack(attacker, defender,  outcome = "damage", approach = "zoom_in", retreat = "hop_away", animation = null, defender_animation = null):
	game.set_game_state(game.GameState.WAITING)
	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_" + approach)
	yield(get_tree().create_timer(attacker.get_node("AnimationPlayer").get_animation(attacker.battler_type.to_lower() + "_" + approach).length), "timeout")
	
	if(defender_animation != null):
		defender.get_node("AnimationPlayer").play(defender.battler_type.to_lower() + "_" + defender_animation)
		yield(get_tree().create_timer(0.5), "timeout")
	
	defender.damage_pose(outcome)
	
	# Add to the current scene (or a specific parent node)
	var animation_instance = animation.instance()
	defender.get_node("AnimationLayer").add_child(animation_instance)
	animation_instance.play_animation(defender)

	yield(get_tree().create_timer(0.5), "timeout")
	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_" + retreat)
	yield(get_tree().create_timer(0.5), "timeout")
	emit_signal("action_completed")  # Notify that this domino's action is done

func multi_attack(attacker, defender, outcome_array: Array = [], animation_array: Array=[], pose_array: Array = [], approach_pose: String = "zoom_in", retreat_pose: String = "hop_away"):
	game.set_game_state(game.GameState.WAITING)
	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_" + approach_pose)
	yield(get_tree().create_timer(0.5), "timeout")
	
	# Check  if animation and outcome arrays are the same length
	if(outcome_array.size() != animation_array.size() && animation_array.size() != pose_array.size()):
		print("Error: Animation, pose and outcome arrays must be the same length")
	else:
		for i in range(pose_array.size()):
			# Special poses:
				# jump_attack
				# rise_and_fall

			if(pose_array[i] == "jump_attack"): # To implement
				attacker.get_node("AnimatedSprite").play("rise")
				yield(get_tree().create_timer(0.5), "timeout")
				attacker.get_node("AnimatedSprite").play("fall")
				yield(get_tree().create_timer(0.5), "timeout")
			elif(pose_array[i] == "rise_and_fall"):		
				attacker.get_node("AnimatedSprite").play("rise")
				yield(get_tree().create_timer(0.5), "timeout")
				attacker.get_node("AnimatedSprite").play("fall")
				yield(get_tree().create_timer(0.5), "timeout")
			else:
				attacker.get_node("AnimatedSprite").play(pose_array[i])
				yield(get_tree().create_timer(0.5), "timeout")
			
			defender.damage_pose(outcome_array[i])
			
			# Add to the current scene (or a specific parent node)
			var animation_instance = animation_array[i].instance()
			defender.get_node("AnimationLayer").add_child(animation_instance)
			animation_instance.play_animation(defender)
			
			yield(get_tree().create_timer(0.5), "timeout")
		
		attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_" + retreat_pose)
		yield(get_tree().create_timer(0.5), "timeout")

		attacker.get_node("AnimatedSprite").play("idle")
		emit_signal("action_completed") 

# This method incorporates attack_message 
# attack_message(origin, target, target.damage(origin, x))
func multi_hit_attack(attacker, defender, type = "slash", damage_value: int = 0, animation = null, approach: String = "hop_towards", times: int = 1):
	game.set_game_state(game.GameState.WAITING)
	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_" + approach)
	yield(get_tree().create_timer(attacker.get_node("AnimationPlayer").get_animation(attacker.battler_type.to_lower()  + "_" + approach).length), "timeout")
	
	attacker.get_node("AnimatedSprite").play(type)
	yield(get_tree().create_timer(0.5), "timeout")

	# Multi-hit
	var animation_instance = animation.instance()
	defender.get_node("AnimationLayer").add_child(animation_instance)
	animation_instance.play_animation(defender)

	for _i in range(times):
		var outcome = attack_message(attacker, defender, defender.damage(attacker, damage_value))
		defender.damage_pose(outcome)
		yield(get_tree().create_timer(0.5), "timeout")


	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_hop_away")
	yield(get_tree().create_timer(0.5), "timeout")	
	emit_signal("action_completed")  # Notify that this domino's action is done
	

func charge_up(origin, animation):
	game.set_game_state(game.GameState.WAITING)
	origin.get_node("AnimatedSprite").play("spell")

	var animation_instance = animation.instance()
	origin.get_node("AnimationLayer").add_child(animation_instance)
	animation_instance.play_animation(origin)
	yield(get_tree().create_timer(0.5), "timeout")

	origin.get_node("AnimatedSprite").play("idle")

func charge_smash(attacker, defender, outcome: int = 0, charge_animation = null, animation = null):
	game.set_game_state(game.GameState.WAITING)
	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_hop_towards")
	yield(get_tree().create_timer(0.8), "timeout")

	if(charge_animation != null):
		var animation_instance = charge_animation.instance()
		attacker.get_node("AnimationLayer").add_child(animation_instance)
		animation_instance.play_animation(attacker)
	attacker.get_node("AnimatedSprite").play("rise")
	yield(get_tree().create_timer(0.5), "timeout")

	defender.damage_pose(outcome)
	
	# Add to the current scene (or a specific parent node)
	if (animation != null):
		var animation_instance2 = animation.instance()
		defender.get_node("AnimationLayer").add_child(animation_instance2)
		animation_instance2.play_animation(defender)
	
	attacker.get_node("AnimatedSprite").play("fall")

	yield(get_tree().create_timer(0.5), "timeout")
	attacker.get_node("AnimationPlayer").play(attacker.battler_type.to_lower() + "_hop_away")
	yield(get_tree().create_timer(0.5), "timeout")	
	emit_signal("action_completed") 

func spell(attacker, defender, outcome: int = 0, pose: String = "spell", animation = null, buff_string: String = ""):
	game.set_game_state(game.GameState.WAITING)
	attacker.change_pose(pose)
	
	yield(get_tree().create_timer(0.5), "timeout")

	var animation_instance = animation.instance()
	defender.get_node("AnimationLayer").add_child(animation_instance)
	
	animation_flip_for_enemy(attacker, animation_instance)

	animation_instance.play_animation(defender)
	yield(get_tree().create_timer(0.5), "timeout")

	if(attacker == defender):
		attacker.change_pose("idle")
		attacker.buff_pose(outcome, buff_string)
	else:
		defender.damage_pose(outcome)
		attacker.change_pose("idle")

	yield(get_tree().create_timer(0.5), "timeout")	
	emit_signal("action_completed") 

func animation_flip_for_enemy(target, animation_instance):
	if target.battler_type.to_upper() == "ENEMY":
		animation_instance.scale.x = -1
	else:
		animation_instance.scale.x = 1

#================================================================
# Debug
#================================================================
func show_details():
	print("Domino: ", domino_name,
	" User: ", user,
	" Current User: ", current_user,
	" Mouse In Container: ", is_mouse_in_container,
	" Selected: ", selected,
	" Position:", self.rect_position, 
	" Mouse filter:", self.mouse_filter,
	" Parent:", self.get_parent().name,
	" Clickable: ", self.get_clickable())
	
