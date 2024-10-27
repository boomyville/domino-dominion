class_name DominoContainer
extends Container

# Variables for the two numbers on the domino
var number1: int = 0
var number2: int = 0
var user: String = "none"
var domino_name = ""
var is_mouse_in_container = false
var battle_text;
var shader_material_left: ShaderMaterial
var shader_material_right: ShaderMaterial
var shader_material_domino: ShaderMaterial
signal domino_pressed(domino_container)

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


# Function to set the numbers of the domino
# -1 represents a wild domino (equals the last played domino number)

func set_numbers(n1: int, n2: int, owner: String = ""):
	self.number1 = n1
	self.number2 = n2
	if owner != "":
		self.user = owner
	print("Setting numbers: " + str(n1) + ", " + str(n2))
	update_domino()

func set_user(owner: String):
	self.user = owner
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

	if(get_user() == "board" or get_user() == "enemy"):
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
	
	if(requirements(user, target) == false):
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
	
	battle_text = get_node("/root/Main/GUIContainer/BattleText")

# Highlight based on playability
func update_highlight(can_play: bool):
	if(self.user == "player"):
		$Node2D/TextureRect.material.set_shader_param("outline_enabled", can_play)

func random_value():
	return randi() % 6 + 1
	
# Handle left button press and emit signal with number1
func _on_left_button_pressed():
	emit_signal("domino_pressed", self, number1) # Emit signal with number1 and self (domino container)

# Handle right button press and emit signal with number2
func _on_right_button_pressed():
	emit_signal("domino_pressed", self, number2) # Emit signal with number2 and self (domino container)

# Handle mouse enter - turn outline on
func _on_button_hovered(button: TextureButton):
	var material = button.material as ShaderMaterial
	if material and self.user == "player":
		material.set_shader_param("outline_enabled", true)

# Handle mouse exit - turn outline off
func _on_button_hover_exited(button: TextureButton):
	var material = button.material as ShaderMaterial
	if material:
		material.set_shader_param("outline_enabled", false)

# Handle mouse enter of domino - turn outline on
func _on_domino_mouse_entered():
	var material = $Node2D/TextureRect.material as ShaderMaterial
	if material and self.user == "player":
		pass
		#material.set_shader_param("outline_enabled", true)

# Handle mouse exit of domino - turn outline off
func _on_domino_mouse_exited():
	var material = $Node2D/TextureRect.material as ShaderMaterial
	if material:
		pass
		#material.set_shader_param("outline_enabled", false)

func clear_highlight():
	$HBoxContainer/LeftTile.material.set_shader_param("outline_enabled", false)
	$HBoxContainer/RightTile.material.set_shader_param("outline_enabled", false)
	$Node2D/TextureRect.material.set_shader_param("outline_enabled", false)

func requirements(origin, target):
	return true

func effect(origin, target):
	origin.dominos_played.append(self)
	origin.dominos_played_this_turn.append(self)

func attack_message(origin, target, damage):
	battle_text.text = origin.name() + " used " + domino_name + " on " + target.name() + " for " + str(damage) + " damage!"

func shield_message(origin, target, shield):
	battle_text.text = origin.name() + " used " + domino_name + " and " + target.name() + " gained " + str(shield) + " shield(s)!"

func apply_effect(effect, target):
	target.apply_effect(effect)
