class_name DominoContainer
extends HBoxContainer

# Variables for the two numbers on the domino
var number1: int = 0
var number2: int = 0
var user: String = "none"
var domino_name = ""
var is_mouse_in_container = false
var battle_text;
signal domino_pressed(domino_container)

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
	if(number1 >= 0):
		$HBoxContainer/LeftTile.text = str(number1) # Update Button1 to show number1
	elif(number1 == -1):
		$HBoxContainer/LeftTile.text = "W"
	
	if(number2 >= 0):
		$HBoxContainer/RightTile.text = str(number2) # Update Button1 to show number1
	elif(number2 == -1):
		$HBoxContainer/RightTile.text = "W"

	if(get_user() == "board" or get_user() == "enemy"):
		set_clickable(false)
	else:
		set_clickable(true)
	match get_user():
		"player":
			$HBoxContainer/LeftTile.modulate = Color(0, 1, 0) # Green color for player
			$HBoxContainer/RightTile.modulate = Color(0, 1, 0) # Green color for player
		"enemy":
			$HBoxContainer/LeftTile.modulate = Color(1, 0.5, 0.5) # Red color for enemy
			$HBoxContainer/RightTile.modulate = Color(1, 0.5, 0.5) # Red color for enemy
		"board":
			$HBoxContainer/LeftTile.modulate = Color(1.0, 1.0, 1.0) # Black color for board
			$HBoxContainer/RightTile.modulate = Color(1.0, 1.0, 1.0) # Black color for board

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
	# playable
	# swap
	# unplayable
	# prohibited

	# Check if pressed number is playable
	if(requirements(user, target) == false):
		return "prohibited"

	elif(pressed_number == last_played_number || pressed_number  == -1 || last_played_number == -1):
		if(get_numbers()[0] == pressed_number):
			print("Play: " + str(get_numbers()[0]), " | ", pressed_number)
			return "playable"
		else:
			print("swapping pressed domino")
			return "swap"
	
	# Check if first number is playable
	elif(get_numbers()[0] == -1 || get_numbers()[0] == last_played_number):
		print("first number matches")
		return "playable"

	# Check if second number is playable
	elif(get_numbers()[1] == -1 || get_numbers()[1] == last_played_number):
		print("second number matches, swapping")
		return "swap"
	else:
		#print("Unplayable")
		return "unplayable"

func swap_values():
	var temp = number1
	number1 = number2
	number2 = temp
	print("Swapping numbers...")
	update_domino()

# Called when the node enters the scene tree for the first time
func _ready():
	$HBoxContainer/LeftTile.rect_min_size = Vector2(32, 32)
	$HBoxContainer/RightTile.rect_min_size = Vector2(32,32)
	$HBoxContainer/LeftTile.connect("pressed", self, "_on_left_button_pressed") # Connect HBoxContainer/LeftTile button
	$HBoxContainer/RightTile.connect("pressed", self, "_on_right_button_pressed") # Connect HBoxContainer/RightTile button

	for child in get_children():
		if child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_PASS
		
	connect("mouse_entered", self, "_on_mouse_enter") # Connect HBoxContainer/LeftTile button
	connect("mouse_exited", self, "_on_mouse_exit") # Connect HBoxContainer/LeftTile button

	$Popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Popup.hide()  # Start hidden

	$Popup/NameField.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	$Popup/NameField.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	$Popup/NameField.rect_min_size = Vector2(100, 24) # Ensure minimum size is not zero
	$Popup/NameField.text = domino_name
	$Popup/NameField.update() # Force update to ensure size is recalculated
	update_domino() # Ensure numbers are shown when the domino is created

	battle_text = get_node("/root/Main/GUIContainer/BattleText")

func random_value():
	return randi() % 6 + 1
	
# Handle left button press and emit signal with number1
func _on_left_button_pressed():
	emit_signal("domino_pressed", self, number1) # Emit signal with number1 and self (domino container)

# Handle right button press and emit signal with number2
func _on_right_button_pressed():
	emit_signal("domino_pressed", self, number2) # Emit signal with number2 and self (domino container)

# Handle hover over button
func _on_mouse_enter():
    is_mouse_in_container = true
    $Popup/NameField.text = domino_name  # Change to your domino name
    $Popup.show()
    update_popup_position()

func _on_mouse_exit():
    is_mouse_in_container = false
    # We need to check if the mouse is really outside the container after a short delay
    yield(get_tree().create_timer(0.1), "timeout")  # Short delay to avoid flicker
    if !is_mouse_in_container and !is_mouse_over_any_child():
        $Popup.hide()

func _process(delta):
    if is_mouse_in_container and $Popup.visible:
        update_popup_position()

# Helper to update the popup's position based on the mouse
func update_popup_position():
    $Popup.rect_position = get_global_mouse_position() + Vector2(10, 10)

# Function to check if the mouse is over any child element
func is_mouse_over_any_child() -> bool:
    for child in get_children():
        if child.get_rect().has_point(child.get_local_mouse_position()):
            return true
    return false

func requirements(origin, target):
	print(origin.name() + " | " + target.name())
	return true

func effect(origin, target):
	origin.dominos_played.append(self)
	origin.dominos_played_this_turn.append(self)

func attack_message(origin, target, damage):
	battle_text.text = origin.name() + " used " + domino_name + " on " + target.name() + " for " + str(damage) + " damage!"

func shield_message(origin, shield):
	battle_text.text = origin.name() + " used " + domino_name + " and gained " + str(shield) + " shield(s)!"