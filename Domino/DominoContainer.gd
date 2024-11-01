class_name DominoContainer
extends Container

# Variables for the two numbers on the domino
var number1: int = 0
var number2: int = 0
var user: String = "none"
var domino_name = ""
var description = ""
var is_mouse_in_container = false
var battle_text;
var shader_material_left: ShaderMaterial
var shader_material_right: ShaderMaterial
var shader_material_domino: ShaderMaterial
var selected: bool = false
signal domino_pressed
signal pre_effect_complete
var description_popup = preload("res://Domino/DominoPopup.tscn")

var dot_images = {
	-1: preload("res://Domino/-1_dots.png"),
	0: preload("res://Domino/0_dots.png"),
	1: preload("res://Domino/1_dots.png"),
	2: preload("res://Domino/2_dots.png"),
	3: preload("res://Domino/3_dots.png"),
	4: preload("res://Domino/4_dots.png"),
	5: preload("res://Domino/5_dots.png"),
	6: preload("res://Domino/6_dots.png")
}

#================================================================
# BB code functions
#================================================================

func bb_code_dot(num: int):
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(num) + "Tile.png[/img][/font]"

func bb_code_tile():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(get_numbers()[0]) + "Tile.png[/img][/font] [font=res://Fonts/VAlign.tres][img]res://Icons/" + str(get_numbers()[1]) + "Tile.png[/img][/font]"

func bb_code_max_tile():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(max(get_numbers()[0], get_numbers()[1])) + "Tile.png[/img][/font]"

func bb_code_min_tile():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/" + str(min(get_numbers()[0], get_numbers()[1])) + "Tile.png[/img][/font]"

func bb_code_attack():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Attack.png[/img][/font]"

func bb_code_double():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Double.png[/img][/font]"

func bb_code_shield():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Shield.png[/img][/font]"

func bb_code_discard():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Discard.png[/img][/font]"

func bb_code_draw():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Draw.png[/img][/font]"

func bb_code_pile():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Pile.png[/img][/font]"
	
func bb_code_vulnerable():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Vulnerable.png[/img][/font]"

func bb_code_random():
	return "[font=res://Fonts/VAlign.tres][img]res://Icons/Random.png[/img][/font]"

# Add this function in your DominoContainer script
func shadow_copy() -> DominoContainer:
	var duplicate_instance = self.duplicate()
	
	# Copy each custom property
	duplicate_instance.number1 = self.number1
	duplicate_instance.number2 = self.number2
	duplicate_instance.user = self.user
	duplicate_instance.domino_name = self.domino_name
	duplicate_instance.is_mouse_in_container = self.is_mouse_in_container
	duplicate_instance.battle_text = self.battle_text
	duplicate_instance.shader_material_left = self.shader_material_left
	duplicate_instance.shader_material_right = self.shader_material_right
	duplicate_instance.shader_material_domino = self.shader_material_domino
	
	return duplicate_instance

func check_shadow_match(domino: DominoContainer) -> bool:
	return self.number1 == domino.number1 && self.number2 == domino.number2 && domino.user == self.user && domino.domino_name == self.domino_name

# Function to set the numbers of the domino
# -1 represents a wild domino (equals the last played domino number)

func set_numbers(n1: int, n2: int, owner: String = ""):
	self.number1 = n1
	self.number2 = n2
	if owner != "":
		self.user = owner.to_upper()
	print("Setting numbers: " + str(n1) + ", " + str(n2))
	update_domino()

func set_user(owner: String):
	self.user = owner.to_upper()
	update_domino()

func get_user() -> String:
	return user

func get_numbers() -> Array:
	return [number1, number2]

# Update the buttons to show the domino numbers
func update_domino():

	$DominoLabel/Label.text = self.domino_name

	if(number1 >= -1):
		#$HBoxContainer/LeftTile.text = str(number1) # Update Button1 to show number1
		$HBoxContainer/LeftTile.set_normal_texture(dot_images[number1])
		$HBoxContainer/LeftTile.set_pressed_texture(dot_images[number1])
		$HBoxContainer/LeftTile.set_hover_texture(dot_images[number1])
	#elif(number1 == -1):
		#$HBoxContainer/LeftTile.text = "W"
	
	if(number2 >= -1):
		$HBoxContainer/RightTile.set_normal_texture(dot_images[number2])
		$HBoxContainer/RightTile.set_hover_texture(dot_images[number2])
		$HBoxContainer/RightTile.set_pressed_texture(dot_images[number2])
		#$HBoxContainer/RightTile.text = str(number2) # Update Button1 to show number1
	#elif(number2 == -1):
		#$HBoxContainer/RightTile.text = "W"

	if(get_user().to_upper() == "BOARD" or get_user().to_upper() == "ENEMY"):
		set_clickable(false)
	else:
		set_clickable(true)
	#match get_user():
		#"player":
			#$HBoxContainer/LeftTile.modulate = Color(0, 1, 0, 1) # Green color for player
			#$HBoxContainer/RightTile.modulate = Color(0, 1, 0, 1) # Green color for player
		#"enemy":
			#$HBoxContainer/LeftTile.modulate = Color(1, 0.5, 0.5, 1) # Red color for enemy
			#$HBoxContainer/RightTile.modulate = Color(1, 0.5, 0.5, 1) # Red color for enemy

func set_clickable(clickable: bool):
	$HBoxContainer/LeftTile.disabled = not clickable # Disable Button1 if not clickable
	$HBoxContainer/RightTile.disabled = not clickable # Disable Button2 if not clickable
	if(not clickable):
		$HBoxContainer/LeftTile.focus_mode = Control.FOCUS_NONE
		$HBoxContainer/RightTile.focus_mode = Control.FOCUS_NONE
	else:
		$HBoxContainer/LeftTile.focus_mode = Control.FOCUS_CLICK
		$HBoxContainer/RightTile.focus_mode = Control.FOCUS_CLICK	

func get_non_matching_values(arr: Array, value: int) -> Array:
	var non_matching_values = []
	for element in arr:
		if element != value:
			non_matching_values.append(element)
	return non_matching_values

func can_play(last_played_number: int, user, target, pressed_number: int = get_numbers()[0]) -> String:
	var result = "unplayable"
	
	if Game.get_node("Game").game_state != Game.get_node("Game").GameState.DEFAULT:
		return result
	elif(requirements(user, target) == false):
		result = "prohibited"
	elif(pressed_number == last_played_number || pressed_number == -1 || last_played_number == -1):
		if(get_numbers()[0] == pressed_number):
			result = "playable"
		else:
			result = "swap"
	elif(get_numbers()[0] == -1 || get_numbers()[0] == last_played_number):
		result = "playable"
	elif(get_numbers()[1] == -1 || get_numbers()[1] == last_played_number):
		result = "swap"
	return result

func swap_values():
	var temp = number1
	number1 = number2
	number2 = temp
	print("Swapping numbers...")
	update_domino()

# Called when the node enters the scene tree for the first time
func _ready():
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
	
	$HBoxContainer/LeftTile.material = shader_material_left
	$HBoxContainer/RightTile.material = shader_material_right
	$Node2D/TextureRect.material = shader_material_domino
	
	$HBoxContainer/LeftTile.rect_min_size = Vector2(48, 48)
	$HBoxContainer/RightTile.rect_min_size = Vector2(48,48)
	$HBoxContainer/LeftTile.connect("pressed", self, "_on_left_button_pressed") # Connect HBoxContainer/LeftTile button
	$HBoxContainer/RightTile.connect("pressed", self, "_on_right_button_pressed") # Connect HBoxContainer/RightTile button

	$HBoxContainer/RightTile.connect("mouse_entered", self, "_on_button_hovered", [$HBoxContainer/RightTile])
	$HBoxContainer/RightTile.connect("mouse_exited", self, "_on_button_hover_exited", [$HBoxContainer/RightTile])

	$HBoxContainer/LeftTile.connect("mouse_entered", self, "_on_button_hovered", [$HBoxContainer/LeftTile])
	$HBoxContainer/LeftTile.connect("mouse_exited", self, "_on_button_hover_exited", [$HBoxContainer/LeftTile])

	$Node2D/TextureRect.connect("mouse_entered", self, "_on_domino_mouse_entered")
	$Node2D/TextureRect.connect("mouse_exited", self, "_on_domino_mouse_exited")

	update_domino()
	

# Highlight based on playability
func update_highlight(can_play: bool):
	if(self.user.to_upper() == "PLAYER"):
		$Node2D/TextureRect.material.set_shader_param("outline_enabled", can_play)

func random_value():
	return randi() % 6 + 1

func unique_random_value(arr: Array):
	var array = [1, 2, 3, 4, 5, 6]
	var result = []
	for item in array:
		if not arr.has(item):
			result.append(item)
	result.shuffle()
	return result[0]

# Handle left button press and emit signal with number1
func _on_left_button_pressed():
	emit_signal("domino_pressed", self, number1) # Emit signal with number1 and self (domino container)

# Handle right button press and emit signal with number2
func _on_right_button_pressed():
	emit_signal("domino_pressed", self, number2) # Emit signal with number2 and self (domino container)

# Handle mouse enter - turn outline on
func _on_button_hovered(button: TextureButton):
	var material = button.material as ShaderMaterial
	var material2 = $Node2D/TextureRect.material as ShaderMaterial
	if material and self.user.to_upper() == "PLAYER" and Game.get_node("Game").game_state_default():
		material.set_shader_param("outline_enabled", true)
	elif(material2 and self.user.to_upper() == "PLAYER" and Game.get_node("Game").is_selection()):
		material2.set_shader_param("outline_enabled", true)
	if(Game.get_node("Game").touch_mode == false):
		show_domino_description(self)

# Handle mouse exit - turn outline off
func _on_button_hover_exited(button: TextureButton):
	var material = button.material as ShaderMaterial
	var material2 = $Node2D/TextureRect.material as ShaderMaterial
	if material and Game.get_node("Game").game_state_default():
		material.set_shader_param("outline_enabled", false)
	elif(material2 and Game.get_node("Game").is_selection() && !selected):
		material2.set_shader_param("outline_enabled", false)
	if(Game.get_node("Game").touch_mode == false):
		if(has_node("DominoPopup")):
			get_node("DominoPopup").queue_free()

func clear_highlight():
	$HBoxContainer/LeftTile.material.set_shader_param("outline_enabled", false)
	$HBoxContainer/RightTile.material.set_shader_param("outline_enabled", false)
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
	return true
	#print("Origin: ", origin, " | Domino: ", domino_name)

func effect(origin, target):
	origin.dominos_played.append(self)
	origin.dominos_played_this_turn.append(self)

func attack_message(origin, target, damage):
	Game.get_node("Game").update_battle_text(origin.name() + " used " + domino_name + " on " + target.name() + " for " + str(damage) + " damage!")

func shield_message(origin, target, shield):
	Game.get_node("Game").update_battle_text(origin.name() + " used " + domino_name + " and " + target.name() + " gained " + str(shield) + " shield(s)!")

func apply_effect(effect, target):
	target.apply_effect(effect)

#================================
# Description Popup
#================================
# Function to handle showing the popup
func show_domino_description(domino):
	# Instance the popup and add it to the scene tree
	var popup = description_popup.instance()
	add_child(popup)
	
	# Set the popup description
	popup.set_description("[center]" +  domino.description + "[/center]")	
	
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

#================================================================
# Domino repositioning
#================================================================


func final_domino_position(position: int, collection):
	var target_positionX: int
	var target_positionY: int

	if(collection is GridContainer):
		target_positionX = position % collection.columns * (self.get_combined_minimum_size().x + collection.get_constant("hseparation"))
		target_positionY = floor(position / collection.columns) * (self.get_combined_minimum_size().y + collection.get_constant("vseparation"))	
	else:
		target_positionX = position * (self.get_combined_minimum_size().x + collection.get_constant("hseparation"))
		target_positionY = 0

	return Vector2(target_positionX, target_positionY)
