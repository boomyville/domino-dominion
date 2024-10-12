extends HBoxContainer

# Variables for the two numbers on the domino
var number1: int = 0
var number2: int = 0
var user: String = "none"
signal domino_pressed(domino_container)

# Function to set the numbers of the domino
func set_numbers(n1: int, n2: int, owner: String):
	self.number1 = n1
	self.number2 = n2
	self.user = owner
	update_domino()

func get_user():
	return user

func get_numbers():
	return [number1, number2]

# Update the buttons to show the domino numbers
func update_domino():
	$LeftTile.text = str(number1) # Update Button1 to show number1
	$RightTile.text = str(number2) # Update Button2 to show number2
	if(get_user() == "board" or get_user() == "enemy"):
		set_clickable(false)
	else:
		set_clickable(true)

func set_clickable(clickable: bool):
	$LeftTile.disabled = not clickable # Disable Button1 if not clickable
	$RightTile.disabled = not clickable # Disable Button2 if not clickable
	if(not clickable):
		$LeftTile.focus_mode = Control.FOCUS_NONE
		$RightTile.focus_mode = Control.FOCUS_NONE
	else:
		$LeftTile.focus_mode = Control.FOCUS_CLICK
		$RightTile.focus_mode = Control.FOCUS_CLICK	

# Called when the node enters the scene tree for the first time
func _ready():
	$LeftTile.rect_min_size = Vector2(32, 32)
	$RightTile.rect_min_size = Vector2(32,32)
	$LeftTile.connect("pressed", self, "_on_left_button_pressed") # Connect LeftTile button
	$RightTile.connect("pressed", self, "_on_right_button_pressed") # Connect RightTile button
	update_domino() # Ensure numbers are shown when the domino is created



# Handle left button press and emit signal with number1
func _on_left_button_pressed():
	emit_signal("domino_pressed", self) # Emit signal with number1 and self (domino container)
	print(str(number1) + " was pressed")

# Handle right button press and emit signal with number2
func _on_right_button_pressed():
	emit_signal("domino_pressed", self) # Emit signal with number2 and self (domino container)
	print(str(number2) + " was pressed")
